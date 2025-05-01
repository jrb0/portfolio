library(tidyverse)
library(readxl)

# Read original files
energy <- read_excel('2023 Energy Consumption.xlsx')
fares <- read_excel('2023 Fare Revenues.xlsx')

# Join the two datasets
energy_fares <- full_join(
  energy,
  fares,
  by = c("NTD ID", "Agency Name", "Reporter Type", "Reporting Module", "Mode", "TOS")
)

# Pivot "Other Fuel Description" column into wide format
energy_fares <- energy_fares %>%
  pivot_wider(
    names_from = 'Other Fuel Description',
    values_from = 'Other Fuel'
  )

# Clean and transform data
energy_fares <- energy_fares %>%
  mutate(
    across(7:20, as.numeric),
    across(24:26, as.numeric),
    across(where(is.numeric), ~replace_na(., 0)),
    `Diesel Fuel` = `Diesel Fuel` + diesel
  ) %>%
  select(
    -'State/Parent NTD ID',
    -'Expense Type',
    -'NA',
    -'diesel'
  ) %>%
  rename('Renewable Diesel' = 'RenewableDiesel') %>%
  relocate('Renewable Diesel', .after = 19) %>%
  rename_with(~ make.names(.))  # Make column names safe for programming

# Convert to long format for fuel consumption analysis
energy_fares_long <- energy_fares %>%
  pivot_longer(cols = 7:20,
               names_to = 'Fuel Type',
               values_to = 'Fuel Consumption')

# Summary function: stats
summary_stats <- function(var){
  require(dplyr)
  require(knitr)
  require(magrittr)
  
  energy_fares %>%
    summarize(
      Min = min({{ var }}, na.rm = TRUE),
      Mean = mean({{ var }}, na.rm = TRUE),
      Median = median({{ var }}, na.rm = TRUE),
      Max = max({{ var }}, na.rm = TRUE)
    ) %>%
    kable(digits = 1L)
}

# Summary function: counts
summary_counts <- function(var) {
  require(dplyr)
  require(knitr)
  require(magrittr)
  
  energy_fares %>%
    count({{ var }}, sort = TRUE) %>%
    rename(Count = n) %>%
    kable()
}

# Example usage
summary_stats(Gasoline)

# Export to CSV
write.csv(energy_fares, 'energy_fares.csv')