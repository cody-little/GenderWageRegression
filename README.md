# GenderWageRegression
Repository for Gender Wage Regression Project


## Sumarry
This project was completed during my master's degree at the University of Pennsylvania for a course called Applied Linear Modelling. I use publicly available data to build a mediation effects regression model that details the effects of gender and wages. While controlling for other variables I show there is a statistically significant mediation effect where males working in high paying industries such as finance and technology earn more while controlling for education and age.

### Research Question


### Walkthrough

- Data cleaning and set up
- Base model creation and assumption corrections
- Mediation effect model creation 
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

Once all of the variables were cleaned I looked at some exploratory analysis through tables, charts, and a correlation plot to better understand the data set. I then subsetted the dataset by male and female to better understand the descriptives related to the research question. 