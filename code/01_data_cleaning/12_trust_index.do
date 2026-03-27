********************************************************************************
* 12 - Trust Index
* Bekaert, Constant, Foubert & Ruyssen (2024) - JEBO
********************************************************************************
*
* Purpose: Cleans trust indicators for host and home countries.
*
* Input:   Trust survey data
*
* Output:  Trust cleaned.dta
*
* Note: These scripts were developed as part of a collaborative research workflow
* among co-authors over several years. Internal annotations, commented-out file
* paths, and exploratory code blocks reflect this iterative process and have been
* preserved for transparency and reproducibility.
********************************************************************************

clear all
use "C:\Users\kifouber\Dropbox\Return Migration\Data\Corruption\Old\dta\Corruption_2018.dta"
drop id
drop if year<2005
drop if year>2016
replace year = year+1
replace iso="XKO" if iso=="KSV"

save "C:\Users\kifouber\Dropbox\Return Migration\Data\Corruption\Clean\dta\Bayesian Corruption Index.dta", replace

rename iso iso3_cntrycurrent
rename name cntrycurrent
rename BCI BCI_cntrycurrent
rename BCI_std BCI_std_cntrycurrent
rename sources sources_cntrycurrent

save "C:\Users\kifouber\Dropbox\Return Migration\Data\Corruption\Clean\dta\Bayesian Corruption Index - cntrycurrent.dta", replace

rename iso3_cntrycurrent iso3_cntrybirth
rename cntrycurrent cntrybirth
rename BCI_cntrycurrent BCI_cntrybirth
rename BCI_std_cntrycurrent BCI_std_cntrybirth
rename sources_cntrycurrent sources_cntrybirth

save "C:\Users\kifouber\Dropbox\Return Migration\Data\Corruption\Clean\dta\Bayesian Corruption Index - cntrybirth.dta", replace

rename iso3_cntrybirth iso3_dest
rename cntrybirth dest
rename BCI_cntrybirth BCI_dest
rename BCI_std_cntrybirth BCI_std_dest
rename sources_cntrybirth sources_dest

save "C:\Users\kifouber\Dropbox\Return Migration\Data\Corruption\Clean\dta\Bayesian Corruption Index - dest.dta", replace
