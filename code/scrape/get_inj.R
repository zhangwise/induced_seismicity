# =================================================================================================
# AGGREGATING INJECTION DATA

# Author: Michael Jetsupphasuk
# Last Updated: 31 October, 2017

# Pull Date: 24 October, 2017

# This file takes the .csv files generated by scraping the Microsft Access databases downloaded
# from ftp://ftp.consrv.ca.gov/pub/oil/new_database_format/ and aggregates them into a single
# data frame that is saved as an .rds file

# =================================================================================================

library(dplyr)

# For each year, use an inner join to combine the injection and general data from Access database
# Join by column "PWT__ID"
# This code does not filter for water disposal wells, etc.

years = 1977:2017 # all years available from database
list_dfs = list() # dummy list to store data frames for each year

for (i in 1:length(years)){
  str_general = paste0("ftp_data/injection_data/csvs/", years[i], 'general.csv')
  str_inject = paste0("ftp_data/injection_data/csvs/", years[i], 'injections.csv')
  gen = read.csv(str_general, stringsAsFactors = F)
  inj = read.csv(str_inject, stringsAsFactors = F)
  combine = inner_join(gen, inj, by = "PWT__ID") %>%
              mutate(Year = years[i])
  list_dfs[[i]] = combine
}

# Some data frames have different classes for same columns
# Coerce all to "character" to resolve conflicts when binding
list_dfs = lapply(list_dfs, function(df) mutate_all(df, funs('as.character')))

# Combine all data frames into one
raw_injection = bind_rows(list_dfs)

# Save data frame as .rds
saveRDS(raw_injection, 'rawdata/wells/california/raw_injection_wells.rds')

