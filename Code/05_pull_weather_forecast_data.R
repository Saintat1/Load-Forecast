#'LoadForecast Aztec Data Pulling
#'@author Colin
#'=====================================================================
get.observed.weather <- function(PPA.location, start.date, end.date, timezone){
  # timezone <- switch(PPA.location,Aztec = "US/Mountain",KitCarson = "US/Mountain")
  weather_station <- switch(PPA.location, Aztec = "WSI.MN.KFMN.", KitCarson = "WSI.MN.KSKX.")
  avg.cloud.cover <- paste0("Hourly AverageCloudCover of ",weather_station, "OBS.HOURLY")
  avg.dewpoint.temp <- paste0("Hourly AverageDewPointTemp of ",weather_station, "OBS.HOURLY")
  heat.index <- paste0("Hourly HeatIndex of ", weather_station, "OBS.HOURLY")
  weather.hum <- paste0("Hourly AvgRelativeHumidity of ",weather_station, "OBS.HOURLY")
  avg.wetbulb.temp <- paste0("Hourly AvgWetBulbTemp of ",weather_station, "OBS.HOURLY")
  avg.wind.speed <- paste0("Hourly AvgWindSpeed of ",weather_station, "OBS.HOURLY")
  norm.avg.Temp <- paste0("Hourly NormAvgTemp of ",weather_station, "OBS.HOURLY")
  precipitation <- paste0("Hourly Precipitation of ",weather_station, "OBS.HOURLY")
  wind.chill <- paste0("Hourly WindChill of ",weather_station, "OBS.HOURLY")
  wind.dir <- paste0("Hourly WindDir of ",weather_station, "OBS.HOURLY")
  
  weather.vector <- c(avg.cloud.cover, avg.dewpoint.temp, heat.index,
                      weather.hum, avg.wetbulb.temp, avg.wind.speed,
                      norm.avg.Temp, precipitation, wind.chill, wind.dir)
  
  historical.weather <- query.lim.show(show = weather.vector,
                                       datefrom = ymd(start.date), 
                                       dateto = ymd(end.date),
                                       cache.folder = NULL, 
                                       date.he = FALSE, time.unit = "Hours")
  
  historical.weather <- mutate(historical.weather, 
                               date.time = ymd_hms(date.time, tz = timezone))
  colnames(historical.weather) <- c("date_time", "avg.cloud.cover", "avg.dewpoint.temp", "heat.index",
                                    "weather.hum", "avg.wetbulb.temp", "avg.wind.speed",
                                    "norm.avg.Temp", "precipitation",
                                    "wind.chill", "wind.dir")
  historical.weather <- FillDown(historical.weather, Var = c("date_time"))
  return(historical.weather)
}


get.fc.weather <- function(PPA.location, start.date, end.date, timezone){
  timezone <- switch(PPA.location,Aztec = "US/Mountain",KitCarson = "US/Mountain")
  weather_station <- switch(PPA.location, Aztec = "WSI.MN.KFMN.", KitCarson = "WSI.MN.KSKX.")
  avg.cloud.cover <- paste0("Hourly AverageCloudCover of ",weather_station, "HOURLY.FCAST")
  avg.dewpoint.temp <- paste0("Hourly AverageDewPointTemp of ",weather_station, "HOURLY.FCAST")
  heat.index <- paste0("Hourly HeatIndex of ", weather_station, "HOURLY.FCAST")
  weather.hum <- paste0("Hourly AvgRelativeHumidity of ",weather_station, "HOURLY.FCAST")
  avg.wetbulb.temp <- paste0("Hourly AvgWetBulbTemp of ",weather_station, "HOURLY.FCAST")
  avg.wind.speed <- paste0("Hourly AvgWindSpeed of ",weather_station, "HOURLY.FCAST")
  norm.avg.Temp <- paste0("Hourly NormAvgTemp of ",weather_station, "HOURLY.FCAST")
  precipitation <- paste0("Hourly Precipitation of ",weather_station, "HOURLY.FCAST")
  wind.chill <- paste0("Hourly WindChill of ",weather_station, "HOURLY.FCAST")
  wind.dir <- paste0("Hourly WindDir of ",weather_station, "HOURLY.FCAST")
  
  weather.vector <- c(avg.cloud.cover, avg.dewpoint.temp, heat.index,
                      weather.hum, avg.wetbulb.temp, avg.wind.speed,
                      norm.avg.Temp, precipitation, wind.chill, wind.dir)
  
  fc.weather <- query.lim.show(show = weather.vector,
                                       datefrom = ymd(start.date), 
                                       dateto = ymd(end.date),
                                       cache.folder = NULL, 
                                       date.he = FALSE, time.unit = "Hours")
  
  fc.weather <- mutate(fc.weather, 
                               date.time = ymd_hms(date.time, tz = timezone))
  colnames(fc.weather) <- c("date_time", "avg.cloud.cover", "avg.dewpoint.temp", "heat.index",
                                    "weather.hum", "avg.wetbulb.temp", "avg.wind.speed",
                                    "norm.avg.Temp", "precipitation",
                                    "wind.chill", "wind.dir")
  historical.weather <- FillDown(fc.weather, Var = c("date_time"))
  return(fc.weather)
}



#' Aztec.df <- getHistoricalWeather("Aztec",start.date,end.date)
#' #' MPT
#' KitCarson.df <- getHistoricalWeather("KitCarson",start.date,end.date)
#' MPT
# saveRDS(Aztec.df,"Aztec_weather.rds")
# saveRDS(KitCarson.df,"KitCarson_weather.rds")
