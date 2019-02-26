# TODO: Add comment
# 
# Author: bwu
###############################################################################
# Clear workspace
rm(list = ls())
gc()

init.dir <<- paste0(dirname(parent.frame(2)$ofile), "/")

# load.forecast.engine <- function(location, server.name){
  server.name = "quant05_etrm_ge"
  location = "KitCarson"       
  ###########################################################################
  # Allocate Memory and Define All Directories
  ###########################################################################
  # Allocate additional memory
  memory.size(8192)
  # Define hardcoded parameters - width of text output
  width <<- 79
  # Set directories
  api.dir <<- paste0(init.dir, "APIs/")
  code.dir <<- paste0(init.dir, "Code/")
  sub.dir <<- paste0(code.dir, "Sub-Modules/")
  input.dir <<- paste0(init.dir, "Inputs/")
  output.dir <<- paste0(init.dir, "Outputs/")
  
  ###########################################################################
  # Load Like Day Input Files, Source Function-Defining Scripts and APIs
  ###########################################################################
  # Source utilities
  source(paste0(code.dir, "01_utilities.R"))
  
  # Load inputs, packages and scripts
  call.script("02_load_packages_scripts_inputs")
  
  # step 3: update actual data in DB (table: forecast_actual_data)
  #     weather actual data from morningstar (lim)
  #     load actual from DB (table: dashboard_load_forecast 
  #                         forecast_model = 'PRT_Original')
  #     solar actual from DB (forecast_forecast_data & mark "final=FALSE")
  update.success = update.actual.data(location, server.name)
  
  # step 4: pull historical load data for model training 
  hist.actual.data = pull.actual.data(location, server.name, 600)
  
  
  # step 5: pull weather forecast data 
  fc.weather.df <- get.fc.weather(location,Sys.Date(),Sys.Date() + days(7))
  
  # step 6: train/run load/solar model 
  training.days = 100
  load.forecast.df = load.forecast.model(hist.actual.data, fc.weather.df, training.days)
  
  # step 7: save forecast into DB (table: forecast_forecast_data)
  
  
  
  
  # step 8: update dashboard_load_forecast and forecast_model = 'PRT_Original'

  
  
  
  
  
  