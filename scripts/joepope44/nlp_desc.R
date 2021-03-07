library(tidyverse)
library(tidytext)
library(topicmodels)
library(tm)
# library(textmineR)
library(quanteda)
library(seededlda)

# Data Handling -----------------------------------------------------------

# Load Data
geo_data_raw <- read_csv('data/brownfields_data_with_county_geoid.zip')

# Clean up and coalesce desc/history to highlights. Highlights often has the full text to 
geo_text <- geo_data_raw %>% 
  mutate(row_num = 1:nrow(.)) %>% 
  select(row_num, "coop_num" = `Cooperative Agreement Number`, 
         "acres_id" = `ACRES Property ID`, "desc" = `Description/History`, "highlights" = `Highlights`) %>% 
  mutate(text = ifelse(
    is.na(highlights),
    coalesce(desc, highlights),
    highlights)
    ) %>% 
  distinct(text, coop_num) %>% 
  drop_na() %>% 
  filter(coop_num != "n/a")

head(geo_text, 10)


# Create DTM --------------------------------------------------------------

custom_stopwords <- c("site", "property", "use", "former", "building", "used")

acres_corpus = Corpus(VectorSource(geo_text$text))

acres_corpus = tm_map(acres_corpus, content_transformer(tolower))
acres_corpus = tm_map(acres_corpus, removeNumbers)
acres_corpus = tm_map(acres_corpus, removePunctuation)
acres_corpus = tm_map(acres_corpus, removeWords, c("the", "and", custom_stopwords, stopwords("english")))
acres_corpus =  tm_map(acres_corpus, stripWhitespace)

acres_dtm <- DocumentTermMatrix(acres_corpus)

review_dtm = removeSparseTerms(acres_dtm, 0.999)
review_dtm


raw.sum <- apply(review_dtm, 1, FUN=sum)
dtm <- review_dtm[raw.sum != 0, ]


# LDA ---------------------------------------------------------------------

# tidy_docs <- geo_text %>% 
#   select(coop_num, text) %>% 
#   unnest_tokens(output = word, 
#                 input = text,
#                 stopwords = c(stopwords::stopwords("en"), 
#                               stopwords::stopwords(source = "smart"),
#                               custom_stopwords),
#                 token = "words") %>% 
#   count(coop_num, word) %>% 
#   filter(n>5)
# 
# d <- tidy_docs %>% 
#   cast_sparse(coop_num, word, n)
# 
# # create a topic model
# m <- FitLdaModel(dtm = d, 
#                  calc_r2 = TRUE,
#                  k = 4,
#                  iterations = 10,
#                  burnin = 5)


rm(ac_lda)
ac_lda <- LDA(dtm, k = 6, control = list(seed = 1234))
ac_lda

topics <- tidy(ac_lda, matrix = "beta")
topics

top_terms <- topics %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)
top_terms


top_terms %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered()


# Seeded LDA --------------------------------------------------------------

# Create the topics with a few keywords to guide the LDA model 
dict <- dictionary(file = "scripts/joepope44/topics.yml")
print(dict)

# Create new corpus for seededlda, using quanteda format 
q_corpus = corpus(geo_text$text, docnames = geo_text$coop_num)

# Create tokens and pre-process them. Can try bigrams for better fits. 
toks <- tokens(q_corpus, 
               remove_numbers = TRUE,
               remove_punct = TRUE,
               remove_symbols = TRUE) %>%
  # tokens_select("^[A-Za-z]+$", valuetype = "regex", min_nchar = 2) %>% 
  tokens_compound(dict) 

# Create DTM to put into model. These parameters could be tweaked further. 
dfmt <- dfm(toks) %>% 
  dfm_remove(c(stopwords('en'), custom_stopwords)) %>% 
  dfm_trim(min_termfreq = 0.90, termfreq_type = "quantile", 
           max_docfreq = 0.2, docfreq_type = "prop")

# Set seed and run model. Residual will create a garbage model to fit other documents into. 
set.seed(1234)
slda <- textmodel_seededlda(dfmt, dict, residual = TRUE)
print(terms(slda, 20))

topic <- table(topics(slda))
print(topic)

