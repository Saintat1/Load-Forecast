# TODO: Add comment
# 
# Author: bwu
###############################################################################

update.weather.data <- function(location, server.name){
  header.msg("1. Start to update weather data ....")
  # update weather actual data
  time.zone <- switch(location, Aztec = "US/Mountain", KitCarson = "US/Mountain")
  cur.date = format(Sys.time(), format="%Y-%m-%d", tz=time.zone);
  
  conn = get.connection.rmysql(server.name)
  last.flow.date.query = paste("SELECT flow_date FROM forecast_actual_data ",
                               "where data_type='weather' order by flow_date desc limit 1;")
  
  last.flow.date <- dbGetQuery(conn, last.flow.date.query)
  dbDisconnect(conn) 
  
  weather.actual = get.observed.weather(location, last.flow.date$flow_date, 
                                        cur.date, timezone = time.zone)
  
  field.name.list <- list("DATE", "INT", "VARCHAR(60)", "VARCHAR(120)", "VARCHAR(300)",
                          "BOOLEAN", "DECIMAL(10,4)")
  
  for(column.name in names(weather.actual)[-1]){
    sub.header.msg(paste0("updating ",column.name, "from ",last.flow.date, 
                          "to", cur.date))
    data = weather.actual %>% 
      select(.dots=c("date_time",column.name)) %>%
      rename(date_time = .dots1, data_value_orig = .dots2)
    single.weather.data = format.weather.data(data, column.name, location, time.zone)
    
    conn = get.connection.rmysql(server.name)
    
    tryCatch({
      dbWriteTable(conn, value = single.weather.data, name = "forecast_actual_data", append=TRUE, 
                   field.types=field.name.list, row.names = FALSE)
    },
    error = function(e) {
      dbDisconnect(conn) 
      stop(paste0("Can't insert single weather data ",
                  column.name), call. = FALSE)
    }
    )
    dbDisconnect(conn) 
  }
  
}

format.weather.data <- function(data, column.name, location, timezone){
  single.weather.data <- data %>%
    mutate(flow_date = as.Date(date_time,tz = timezone),
           he = as.numeric(format(date_time, format = "%H")) + 1,
           data_type = "weather",
           location = location,
           data_name = column.name,
           final=1,
           data_value = data_value_orig) %>%
    select(-date_time, -data_value_orig)
  return(single.weather.data)
}
