use "Z:\Downloads\CLOUDAPP FILES\project\EmployeeStatus.dta", clear

// check EmployeeStatus
tab personid
codebook personid

// merge EmployeeStatus and EmployeeCharacteristics data sets
merge 1:1 personid using EmployeeCharacteristics
drop _merge

// data cleaning for EmployeeCharacteristics

// Checking variables for abnormal data

// create missing value for age that was found to be -99
summarize age
tab age
replace age = . if age == -99
summarize basewage
summarize bonus
summarize costofcommute
summarize grosswage
summarize high_school
// create missing variable for experience years that was found to be -99
summarize prior_experience
tab prior_experience
replace prior_experience = . if prior_experience == -99
summarize male
summarize married
summarize rental
// create missing value for tenure that was found to be -99
summarize tenure
tab tenure
replace tenure = . if tenure == -99

// Saving cleaned dataset
save "Z:\Downloads\CLOUDAPP FILES\project\EmployeeStatusxCharacteristics.dta"


// Data cleaning for attitudes
// Checking other variables for abnormal data
//tab general
//tab life
//tab satisfaction
// Save clean and merged dataset
//save "Z:\Downloads\CLOUDAPP FILES\project\EmployeexStatusxCharacteristicsxAttitudes.dta" 
// attitudes omitted in final analysis


// Data cleaning for performance 
use "Z:\Downloads\CLOUDAPP FILES\project\EmployeeStatusxCharacteristics.dta" , clear
merge 1:m personid using Performance_Panel
drop _merge

// Designate missing values for invalid values
summarize calls_per_hour
list if calls_per_hour > 100 & calls_per_hour < 201
replace calls_per_hour = . if calls_per_hour > 100
summarize performance_score
list if performance_score == 1000
replace performance_score = . if performance_score > 100
summarize total_monthly_calls
list if performance_score == 1000
replace total_monthly_calls = . if total_monthly_calls < 0

// Save clean data as new dataset
save "Z:\Downloads\CLOUDAPP FILES\project\EmployeexStatusxCharacteristicsxPerformancePanel.dta"





// Creating table for Figure 1, comparing control and treatment group for parallel trends assumption in DID analysis
ssc install ietoolkit

iebaltab performance_score total_monthly_calls calls_per_hour if post == 0, grpvar("treatment") savexlsx ("Z:\Downloads\CLOUDAPP FILES\project\PanelBalanceie.xlsx") rowvarlabels rowlabels("performance_score Average performance evaluations @ total_monthly_calls Monthly Calls Total @ calls_per_hour Average Calls per Hour")

// Creating DID analysis of treatment and control 
generate postxtreatment = treatment*post
regress performance_score post treatment postxtreatment, cluster(personid)
ssc install estout
eststo clear
eststo: reg performance_score post treatment postxtreatment, cluster(personid)
esttab using "Z:\Downloads\CLOUDAPP FILES\project\EmployeeStatusxCharacteristicsxPerformanceScore.rtf"



// Cleaning data for quitting data
use "Z:\Downloads\CLOUDAPP FILES\project\EmployeeStatusxCharacteristics.dta" , clear
merge 1:1 personid using Quits
drop _merge
summarize quitjob
save "Z:\Downloads\CLOUDAPP FILES\project\EmployeeStatusxCharacteristicsxQuits.dta"


// Graph for quitting data by whether or not they were in the treatment group
histogram quitjob, by(treatment) discrete percent   

// Regressing for quitting dataset
summarize quitjob if treatment == 1
summarize quitjob if treatment == 0
summarize age if treatment == 1
summarize age if treatment == 0
summarize basewage if treatment == 1
summarize basewage if treatment == 0
summarize grosswage if treatment == 1
summarize grosswage if treatment == 0
summarize bonus if treatment == 1
summarize bonus if treatment == 0
tab quitjob if treatment == 1
tab quitjob if treatment == 0

regress quitjob treatment rental costofcommute basewage prior_experience tenure
eststo clear
eststo: regress quitjob treatment rental costofcommute basewage prior_experience tenure
esttab using "Z:\Downloads\CLOUDAPP FILES\project\JobQuittingRegression.rtf"



