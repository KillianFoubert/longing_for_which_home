********************************************************************************
* 02 - Clean ISO3 Codes
* Bekaert, Constant, Foubert & Ruyssen (2024) - JEBO
********************************************************************************
*
* Purpose: Harmonises ISO3 country codes.
*
* Input:   iso3.dta
*
* Output:  iso3clean.dta
*
* Note: These scripts were developed as part of a collaborative research workflow
* among co-authors over several years. Internal annotations, commented-out file
* paths, and exploratory code blocks reflect this iterative process and have been
* preserved for transparency and reproducibility.
********************************************************************************

use "C:\Users\kifouber\Dropbox\Return Migration\Data\iso3 codes\Clean\iso3.dta", clear
drop id
rename NAME_0 origin
rename GID_0 iso3o
save "C:\Users\kifouber\Dropbox\Return Migration\Data\iso3 codes\Clean\iso3clean.dta", replace
