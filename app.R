#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(RSQLite)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(shinythemes)
library(shinydashboard)
source("./R/functions.R")

# Define UI for application that draws a histogram

ui <- navbarPage("KBO 그래프",theme = shinytheme("cerulean"),
                 tabPanel("팀 그래프",
                          sidebarLayout(sidebarPanel(
                              widths = c(12,12),"원하는 팀을 선택하세요",
                              tabPanel(selectInput("team","Select Team",unique(scoreboard$팀))
                              
                              
                          )),
                          mainPanel(navbarPage(title="그래프 종류",
                                               tabPanel("팀 승패 그래프",plotOutput("w_l_plot")),
                                               tabPanel("팀 득점 그래프",plotOutput("r_plot")),
                                               tabPanel("팀 실책 그래프",plotOutput("e_plot"))))
                          )),
                 tabPanel("타자 선수 그래프",
                          sidebarLayout(sidebarPanel(navlistPanel(
                              widths = c(12,12),"원하는 타자선수을 입력하세요",
                              tabPanel(selectInput("batter_player","Select player",
                                                   unique(batter$선수명)[order(unique(batter$선수명))]))
                              
                          )),
                          mainPanel(navbarPage(title="그래프 종류",
                                               tabPanel("선수 타율 그래프",plotOutput("avg_plot"))
                                               ))
                          )),
                 tabPanel("투수 선수 그래프",
                          sidebarLayout(sidebarPanel(navlistPanel(
                              widths = c(12,12),"원하는 투수선수을 선택하세요",
                              tabPanel(selectInput("pitcher_player","Select player",
                                                   unique(pitcher$선수명)[order(unique(pitcher$선수명))]))
                              
                          )),
                          mainPanel(navbarPage(title="그래프 종류",
                                               tabPanel("선수 방어율 그래프",plotOutput("era_plot"))
                          ))
                          ))
)



# Define server logic required to draw a histogram
server <- function(input, output, session) {
    observe({
        win_lose_data <- get_win_lose_data(input$team)
        run_error_data <- get_run_error_data(input$team)
        batter_temp <- get_player_data(batter,get_id(batter,input$batter_player))
        picher_temp <- get_player_data(pitcher,get_id(pitcher,input$pitcher_player))
        avg_data <- get_player_record(batter_temp,avg_fomula)
        era_data <- get_player_record(picher_temp,era_fomula)
        
        output$w_l_plot <- renderPlot({
            ggplot(win_lose_data$win,aes(x=year,y=sum))+ geom_line(aes(colour = 'blue'))+
                geom_line(data = win_lose_data$lose,aes(x=year,y=sum,colour = 'red'))+
                scale_x_continuous("year",limits = c(2010,2021),breaks = seq(2010,2020,2))+
                scale_color_discrete(name = "Win_or_Lose", labels = c("Win", "Lose"))
            
        })
        output$r_plot <- renderPlot({
            ggplot(run_error_data$run,aes(x=year,y=r_sum))+ geom_line(aes(colour = 'Run'))+
                scale_x_continuous("year",limits = c(2010,2021),breaks = seq(2010,2020,2))
        })
        output$e_plot <- renderPlot({
            ggplot(run_error_data$error,aes(x=year,y=e_sum))+ geom_line(aes(colour = 'Error'))+
                scale_x_continuous("year",limits = c(2010,2021),breaks = seq(2010,2020,2))
        })
        output$avg_plot <- renderPlot({
            ggplot(avg_data,aes(x=year,y=record,group=1))+geom_line()+geom_point(aes(colour=id))+
                facet_wrap(~id)+scale_x_continuous("year",limits = c(2010,2021),breaks = seq(2010,2020,2))+
            scale_y_continuous("AVG",limits=c(0,max(avg_data$record)),breaks = seq(0,max(avg_data$record),0.1))
        })
        output$era_plot <- renderPlot({
            ggplot(era_data,aes(x=year,y=record,group=1))+geom_line()+geom_point(aes(colour=id))+
                facet_wrap(~id)+scale_x_continuous("year",limits = c(2010,2021),breaks = seq(2010,2020,2))+
                scale_y_continuous("ERA",limits=c(0,max(era_data$record)),breaks = seq(0,max(era_data$record)))
        })
    })
    
}


# Run the application 
shinyApp(ui = ui, server = server)
