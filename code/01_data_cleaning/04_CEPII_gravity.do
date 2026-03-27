********************************************************************************
* 04 - CEPII Gravity Variables
* Bekaert, Constant, Foubert & Ruyssen (2024) - JEBO
********************************************************************************
*
* Purpose: Cleans bilateral distance, contiguity, and language from CEPII GeoDist.
*
* Input:   CEPII raw data
*
* Output:  CEPII_compatibleGWP.dta
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

*cd "D:\Dropbox\Return Migration\" // Killian fix PC
cd "C:\Users\kifouber\Dropbox\Return Migration\" // Killian laptop

use "Data\CEPII\Old\Dta\CEPII_compatibleGWP_raw.dta"

*** Israel -> Israel and PSE

expand 2 if origin=="Israel"
expand 2 if destination=="Israel"

gen z=_n

replace origin="Palestine" if origin=="Israel" & z>=51077 & z<= 51302
replace destination="Palestine" if destination=="Israel" & z>=51303 & z<=51527

drop z

*** Serbia and Montenegro -> Serbia AND Montenegro

expand 2 if origin=="Serbia and Montenegro"
expand 2 if destination=="Serbia and Montenegro"

gen z=_n

replace origin="Serbia" if origin=="Serbia and Montenegro" & z>=39325 & z<= 39550
replace origin="Montenegro" if origin=="Serbia and Montenegro" & z>=51528 & z<= 51754

replace destination="Serbia" if destination=="Serbia and Montenegro" & z>=51755 & z<=51980
drop z

sort destination
gen z=_n

replace destination="Montenegro" if destination=="Serbia and Montenegro" & z>=40178 & z<=40403
drop z

expand 2 if origin=="Serbia and Montenegro"
sort origin
gen z=_n
replace origin="Serbia" if origin=="Serbia and Montenegro" & z==40352
replace origin="Montenegro" if origin=="Serbia and Montenegro" & z==40353

keep origin destination contig comlang_ethno colony dist

* Merge with GADM level 0 iso3 codes - Origin

rename origin NAME_0
replace NAME_0="Brunei" if NAME_0=="Brunei Darussalam"
replace NAME_0="Republic of Congo" if NAME_0=="Congo Brazzaville"
replace NAME_0="Democratic Republic of the Congo" if NAME_0=="Congo Kinshasa"
replace NAME_0="Czech Republic" if NAME_0=="Czechoslovakia"
replace NAME_0="Timor-Leste" if NAME_0=="East Timor"
replace NAME_0="Côte d'Ivoire" if NAME_0=="Ivory Coast"
replace NAME_0="Macao" if NAME_0=="Macau (Aomen)"
replace NAME_0="Cocos Islands" if NAME_0=="Cocos (Keeling) Islands"
drop if NAME_0=="Netherland Antilles"
replace NAME_0="Palestina" if NAME_0=="Palestine"
replace NAME_0="Palestina" if NAME_0=="Palestinian Territory"
replace NAME_0="Pitcairn Islands" if NAME_0=="Pitcairn"
replace NAME_0="São Tomé and Príncipe" if NAME_0=="Sao Tome & Principe"
drop if NAME_0=="Socialist Federal Republic of Yugoslavia"
replace NAME_0="Saint Kitts and Nevis" if NAME_0=="St. Kitts & Nevis"
replace NAME_0="Saint Pierre and Miquelon" if NAME_0=="St. Pierre and Miquelon"
replace NAME_0="Saint Vincent and the Grenadines" if NAME_0=="St. Vincent and Grenadines"
replace NAME_0="Gambia" if NAME_0=="The Gambia"
replace NAME_0="Russia" if NAME_0=="USSR"

merge m:1 NAME_0 using "Maps\Do & files\worlddata.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                            33
        from master                         0  (_merge==1)
        from using                         33  (_merge==2)

    matched                            51,525  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2
drop _merge
drop NAME_0
rename GID_0 iso3o
drop id

* Merge with GADM level 0 iso3 codes - Destination

rename destination NAME_0
replace NAME_0="Brunei" if NAME_0=="Brunei Darussalam"
replace NAME_0="Republic of Congo" if NAME_0=="Congo Brazzaville"
replace NAME_0="Democratic Republic of the Congo" if NAME_0=="Congo Kinshasa"
replace NAME_0="Czech Republic" if NAME_0=="Czechoslovakia"
replace NAME_0="Timor-Leste" if NAME_0=="East Timor"
replace NAME_0="Côte d'Ivoire" if NAME_0=="Ivory Coast"
replace NAME_0="Macao" if NAME_0=="Macau (Aomen)"
replace NAME_0="Cocos Islands" if NAME_0=="Cocos (Keeling) Islands"
drop if NAME_0=="Netherland Antilles"
replace NAME_0="Palestina" if NAME_0=="Palestine"
replace NAME_0="Palestina" if NAME_0=="Palestinian Territory"
replace NAME_0="Pitcairn Islands" if NAME_0=="Pitcairn"
replace NAME_0="São Tomé and Príncipe" if NAME_0=="Sao Tome & Principe"
drop if NAME_0=="Socialist Federal Republic of Yugoslavia"
replace NAME_0="Saint Kitts and Nevis" if NAME_0=="St. Kitts & Nevis"
replace NAME_0="Saint Pierre and Miquelon" if NAME_0=="St. Pierre and Miquelon"
replace NAME_0="Saint Vincent and the Grenadines" if NAME_0=="St. Vincent and Grenadines"
replace NAME_0="Gambia" if NAME_0=="The Gambia"
replace NAME_0="Russia" if NAME_0=="USSR"

merge m:1 NAME_0 using "Maps\Do & files\worlddata.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                            32
        from master                         0  (_merge==1)
        from using                         32  (_merge==2)

    matched                            51,073  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2
drop _merge
drop NAME_0
rename GID_0 iso3d
drop id

sort iso3o iso3d
order iso3o iso3d

rename iso3o iso3_cntrycurrent
rename iso3d iso3_cntrybirth
rename contig contig_current_birth
rename comlang_ethno comlang_ethno_current_birth
rename colony colony_current_birth
rename dist dist_current_birth
duplicates drop
sort iso3_cntrycurrent iso3_cntrybirth
quietly by iso3_cntrycurrent iso3_cntrybirth:  gen dup = cond(_N==1,0,_n)
drop if dup==2 // Drops one bilateral observation everytime there is PSE, since we gathered palestine and israel together
drop dup

save "Data\CEPII\Clean\Dta\CEPII_compatibleGWP_currentbirth.dta", replace

rename iso3_cntrybirth iso3_dest
rename contig_current_birth contig_current_dest
rename comlang_ethno_current_birth comlang_ethno_current_dest
rename colony_current_birth colony_current_dest
rename dist_current_birth dist_current_dest
duplicates drop

save "Data\CEPII\Clean\Dta\CEPII_compatibleGWP_currentdest.dta", replace

