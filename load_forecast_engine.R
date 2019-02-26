# TODO: Add comment
# 
# Author: colin
###############################################################################
  # Clear workspace
  rm(list = ls())
  gc()

  init.dir <<- paste0(dirname(parent.frame(2)$ofile), "/")
  # init.dir <<-paste0(getwd(), "/")
  print(paste0("Start at ",Sys.time()," CG office"))
  
  # Passing Argument to Crobjob
  args <- commandArgs(TRUE)
  location <- as.character(args[1])
  server.name <- as.character(args[2])
  
  
  load.forecast.engine <- function(location, server.name){
  # server.name = "rds_etrm_grep"
  # location = "KitCarson"
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
  
  # curr.date <<- Sys.Date()
  # slack.simple.message("start!","@colin")
  time.zone <<- switch(location, Aztec = "US/Mountain", KitCarson = "US/Mountain")
  curr.date <<- format(Sys.time(), format = "%Y-%m-%d", tz = time.zone);
  # curr.date <<- "2017-08-11"
  curr.he <<- as.numeric(format(Sys.time(), format = "%H", tz = time.zone)) + 1
  # curr.he <<- 1
  # step 3: update actual data in DB (table: forecast_actual_data)
  #     weather actual data from morningstar (lim)
  #     load actual from DB (table: dashboard_load_forecast 
  #                         forecast_model = 'PRT_Original')
  #     solar actual from DB (forecast_forecast_data & mark "final=FALSE")
  
  tryCatch({
    update.success = update.actual.data(location, server.name)
  },
  error = function(e){
    slack.simple.message(paste0("update.actual.data error :",e$message),"@colin")
    slack.simple.message(paste0("update.actual.data error :",e$message),"@bwu")
  })
  
  # step 4: pull historical load data for model training 
  backtest.days = 600
  hist.actual.data = pull.actual.data(location, server.name, backtest.days)
  last.hour.load <- pull.last.he.load(location, server.name)
  
  # step 5: pull weather forecast data 
  # fc.weather.df <- get.fc.weather(location, curr.date, curr.date + days(7))
  tryCatch({
    fc.weather.df <- get.fc.weather(location,curr.date, as.Date(curr.date) + days(7), time.zone)
  },
  error = function(e){
    slack.simple.message(paste0("get.fc.weather error :",e$message),"@colin")
    slack.simple.message(paste0("get.fc.weather error :",e$message),"@bwu")
  })

  # step 6: train/run load/solar model
  training.days = 500
  load.forecast.df = load.forecast.model(location, hist.actual.data, 
                                         fc.weather.df, training.days, last.hour.load)

  # step 7: (optional for location) solar forecast model
  if (location == "KitCarson") {
    facilities = c("CHEVRON", "BLUESKY", "AMALIA")
    local.latitude.numeric <<- 36.389053
    local.longitude.numeric <<- 105.58076
  }
  if (location == "Aztec") {
    facilities = c("LOCUS")
    local.latitude.numeric <<- 36.819059
    local.longitude.numeric <<- 108.021649
  }
  solar.forecast.df = run.solar.forecast.model(hist.actual.data, facilities, fc.weather.df)

  
  # step 8: save forecast into DB (table: forecast_forecast_data)
  save.forecast.data(load.forecast.df %>% mutate(data_value_orig = total_load),
                     location, "load", "total_load", 1, server.name)

  for (facility.name in facilities) {
      solar.forecast.facility = solar.forecast.df
      solar.forecast.facility$solar.site = solar.forecast.facility[[facility.name]]
      save.forecast.data(solar.forecast.facility %<>% mutate(data_value_orig = solar.site),
                         location, "solar", facility.name, 1, server.name)
  }
  save.forecast.data(solar.forecast.df %>% mutate(data_value_orig = total_solar),
                       location, "solar", "total_solar", 1, server.name)

  forecast.df =  (solar.forecast.df %>% mutate(flow_date=as.Date(flow_date))) %>%
    left_join(load.forecast.df %>% mutate(flow_date=as.Date(flow_date)), by = c("flow_date", "he")) %>%
    mutate(total_solar_fc = total_solar, total_load_fc = total_load,
           net_load_fc = total_load_fc - total_solar_fc) %>%
    select(-date_time, -total_load, -total_solar)
  
  # if (location == "KitCarson") {
  #   forecast.df =  (solar.forecast.df %>% mutate(flow_date=as.Date(flow_date))) %>%
  #     left_join(load.forecast.df %>% mutate(flow_date=as.Date(flow_date)), by = c("flow_date", "he")) %>%
  #     mutate(total_solar_fc = total_solar, total_load_fc = total_load,
  #            net_load_fc = total_load_fc) %>%
  #     select(-date_time, -total_load, -total_solar)
  # }
  # 
  # if(location == "Aztec") {
  #   forecast.df =  (solar.forecast.df %>% mutate(flow_date=as.Date(flow_date))) %>%
  #     left_join(load.forecast.df %>% mutate(flow_date=as.Date(flow_date)), by = c("flow_date", "he")) %>%
  #     mutate(total_solar_fc = total_solar, total_load_fc = total_load,
  #            net_load_fc = total_load_fc - total_solar_fc) %>%
  #     select(-date_time, -total_load, -total_solar)
  # }
  # 
  
  
  
  
  
  # write.csv(forecast.df, paste0("c://temp//forecast_",location,"_",curr.date, "_he_",curr.he,".csv"),row.names = FALSE)
  
  # step 9: 
  # update dashboard_load_forecast and forecast_model = 'PRT_Orig'
  # update dashboard_load_forecast and forecast_model = 'dnp3'
  
  tryCatch({
    update.etrm(location, server.name, forecast.df)
  },
  error = function(e){
    slack.simple.message(paste0("update.etrm error :",e$message),"@colin")
    slack.simple.message(paste0("update.etrm error :",e$message),"@bwu")
  })
  output.data.to.csv(location,server.name)
}

  print(paste0(location," starts at ",Sys.time()," CG office"))
  load.forecast.engine(location,server.name)
  # print(paste0("Aztec starts at ",Sys.time()," CG office"))
  # load.forecast.engine("Aztec","rds_etrm_ge")
  
    # server.name = "rds_etrm_grep"
    # location = "KitCarson"
    
    # server.name = "rds_etrm_ge"
    # location = "Aztec"
    
  print(paste0("End at ",Sys.time()," CG office"))
  
  
