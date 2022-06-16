library(tidyverse)

###clean data
shooting<-read_csv("shootingclean.csv")
allgame<-read_csv("cleanseason.csv")
# age (game stats)
allgame$Age<-substr(allgame$Age,1,2)

#age(shooting stats)
library(lubridate)
shooting$GAME_DATE<-ymd(shooting$GAME_DATE)

lbj_birth<-ymd("1984-12-30")
shooting$AGE<-time_length(difftime(shooting$GAME_DATE, lbj_birth),"years")
shooting$AGE<-substr(as.character(shooting$AGE),1,2)

# delete useless cols
allgame <- subset(allgame, select = -c(1,6,7,14,15,16,17,18,20,21,23,24,26,27))
shooting <- subset(shooting, select = -c(1,2,3,4,5,6,8,9,10,22,23,24))
allgame<-na.omit(allgame)
shooting<-na.omit(shooting)
shooting <- shooting[which(!shooting$SHOT_ZONE_BASIC=='Backcourt'), ]
shooting$SHOT_TYPE<-
  case_when(
    shooting$ACTION_TYPE %in% c('Alley Oop Dunk Shot','Alley Oop Layup shot',"Running Alley Oop Dunk Shot") ~"Alley Oop",
    shooting$ACTION_TYPE %in% c('Cutting Dunk Shot','Driving Dunk Shot',
                                'Driving Reverse Dunk Shot','Driving Slam Dunk Shot',"Dunk Shot",
                                "Follow Up Dunk Shot","Putback Dunk Shot","Putback Reverse Dunk Shot",
                                "Putback Slam Dunk Shot","Reverse Dunk Shot","Reverse Slam Dunk Shot",
                                "Running Dunk Shot","Running Reverse Dunk Shot","Running Slam Dunk Shot",
                                "Slam Dunk Shot","	Tip Dunk Shot"
    ) ~"Dunk Shot",
    shooting$ACTION_TYPE %in% c('Cutting Finger Roll Layup Shot','Cutting Layup Shot',"Driving Finger Roll Layup Shot",
                                "Driving Layup Shot","Driving Reverse Layup Shot","Finger Roll Layup Shot",
                                "Layup Shot","Putback Layup Shot","Reverse Layup Shot","Running Finger Roll Layup Shot",
                                "Running Layup Shot","Running Reverse Layup Shot","Tip Layup Shot"
                                ,"Driving Finger Roll Shot") ~"Layup Shot",
    shooting$ACTION_TYPE %in% c('Driving Bank Hook Shot','Driving Hook Shot',"Hook Bank Shot","Hook Shot",
                                "Jump Hook Shot","Running Bank Hook Shot","Running Hook Shot",
                                "Turnaround Bank Hook Shot","Turnaround Hook Shot"
    ) ~"Hook Shot",
    shooting$ACTION_TYPE %in% c('Driving Bank shot','Fadeaway Bank shot',"Running Bank shot","Turnaround Bank shot",
                                "Pullup Bank shot")~"Bank Shot",
    shooting$ACTION_TYPE %in% c('Driving Floating Bank Jump Shot','Driving Floating Jump Shot',
                                "Driving Jump shot","Fadeaway Jump Shot","Floating Jump shot","Jump Bank Shot",
                                "Jump Shot","Pullup Jump shot","Running Jump Shot",
                                "Running Pull-Up Jump Shot","Step Back Bank Jump Shot",
                                "Step Back Jump shot","Turnaround Fadeaway Bank Jump Shot",
                                "Turnaround Jump Shot")~"Jump Shot" ,
    TRUE ~"Others")

shooting$SHOT_ZONE_BASIC<-factor(shooting$SHOT_ZONE_BASIC, 
       levels=c("Right Corner 3","Above the Break 3","Mid-Range",
                "Restricted Area","In The Paint (Non-RA)","Left Corner 3"))



###clean data)

store_csv2=paste("dvpallgame.csv")
write_csv(allgame, path=store_csv2)
