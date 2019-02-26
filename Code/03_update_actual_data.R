# TODO: Add comment
# 
# Author: bwu
###############################################################################

update.actual.data <- function(location, server.name){
  
  header.msg("Start to update actual data ....")
  #### Update weather data from LIM
  update.weather.data(location, server.name)
  
  #### Update Solar data from forecast_forecast_data table
  if(location == "KitCarson") update.solar.data(location, server.name)
  
  #### Update Actual load data from dashboard_load_forecast and forecast_model = 'PRT_Original'
  update.load.data(location, server.name)
  
  return(TRUE)
}
