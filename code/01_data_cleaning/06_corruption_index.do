********************************************************************************
* 06 - Corruption Index
* Bekaert, Constant, Foubert & Ruyssen (2024) - JEBO
********************************************************************************
*
* Purpose: Cleans the Bayesian Corruption Index for host and home countries.
*
* Input:   BCI data
*
* Output:  Corruption Index (host/home).dta
*
* Note: These scripts were developed as part of a collaborative research workflow
* among co-authors over several years. Internal annotations, commented-out file
* paths, and exploratory code blocks reflect this iterative process and have been
* preserved for transparency and reproducibility.
********************************************************************************

clear all
import delimited "C:\Users\kifouber\Dropbox\Return Migration\Data\Migration Policy Index\Old\dta\MPI_2014.csv"
drop if year<2006
replace year = year+1

drop id stdev rank stdev_e rank_e stdev_s rank_s stdev_i rank_i

rename * *_cntrybirth
rename iso_cntrybirth iso3_cntrybirth
rename name_cntrybirth cntrybirth
rename year_cntrybirth year
replace year = year+1

save "C:\Users\kifouber\Dropbox\Return Migration\Data\Migration Policy Index\Clean\dta\MPIcntrybirth.dta", replace

rename *_cntrybirth *_cntrycurrent
rename cntrybirth cntrycurrent

save "C:\Users\kifouber\Dropbox\Return Migration\Data\Migration Policy Index\Clean\dta\MPIcntrycurrent.dta", replace

rename *_cntrycurrent *_dest
rename cntrycurrent dest

save "C:\Users\kifouber\Dropbox\Return Migration\Data\Migration Policy Index\Clean\dta\MPIdest.dta", replace
