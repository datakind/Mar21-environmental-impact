library(tidyverse)
library(tidytext)
library(topicmodels)
library(tm)


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
  distinct(text, coop_num)

head(geo_text, 10)


# Create DTM --------------------------------------------------------------

acres_corpus = Corpus(VectorSource(geo_text$text))

acres_corpus = tm_map(acres_corpus, content_transformer(tolower))
acres_corpus = tm_map(acres_corpus, removeNumbers)
acres_corpus = tm_map(acres_corpus, removePunctuation)
acres_corpus = tm_map(acres_corpus, removeWords, c("the", "and", stopwords("english")))
acres_corpus =  tm_map(acres_corpus, stripWhitespace)

acres_dtm <- DocumentTermMatrix(acres_corpus)

review_dtm = removeSparseTerms(acres_dtm, 0.99)
review_dtm


# LDA ---------------------------------------------------------------------



