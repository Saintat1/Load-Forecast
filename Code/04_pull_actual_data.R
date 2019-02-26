# TODO: Add comment
# 
# Author: bwu
###############################################################################
# backtest.days = 600
pull.actual.data <- function(location, server.name, backtest.days){
    header.msg("pull actual data for model training....")
  time.zone <- switch(location, Aztec = "US/Mountain", KitCarson = "US/Mountain")
  cur.date = format(Sys.time(), format="%Y-%m-%d", tz=time.zone);
  end.date = as.Date(cur.date) - days(1)
  start.date = as.Date(cur.date) - days(backtest.days + 1)
  
  conn = get.connection.rmysql(server.name)
  select.query = paste0("SELECT * FROM forecast_actual_data ",
                               "where flow_date between '", start.date, "' AND '", 
                               end.date, "'")
  
  actual.data <- dbGetQuery(conn, select.query)
  dbDisconnect(conn) 

  actual.data = actual.data %>%
    select(-data_type, -location, -final) %>%
      spread(data_name,data_value, )
  return(actual.data)
  }
  