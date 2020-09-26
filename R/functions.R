library(RSQLite)
library(dplyr)
library(tidyverse)
library(DBI)

scoreboard <- read.csv("./data/scoreboard.csv",stringsAsFactors = F)
batter <- read.csv("./data/KBO_batter_full.csv",stringsAsFactors = F)
pitcher <- read.csv("./data/KBO_pitcher_full.csv",stringsAsFactors = F)


con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
copy_to(con, scoreboard)
scoreboard_db <- tbl(con, "scoreboard")


get_win_lose_data  <- function(team){
  win <- data.frame()
  lose <- data.frame()
  for(i in 2010:2020){
    win <- rbind(win,scoreboard_db %>% 
                   filter(팀==team) %>%
                   filter(year == i) %>%
                   summarize(year=year,sum=sum(승패=="승")) %>%
                   collect())
    lose <- rbind(lose,scoreboard_db %>% 
                    filter(팀==team) %>%
                    filter(year == i) %>%
                    summarize(year=year,sum=sum(승패=="패")) %>%
                    collect())
  }
  return(list(win=win,lose=lose))
}

get_run_error_data <- function(team){
  run <- data.frame()
  error <- data.frame()
  for(i in 2010:2020){
    run <- rbind(run,scoreboard_db %>% 
                   filter(팀==team) %>%
                   filter(year == i) %>%
                   summarize(year=year,r_sum=sum(R)) %>%
                   collect())
    error <- rbind(error,scoreboard_db %>% 
                   filter(팀==team) %>%
                   filter(year == i) %>%
                   summarize(year=year,e_sum=sum(E)) %>%
                   collect())
  }
  return(list(run=run,error=error))
}

get_id <- function(data,name){
  id_list <- unique(data$id[data$선수명==name])
  return(id_list) 
}

get_player_data <- function(data,id_list){
 
  if(NROW(id_list) >=2){
    player_temp <- data.frame()
    for(i in id_list){
      player_temp <- rbind(player_temp,data %>% filter(id==i))
    }
    return(player_temp)
  }
  else{
    player_temp <- data %>% filter(id==id_list)
    return(player_temp)
  }
}

avg_fomula <- function(data){
  return(ifelse(sum(data$타수)>0,sum(data$안타)/sum(data$타수),0))
}

era_fomula <- function(data){
  ip <- sum(data$이닝, data$잔여이닝/3)
  era <- ifelse(ip> 0,sum(data$자책*9) /ip,ifelse(sum(data$자책)==0,0,99.99))
  return(round(era,2))
}
 

get_player_record <- function(data,formula){
  player_record_data <- data.frame()
  for(i in unique(data$id)){
    for(j in unique(data$year)){
      yearly_data <- data %>% 
        filter(id==i) %>%
        filter(year==j) %>%
        collect()
      if(NROW(yearly_data)==0){
        record <- ""
      }
      else{
        record <- yearly_data %>% 
          formula()
      }
      player_record_data <- rbind(player_record_data,yearly_data %>% 
                                 summarize(year=j,id=i,record=record))
    }
  }
  player_record_data <- player_record_data[player_record_data$record !="",] 
  player_record_data$record <- as.numeric(player_record_data$record)
  player_record_data$id <- as.factor(player_record_data$id)
  return(player_record_data)
}


