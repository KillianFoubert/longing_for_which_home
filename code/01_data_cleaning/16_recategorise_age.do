********************************************************************************
* 16 - Age Recategorisation
* Bekaert, Constant, Foubert & Ruyssen (2024) - JEBO
********************************************************************************
*
* Purpose: Recategorises age into groups used in the empirical analysis (18-34, 35-49, 50-64, 65-75).
*
* Input:   GWP age variable
*
* Output:  Age group dummies
*
* Note: These scripts were developed as part of a collaborative research workflow
* among co-authors over several years. Internal annotations, commented-out file
* paths, and exploratory code blocks reflect this iterative process and have been
* preserved for transparency and reproducibility.
********************************************************************************

// ----------------------------------------
// DATA TRANSFORMATIONS 
// ----------------------------------------
clear all
cd "/Users/elsbekaert/Dropbox/Return Migration/" // Els 
use "Database representativeness DIOC/Return database.dta"  // Els 

*** New categorisation age *** 
* FILE 1 
gen age014 = 0
gen age1524 = 0
gen age2534 = 0
gen age3544 = 0
gen age4554 = 0
gen age5564 = 0
gen age65plus = 0

replace age014 = 1 if age<15
replace age1524 = 1 if age>=15 & age<25
replace age2534 = 1 if age>=25 & age<35
replace age3544 = 1 if age>=35 & age<45
replace age4554 = 1 if age>=45 & age<55
replace age5564 = 1 if age>=55 & age<65
replace age65plus = 1 if age>=65

label var age014 "aged 0 to 14"
label var age1524 "aged 15 to 24"
label var age2534 "aged 25 to 34"
label var age3544 "aged 35 to 44"
label var age4554 "aged 45 to 54"
label var age5564 "aged 55 to 64"
label var age65plus "aged 65+"


* FILE 2 
gen age1524_file2 = 0
gen age2564_file2 = 0
gen age65plus_file2 = 0

replace age1524_file2 = 1 if age>=15 & age<25
replace age2564_file2 = 1 if age>=25 & age<65
replace age65plus_file2 = 1 if age>=65

label var age1524_file2 "aged 15 to 24"
label var age2564_file2 "aged 25 to 64"
label var age65plus_file2 "aged65plus"


save "Database representativeness DIOC/Return database Gallup for representativeness.dta", replace


*****************************************************************************************************************
*** Matching countries DIOC - Gallup 
*****************************************************************************************************************
* Select countries both current and birth in Gallup 
clear all
cd "/Users/elsbekaert/Dropbox/Return Migration/Database representativeness DIOC/" // Els 
use "Return database Gallup for representativeness.dta", clear 
*current
preserve
	keep iso3_cntrycurrent
	rename iso3_cntrycurrent country
	duplicates drop
	save "Temp/Countries_current_Gallup.dta", replace
restore 
*birth
preserve
	keep iso3_cntrybirth
	rename iso3_cntrybirth coub
	duplicates drop
	save "Temp/Countries_birth_Gallup.dta",replace
restore 

* Select countries in DIOC-Age 
use "DIOCage.dta", clear 
* current
preserve
	keep country 
	duplicates drop
	replace country = "ARM" if country=="USSR-ARM"
	replace country = "BLR" if country=="USSR-BLR" 
	replace country = "KAZ" if country == "USSR-KAZ"
	replace country = "TJK" if country == "USSR-TJK"
	replace country = "HRV" if country == "FYUG-HRV"
	save "Temp/Countries_residence_DIOC_age.dta",replace
restore 
*birth 
preserve
	keep coub 
	duplicates drop
	replace coub = "ARM" if coub=="USSR-ARM"
	replace coub = "AZE" if coub=="USSR-AZE" 
	replace coub = "BLR" if coub=="USSR-BLR" 
	replace coub = "GEO" if coub=="USSR-GEO" 
	replace coub = "KAZ" if coub == "USSR-KAZ"
	replace coub = "KGZ" if coub == "USSR-KGZ"
	replace coub = "MDA" if coub == "USSR-MDA"
	replace coub = "TJK" if coub == "USSR-TJK"
	replace coub = "TKM" if coub == "USSR-TKM"
	replace coub = "UKR" if coub == "USSR-UKR"
	replace coub = "UZB" if coub == "USSR-UZB"
	replace coub = "BIH" if coub == "FYUG-BIH"
	replace coub = "HRV" if coub == "FYUG-HRV"
	replace coub = "MKD" if coub == "FYUG-MKD"
	replace coub = "MNE" if coub == "FYUG-MNE"
	replace coub = "SRB" if coub == "FYUG-SRB"
	replace coub = "KOR" if coub == "KOREA-SO"
	replace coub = "PRK" if coub == "KOREA-NO"
	save "Temp/Countries_birth_DIOC_age.dta",replace
restore 

* Select countries in DIOC-Labour 
use "DIOClabour.dta", clear 
* current
preserve
	keep country 
	duplicates drop
	replace country = "ARM" if country=="USSR-ARM"
	replace country = "BLR" if country=="USSR-BLR" 
	replace country = "TJK" if country == "USSR-TJK"
	replace country = "HRV" if country == "FYUG-HRV"
	save "Temp/Countries_residence_DIOC_labour.dta",replace
restore 
*birth 
preserve
	keep coub 
	duplicates drop
	replace coub = "ARM" if coub=="USSR-ARM"
	replace coub = "AZE" if coub=="USSR-AZE" 
	replace coub = "BLR" if coub=="USSR-BLR" 
	replace coub = "GEO" if coub=="USSR-GEO" 
	replace coub = "KAZ" if coub == "USSR-KAZ"
	replace coub = "KGZ" if coub == "USSR-KGZ"
	replace coub = "MDA" if coub == "USSR-MDA"
	replace coub = "TJK" if coub == "USSR-TJK"
	replace coub = "TKM" if coub == "USSR-TKM"
	replace coub = "UKR" if coub == "USSR-UKR"
	replace coub = "UZB" if coub == "USSR-UZB"
	replace coub = "BIH" if coub == "FYUG-BIH"
	replace coub = "HRV" if coub == "FYUG-HRV"
	replace coub = "MKD" if coub == "FYUG-MKD"
	replace coub = "MNE" if coub == "FYUG-MNE"
	replace coub = "SRB" if coub == "FYUG-SRB"
	replace coub = "KOR" if coub == "KOREA-SO"
	replace coub = "PRK" if coub == "KOREA-NO"
	save "Temp/Countries_birth_DIOC_labour.dta",replace
restore 

** SELECT OVERLAPPING COUNTRIES FROM 3 DATABASES: 
* GALLUP - DIOC AGE - DIOC LABOUR 
use "Return database Gallup for representativeness.dta", clear 
gen country = iso3_cntrycurrent 
gen coub = iso3_cntrybirth
merge m:1 country using "Temp/Countries_residence_DIOC_age.dta", keep(match) nogen
merge m:1 coub using "Temp/Countries_birth_DIOC_age.dta", keep(match) nogen
merge m:1 country using "Temp/Countries_residence_DIOC_labour.dta", keep(match master) nogen 
merge m:1 coub using "Temp/Countries_birth_DIOC_labour.dta", keep(match master) nogen 
save "Temp/Gallup matched DIOC Age en Labour.dta",replace

summarize male age1524 age2534 age3544 age4554 age5564 age65plus age1524_file2 age2564_file2 age65plus_file2 hskill empl
sutex male age1524 age2534 age3544 age4554 age5564 age65plus age1524_file2 age2564_file2 age65plus_file2 hskill empl, long lab par nobs minmax

/*
%------- Begin LaTeX code -------%
\begin{center}
\begin{longtable}{l c c c c c}
\caption{Summary statistics \label{sumstat}}\\
\hline\hline\multicolumn{1}{c}{\textbf{Variable}}
 &\textbf{Mean}
 & \textbf{(Std. Dev.)}& \textbf{Min.} &  \textbf{Max.} & \textbf{N} \\ \hline
\endfirsthead
\multicolumn{6}{l}{\emph{... table \thetable{} continued}}
\\ \hline\hline\multicolumn{1}{c}{\textbf{Variable}}
 & \textbf{Mean}
 & \textbf{(Std. Dev.)}& \textbf{Min.} &  \textbf{Max.} & \textbf{N} \\ \hline
\endhead
\hline
\multicolumn{6}{r}{\emph{Continued on next page...}}\\
\endfoot
\endlastfoot
male & 0.435 & (0.496) & 0 & 1 & 25015\\
aged 15 to 24 & 0.11 & (0.313) & 0 & 1 & 25015\\
aged 25 to 34 & 0.169 & (0.374) & 0 & 1 & 25015\\
aged 35 to 44 & 0.179 & (0.383) & 0 & 1 & 25015\\
aged 45 to 54 & 0.169 & (0.375) & 0 & 1 & 25015\\
aged 55 to 64 & 0.157 & (0.364) & 0 & 1 & 25015\\
aged 65+ & 0.216 & (0.411) & 0 & 1 & 25015\\
aged 15 to 24 & 0.11 & (0.313) & 0 & 1 & 25015\\
aged 25 to 64 & 0.674 & (0.469) & 0 & 1 & 25015\\
aged65plus & 0.216 & (0.411) & 0 & 1 & 25015\\
tert educ & 0.306 & (0.461) & 0 & 1 & 24811\\
Employment dummy=1 if employed (working), 0 otherwise & 0.561 & (0.496) & 0 & 1 & 24606\\
\hline
\end{longtable}
\end{center}
%------- End LaTeX code -------%
*/ 


* GALLUP - DIOC AGE 
use "Return database Gallup for representativeness.dta", clear 
gen country = iso3_cntrycurrent 
gen coub = iso3_cntrybirth
merge m:1 country using "Temp/Countries_residence_DIOC_age.dta", keep(match) nogen
merge m:1 coub using "Temp/Countries_birth_DIOC_age.dta", keep(match) nogen
save "Temp/Gallup matched DIOC Age",replace

summarize male age1524 age2534 age3544 age4554 age5564 age65plus hskill empl
sutex male age1524 age2534 age3544 age4554 age5564 age65plus hskill empl, long lab par nobs minmax

/* 
\begin{center}
\begin{longtable}{l c c c c c}
\caption{Summary statistics \label{sumstat}}\\
\hline\hline\multicolumn{1}{c}{\textbf{Variable}}
 &\textbf{Mean}
 & \textbf{(Std. Dev.)}& \textbf{Min.} &  \textbf{Max.} & \textbf{N} \\ \hline
\endfirsthead
\multicolumn{6}{l}{\emph{... table \thetable{} continued}}
\\ \hline\hline\multicolumn{1}{c}{\textbf{Variable}}
 & \textbf{Mean}
 & \textbf{(Std. Dev.)}& \textbf{Min.} &  \textbf{Max.} & \textbf{N} \\ \hline
\endhead
\hline
\multicolumn{6}{r}{\emph{Continued on next page...}}\\
\endfoot
\endlastfoot
male & 0.435 & (0.496) & 0 & 1 & 25015\\
aged 15 to 24 & 0.11 & (0.313) & 0 & 1 & 25015\\
aged 25 to 34 & 0.169 & (0.374) & 0 & 1 & 25015\\
aged 35 to 44 & 0.179 & (0.383) & 0 & 1 & 25015\\
aged 45 to 54 & 0.169 & (0.375) & 0 & 1 & 25015\\
aged 55 to 64 & 0.157 & (0.364) & 0 & 1 & 25015\\
aged 65+ & 0.216 & (0.411) & 0 & 1 & 25015\\
tert educ & 0.306 & (0.461) & 0 & 1 & 24811\\
Employment dummy=1 if employed (working), 0 otherwise & 0.561 & (0.496) & 0 & 1 & 24606\\
\hline
\end{longtable}
\end{center}
*/ 

* GALLUP - DIOC LABOUR 
use "Return database Gallup for representativeness.dta", clear 
gen country = iso3_cntrycurrent 
gen coub = iso3_cntrybirth
merge m:1 country using "Temp/Countries_residence_DIOC_labour.dta", keep(match) nogen
merge m:1 coub using "Temp/Countries_birth_DIOC_labour.dta", keep(match) nogen
save "Temp/Gallup matched DIOC labour",replace

summarize male age1524_file2 age2564_file2 age65plus_file2 hskill empl
sutex male age1524_file2 age2564_file2 age65plus_file2 hskill empl, long lab par nobs minmax

/*
\begin{center}
\begin{longtable}{l c c c c c}
\caption{Summary statistics \label{sumstat}}\\
\hline\hline\multicolumn{1}{c}{\textbf{Variable}}
 &\textbf{Mean}
 & \textbf{(Std. Dev.)}& \textbf{Min.} &  \textbf{Max.} & \textbf{N} \\ \hline
\endfirsthead
\multicolumn{6}{l}{\emph{... table \thetable{} continued}}
\\ \hline\hline\multicolumn{1}{c}{\textbf{Variable}}
 & \textbf{Mean}
 & \textbf{(Std. Dev.)}& \textbf{Min.} &  \textbf{Max.} & \textbf{N} \\ \hline
\endhead
\hline
\multicolumn{6}{r}{\emph{Continued on next page...}}\\
\endfoot
\endlastfoot
male & 0.437 & (0.496) & 0 & 1 & 24323\\
aged 15 to 24 & 0.111 & (0.314) & 0 & 1 & 24323\\
aged 25 to 64 & 0.676 & (0.468) & 0 & 1 & 24323\\
aged65plus & 0.213 & (0.41) & 0 & 1 & 24323\\
tert educ & 0.308 & (0.462) & 0 & 1 & 24125\\
Employment dummy=1 if employed (working), 0 otherwise & 0.561 & (0.496) & 0 & 1 & 23914\\
\hline
\end{longtable}
\end{center}
*/ 

*** COVER PERIODS: 2010 - 2011 
use "Temp/Gallup matched DIOC Age en Labour.dta"  // Els 
drop if year==2012 // 3,554 observations deleted
drop if year==2013 // 3,023 observations deleted)
drop if year==2014  // 1,872 observations deleted
drop if year==2015 // 3,938 observations deleted
drop if year==2016 // 4,686 observations deleted
drop if year==2009 // 1,651 observations deleted


summarize male age1524 age2534 age3544 age4554 age5564 age65plus age1524_file2 age2564_file2 age65plus_file2 hskill empl
sutex male age1524 age2534 age3544 age4554 age5564 age65plus age1524_file2 age2564_file2 age65plus_file2 hskill empl, long lab par nobs minmax

/*
%------- Begin LaTeX code -------%

\begin{center}
\begin{longtable}{l c c c c c}
\caption{Summary statistics \label{sumstat}}\\
\hline\hline\multicolumn{1}{c}{\textbf{Variable}}
 &\textbf{Mean}
 & \textbf{(Std. Dev.)}& \textbf{Min.} &  \textbf{Max.} & \textbf{N} \\ \hline
\endfirsthead
\multicolumn{6}{l}{\emph{... table \thetable{} continued}}
\\ \hline\hline\multicolumn{1}{c}{\textbf{Variable}}
 & \textbf{Mean}
 & \textbf{(Std. Dev.)}& \textbf{Min.} &  \textbf{Max.} & \textbf{N} \\ \hline
\endhead
\hline
\multicolumn{6}{r}{\emph{Continued on next page...}}\\
\endfoot
\endlastfoot
male & 0.403 & (0.49) & 0 & 1 & 6291\\
aged 15 to 24 & 0.107 & (0.31) & 0 & 1 & 6291\\
aged 25 to 34 & 0.165 & (0.371) & 0 & 1 & 6291\\
aged 35 to 44 & 0.181 & (0.385) & 0 & 1 & 6291\\
aged 45 to 54 & 0.177 & (0.382) & 0 & 1 & 6291\\
aged 55 to 64 & 0.168 & (0.374) & 0 & 1 & 6291\\
aged 65+ & 0.202 & (0.401) & 0 & 1 & 6291\\
aged 15 to 24 & 0.107 & (0.31) & 0 & 1 & 6291\\
aged 25 to 64 & 0.691 & (0.462) & 0 & 1 & 6291\\
aged65plus & 0.202 & (0.401) & 0 & 1 & 6291\\
tert educ & 0.311 & (0.463) & 0 & 1 & 6228\\
Employment dummy=1 if employed (working), 0 otherwise & 0.557 & (0.497) & 0 & 1 & 6280\\
\hline
\end{longtable}
\end{center}
%------- End LaTeX code -------%
*/ 


** OECD vs non-OECD 
use "Temp/Gallup matched DIOC Age en Labour.dta",clear
gen OECD=cntrycurrent
foreach k in OECD {
replace `k'="OECD" if `k'=="Australia" || `k'=="Austria" || `k'=="Belgium"|| `k'=="Canada"|| `k'=="Chile" || ///
`k'=="Czech Republic"|| `k'=="Denmark" || `k'=="Estonia" || `k'=="Spain" || `k'=="Finland" ||  `k'=="France" || ///
`k'=="Germany" || `k'=="Greece" || `k'=="Hungary" || `k'=="Iceland" || `k'=="Ireland" || `k'=="Israel" ||  ///
`k'=="Italy" || `k'=="Japan" ||  `k'=="Luxembourg" || `k'=="Mexico" ||`k'=="Netherlands" || ///
`k'=="New Zealand" || `k'=="Norway" || `k'=="Poland" || `k'=="Portugal" || `k'=="Slovenia" || ///
`k'=="Sweden" || `k'=="Switzerland" || `k'=="Turkey" || `k'=="United Kingdom" || `k'=="United States"

replace `k'="non-OECD" if `k' !="OECD"
}

summarize male age1524 age2534 age3544 age4554 age5564 age65plus age1524_file2 age2564_file2 age65plus_file2 hskill empl if OECD=="OECD"
sutex male age1524 age2534 age3544 age4554 age5564 age65plus age1524_file2 age2564_file2 age65plus_file2 hskill empl if OECD=="OECD", long lab par nobs minmax
/*
\begin{center}
\begin{longtable}{l c c c c c}
\caption{Summary statistics \label{sumstat}}\\
\hline\hline\multicolumn{1}{c}{\textbf{Variable}}
 &\textbf{Mean}
 & \textbf{(Std. Dev.)}& \textbf{Min.} &  \textbf{Max.} & \textbf{N} \\ \hline
\endfirsthead
\multicolumn{6}{l}{\emph{... table \thetable{} continued}}
\\ \hline\hline\multicolumn{1}{c}{\textbf{Variable}}
 & \textbf{Mean}
 & \textbf{(Std. Dev.)}& \textbf{Min.} &  \textbf{Max.} & \textbf{N} \\ \hline
\endhead
\hline
\multicolumn{6}{r}{\emph{Continued on next page...}}\\
\endfoot
\endlastfoot
male & 0.439 & (0.496) & 0 & 1 & 15251\\
aged 15 to 24 & 0.088 & (0.283) & 0 & 1 & 15251\\
aged 25 to 34 & 0.152 & (0.359) & 0 & 1 & 15251\\
aged 35 to 44 & 0.188 & (0.391) & 0 & 1 & 15251\\
aged 45 to 54 & 0.184 & (0.387) & 0 & 1 & 15251\\
aged 55 to 64 & 0.168 & (0.374) & 0 & 1 & 15251\\
aged 65+ & 0.22 & (0.414) & 0 & 1 & 15251\\
aged 15 to 24 & 0.088 & (0.283) & 0 & 1 & 15251\\
aged 25 to 64 & 0.692 & (0.462) & 0 & 1 & 15251\\
aged65plus & 0.22 & (0.414) & 0 & 1 & 15251\\
tert educ & 0.359 & (0.48) & 0 & 1 & 15101\\
Employment dummy=1 if employed (working), 0 otherwise & 0.582 & (0.493) & 0 & 1 & 14897\\
\hline
\end{longtable}
\end{center}

*/ 
summarize male age1524 age2534 age3544 age4554 age5564 age65plus age1524_file2 age2564_file2 age65plus_file2 hskill empl if OECD=="non-OECD"
sutex male age1524 age2534 age3544 age4554 age5564 age65plus age1524_file2 age2564_file2 age65plus_file2 hskill empl if OECD=="non-OECD", long lab par nobs minmax 
/*
\begin{center}
\begin{longtable}{l c c c c c}
\caption{Summary statistics \label{sumstat}}\\
\hline\hline\multicolumn{1}{c}{\textbf{Variable}}
 &\textbf{Mean}
 & \textbf{(Std. Dev.)}& \textbf{Min.} &  \textbf{Max.} & \textbf{N} \\ \hline
\endfirsthead
\multicolumn{6}{l}{\emph{... table \thetable{} continued}}
\\ \hline\hline\multicolumn{1}{c}{\textbf{Variable}}
 & \textbf{Mean}
 & \textbf{(Std. Dev.)}& \textbf{Min.} &  \textbf{Max.} & \textbf{N} \\ \hline
\endhead
\hline
\multicolumn{6}{r}{\emph{Continued on next page...}}\\
\endfoot
\endlastfoot
male & 0.429 & (0.495) & 0 & 1 & 9764\\
aged 15 to 24 & 0.145 & (0.352) & 0 & 1 & 9764\\
aged 25 to 34 & 0.195 & (0.396) & 0 & 1 & 9764\\
aged 35 to 44 & 0.165 & (0.371) & 0 & 1 & 9764\\
aged 45 to 54 & 0.146 & (0.353) & 0 & 1 & 9764\\
aged 55 to 64 & 0.14 & (0.347) & 0 & 1 & 9764\\
aged 65+ & 0.209 & (0.407) & 0 & 1 & 9764\\
aged 15 to 24 & 0.145 & (0.352) & 0 & 1 & 9764\\
aged 25 to 64 & 0.645 & (0.478) & 0 & 1 & 9764\\
aged65plus & 0.209 & (0.407) & 0 & 1 & 9764\\
tert educ & 0.223 & (0.416) & 0 & 1 & 9710\\
Employment dummy=1 if employed (working), 0 otherwise & 0.528 & (0.499) & 0 & 1 & 9709\\
\hline
\end{longtable}
\end{center}

*/ 

