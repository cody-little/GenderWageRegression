rm(list = ls())

#Load Data#
data <- read.csv("C:/Users/Owner1/Desktop/MSSP897 Final/ASEC Clean Data.csv")

#total n before cleaning 180,101#

####Clean Variables###
#Clean out the labor force so we can use it as a dummy#
View(data)
data$labor <- data$Labor.Force.Status


data$labor[data$labor==1] <- 1
data$labor[data$labor==2] <- 1
data$labor[data$labor==0] <- 0
data$labor[data$labor==3] <- 0
data$labor[data$labor==4] <- 0
data$labor[data$labor==5] <- 0
data$labor[data$labor==6] <- 0
data$labor[data$labor==7] <- 0
labortable <- table(data$labor)

labortable

#Clean sexvariable#

data$gender <-data$SEX

data$gender[data$gender==2]<-0

gendertable<-table(data$gender)
gendertable

#Clean Educational attainment#

data$educ <- data$Educational.Attainment

data$educ[data$educ <= 38]<-1
data$educ[data$educ == 39]<-2
data$educ[data$educ == 40]<-3
data$educ[data$educ == 41]<-3
data$educ[data$educ == 42]<-3
data$educ[data$educ == 43]<-4
data$educ[data$educ >= 44]<-5

eductable<-table(data$educ)
eductable

data$degree <-data$educ
data$degree[data$degree == 1] <- 0
data$degree[data$degree == 2] <- 0
data$degree[data$degree == 3] <- 0
data$degree[data$degree == 4] <- 1
data$degree[data$degree == 5] <- 1

degreetble <- table(data$degree)
degreetble

#now lets deal with industry#

data$industry = data$Job.Industry

data$industry[data$industry==1] <- 0
data$industry[data$industry==2] <- 0
data$industry[data$industry==3] <- 0
data$industry[data$industry==4] <- 0
data$industry[data$industry==5] <- 0
data$industry[data$industry==6] <- 0
data$industry[data$industry==7] <- 1
data$industry[data$industry==8] <- 1
data$industry[data$industry==9] <- 1
data$industry[data$industry==10] <- 0
data$industry[data$industry==11] <- 0
data$industry[data$industry==12] <- 0
data$industry[data$industry==13] <- 0
data$industry[data$industry==14] <- 0

industrytable <- table(data$industry)
industrytable

data$weekearn <- data$Weekly.Earnings.Gross

#drop the ones we dont need#

data2<- data[,c( "weekearn","AGE", "degree","gender","industry")]

data<- data2


#Check average earnings
womenearnavg <- mean(data$weekearn[data$gender==0])
womenearnavg
menearnavg<- mean(data$weekearn[data$gender==1])
menearnavg


# Gonna have to remove the zeros#

data$weekearn[data$weekearn == 0] <- NA


data<- na.omit(data)
View(data)

#now lets see some average earnings#
womenearnavg <- median(data$weekearn[data$gender==0])
womenearnavg
menearnavg<- median(data$weekearn[data$gender==1])
menearnavg
#######################################################
#Ready to do analysis#
#Research Questions#
#Do men earn more than women when controlling for age, industry, labor force status, marrital status#
#Are there interaction Effects between the industry women or men work in and the wages they get?#

#Get some Descriptives#
#Age#
summary(data$AGE)

#week earns#
summary(data$weekearn)

#Labor force status#
labortable<-table(data$labor)
labortable
#so it seems we wont need to worry about including that as a control lets pull it#


View(data)
#Educ#
eductable<-table(data$educ)
eductable

meductable<-table(data$educ[data$gender==1])
meductable

feductable<-table(data$educ[data$gender==0])
feductable
#industry#
industrytable<- table(data$industry)
industrytable

#gender#
gendertable <- table(data$gender)
gendertable


########## start some correlations#####
library()
library("Hmisc")
library("corrplot")

corrplot(data,method = 'circle')
cor2 <- rcorr(as.matrix(data))
cor2
cortable<-cor(data)
cortable

####Make a model and then we can test for assumptions##
############################################################
#Test linearity between age and weekly earnings#
library(ggplot2)

ggplot(data, aes(x = AGE, y = weekearn)) +  geom_point(size = 0.5) +  xlab("Age") +  ylab("Weekly Earnings") +  ggtitle("Linear Relationship of Age and Weekly Earnings") + geom_smooth(method = "loess", color = "blue", size = 1) + geom_smooth(method = "lm", color = "red", size = 1)
#Wow I have never seen such a quadratic relationship in my whole Life#
#square it#
data$AGE2 <- (data$AGE **2)
ggplot(data, aes(x = AGE2, y = weekearn)) +  geom_point(size = 0.5) +  xlab("Age") +  ylab("Weekly Earnings") +  ggtitle("Linear Relationship of Age Squared and Weekly Earnings") + geom_smooth(method = "loess", color = "blue", size = 1) + geom_smooth(method = "lm", color = "red", size = 1)
###################################################################################
#Lets make a base model now and see whats going on here#

model_base <- lm(weekearn ~ gender + AGE + AGE2 + degree + industry, data = data)

round(summary(model_base)$coeff, digits =4)
###########################################################################################
#check for homoscedasicity and normality of residuals#
#homoscedasicity#
model_base_res<- resid(model_base)
model_base_fitted_res<-fitted(model_base)
model_base_df <- data.frame(model_base_res, model_base_fitted_res)
plot(model_base_fitted_res,model_base_res, pch = 1, main = "Residuals Test for Homoscedasticisty", xlab = "Fitted Residuals", ylab = "Model Residuals")
abline(0, 0, col= "blue", lwd = 2) 
lines(lowess(model_base_res ~ model_base_fitted_res), col="red", lwd  = 2)  

#look at normality#
qqnorm(model_base_df$model_base_res, main="QQ-plot Residuals Corrected")
qqline(model_base_df$model_base_res, col = "red")



outliers<- na.omit(data[,c( 
  "industry",
  "degree", 
  "AGE",
  "gender",
  "weekearn",
  "AGE2")])



outliers$cd <- cooks.distance(model_base)
plot(outliers$cd,xlab="Index",ylab="cooks distance",pch=19,main = "Outlier Analysis")
abline(h=5/12804, col="red")

#yep lots of outliers so we omit them using cooks distance#



data2<-subset(outliers, cd <5/12804 )
View(data2)


#######################################################################
#make a new corrected model and see how it is different
#12488n#
model_corrected <- lm(weekearn ~ gender + AGE + AGE2 + degree + industry, data = data2)

#Model Corrected Results#
round(summary(model_corrected)$coeff, digits =4)


#now lets look at it all again#
#Residual Normality
model_c_res<- resid(model_corrected)
model_c_fitted_res<-fitted(model_corrected)
model_c_df <- data.frame(model_c_res, model_c_fitted_res)
plot(model_base_fitted_res,model_base_res, pch = 1, main = "Residuals Test for Homoscedasticisty", xlab = "Fitted Residuals", ylab = "Model Residuals")
abline(0, 0, col= "blue", lwd = 2) 
lines(lowess(model_c_res ~ model_c_fitted_res), col="red", lwd  = 2)

qqnorm(model_c_df$model_c_res, main="QQ-plot Residuals Corrected")
qqline(model_c_df$model_c_res, col = "red")



####build an interaction effects model
data2$maleindus <- data2$gender * data2$industry
model_inter <- lm(weekearn ~ gender + industry + AGE + AGE2 + degree +  maleindus, data = data2)
###Interaction Effeccts Model Results
round(summary(model_inter)$coeff, digits =4)

##################################################
summary(data$weekearn)

degreetble <- table(data2$degree)

degreetble

##Descriptives for final dataset##

womenage <- summary(data2$AGE[data2$gender=='0'])
womenage

summary(data$weekearn[data$gender == '0'])

industable <- table(data2$industry[data2$gender=='1'])
industable
#########################################################################################

