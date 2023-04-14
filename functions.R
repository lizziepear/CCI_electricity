#' FUNCTIONS for CCI electricity monitoring

#'
#' Read meter data from xlsx
#' 
#' Reads and formats the data from an individual electricity meter XLSX file.
#' 
#' @param filename the filepath to the xlsx file (including file extension)
#' 
#' @return the meter data as data frame with the following fields: meter_ref,
#'   date, t01-t48 (half hourly usage values), year, month
#' 
read_meter_xlsx <- function(filename) {
  ## read the correct rows from the correct sheet
  t <- readxl::read_xlsx(filename,
                         sheet = "DataDownload",
                         range = cell_cols("B:AY"),
                         col_types = c("text", "date", rep("numeric", 48)))
  
  ## CHECK: quick check that the first two cols have the right names
  if (! all.equal(colnames(t)[1:2], c("Data Set Reference", "Date"))) {
    stop("First two columns have the wrong name. Check before continuing.")
  }
  
  ## set colnames for the 48 usage value columns as t_01, t_02 etc
  colnames(t)[1] <- "meter_ref"
  colnames(t)[2] <- "date"
  colnames(t)[3:50] <- paste("t", sprintf("%02d", seq(1:48)), sep="_")
  
  ## TODO add some more quality control checks here
  
  ## add year and month fields
  t$year <- lubridate::year(t$date)
  t$month <- lubridate::month(t$date)
  
  ## return as data frame so that it's not grouped or anything weird
  t <- as.data.frame(t)
  # head(t)
  return(t)

}

#'
#' Turn raw meter data into daily sums
#' 
#' Calculates daily sum of power usage from meter reading data.
#' 
#' @param my_df the dataframe of meter readings as output from read_meter_xlsx()
#' 
#' @return the meter data as data frame with the following fields: meter_ref,
#'   date, year, month, usage (sum of all the usage values for that day)

calc_daily_sums <- function(my_df) {
  
  ## CHECK: quick check that the first two cols have the right names
  if (! all.equal(colnames(my_df)[1:3], c("meter_ref", "date", "t_01"))) {
    stop("First two columns have the wrong name. Check before continuing.")
  }
  
  ## TODO add more checks here (formatting etc)
  
  ## sum usage by day
  ## TODO make this more robust by choosing columns to sum by name not index
  my_df$usage <- rowSums(my_df[3:50], na.rm=TRUE)
  
  ## keep only meter_ref, date, year, month, and usage
  df_dailysum <- my_df[ , which(colnames(my_df) %in% c("meter_ref", "date", "year", "month", "usage"))]
  
  ## return daily sum table
  return(df_dailysum)
}

#'
#' Process the power vs lighting vs both usage
#' 
#' Takes the daily sum data and uses \code{tidyr::pivot_wider} to match the 
#'   power/lighting/both values for each pair of meters (i.e. each meter_group).
#' 
#' @param my_df the dataframe of daily sums as returned by calc_daily_sums()
#' 
#' @return the meter data by meter_group with new usage value 
#'   fields: pwr, ltg and both.
#'
combine_power_lighting <- function(my_df) {
  
  ## test on a subset of data
  # my_df <- subset(df, meter_group %in% c("02B0F5-DB-3D", "02B0FB-DB-ET-1"))
  # my_df %>% dplyr::group_by(meter_ref, meter_group, meter_type) %>% dplyr::summarise(n_days = n())
  # head(my_df)
  
  ## pivot wider to make pwr, ltg, and both fields
  t2 <- tidyr::pivot_wider(my_df,
                           id_cols = c("floor", "location", "perc_to_CCI", "meter_group", "date", "year", "month"),
                           names_from = "meter_type",
                           values_from = "usage") %>%
    as.data.frame()
  # head(t2)
  
  ## we should have half as many rows: each set of two meters has been combined into one
  if (! ((nrow(my_df) / nrow(t2)) == 2)) {
    stop("New nrow() should be half of old nrow() but is not. Something has gone wrong in the pivot_wider() function.")
  }
  # nrow(my_df) / nrow(t2)
  t3 <- t2  # save a copy
  
  ## now we need to fill in the fields that have NAs
  t3[which(is.na(t3$pwr)), "pwr"] <- t3[which(is.na(t3$pwr)), "both"] - t3[which(is.na(t3$pwr)), "ltg"]
  t3[which(is.na(t3$both)), "both"] <- t3[which(is.na(t3$both)), "pwr"] + t3[which(is.na(t3$both)), "ltg"]
  
  ## check when debugging
  # head(t2)
  # head(t3)
  # tail(t2)
  # tail(t3)
  
  return(t3)
  
}


