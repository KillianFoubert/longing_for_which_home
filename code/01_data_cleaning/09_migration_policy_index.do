********************************************************************************
* 09 - Migration Policy Index
* Bekaert, Constant, Foubert & Ruyssen (2024) - JEBO
********************************************************************************
*
* Purpose: Cleans migration policy restrictiveness indicators for host countries.
*
* Input:   IMPIC data
*
* Output:  Migration Policy Index.dta
*
* Note: These scripts were developed as part of a collaborative research workflow
* among co-authors over several years. Internal annotations, commented-out file
* paths, and exploratory code blocks reflect this iterative process and have been
* preserved for transparency and reproducibility.
********************************************************************************

cls 
clear all 
set more off 
set scrollbufsize 500000 
set maxvar 10000
graph drop _all 
capture log close 
set matsize 11000

cd "C:\Users\kifouber\Dropbox\Return Migration\Data\Trust\"

use "old\dta\WVS_Longitudinal_1981_2014_stata_v2015.dta", clear

keep S002 S003 A165

decode S002, gen(string_version_S002)
drop S002
rename string_version_S002 year

decode S003, gen(string_version_S003)
drop S003
rename string_version_S003 origin

decode A165, gen(string_version_A165)
replace string_version_A165="0" if string_version_A165=="Can´t be too careful"
replace string_version_A165="1" if string_version_A165=="Most people can be trusted"
replace string_version_A165="999" if string_version_A165=="Don´t know"
replace string_version_A165="999" if string_version_A165=="No answer"
replace string_version_A165="999" if string_version_A165=="Missing; Unknown"
replace string_version_A165="999" if string_version_A165=="Not asked in survey"
destring string_version_A165, gen(corrected_A165)
drop string_version_A165
des corrected_A165
summ corrected_A165
replace corrected_A165=. if corrected_A165==999
rename corrected_A165 Trust
drop A165
egen Trust_avg=mean(Trust), by(origin year)
label variable Trust_avg "Average A165 by origin wave: most people can be trusted"
drop Trust

drop if year=="1999-2004" | year=="1994-1998" | year=="1989-1993" | year=="1981-1984"
duplicates drop 

preserve
keep if year=="2005-2009"
replace year="2006"
save "old\dta\2006.dta", replace
restore

preserve
keep if year=="2005-2009"
replace year="2007"
save "old\dta\2007.dta", replace
restore

preserve
keep if year=="2005-2009"
replace year="2008"
save "old\dta\2008.dta", replace
restore

preserve
keep if year=="2005-2009"
replace year="2009"
save "old\dta\2009.dta", replace
restore

preserve
keep if year=="2010-2014"
replace year="2010"
save "old\dta\2010.dta", replace
restore

preserve
keep if year=="2010-2014"
replace year="2011"
save "old\dta\2011.dta", replace
restore

preserve
keep if year=="2010-2014"
replace year="2012"
save "old\dta\2012.dta", replace
restore

preserve
keep if year=="2010-2014"
replace year="2013"
save "old\dta\2013.dta", replace
restore

preserve
keep if year=="2010-2014"
replace year="2014"
save "old\dta\2014.dta", replace
restore

***

clear
cls 
clear all 
set more off 
set scrollbufsize 500000 
set maxvar 10000
graph drop _all 
capture log close 
set matsize 11000

cd "C:\Users\kifouber\Dropbox\Return Migration\Data\Trust\old\dta"
use "2006.dta", clear

append using "C:\Users\kifouber\Dropbox\Return Migration\Data\Trust\old\dta\2007.dta"
append using "C:\Users\kifouber\Dropbox\Return Migration\Data\Trust\old\dta\2008.dta"
append using "C:\Users\kifouber\Dropbox\Return Migration\Data\Trust\old\dta\2009.dta"
append using "C:\Users\kifouber\Dropbox\Return Migration\Data\Trust\old\dta\2010.dta"
append using "C:\Users\kifouber\Dropbox\Return Migration\Data\Trust\old\dta\2011.dta"
append using "C:\Users\kifouber\Dropbox\Return Migration\Data\Trust\old\dta\2012.dta"
append using "C:\Users\kifouber\Dropbox\Return Migration\Data\Trust\old\dta\2013.dta"
append using "C:\Users\kifouber\Dropbox\Return Migration\Data\Trust\old\dta\2014.dta"

destring year, replace

sort year
by year: egen Trust_p10 = pctile(Trust_avg), p(10)
by year: egen Trust_p25 = pctile(Trust_avg), p(25)
by year: egen Trust_p50 = pctile(Trust_avg), p(50)
by year: egen Trust_p75 = pctile(Trust_avg), p(75)
by year: egen Trust_p90 = pctile(Trust_avg), p(90)

replace year=year+1

replace origin="United Kingdom" if origin=="Great Britain"
replace origin="Palestina" if origin=="Palestine"
replace origin="Vietnam" if origin=="Viet Nam"

merge m:1 origin using "C:\Users\kifouber\Dropbox\Return Migration\Data\iso3 codes\Clean\iso3clean.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           181
        from master                         4  (_merge==1)
        from using                        177  (_merge==2)

    matched                               528  (_merge==3)
    -----------------------------------------
*/

expand 2 if origin=="Serbia and Montenegro"
gen n=_n
replace origin="Serbia" if origin=="Serbia and Montenegro" & n>=710
replace origin="Montenegro" if origin=="Serbia and Montenegro"
replace iso3="SRB" if origin=="Serbia"
replace iso3="MNE" if origin=="Montenegro"
drop n

drop if _merge==2
drop _merge

save "C:\Users\kifouber\Dropbox\Return Migration\Data\Trust\clean\dta\Trust cleaned.dta", replace

* Current country

rename * *_cntrycurrent
rename year_cntrycurrent year
rename origin_cntrycurrent cntrycurrent
rename iso3o_cntrycurrent iso3_cntrycurrent

save "C:\Users\kifouber\Dropbox\Return Migration\Data\Trust\clean\dta\Trust cleaned - cntrycurrent.dta", replace

* Birth country

rename cntrycurrent cntrybirth
rename Trust_avg_cntrycurrent Trust_avg_cntrybirth
rename Trust_p10_cntrycurrent Trust_p10_cntrybirth
rename Trust_p25_cntrycurrent Trust_p25_cntrybirth
rename Trust_p50_cntrycurrent Trust_p50_cntrybirth
rename Trust_p75_cntrycurrent Trust_p75_cntrybirth
rename Trust_p90_cntrycurrent Trust_p90_cntrybirth
rename iso3_cntrycurrent iso3_cntrybirth

save "C:\Users\kifouber\Dropbox\Return Migration\Data\Trust\clean\dta\Trust cleaned - cntrybirth.dta", replace

* Dest country

rename cntrybirth dest
rename Trust_avg_cntrybirth Trust_avg_dest
rename Trust_p10_cntrybirth Trust_p10_dest
rename Trust_p25_cntrybirth Trust_p25_dest
rename Trust_p50_cntrybirth Trust_p50_dest
rename Trust_p75_cntrybirth Trust_p75_dest
rename Trust_p90_cntrybirth Trust_p90_dest
rename iso3_cntrybirth iso3_dest

save "C:\Users\kifouber\Dropbox\Return Migration\Data\Trust\clean\dta\Trust cleaned - dest.dta", replace
