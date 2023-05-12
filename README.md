# CCI_electricity

Importing and exploring CCI electricity usage data.


## navigating this repo

* `functions.R` contains the functions for reading and processing the meter data.

* `meter_metadata.csv` is a metadata table which is used to make sure we're reading in the right files, and for matching pairs of meters to their location and the percentage of their usage that should be apportioned to CCI, etc.

* `data_meters` is a folder containing the raw meter readings (`.xlsx` files). These are not tracked by git so are not in the online version of this repo.

* `plots` is a folder containing any plots that we save to file (to prevent them cluttering up the main folder).


### R scripts and outputs

* **script 1: process meters**: this is a first go at using the functions to read in all the meter readings, process them, save the processed data to a file (not tracked by git so not in the online version of this repo). 
    * `s01_process_meters.Rmd` is an R markdown file containing the R code and explanations. Knitting this file produces the associated outputs:
    * `s01_process_meters.md` shows the outputs of the R script. Click on this file to view the outputs online
    * `s01_process_meters/figure-gfm` contains the plots used in the `.md` file above (just ignore this folder)
    * This script also saves a file called `processed_meter_data.csv` (not on the online GitHub version).

* **script 2: summarise and plot**: this contains some code to make summaries and plots. 
    * `s02_plots.Rmd` = the R code and explanations 
    * `s02_plots.md` and `s02_plots/figure-gfm` = outputs of the R markdown file
    * This script also saves some plots as `.png` files in the `plots` folder.


### administrative files:

* `.gitignore`: this tells git which files *not* to track. We use this to make sure that the raw data, processed data, and plots are not version-controlled and are not uploaded to GitHub.
* `LICENSE`: this file specifies that other people who find this repo on GitHub may re-use the code.
* `README.md`: there is a 'readme' file in each folder explaining what the folder is for. These help people to navigate the folders on GitHub.

***

## next steps

* add more fields to metadata to apportion usage to different CCI orgs
* use the usage apportioning fields to split out data into usage by organisation / by CCI / total
* develop more functions for summarising and plotting in useful ways
* develop a shiny app for displaying the data (need to think about how the data processing would be controlled)

***

## shiny app

ideal situation:

* have an optional, specific *'re-process meter readings'* button that causes the data to be read in from a folder of raw meter reading files,the data processing steps to be performed, and a new `processed_meter_data.csv` file to be produced and saved.
* then all the plotting and summarising actions can be done on that `processed_meter_data.csv` dataset. This way the whole processing doesn't have to be re-done every time you want to make some new plots.

caveats:

* I don't think a shiny app can access a folder of files on your computer (unless it's run on your computer rather than on a separate server e.g. shinyapps.io). So if the app is only ever run on Sophie's computer, it can read in the 39 raw data files from a local folder. However if it's hosted elsewhere, it might be easier to run the data processing locally in an R Markdown file, and upload the latest `processed_meter_data.csv` file to the shiny app each time you use it.
