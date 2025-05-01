library(tidyverse)y
library(readxl)

energy <- read_excel('2023 Energy Consumption.xlsx') #read original files
fares <- read_excel('2023 Fare Revenues.xlsx')

energy_fares <- full_join( #join files together
  energy,
  fares,
  by = c("NTD ID", "Agency Name", "Reporter Type", "Reporting Module", "Mode", "TOS")
)

energy_fares <- energy_fares %>% #remove "other fuel description" column in favor of dedicated variables 
  pivot_wider(
    names_from = 'Other Fuel Description',
    values_from = 'Other Fuel'
  )

energy_fares <- energy_fares %>%
  mutate(across(7:20, as.numeric)) #change values to numeric

energy_fares <- energy_fares %>%
  mutate(across(24:26, as.numeric))

energy_fares <- energy_fares %>%
  mutate(across(where(is.numeric), ~replace_na(., 0))) #replace NA values with 0 for numeric columns

energy_fares <- energy_fares %>% select(-'State/Parent NTD ID', #remove unecessary columns
                                        -'Expense Type',
                                        -'NA') 
energy_fares <- energy_fares %>%
  rename('Renewable Diesel' = 'RenewableDiesel') #add space

energy_fares <- energy_fares %>%
  mutate(`Diesel Fuel` = `Diesel Fuel` + diesel) #combine duplicative diesel columns

energy_fares <- energy_fares %>% select(-'diesel') #remove duplicative diesel columnn

energy_fares <- energy_fares[, c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 23, 20, 21, 22)] #move renewable diesel column to be next to the other fuels

energy_fares_long <- energy_fares %>%
  pivot_longer(cols = 7:20,
               names_to = 'Fuel Type',
               values_to = 'Fuel Consumption')

energy_fares <- energy_fares %>%
  rename_with(~ make.names(.)) #makes variables programming safe with periods to replace spaces

summary_stats <- function(var){
  require(dplyr)
  require(knitr)
  require(magrittr)
  
  table <- energy_fares %>%
    summarize(
      Min = min({{ var }}, na.rm=T),
      Mean = mean({{ var }}, na.rm=T),
      Median = median({{ var }}, na.rm=T),
      Max = max({{ var }}, na.rm=T),
    ) %>%
    kable(
      digits = 1L)
  
  return(table)
}

summary_counts <- function(var) {
  require(dplyr)
  require(knitr)
  require(magrittr)
  
  table <- energy_fares %>%
    count({{ var }}, sort = TRUE) %>%
    rename(Count = n) %>%
    kable()
  
  return(table)
}

summary_stats(Gasoline)

 write.csv(energy_fares, 'energy_fares.csv')

