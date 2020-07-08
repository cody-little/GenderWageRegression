# GenderWageInteractionEffectRegression
Repository for Gender Wage Interaction Effect Regression Project


## Summary
This was a project I designed and completed during my master's degree at the University of Pennsylvania for a course called Applied Linear Modelling. I use publicly available data to build an interaction effects multivariate regression model that details the effects of gender on weekly wages. While controlling for other variables I show there is a statistically significant interaction effect where males working in high paying industries such as finance and technology earn more than women while controlling for education and age.

### Research Question
Are men's weekly earning's higher than women when controlling for some wage influencing variables such as; age, working in a high paying industry, and education? If so, is there an interaction effect between being male and working in the high paying industries?

### Walkthrough

- Data cleaning and set up
- Base model creation and assumption corrections
- Interaction effect model creation 
- Results


### Data cleaning and set up

*Data cleaning*

The dataset for this project was the Annual Social and Economic Supplement Survey to the Current Population Survey (ASEC0 gathered from the Bureau of Labor Statistics website 
found at https://www.census.gov/programs-surveys/saipe/guidance/model-input-data/cpsasec.html. The data set was very large and dirty, along with this it came in the original form of a .dat file. I uploaded the .dat file into excel, and used it to transfer it into a csv file to make it more manageable. Then I used the codebook found on the ASEC source website to decide which columns would help answer my research question or were useful as control variables. I renamed the columns and left the original values from the ASEC within them to later change in R.

Once this was done I loaded the csv into R studio and began using R syntax to clean up the data and make my control variables/variables of interest. The ASEC used different values for sectors respondents worked in and their labor force status so I had to clean those up manually with syntax like the example below.

```
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
```

Once all of the variables were cleaned I looked at some exploratory analysis through tables, charts, and a correlation plot to better understand the data set. I then subsetted the dataset by male and female to better understand the descriptives related to the research question. After further exploration I moved on to the statistical analysis for the project. 

### Base Model Creation and Assumption Corrections

The base model for this analysis is a multivariate linear regression. The goal is to understand the interaction effect of being male and working in the high paying industries I cleaned up in the first phase of the analysis. Below is the actual equation mapped out that I used and the regression table results. 

γ(weeklyearnings)= β_0+β_1 (Sex/Gender  is male)+ β_2 (Industry)+ β_3 (Degree)+ β_4 (Age)+  ε


*Linearity*

To check linearity I plotted the continuous variables to the weekly earning variable of interest using a scatter plot and a loess line. The age variable had a hard curved line, as expected when looking at wages. Early career professionals earn less, recieve raises over time. To correct the heavy parabolic curve I squared the variable and included this squared term in the assumption corrected model. Below is an image depicting the before and after plots. Once this was done I ran the above equation as the base model to get an idea of the statistical results.


![](https://github.com/cody-little/GenderWageRegression/blob/master/agecorrectedregress.PNG)

```
model_base <- lm(weekearn ~ gender + AGE + AGE2 + degree + industry, data = data)

round(summary(model_base)$coeff, digits =4)

             Estimate Std. Error  t value Pr(>|t|)
(Intercept) -967.6835    42.7905 -22.6144        0
gender       336.8392    10.4569  32.2122        0
AGE           69.2811     2.0618  33.6023        0
AGE2          -0.6987     0.0231 -30.2766        0
degree       570.9451    10.9066  52.3487        0
industry     181.2786    13.3861  13.5423        0
```
All of the variables are statistically significant and we can see that the gender estimate indicates men earn about $336 dollars more per week on average when controlling for all other variables. We can also see the age squared estimate is helping to address that quadratic relationship mathematically corroborating the decision to add the squared term. The next step in this analysis is to see if the residuals from the model are normal, and if there is heteroscedasticity. To do this I used a Q-Q plot which plots two quantiles against eachother and then I added a linear best fit line to see what normal should be. The Q-Q plot did show that there was a lack of normalitity among residuals. To correct this I removed outliers from the data set using a cooks distance formula. 

```
outliers$cd <- cooks.distance(model_base)
plot(outliers$cd,xlab="Index",ylab="cooks distance",pch=19,main = "Outlier Analysis")
abline(h=5/12804, col="red")
data2<-subset(outliers, cd <5/12804 )
```

The cooks distance essentially shows the effect each observation has on a fitted value, which means we can identify outliers which throw off the residuals and lead to a more poor model fit. Calculating cooks distance in R is shown above. I used 5/12,804 because there are five variables in the model, and there are 12,804 observations in the data set. This gives a threshold that we can remove any observations lying above it. Below is a plot demonstrating how this looks conceptually using this data.

![](https://github.com/cody-little/GenderWageRegression/blob/master/outlieranalysis.png)

Below we can see how the method of cooks distance for outlier analysis can create a more robust normality among the residuals leading to a better model fit. By removing these observations we essentially remove the residuals which draw our line upwards towards the top end. 

![](https://github.com/cody-little/GenderWageRegression/blob/master/residualsnormality.PNG)

Now that the normality of residuals assumption is corrected I look at whether or not the errors are homoscedastic. This means that variance across the residuals is about the same. Using a plot of the residuals with a straight line and loess line gives us a quick way to check for this assumption. Below is the syntax and output for this plot that I used. There is very little deviation between the lines which means our assumption of homoscedasticity is okay and we can move forward. 

![](https://github.com/cody-little/GenderWageRegression/blob/master/homoscedcheckplot.png)

### Interaction Effects Model Creation

Now that the original model specifications have been adddressed by correcting any assumptions which were violated I moved on to create the mediation effects model. This equation is the same as the base model but includes an interaction term. The interaction term is the effect of being both male and working in the high paying industries. This interaction effect gives us the ability to calculate how much of the additional money men earn found in the base model can be attributed to the fact that they are males working in these high paying industries by using the model estimates. Below is an updated equation in both text and R syntax along with the regression table results.

γ(weeklyearnings)= β_0+β_1 (Sex/Gender  ismale)+ β_2 (Industry)+ β_3 (Degree)+ β_4 (Age)+β_5 Age(Squared)+β_6 (Male*Industry)+ ε

```
data2$maleindus <- data2$gender * data2$industry
model_inter <- lm(weekearn ~ gender + industry + AGE + AGE2 + degree +  maleindus, data = data2)
###Interaction Effeccts Model Results
round(summary(model_inter)$coeff, digits =4)
             Estimate Std. Error  t value Pr(>|t|)
(Intercept) -970.6975    38.4516 -25.2447        0
gender       333.0692    10.2066  32.6327        0
industry     109.7191    16.9874   6.4589        0
AGE           69.3792     1.8882  36.7440        0
AGE2          -0.7118     0.0215 -33.1614        0
degree       533.9085     9.7150  54.9573        0
maleindus    101.5245    23.8930   4.2491        0
```

### Results

The model results show that the interaction effect is statistically significant and has an estimate of about $101.5 dollars. This interaction effect helps us to understand how much of that additional weekly income in the gender variable estimate can be attributed to being both male and in a high paying industry. When gender is a male a respondent to the ASEC can expect to earn that additional amount if they work in a high paying industry compared to a female. Given this analysis we can confidently answer our research question. Yes, men earn more than women when controlling for variables such as education, age, and working in a high paying industry, and also Yes there is an additional interaction effect for the relationship of being male and working in a high paying industry leading to an increased gender wage gap amond the ASEC respondents.
