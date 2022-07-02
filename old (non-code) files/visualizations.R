library(readr)

s3trial1<- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/3x3trial1.csv")
s3trial2 <- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/3x3trial2.csv")
s3trial3 <- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/3x3trial3.csv")
s3trial4 <- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/3x3trial4.csv")
s3trial5 <- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/3x3trial5.csv")
s3trial6 <- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/3x3trial6.csv")
s3trial7 <- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/3x3trial7.csv")
s3trial8 <- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/3x3trial8.csv")
s3trial9 <- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/3x3trial9.csv")
s3trial10 <- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/3x3trial10.csv")

s4trial1<- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/4x4trial1.csv")
s4trial2 <- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/4x4trial2.csv")
s4trial3 <- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/4x4trial3.csv")
s4trial4 <- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/4x4trial4.csv")
s4trial5 <- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/4x4trial5.csv")
s4trial6 <- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/4x4trial6.csv")
s4trial7 <- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/4x4trial7.csv")
s4trial8 <- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/4x4trial8.csv")
s4trial9 <- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/4x4trial9.csv")
s4trial10 <- read.csv("C:/Users/hanna/Google Drive/RPI/Research/toy code/4x4trial10.csv")

#plot a histogram of each vari
library(ggplot2)
library(grid)
library(gridExtra)
########### comparing objective val distributions########################################

p1 <- qplot(s3trial1$obj,main = "3x3 Trial 1",geom="histogram",xlim=c(-2,3.1),xlab = 'obj val')
p2 <- qplot(s3trial2$obj,main = "3x3 Trial 2",geom="histogram",xlim=c(-2,3.1),xlab = 'obj val')
p3 <- qplot(s3trial3$obj,main = "3x3 Trial 3",geom="histogram",xlim=c(-2,3.1),xlab = 'obj val')
p4 <- qplot(s3trial4$obj,main = "3x3 Trial 4",geom="histogram",xlim=c(-2,3.1),xlab = 'obj val')
p5 <- qplot(s3trial5$obj,main = "3x3 Trial 5",geom="histogram",xlim=c(-2,3.1),xlab = 'obj val')
p6 <- qplot(s3trial6$obj,main = "3x3 Trial 6",geom="histogram",xlim=c(-2,3.1),xlab = 'obj val')
p7 <- qplot(s3trial7$obj,main = "3x3 Trial 7",geom="histogram",xlim=c(-2,3.1),xlab = 'obj val')
p8 <- qplot(s3trial8$obj,main = "3x3 Trial 8",geom="histogram",xlim=c(-2,3.1),xlab = 'obj val')
p9 <- qplot(s3trial9$obj,main = "3x3 Trial 9",geom="histogram",xlim=c(-2,3.1),xlab = 'obj val')
p10 <- qplot(s3trial10$obj,main = " 3x3 Trial 10",geom="histogram",xlim=c(-2,3.1),xlab = 'obj val')

#puts the histograms together into a grid
grid.arrange(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10, nrow = 2)

#plot a histogram of each vari
p1 <- qplot(s4trial1$obj,main = "4x4 Trial 1",geom="histogram",xlim=c(-1.6,3.5),xlab = 'obj val')
p2 <- qplot(s4trial2$obj,main = "4x4 Trial 2",geom="histogram",xlim=c(-1.6,3.5),xlab = 'obj val')
p3 <- qplot(s4trial3$obj,main = "4x4 Trial 3",geom="histogram",xlim=c(-1.6,3.5),xlab = 'obj val')
p4 <- qplot(s4trial4$obj,main = "4x4 Trial 4",geom="histogram",xlim=c(-1.6,3.5),xlab = 'obj val')
p5 <- qplot(s4trial5$obj,main = "4x4 Trial 5",geom="histogram",xlim=c(-1.6,3.5),xlab = 'obj val')
p6 <- qplot(s4trial6$obj,main = "4x4 Trial 6",geom="histogram",xlim=c(-1.6,3.5),xlab = 'obj val')
p7 <- qplot(s4trial7$obj,main = "4x4 Trial 7",geom="histogram",xlim=c(-1.6,3.5),xlab = 'obj val')
p8 <- qplot(s4trial8$obj,main = "4x4 Trial 8",geom="histogram",xlim=c(-1.6,3.5),xlab = 'obj val')
p9 <- qplot(s4trial9$obj,main = "4x4 Trial 9",geom="histogram",xlim=c(-1.6,3.5),xlab = 'obj val')
p10 <- qplot(s4trial10$obj,main = " 4x4 Trial 10",geom="histogram",xlim=c(-1.6,3.5),xlab = 'obj val')

#puts the histograms together into a grid
grid.arrange(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10, nrow = 2)


############comparing number of rejections################################################

p1 <- qplot(s3trial1$rejects,main = "3x3 Trial 1",geom="histogram",xlim=c(-0.1,3.1),xlab = 'rejections')
p2 <- qplot(s3trial2$rejects,main = "3x3 Trial 2",geom="histogram",xlim=c(-0.1,3.1),xlab = 'rejections')
p3 <- qplot(s3trial3$rejects,main = "3x3 Trial 3",geom="histogram",xlim=c(-0.1,3.1),xlab = 'rejections')
p4 <- qplot(s3trial4$rejects,main = "3x3 Trial 4",geom="histogram",xlim=c(-0.1,3.1),xlab = 'rejections')
p5 <- qplot(s3trial5$rejects,main = "3x3 Trial 5",geom="histogram",xlim=c(-0.1,3.1),xlab = 'rejections')
p6 <- qplot(s3trial6$rejects,main = "3x3 Trial 6",geom="histogram",xlim=c(-0.1,3.1),xlab = 'rejections')
p7 <- qplot(s3trial7$rejects,main = "3x3 Trial 7",geom="histogram",xlim=c(-0.1,3.1),xlab = 'rejections')
p8 <- qplot(s3trial8$rejects,main = "3x3 Trial 8",geom="histogram",xlim=c(-0.1,3.1),xlab = 'rejections')
p9 <- qplot(s3trial9$rejects,main = "3x3 Trial 9",geom="histogram",xlim=c(-0.1,3.1),xlab = 'rejections')
p10 <- qplot(s3trial10$rejects,main = " 3x3 Trial 10",geom="histogram",xlim=c(-0.1,3.1),xlab = 'rejections')

#puts the histograms together into a grid
grid.arrange(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10, nrow = 2)

#plot a histogram of each vari
p1 <- qplot(s4trial1$rejects,main = "4x4 Trial 1",geom="histogram",xlim=c(-0.1,4.1),xlab = 'rejections')
p2 <- qplot(s4trial2$rejects,main = "4x4 Trial 2",geom="histogram",xlim=c(-0.1,4.1),xlab = 'rejections')
p3 <- qplot(s4trial3$rejects,main = "4x4 Trial 3",geom="histogram",xlim=c(-0.1,4.1),xlab = 'rejections')
p4 <- qplot(s4trial4$rejects,main = "4x4 Trial 4",geom="histogram",xlim=c(-0.1,4.1),xlab = 'rejections')
p5 <- qplot(s4trial5$rejects,main = "4x4 Trial 5",geom="histogram",xlim=c(-0.1,4.1),xlab = 'rejections')
p6 <- qplot(s4trial6$rejects,main = "4x4 Trial 6",geom="histogram",xlim=c(-0.1,4.1),xlab = 'rejections')
p7 <- qplot(s4trial7$rejects,main = "4x4 Trial 7",geom="histogram",xlim=c(-0.1,4.1),xlab = 'rejections')
p8 <- qplot(s4trial8$rejects,main = "4x4 Trial 8",geom="histogram",xlim=c(-0.1,4.1),xlab = 'rejections')
p9 <- qplot(s4trial9$rejects,main = "4x4 Trial 9",geom="histogram",xlim=c(-0.1,4.1),xlab = 'rejections')
p10 <- qplot(s4trial10$rejects,main = " 4x4 Trial 10",geom="histogram",xlim=c(-0.1,4.1),xlab = 'rejections')

#puts the histograms together into a grid
grid.arrange(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10, nrow = 2)


########### comparing number of duplicates ########################################

p1 <- qplot(s3trial1$duplicates,main = "3x3 Trial 1",geom="histogram",xlim=c(-0.1,3.1),xlab = 'duplicates')
p2 <- qplot(s3trial2$duplicates,main = "3x3 Trial 2",geom="histogram",xlim=c(-0.1,3.1),xlab = 'duplicates')
p3 <- qplot(s3trial3$duplicates,main = "3x3 Trial 3",geom="histogram",xlim=c(-0.1,3.1),xlab = 'duplicates')
p4 <- qplot(s3trial4$duplicates,main = "3x3 Trial 4",geom="histogram",xlim=c(-0.1,3.1),xlab = 'duplicates')
p5 <- qplot(s3trial5$duplicates,main = "3x3 Trial 5",geom="histogram",xlim=c(-0.1,3.1),xlab = 'duplicates')
p6 <- qplot(s3trial6$duplicates,main = "3x3 Trial 6",geom="histogram",xlim=c(-0.1,3.1),xlab = 'duplicates')
p7 <- qplot(s3trial7$duplicates,main = "3x3 Trial 7",geom="histogram",xlim=c(-0.1,3.1),xlab = 'duplicates')
p8 <- qplot(s3trial8$duplicates,main = "3x3 Trial 8",geom="histogram",xlim=c(-0.1,3.1),xlab = 'duplicates')
p9 <- qplot(s3trial9$duplicates,main = "3x3 Trial 9",geom="histogram",xlim=c(-0.1,3.1),xlab = 'duplicates')
p10 <- qplot(s3trial10$duplicates,main = " 3x3 Trial 10",geom="histogram",xlim=c(-0.1,3.1),xlab = 'duplicates')

#puts the histograms together into a grid
grid.arrange(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10, nrow = 2)

#plot a histogram of each vari
p1 <- qplot(s4trial1$duplicates,main = "4x4 Trial 1",geom="histogram",xlim=c(-0.1,4.1),xlab = 'duplicates')
p2 <- qplot(s4trial2$duplicates,main = "4x4 Trial 2",geom="histogram",xlim=c(-0.1,4.1),xlab = 'duplicates')
p3 <- qplot(s4trial3$duplicates,main = "4x4 Trial 3",geom="histogram",xlim=c(-0.1,4.1),xlab = 'duplicates')
p4 <- qplot(s4trial4$duplicates,main = "4x4 Trial 4",geom="histogram",xlim=c(-0.1,4.1),xlab = 'duplicates')
p5 <- qplot(s4trial5$duplicates,main = "4x4 Trial 5",geom="histogram",xlim=c(-0.1,4.1),xlab = 'duplicates')
p6 <- qplot(s4trial6$duplicates,main = "4x4 Trial 6",geom="histogram",xlim=c(-0.1,4.1),xlab = 'duplicates')
p7 <- qplot(s4trial7$duplicates,main = "4x4 Trial 7",geom="histogram",xlim=c(-0.1,4.1),xlab = 'duplicates')
p8 <- qplot(s4trial8$duplicates,main = "4x4 Trial 8",geom="histogram",xlim=c(-0.1,4.1),xlab = 'duplicates')
p9 <- qplot(s4trial9$duplicates,main = "4x4 Trial 9",geom="histogram",xlim=c(-0.1,4.1),xlab = 'duplicates')
p10 <- qplot(s4trial10$duplicates,main = " 4x4 Trial 10",geom="histogram",xlim=c(-0.1,4.1),xlab = 'duplicates')

#puts the histograms together into a grid
grid.arrange(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10, nrow = 2)
