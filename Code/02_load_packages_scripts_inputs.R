# TODO: Add comment
# 
# Author: bwu
###############################################################################

load.packages(c("dplyr","DBI", "RMySQL", "lubridate","DataCombine", 
                "digest","XML", "httr", "tidyr"))

source(paste0(api.dir, "lim_api.R"))
source(paste0(api.dir, "rmysql_api.R"))

call.script("03_update_actual_data")
call.sub.module("03.1_update_weather_data")
call.sub.module("03.2_update_solar_data")
call.sub.module("03.3_update_load_data")

call.script("04_pull_actual_data")
call.script("05_pull_weather_forecast_data")
call.script("06_run_forecast_model")
# call.sub.module("06.2_solar_forecast_model")
# 
# call.script("07_save_forecast_data")
# call.script("08_update_dashboard_data")
