
library(tidyverse)
<<<<<<< HEAD
shot<-read_csv("shootingclean.csv")
shot <- shot[which(!shot$SHOT_ZONE_BASIC=='Backcourt'), ]
=======
shot<-read_csv("shooting_shootingclean.csv")
>>>>>>> b48820e22bfe6f537563e44139b5faf27be71df2

# covert x and y coordinates into numeric
shot$LOC_X <- as.numeric(as.character(shot$LOC_X))
shot$LOC_Y <- as.numeric(as.character(shot$LOC_Y))
shot$SHOT_DISTANCE <- as.numeric(as.character(shot$SHOT_DISTANCE))

# summarise shot data

<<<<<<< HEAD
library(ggplot2)
=======
library(tidyverse)
library(ggplot2)
detach('package:plyr')
>>>>>>> b48820e22bfe6f537563e44139b5faf27be71df2
shot$SHOT_ATTEMPTED_FLAG<-as.numeric(as.character(shot$SHOT_ATTEMPTED_FLAG))
shot$SHOT_MADE_FLAG<-as.numeric(as.character(shot$SHOT_MADE_FLAG))

shotp<-shot%>%group_by(SHOT_ZONE_BASIC,TEAM_NAME)%>%
  summarise(loc_x=mean(LOC_X), loc_y=mean(LOC_Y), 
            accuracy=sum(SHOT_MADE_FLAG)/sum(SHOT_ATTEMPTED_FLAG))

shotp[shotp=='n/a']<- NA

shotp<-na.omit(shotp)


shotp$SHOT_ACCURACY_LAB <- paste(as.character(round(100 * shotp$accuracy, 1)), "%", sep="")


<<<<<<< HEAD

img <- jpeg::readJPEG("nba_court.jpeg")



ggplot(data=shotp, aes(x=loc_x, y=loc_y)) +
  annotation_custom(img, -250, 250, -52, 418) +
=======
img <- jpeg::readJPEG("nba_court.jpeg")

library(grid)

ggplot(shotp, aes(x=loc_x, y=loc_y)) +
  annotation_custom(court, -250, 250, -52, 418) +
>>>>>>> b48820e22bfe6f537563e44139b5faf27be71df2
  geom_point(aes(color=SHOT_ZONE_BASIC, size=accuracy,alpha = 0.8),size = 6) +
  geom_text(aes(color=SHOT_ZONE_BASIC,label = SHOT_ACCURACY_LAB), vjust = -1, size = 6)+
    xlim(250, -250) +
    ylim(-52, 418) +
<<<<<<< HEAD
    coord_fixed()
=======
    coord_fixed()+
  facet_wrap( ~ TEAM_NAME)
>>>>>>> b48820e22bfe6f537563e44139b5faf27be71df2

store_csv=paste("shotp.csv")

write_csv(shotp, path=store_csv)





