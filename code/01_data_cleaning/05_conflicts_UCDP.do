********************************************************************************
* 05 - Armed Conflicts (UCDP/PRIO)
* Bekaert, Constant, Foubert & Ruyssen (2024) - JEBO
********************************************************************************
*
* Purpose: Constructs conflict occurrence dummies for host and home countries.
*
* Input:   UCDP/PRIO data
*
* Output:  Occurrence of conflict (host/home).dta
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

*cd "D:\Dropbox\Return Migration\Data\" // Killian fix computer
cd "C:\Users\kifouber\Dropbox\Return Migration\Data\" // Killian laptop
* Add your path here
use "Conflicts\Old\dta\ucdp-prio-acd-181.dta"

drop if year < 2006
drop if year > 2015
keep location territory_name side_a side_a_2nd side_b side_b_2nd incompatibility year intensity_level cumulative_intensity type_of_conflict
rename location Origin

tostring year, replace

**************************************************************************************
*** Rearrange data on conflicts -> attribute them to the territory where it took place
**************************************************************************************

replace Origin="Myanmar" if Origin=="Myanmar (Burma)"
replace Origin="Yemen" if Origin=="Yemen (North Yemen)"
replace Origin="Democratic Republic of the Congo" if Origin=="DR Congo (Zaire)"
replace Origin="Russia" if Origin=="Russia (Soviet Union)"
replace Origin="United States" if Origin=="United States of America"
replace Origin="Sudan" if Origin=="South Sudan, Sudan"
replace Origin="Côte d'Ivoire" if Origin=="Ivory Coast"

order Origin year intensity_level
sort Origin year
rename Origin origin
// We use Dreher methodology here
gen WarOccurrence_low = 1 if intensity_level == 1
replace WarOccurrence_low = 0 if WarOccurrence_low == .
gen WarOccurrence_high = 1 if intensity_level == 2
replace WarOccurrence_high = 0 if WarOccurrence_high == .

collapse (max) WarOccurrence_low WarOccurrence_high, by(origin year)
replace WarOccurrence_low = 0 if WarOccurrence_high == 1
gen WarOccurrence = 1

* Merge with iso3 codes
merge m:1 origin using "iso3 codes/Clean/iso3clean.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           211
        from master                         4  (_merge==1)
        from using                        207  (_merge==2)

    matched                               269  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2
expand 2 if _merge==1
sort origin year
quietly by origin year:  gen dup = cond(_N==1,0,_n)

replace iso3="KHM" if origin=="Cambodia (Kampuchea), Thailand" & dup==1
replace iso3="THA" if origin=="Cambodia (Kampuchea), Thailand" & dup==2
replace iso3="DJI" if origin=="Djibouti, Eritrea" & dup==1
replace iso3="ERI" if origin=="Djibouti, Eritrea" & dup==2
replace iso3="IND" if origin=="India, Pakistan" & dup==1
replace iso3="PAK" if origin=="India, Pakistan" & dup==2

drop origin _merge dup
sort iso3o year
order iso3o year

destring year, replace
replace year = year+1 
* Adjust observations for which I had to change iso code above
replace WarOccurrence_low=1 if iso3o=="PAK" & year==2015
replace WarOccurrence_high=1 if iso3o=="PAK" & year==2015
replace WarOccurrence_low=1 if iso3o=="PAK" & year==2016
replace WarOccurrence_high=1 if iso3o=="PAK" & year==2016

duplicates drop

destring year, replace
replace year = year+1

save "Conflicts/Clean/Dta/Occurrence of conflict", replace

rename iso3 iso3_cntrycurrent
rename WarOccurrence* WarOccurrence*_cntrycurrent

save "Conflicts/Clean/Dta/Occurrence of conflict - Current country", replace

rename iso3_cntrycurrent iso3_cntrybirth
rename WarOccurrence*_cntrycurrent WarOccurrence*_cntrybirth

save "Conflicts/Clean/Dta/Occurrence of conflict - Birth country", replace

rename iso3_cntrybirth iso3_dest
rename WarOccurrence*_cntrybirth WarOccurrence*_dest

save "Conflicts/Clean/Dta/Occurrence of conflict - Dest", replace


