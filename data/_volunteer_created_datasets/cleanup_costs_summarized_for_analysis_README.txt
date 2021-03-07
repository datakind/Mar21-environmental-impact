This dataset was created for analyzing Clean Up Costs only.  Target variable: sum_cleanup_funding

All details for its creation (aggregation, dedupping, filtering) can be found in the script that is pushed to the Git repository:
Mar21-environmental-impact/scripts/muiashley/cleanup_costs_gradient_boosting.sas


Filtering:
The following rows were removed -
1.  'Type of Brownfields Grant' contains "BCRLF"
2.  'Amount of Cleanup Funding' less than or equal to 0 
3.  'Cleanup Completion Date' is not populated
4.  'ACRES Cleaned Up' is not populated

De-dupping and aggregating was done by:
1.  Identifying rows where the 'ACRES Property ID' and 'Cleanup Completion Date' are the same.  It is assumed that this is for the same cleanup event.
2.  De-dup where 'ACRES Property ID', 'Cleanup Completion Date', and 'Amount of Cleanup Funding' are exactly the same.  It's assumed these are duplicates.
3.  Aggregate rows pertaining to the same Cleanup Event by:

     summing 'Amount of Cleanup Funding' as a new variable: sum_cleanup_funding
     averaging 'ACRES Cleaned Up' as new variable: avg_acres_cleaned
     averaging 'Acreage and Greenspace Created'n) as new variable: avg__acres_grn_created

After data prep, 1,642 Brownfields cleanup events were left to model on.
