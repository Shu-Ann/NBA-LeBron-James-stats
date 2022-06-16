library(tidyverse)
library(ggplot2)
library(ggpubr)
library(leaflet)
library(shiny)
library(jpeg)
library(ggthemes)
library(plotly)
library(shinythemes)






ui<-fluidPage(theme = shinytheme("sandstone"),navbarPage("LeBron James Career",
               tabPanel("Overall Stats",
                        fluidRow(column(2, img(src = "lbj.png", height = 200, width = 200)),
                                 column(10,column(12,div(style="height:30px;font-size:30px;","LeBron James | 2003-2022 | Career Data Visualisation")),
                                        column(12,h3("Points 30.3|| Rebounds 8.2 || Assist 6.2")),
                                        column(6,h4("This project is a visualization of LeBron James' career stats.",br(),
                                                    "LeBron James is 37 years old this year. However, his stats do",br(),
                                                    "not appear to be affected by age.",br(),
                                                    "Here, users can compare data - shooting, average points,",br(), 
                                                    "winning
                                                    for different ages and teams by comparing with",br(), "various data sets.")))),
                        fluidRow(column(12)),
                        fluidRow(column(12)),
                        fluidRow(column(12)),
                        fluidRow(column(6,h4("Click on the grpah to find out more!",br(),"Double click to return back."),
                                        plotlyOutput(outputId = "g1", height = "400px"))
                                 ,column(6,h4("Click on the grpah to find out more!",br(),"Double click to return back."),
                                         plotlyOutput(outputId = "g2", height = "400px"))),
                        fluidRow(column(6,
                                        plotlyOutput(outputId = "g3", height = "400px"))
                                 ,column(6,plotlyOutput(outputId = "g4", height = "400px"))),
                        fluidRow(column(12, h3("Conclusion"))),
                        fluidRow(column(12, h4("Three-point attempts seem to have risen in recent years, but rebounds and blocks are still holding up well.",br(),
                                               "LeBron James doesn't seem to be affected by age at all.",br(),"Check out more on other pages!")))
                        ),
               tabPanel("Shooting Stats",
                        fluidRow(column(12,h3("You can observe shooting stats for different periods on this page.",br(),
                                              "First, please choose to compare when you are in different teams or at different ages"))),
                        fluidRow(column(6,
                                       radioButtons(inputId ="types",
                                                    label ="Choose to compare ages or teams", 
                                                    list("Team","Age")))),
                        fluidRow(column(2, 
                                        selectInput(inputId = "select_1",
                                                    label = "Choose the team/age",
                                                    NULL)),
                                 column(3),
                                 column(2,h3("VS")),
                                 column(3),
                                 column(2,
                                        selectInput(inputId = "select_2",
                                                    label = "Choose the team/age",
                                                    NULL))
                                 ),
                        fluidRow(
                                 column(6,plotOutput(outputId = "shot_acc",height="400px")),
                                 column(6,plotOutput(outputId = "shot_acc2",height="400px"))
                                 ),
                        fluidRow(
                                 column(6,plotOutput(outputId = "scatter",height="400px")),
                                 column(6,plotOutput(outputId = "scatter2",height="400px"))
                                        ),
                        fluidRow(
                                 column(6,plotOutput(outputId ="bar",height="400px")),
                                 column(6,plotOutput(outputId ="bar2",height="400px"))
                                 ),
                        fluidRow(
                                 column(6,plotOutput(outputId = "pie", height="400px")),
                                 column(6,plotOutput(outputId = "pie2", height="400px"))
                                  )
                        ),
              tabPanel("Win Rate",
                       fluidRow(column(12),h3("Win rate also matters, doesn't it?",br(),
                                              "Find out more about the win rate when LBJ against to others at different period")),
                       fluidRow(column(6,
                                       radioButtons(inputId ="types2",
                                                    label ="Choose to compare ages or teams", 
                                                    list("Team","Age")))),
                       fluidRow(column(2, 
                                       selectInput(inputId = "select_3",
                                                   label = "Choose the team/age",
                                                   NULL))),
                       fluidRow(column(1),
                                column(10,h4("Try to click on the logo!")
                                       ,leafletOutput("MAP")),
                                column(1)),
                       fluidRow(column(12,h4("Click on the grpah to find out more!",br(),"Double click to return back."),
                                       plotlyOutput(outputId = "barmap", height="400px")))

               )
))

server<-function(input, output, session) {
  
  allgame<-read_csv("dvpallgame.csv")
  shot_accuracy<-read_csv("shot_accuracy.csv")
  shooting<-read_csv("dvpshooting.csv")
  winrate<-read_csv("winrate.csv")

  
  p1_point<-allgame%>%
    group_by(Age)%>%
    summarise(`2 Point`=mean(FGA),`3 Point`=mean(`3PA`))
  
  p1_point$`2 Point`<-round(p1_point$`2 Point`,2)
  p1_point$`3 Point`<-round(p1_point$`3 Point`,2)

  p1_rb<-allgame%>%
    group_by(Age)%>%
    summarise(`Rebounds`=mean(TRB),`Blocks`=mean(BLK))
  
  p1_rb$`Rebounds`<-round(p1_rb$`Rebounds`,2)
  p1_rb$`Blocks`<-round(p1_rb$`Blocks`,2)
  
  p1_point<- data.frame(p1_point[1:1], stack(p1_point[2:3]))
  names(p1_point)[3] <- "Points"
  p1_rb<-data.frame(p1_rb[1:1], stack(p1_rb[2:3]))
  names(p1_rb)[3] <- "Types"

  shooting$SHOT_ZONE_BASIC<-factor(shooting$SHOT_ZONE_BASIC, 
                                   levels=c("Left Corner 3","Above the Break 3","Mid-Range",
                                            "Restricted Area","In The Paint (Non-RA)","Right Corner 3"))
  
  shot_accuracy$SHOT_ZONE_BASIC<-factor(shot_accuracy$SHOT_ZONE_BASIC, 
                                   levels=c("Left Corner 3","Above the Break 3","Mid-Range",
                                            "Restricted Area","In The Paint (Non-RA)","Right Corner 3"))
  shooting$group<-factor(shooting$group,
                              levels=c("2003-2010 CLE","2010-2014 MIA","2014-2018 CLE",
                                       "2018-Now LAL","18","19","20","21","22","23","24","25","26","27"
                                       ,"28","29","30","31","32","33","34","35","36","37"))
  
  shooting$SHOT_TYPE<-factor(shooting$SHOT_TYPE,
                         levels=c("Jump Shot","Layup Shot", "Dunk Shot", "Alley Oop", "Others"))
  
  shooting<-as.data.frame(shooting)
  shot_accuracy<-as.data.frame(shot_accuracy)
  
  
  img <- jpeg::readJPEG("nba_court.jpeg")
  rb<-highlight_key(p1_rb,~Age)
  point<-highlight_key(p1_point,~Age)
  
  output$g1 <- renderPlotly({
    ggplotly(ggplot(point, aes(x=Age, y=values, group=Points, color=Points,
                               text = paste("Age:",Age,"\n",values,"times"))) +
      geom_line()+
      geom_point(size = 1.1) +
      labs(title = "Shooting Attempts",
          x = "Age",
          y = "Number of Average Attempts")+
      scale_color_manual(values=c('SlateBlue','Gold'))+
      theme_set(theme_bw())+theme(panel.grid.major=element_line(colour=NA)),tooltip="text")%>%
    highlight(on = "plotly_hover", off = "plotly_doubleclick")
    })

  output$g2<-renderPlotly({
    ggplotly(ggplot(rb,aes(x=Age, y=values, group=Types, color=Types,
                                text = paste("Age:",Age,"\n",
                                             values,"times"))) +
                 geom_line()+ 
                 geom_point(size = 1.1) + 
                 labs(title = "Average Number of Rebounds and Blocks",
                      x = "Age",
                      y = "Number of Average Types")+
                 scale_color_manual(values=c('#8b81a8','#e9e935'))+
                 theme_set(theme_bw())+theme(panel.grid.major=element_line(colour=NA)),tooltip="text")%>%
      highlight(on = "plotly_hover", off = "plotly_doubleclick")
  })
  
  output$g3<-renderPlotly({
    ggplotly(ggplot(point,aes(fill=Points, y=values, x=Age,text = paste("Age:",Age,"\n",
                                                                        values,"times"))) + 
      theme(axis.text=element_text(size = 6)) +
    geom_bar(position="dodge", stat="identity")+
    labs(title = "Shooting Attempts",x = "Age", y = "Number of Average Attempts")+
    scale_fill_manual(values=c('SlateBlue','Gold'))+
    theme_set(theme_bw())+theme(panel.grid.major=element_line(colour=NA)),tooltip="text")%>%
    highlight(on = "plotly_hover", off = "plotly_doubleclick")
  })
  
  output$g4<-renderPlotly({
    ggplotly(ggplot(rb,aes(fill=Types, y=values, x=Age,text = paste("Age:",Age,"\n",
                                                                    values,"times"))) + 
      geom_bar(position="dodge", stat="identity")+
      labs(title = "Average Number of Rebounds and Blocks",x = "Age", y = "Number of Average Types")+
      scale_fill_manual(values=c('#8b81a8','#e6d300'))+
      theme_set(theme_bw())+theme(panel.grid.major=element_line(colour=NA)),tooltip="text")%>%
      highlight(on = "plotly_hover", off = "plotly_doubleclick")

  })
  
  ########### page2 #######################
  ###########team##########################
  
  group1_a <- reactive({
    req(input$select_1)
    df_shot_team <- shot_accuracy %>% filter(group %in% input$select_1) })
  group1_b<-reactive(({
    req(input$select_1)
    team<-shooting%>% filter(group %in% input$select_1)
  }))
  observe({
    updateSelectInput(session, "select_1", choices = levels(factor(shooting[shooting$type == input$types, "group"])))
  })
  output$shot_acc<-renderPlot({
    ggplot(group1_a(),aes(x=LOC_X, y=LOC_Y))+
      background_image(img)+
      geom_point(aes(color=SHOT_ZONE_BASIC, size=SHOT_ACCURACY,alpha = 0.8),size = 6) +
      geom_text(aes(color=SHOT_ZONE_BASIC,label = SHOT_ACCURACY_LAB), vjust = -1, size = 6)+
      scale_color_manual(name = "ZONE", values=c("#3968bb","#274780","#ffc000","#9a1700","#ff7333","#ff5133"))+
      labs(title = "Shooting Accuracy",x ="", y = "")+
      xlim(250, -250) +
      ylim(-52, 418)+
      coord_fixed()
    })
  
  output$scatter<-renderPlot({
    ggplot(group1_b(),aes(x = LOC_X, y = LOC_Y)) +
      background_image(img)+
      labs(title = "Shooting Frequency at each zone",x = "", y = "")+
      geom_point(aes(colour = SHOT_ZONE_BASIC,alpha=0.8)) +
      scale_color_manual(name = "ZONE", values=c("#3968bb","#274780","#ffc000","#9a1700","#ff7333","#ff5133"))+
      xlim(250, -250) +
      ylim(-52, 418)+
      coord_fixed()
  })
  output$bar<-renderPlot({
      group1_b()%>%group_by(SHOT_ZONE_BASIC)%>%
      summarise(Frequency=sum(SHOT_ATTEMPTED_FLAG))%>%
      ggplot(aes(fill=SHOT_ZONE_BASIC,x=SHOT_ZONE_BASIC, y=Frequency)) +
      labs(title = "Total number of shooting attempts at each zone",x = "Zone", y = "Times")+
      scale_fill_manual(values=c("#3968bb","#274780","#ffc000","#9a1700","#ff7333","#ff5133"))+
      theme_set(theme_bw())+
      theme(panel.grid.major=element_line(colour=NA))+
      geom_bar(stat="identity", width=0.5)
  })
  output$pie<-renderPlot({

    group1_b()%>%group_by(SHOT_TYPE)%>%
      summarise(n=n())%>%
      mutate(prop=n/sum(n))%>%
      ggplot(aes(x="", y=prop, fill=SHOT_TYPE))+ geom_bar(stat = "identity", color = "white") +
      labs(title = "Shooting Type Proportion (%)",x = "", y = "")+
      coord_polar(theta = "y") +
      scale_fill_brewer(palette = "Set2")+
      geom_text(aes(x = 1.7,label = paste0(round(prop*100,1))), position = position_stack(vjust = 0.7))+
      guides(fill = guide_legend(title = "Types")) +
      theme_void()

  })

  
 
  
  ############################age###############################
  
  group2_a <- reactive({
    req(input$select_2)
    df_shot_team2 <- shot_accuracy %>% filter(group %in% input$select_2) })
  group2_b<-reactive(({
    req(input$select_2)
    team<-shooting%>% filter(group %in% input$select_2)
  }))
  observe({
    updateSelectInput(session, "select_2", choices = levels(factor(shooting[shooting$type == input$types, "group"])))
  })
  output$shot_acc2<-renderPlot({
      ggplot(group2_a(), aes(x=LOC_X, y=LOC_Y))+
      background_image(img)+
      labs(title = "Shooting Accuracy",x ="", y = "")+
      geom_point(aes(color=SHOT_ZONE_BASIC, size=SHOT_ACCURACY,alpha=0.8),size = 6) +
      geom_text(aes(color=SHOT_ZONE_BASIC,label = SHOT_ACCURACY_LAB), vjust = -1, size = 6)+
      scale_color_manual(name = "ZONE", values=c("#3968bb","#274780","#ffc000","#9a1700","#ff7333","#ff5133"))+
      xlim(250, -250) +
      ylim(-52, 418)+
      coord_fixed()
    })

  output$scatter2<-renderPlot({
    ggplot(group2_b(),aes(x = LOC_X, y = LOC_Y)) +
      background_image(img)+
      labs(title = "Shooting Frequency at each zone",x = "", y = "")+
      geom_point(aes(colour = SHOT_ZONE_BASIC,alpha=0.8)) +
      scale_color_manual(name = "ZONE", values=c("#3968bb","#274780","#ffc000","#9a1700","#ff7333","#ff5133"))+
      xlim(250, -250) +
      ylim(-52, 418)+
      coord_fixed()
  })
  output$bar2<-renderPlot({
      group2_b()%>%group_by(SHOT_ZONE_BASIC)%>%
      summarise(Frequency=sum(SHOT_ATTEMPTED_FLAG))%>%
      ggplot(aes(fill=SHOT_ZONE_BASIC,x=SHOT_ZONE_BASIC, y=Frequency)) +
      labs(title = "Total number of shooting attempts at each zone",x = "Zone", y = "Times")+
      scale_fill_manual(values=c("#3968bb","#274780","#ffc000","#9a1700","#ff7333","#ff5133"))+
      theme_set(theme_bw())+
      theme(panel.grid.major=element_line(colour=NA))+
      geom_bar(stat="identity", width=0.5)
  })
  output$pie2<-renderPlot({
      group2_b()%>%group_by(SHOT_TYPE)%>%
      summarise(n=n())%>%
      mutate(prop=n/sum(n))%>%
      ggplot(aes(x="", y=prop, fill=SHOT_TYPE))+ geom_bar(stat = "identity", color = "white") +
      coord_polar(theta = "y") +
      labs(title = "Shooting Type Proportion",x = "", y = "")+
      scale_fill_brewer(palette = "Set2")+
      geom_text(aes(x = 1.7,label = paste0(round(prop*100,1))), position = position_stack(vjust = 0.7))+
      guides(fill = guide_legend(title = "Types")) +
      theme_void()
  })
  
  
  ###########################page3#####################################
  
  group3<-reactive(({
    req(input$select_3)
    win<-winrate%>% filter(group %in% input$select_3)
  }))
  
  observe({
    updateSelectInput(session, "select_3", choices = levels(factor(shot_accuracy[shot_accuracy$type == input$types2, "group"])))
  })
  
  nbaIcons <- iconList(
      ATL = makeIcon("ATL.png","ATL.png", 35, 35),
      BKN = makeIcon("BKN.png","BKN.png",  35, 35),
      BOS = makeIcon("BOS.png","BOS.png", 35, 35),
      CHA = makeIcon("CHA.png", "CHA.png", 35, 35),
      CHI = makeIcon("CHI.png","CHI.png", 35, 35),
      CLE = makeIcon("CLE.png", "CLE.png", 35, 35),
      DAL = makeIcon("DAL.png","DAL.png", 35, 35),
      DEN = makeIcon("DEN.png","DEN.png",  40, 40),
      DET = makeIcon("DET.png", "DET.png",35, 35),
      GSW = makeIcon("GSW.png","GSW.png",  35, 35),
      HOU = makeIcon("HOU.png","HOU.png", 35, 35),
      IND = makeIcon("IND.png","IND.png",  35, 35),
      LAC = makeIcon("LAC.png","LAC.png",  35, 35),
      LAL = makeIcon("LAL.png","LAL.png", 35, 35),
      MEM = makeIcon("MEM.png","MEM.png",  35, 35),
      MIA = makeIcon("MIA.png","MIA.png", 35, 35),
      MIL = makeIcon("MIL.png","MIL.png",  35, 35),
      MIN = makeIcon("MIN.png","MIN.png", 35, 35),
      NOP = makeIcon("NOP.png","NOP.png",  35, 35),
      NYK = makeIcon("NYK.png","NYK.png", 35, 35),
      OKC = makeIcon("OKC.png","OKC.png",  35, 35),
      ORL = makeIcon("ORL.png","ORL.png", 35, 35),
      PHI = makeIcon("PHI.png","PHI.png",  35, 35),
      PHX = makeIcon("PHX.png","PHX.png", 35, 35),
      POR = makeIcon("POR.png","POR.png",  35, 35),
      SAC = makeIcon("SAC.png","SAC.png", 35, 35),
      SAS = makeIcon("SAS.png","SAS.png",  35, 35),
      TOR = makeIcon("TOR.png", "TOR.png", 35, 35),
      UTA = makeIcon("UTA.png","UTA.png", 35, 35),
      WAS = makeIcon("WAS.png","WAS.png",  35, 35)
    )
    
    winrate$Opp<-factor(winrate$Opp,
                        c("ATL","BKN" ,"BOS","CHA","CHI","CLE" ,"DAL","DEN","DET" ,"GSW","HOU","IND","LAC","LAL",
                          "MEM","MIA","MIL","MIN","NOP","NYK","OKC","ORL","PHI","PHX","POR","SAC","SAS","TOR","UTA","WAS"))


  output$barmap<-renderPlotly({
    bar<-highlight_key(group3(),~Opp)
    ggplotly(ggplot(bar,aes( x=Opp, y=win_rate, text=paste("Opp:",Name,"\n",
                                                        "Win%:",win_rate_lab)))+
               theme_set(theme_bw())+
               theme(panel.grid.major=element_line(colour=NA))+
               labs(title = "Average Win Rate Against Other Teams",
                    x = "Teams",
                    y = "")+
               geom_bar(stat="identity", width=0.5, fill="#93c5c5"),tooltip="text")%>%
      highlight(on = "plotly_hover", off = "plotly_doubleclick")
      
  })
  
  output$MAP <- renderLeaflet({
    leaflet(group3()) %>% 
      addProviderTiles(providers$Stamen.TonerLite)%>%
      addMarkers(lat=~Latitude,lng=~Longitude
                 ,icon= ~nbaIcons[Opp],
                  popup = paste(group3()$Name,"<br>",
                              "Win Rate:", group3()$win_rate_lab,"<br>",
                              "Points:", group3()$Points, "<br>",
                               "FG:", group3()$`FG%`, "<br>",
                               "3P:", group3()$`3P%`, "<br>",
                               "Rebounds:", group3()$Rebounds, "<br>",
                               "Blocks:", group3()$Blocks))
  })
  
}

shinyApp(ui = ui, server = server)


