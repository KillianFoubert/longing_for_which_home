********************************************************************************
* 17 - Final Merge
* Bekaert, Constant, Foubert & Ruyssen (2024) - JEBO
********************************************************************************
*
* Purpose: Merges all cleaned datasets into the final individual-level panel of first-generation immigrants. Constructs remaining variables and fixed effects.
*
* Input:   All cleaned datasets from scripts 00-16
*
* Output:  Return database.dta (28,104 immigrants, 138 countries, 2009-2016)
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
*cd "C:\Users\kifouber\Dropbox\Return Migration\Data\" // Killian laptop
cd "/Users/elsbekaert/Dropbox/Return Migration/Data/" // Els 
*cd "/Users/ilseruyssen/Dropbox/Return Migration/Data/" // Ilse 

use "GWP/Clean/dta/GallupCleaned.dta"

********************************************************************************
********************************************************************************
********************************************************************************
replace HHsize=. if HHsize>=49 

replace dest="United States" if dest=="US Hispanic"
replace cntrybirth="United States" if cntrybirth=="US Hispanic"


*** 
*** Merge conflicts (UCDP/PRIO)
***

* Current country 
merge m:1 year iso3_cntrycurrent using "Conflicts/Clean/dta/Occurrence of conflict - Current country.dta"
replace WarOccurrence_low_cntrycurrent=0 if _merge==1
replace WarOccurrence_high_cntrycurrent=0 if _merge==1
replace WarOccurrence_cntrycurrent=0 if _merge==1
drop if _merge==2
drop _merge

* Birth country 
merge m:1 year iso3_cntrybirth using "Conflicts/Clean/dta/Occurrence of conflict - Birth country.dta"
replace WarOccurrence_low_cntrybirth=0 if _merge==1
replace WarOccurrence_high_cntrybirth=0 if _merge==1
replace WarOccurrence_cntrybirth=0 if _merge==1
drop if _merge==2
drop _merge

* Destination country
merge m:1 year iso3_dest using "Conflicts/Clean/dta/Occurrence of conflict - Dest.dta"
replace WarOccurrence_low_dest=0 if _merge==1
replace WarOccurrence_high_dest=0 if _merge==1
replace WarOccurrence_dest=0 if _merge==1
drop if _merge==2
drop _merge

***
*** Merge with Polity IV
***

* Current country
merge m:1 year iso3_cntrycurrent using "Polity IV/Clean/Dta/Polity4 GWP - Current country.dta"
drop if _merge==2
drop _merge
gen autocr_cntrycurrent=1 if polity2_cntrycurrent<0
replace autocr_cntrycurrent=0 if polity2_cntrycurrent>0
gen democr_cntrycurrent=1 if polity2_cntrycurrent>0
replace democr_cntrycurrent=0 if polity2_cntrycurrent<0

* Birth country
merge m:1 year iso3_cntrybirth using "Polity IV/Clean/Dta/Polity4 GWP - Birth country.dta"
drop if _merge==2
drop _merge
gen autocr_cntrybirth=1 if polity2_cntrybirth<0
replace autocr_cntrybirth=0 if polity2_cntrybirth>0
gen democr_cntrybirth=1 if polity2_cntrybirth>0
replace democr_cntrybirth=0 if polity2_cntrybirth<0

* Destination country
merge m:1 year iso3_dest using "Polity IV/Clean/Dta/Polity4 GWP - dest.dta"
drop if _merge==2
drop _merge
gen autocr_dest=1 if polity2_dest<0
replace autocr_dest=0 if polity2_dest>0
gen democr_dest=1 if polity2_dest>0
replace democr_dest=0 if polity2_dest<0

***
*** Merge with Migration Policy Index (MPI)
***

* Current country
merge m:1 year iso3_cntrycurrent using "Migration Policy Index/Clean/dta/MPIcntrycurrent.dta"
drop if _merge==2
drop _merge

* Birth country
merge m:1 year iso3_cntrybirth using "Migration Policy Index/Clean/dta/MPIcntrybirth.dta"
drop if _merge==2
drop _merge

* Dest country
merge m:1 year iso3_dest using "Migration Policy Index/Clean/dta/MPIdest.dta"
drop if _merge==2
drop _merge

***
*** Add Bayesian Corruption Index
***

* Current country
merge m:1 year iso3_cntrycurrent using "Corruption/Clean/dta/Bayesian Corruption Index - cntrycurrent.dta"
drop if _merge==2
drop _merge

* Birth country
merge m:1 year iso3_cntrybirth using "Corruption/Clean/dta/Bayesian Corruption Index - cntrybirth.dta"
drop if _merge==2
drop _merge

* Dest country
merge m:1 year iso3_dest using "Corruption/Clean/dta/Bayesian Corruption Index - dest.dta"
drop if _merge==2
drop _merge

***
*** Add trust index from WVS
***

* Current country
merge m:1 iso3_cntrycurrent year using "Trust/clean/dta/Trust cleaned - cntrycurrent.dta"
drop if _merge==2
drop _merge

* Birth country
merge m:1 iso3_cntrybirth year using "Trust/clean/dta/Trust cleaned - cntrybirth.dta"
drop if _merge==2
drop _merge

* Dest country
merge m:1 iso3_dest year using "Trust/clean/dta/Trust cleaned - dest.dta"
drop if _merge==2
drop _merge

***
*** Add region identifiers
***

* Current country
merge m:1 iso3_cntrycurrent using "Regions identifiers/Clean/dta/Regions identifiers - Current country.dta"
drop if _merge==2
drop _merge

* Birth country
merge m:1 iso3_cntrybirth using "Regions identifiers/Clean/dta/Regions identifiers - Birth country.dta"
drop if _merge==2
drop _merge

* Destination country
merge m:1 iso3_dest using "Regions identifiers/Clean/dta/Regions identifiers - Dest.dta"
drop if _merge==2
drop _merge

***
*** Merge with cultural distance
***

* cntrycurrent - cntrybirth
merge m:1 iso3_cntrycurrent iso3_cntrybirth using "Cultural distance/Clean/dta/Cultural distance - Residence Birth.dta"
drop if _merge==2
drop _merge

* cntrycurrent - dest
merge m:1 iso3_cntrycurrent iso3_dest using "Cultural distance/Clean/dta/Cultural distance - Residence Dest.dta"
drop if _merge==2
drop _merge

***
*** Add region levels of development
***

* Current country
merge m:1 iso3_cntrycurrent year using "WDI/Clean/dta/GNIpc_cntrycurrent.dta"
drop if _merge==2
drop _merge 

* Birth country
merge m:1 iso3_cntrybirth year using "WDI/Clean/dta/GNIpc_cntrybirth.dta"
drop if _merge==2
drop _merge

* Destination country
merge m:1 iso3_dest year using "WDI/Clean/dta/GNIpc_dest.dta" 
drop if _merge==2
drop _merge

***
*** Add GDP per capita in current international $
***

* Current country
merge m:1 iso3_cntrycurrent year using "WDI/Clean/dta/GDPpc_cntrycurrent.dta"
drop if _merge==2
drop _merge
gen GDPpc_cntrycurrent_ln=ln(GDPpc_cntrycurrent)

* Birth country
merge m:1 iso3_cntrybirth year using "WDI/Clean/dta/GDPpc_cntrybirth.dta"
drop if _merge==2
drop _merge
gen GDPpc_cntrybirth_ln=ln(GDPpc_cntrybirth)

* Destination country
merge m:1 iso3_dest year using "WDI/Clean/dta/GDPpc_dest.dta"
drop if _merge==2
drop _merge
gen GDPpc_dest_ln=ln(GDPpc_dest)

***
*** CEPII
***

* cntrycurrent - cntrybirth
merge m:1 iso3_cntrycurrent iso3_cntrybirth using "CEPII/Clean/Dta/CEPII_compatibleGWP_currentbirth.dta"
replace contig_current_birth=. if iso3_cntrycurrent==iso3_cntrybirth
replace comlang_ethno_current_birth=. if iso3_cntrycurrent==iso3_cntrybirth
replace colony_current_birth=. if iso3_cntrycurrent==iso3_cntrybirth
replace dist_current_birth=0 if iso3_cntrycurrent==iso3_cntrybirth
drop if _merge==2
drop _merge
gen dist_current_birth_ln=ln(dist_current_birth)

* cntrycurrent - dest
merge m:1 iso3_cntrycurrent iso3_dest using "CEPII/Clean/Dta/CEPII_compatibleGWP_currentdest.dta"
// large number of _merge==1 due to a large number of missing observations in destination
replace contig_current_dest=. if iso3_cntrycurrent==iso3_dest
replace comlang_ethno_current_dest=. if iso3_cntrycurrent==iso3_dest
replace colony_current_dest=. if iso3_cntrycurrent==iso3_dest
replace dist_current_dest=0 if iso3_cntrycurrent==iso3_dest
drop if _merge==2
drop _merge
gen dist_current_dest_ln=ln(dist_current_dest)

***
*** Add GDP
*** 

* cntrycurrent
merge m:1 iso3_cntrycurrent year using "WDI/Clean/dta/GDP_cntrycurrent.dta"
drop if _merge==2
drop _merge
gen GDP_cntrycurrent_ln=ln(GDP_cntrycurrent)

* cntrybirth
merge m:1 iso3_cntrybirth year using "WDI/Clean/dta/GDP_cntrybirth.dta"
drop if _merge==2
drop _merge
gen GDP_cntrybirth_ln=ln(GDP_cntrybirth)

* dest
merge m:1 iso3_dest year using "WDI/Clean/dta/GDP_dest.dta"
drop if _merge==2
drop _merge
gen GDP_dest_ln=ln(GDP_dest)

***
*** Add GDP growth
***

* cntrycurrent
merge m:1 iso3_cntrycurrent year using "WDI/Clean/dta/GDPgrowth_cntrycurrent.dta" // No data: Taiwan
drop if _merge==2
drop _merge

* cntrybirth
merge m:1 iso3_cntrybirth year using "WDI/Clean/dta/GDPgrowth_cntrybirth.dta" // No info when cntrybirth= None, Other Islamic Country, Somaliland region, African Country, Island Nations (11), Arab Country, Nagorno-Karabakh Republic, US Hispanic, Reunion, Taiwan, Northern Cyprus 
drop if _merge==2
drop _merge

* dest
merge m:1 iso3_dest year using "WDI/Clean/dta/GDPgrowth_dest.dta" // No info when dest=" " (a LOT of obs like this), Somaliland region, Nagorno-Karabakh Republic, US Hispanic, Taiwan
drop if _merge==2
drop _merge

***-----------------------------------------------------------------------------------
*** EMDAT data climate shocks
***-----------------------------------------------------------------------------------
/*
*old by year 
* cntrycurrent 
merge m:1 iso3_cntrycurrent year using "EMDAT/Disaster_Occurrance_Freq - Current country.dta"
foreach k in disaster_freq_cntrycurrent disaster_occ_cntrycurrent {
	replace `k'=0 if `k'==. //This is if it is indeed true that these countries didn't have any natural disasters during the period, so not if they are simply not in the EM-DAT database...
}
replace disaster_freq_cntrycurrent=. if (disaster_freq_cntrycurrent==0 & cntrycurrent=="Kosovo")
replace disaster_occ_cntrycurrent=. if (disaster_occ_cntrycurrent==0 & cntrycurrent=="Kosovo")
drop if _merge==2
drop _merge

* cntrybirth
merge m:1 iso3_cntrybirth year using "EMDAT/Disaster_Occurrance_Freq - Birth country.dta"
replace disaster_freq_cntrybirth=0 if (disaster_freq_cntrybirth==. & cntrybirth=="Bahrain")
replace disaster_occ_cntrybirth=0 if (disaster_occ_cntrybirth==. & cntrybirth=="Bahrain")
replace disaster_freq_cntrybirth=0 if (disaster_freq_cntrybirth==. & cntrybirth=="Brunei")
replace disaster_occ_cntrybirth=0 if (disaster_occ_cntrybirth==. & cntrybirth=="Brunei")
replace disaster_freq_cntrybirth=0 if (disaster_freq_cntrybirth==. & cntrybirth=="Cyprus")
replace disaster_occ_cntrybirth=0 if (disaster_occ_cntrybirth==. & cntrybirth=="Cyprus")
replace disaster_freq_cntrybirth=0 if (disaster_freq_cntrybirth==. & cntrybirth=="Equatorial Guinea")
replace disaster_occ_cntrybirth=0 if (disaster_occ_cntrybirth==. & cntrybirth=="Equatorial Guinea")
replace disaster_freq_cntrybirth=0 if (disaster_freq_cntrybirth==. & cntrybirth=="Finland")
replace disaster_occ_cntrybirth=0 if (disaster_occ_cntrybirth==. & cntrybirth=="Finland")
replace disaster_freq_cntrybirth=0 if (disaster_freq_cntrybirth==. & cntrybirth=="Jordan")
replace disaster_occ_cntrybirth=0 if (disaster_occ_cntrybirth==. & cntrybirth=="Jordan")
replace disaster_freq_cntrybirth=0 if (disaster_freq_cntrybirth==. & cntrybirth=="Kuwait")
replace disaster_occ_cntrybirth=0 if (disaster_occ_cntrybirth==. & cntrybirth=="Kuwait")
replace disaster_freq_cntrybirth=0 if (disaster_freq_cntrybirth==. & cntrybirth=="Macao")
replace disaster_occ_cntrybirth=0 if (disaster_occ_cntrybirth==. & cntrybirth=="Macao")
replace disaster_freq_cntrybirth=0 if (disaster_freq_cntrybirth==. & cntrybirth=="Maldives")
replace disaster_occ_cntrybirth=0 if (disaster_occ_cntrybirth==. & cntrybirth=="Maldives")
replace disaster_freq_cntrybirth=0 if (disaster_freq_cntrybirth==. & cntrybirth=="Malta")
replace disaster_occ_cntrybirth=0 if (disaster_occ_cntrybirth==. & cntrybirth=="Malta")
replace disaster_freq_cntrybirth=0 if (disaster_freq_cntrybirth==. & cntrybirth=="Qatar")
replace disaster_occ_cntrybirth=0 if (disaster_occ_cntrybirth==. & cntrybirth=="Qatar")
replace disaster_freq_cntrybirth=0 if (disaster_freq_cntrybirth==. & cntrybirth=="Saint Kitts and Nevis")
replace disaster_occ_cntrybirth=0 if (disaster_occ_cntrybirth==. & cntrybirth=="Saint Kitts and Nevis")
replace disaster_freq_cntrybirth=0 if (disaster_freq_cntrybirth==. & cntrybirth=="Singapore")
replace disaster_occ_cntrybirth=0 if (disaster_occ_cntrybirth==. & cntrybirth=="Singapore")
replace disaster_freq_cntrybirth=0 if (disaster_freq_cntrybirth==. & cntrybirth=="Turkmenistan")
replace disaster_occ_cntrybirth=0 if (disaster_occ_cntrybirth==. & cntrybirth=="Turkmenistan")
replace disaster_freq_cntrybirth=0 if (disaster_freq_cntrybirth==. & cntrybirth=="United Arab Emirates")
replace disaster_occ_cntrybirth=0 if (disaster_occ_cntrybirth==. & cntrybirth=="United Arab Emirates")
drop if _merge==2
drop _merge

* dest 
merge m:1 iso3_dest year using "EMDAT/Disaster_Occurrance_Freq - Dest.dta", keep(match master)
replace disaster_freq_dest=0 if (disaster_freq_dest==. & dest=="Bahrain")
replace disaster_occ_dest=0 if (disaster_occ_dest==. & dest=="Bahrain")
replace disaster_freq_dest=0 if (disaster_freq_dest==. & dest=="Brunei")
replace disaster_occ_dest=0 if (disaster_occ_dest==. & dest=="Brunei")
replace disaster_freq_dest=0 if (disaster_freq_dest==. & dest=="Cyprus")
replace disaster_occ_dest=0 if (disaster_occ_dest==. & dest=="Cyprus")
replace disaster_freq_dest=0 if (disaster_freq_dest==. & dest=="Equatorial Guinea")
replace disaster_occ_dest=0 if (disaster_occ_dest==. & dest=="Equatorial Guinea")
replace disaster_freq_dest=0 if (disaster_freq_dest==. & dest=="Finland")
replace disaster_occ_dest=0 if (disaster_occ_dest==. & dest=="Finland")
replace disaster_freq_dest=0 if (disaster_freq_dest==. & dest=="Jordan")
replace disaster_occ_dest=0 if (disaster_occ_dest==. & dest=="Jordan")
replace disaster_freq_dest=0 if (disaster_freq_dest==. & dest=="Kuwait")
replace disaster_occ_dest=0 if (disaster_occ_dest==. & dest=="Kuwait")
replace disaster_freq_dest=0 if (disaster_freq_dest==. & dest=="Maldives")
replace disaster_occ_dest=0 if (disaster_occ_dest==. & dest=="Maldives")
replace disaster_freq_dest=0 if (disaster_freq_dest==. & dest=="Malta")
replace disaster_occ_dest=0 if (disaster_occ_dest==. & dest=="Malta")
replace disaster_freq_dest=0 if (disaster_freq_dest==. & dest=="Qatar")
replace disaster_occ_dest=0 if (disaster_occ_dest==. & dest=="Qatar")
replace disaster_freq_dest=0 if (disaster_freq_dest==. & dest=="Singapore")
replace disaster_occ_dest=0 if (disaster_occ_dest==. & dest=="Singapore")
replace disaster_freq_dest=0 if (disaster_freq_dest==. & dest=="Turkmenistan")
replace disaster_occ_dest=0 if (disaster_occ_dest==. & dest=="Turkmenistan")
replace disaster_freq_dest=0 if (disaster_freq_dest==. & dest=="United Arab Emirates")
replace disaster_occ_dest=0 if (disaster_occ_dest==. & dest=="United Arab Emirates")
drop if _merge==2
drop _merge	
*/

* new by monthyear 
*WP4:  change field_date dataset to match mdate emdat 
tab wp4
gen month = month(wp4)
tab month

gen monthyear = ym(year, month)   // 40 missing values 
format monthyear %tm

* merge
*merge m:1 origin monthyear using "disastervariables_reg_Els_IR.dta", keep(match master) 

* cntrycurrent
merge m:1 cntrycurrent monthyear using "EMDAT/Disaster_cc.dta", keep(match master) 
tab cntrycurrent if _merge==1  // check who is not in EMDAT 
/*  --> note: these countries are in dataset, just not for our years !!!!!!!!!!!!
foreach k in Drought_freqC12_cc Earthquake_freqC12_cc Extreme_temperature_freqC12_cc Flood_freqC12_cc Landslide_freqC12_cc Dry_mass_movement_freqC12_cc Storm_freqC12_cc Volcanic_activity_freqC12_cc Wildfire_freqC12_cc disaster_freqC12_cc Drought_occC12_cc Earthquake_occC12_cc Extreme_temperature_occC12_cc Flood_occC12_cc Landslide_occC12_cc Dry_mass_movement_occC12_cc Storm_occC12_cc Volcanic_activity_occC12_cc Wildfire_occC12_cc disaster_occC12_cc {
	replace `k'=0 if `k'==. &  (dest!="Bahrain" | dest!="Cyprus" | dest!="Finland" |  dest!="Jordan" | dest!="Kosovo" ///
	dest!="Kuwait"| dest!="Malta" | dest!="Turkmenistan"| dest!="United Arab Emirates")//This is if it is indeed true that these countries didn't have any natural disasters during the period, so not if they are simply not in the EM-DAT database...
}*/ 

foreach k in Drought_freqC12_cc Earthquake_freqC12_cc Extreme_temperature_freqC12_cc Flood_freqC12_cc Landslide_freqC12_cc Dry_mass_movement_freqC12_cc Storm_freqC12_cc Volcanic_activity_freqC12_cc Wildfire_freqC12_cc disaster_freqC12_cc Drought_occC12_cc Earthquake_occC12_cc Extreme_temperature_occC12_cc Flood_occC12_cc Landslide_occC12_cc Dry_mass_movement_occC12_cc Storm_occC12_cc Volcanic_activity_occC12_cc Wildfire_occC12_cc disaster_occC12_cc {
	replace `k'=0 if `k'==. &  (dest!="Kosovo") //This is if it is indeed true that these countries didn't have any natural disasters during the period, so not if they are simply not in the EM-DAT database...
}
drop _merge

* cntrybirth  
merge m:1 cntrybirth monthyear using "EMDAT/Disaster_cb.dta", keep(match master) 
tab cntrybirth if _merge==1  //  Andorra, Eswatini, Kosovo,  Liechtenstein, Monaco, Nagorno-Karabakh Republic, Northern Cyprus,  Reunion , San Marino, US Hispanic
foreach k in Drought_freqC12_cb Earthquake_freqC12_cb Extreme_temperature_freqC12_cb Flood_freqC12_cb Landslide_freqC12_cb Dry_mass_movement_freqC12_cb Storm_freqC12_cb Volcanic_activity_freqC12_cb Wildfire_freqC12_cb disaster_freqC12_cb Drought_occC12_cb Earthquake_occC12_cb Extreme_temperature_occC12_cb Flood_occC12_cb Landslide_occC12_cb Dry_mass_movement_occC12_cb Storm_occC12_cb Volcanic_activity_occC12_cb Wildfire_occC12_cb disaster_occC12_cb {
	replace `k'=0 if `k'==. &  (dest!="Andorra" | dest!="Eswatini" | dest!="Kosovo" | dest!="Liechtenstein" | dest!="Monaco" | dest!="Nagorno-Karabakh Republic" |  dest!="Northern Cyprus" | ///
	dest!="Reunion"|  dest!="San Marino" | dest!="US Hispanic") //This is if it is indeed true that these countries didn't have any natural disasters during the period, so not if they are simply not in the EM-DAT database...
}
drop _merge

* dest  (create loop) 
merge m:1 dest monthyear using "EMDAT/Disaster_Dest.dta", keep(match master)
tab dest if _merge==1  //  Andorra, Eswatini, Kosovo, Micronesia, Monaco, Nagorno-Karabakh Republic, US Hispanic
foreach k in Drought_freqC12_d Earthquake_freqC12_d Extreme_temperature_freqC12_d Flood_freqC12_d Landslide_freqC12_d Dry_mass_movement_freqC12_d Storm_freqC12_d Volcanic_activity_freqC12_d Wildfire_freqC12_d disaster_freqC12_d Drought_occC12_d Earthquake_occC12_d Extreme_temperature_occC12_d Flood_occC12_d Landslide_occC12_d Dry_mass_movement_occC12_d Storm_occC12_d Volcanic_activity_occC12_d Wildfire_occC12_d disaster_occC12_d {
	replace `k'=0 if `k'==. & (dest!="Andorra" | dest!="Eswatini" | dest!="Kosovo" | dest!="Micronesia" | dest!="Monaco" | dest!="Nagorno-Karabakh Republic" | dest!="US Hispanic")
}
drop _merge	

********************************************************************************

drop o
egen cc = group (cntrycurrent)
egen cb = group (cntrybirth)
egen d = group (dest)
egen y = group (year)
egen ccy = group(cntrycurrent year)
egen cby = group(cntrybirth year)
egen dy = group(dest year)
egen cccb = group(cntrycurrent cntrybirth)
egen ccd = group(cntrycurrent dest)

/*
drop wp5889 FIELD_DATE wave wgt wp10252 wp10253 hhinc hhincpc wp11356 UMIG_in UMIG_pl ///
UMIG_pr BMIG_in BMIG_pl BMIG_pr dest_pl dest_pr HHmabr destHH destFF1 destFF2 destFF3 wp1325 ///
wp1418 wp16 wp3120 wp3331 wp4 ///
wp6880 wp69 wp70 wp73 wp74 wp85 wp9455 wp9498 wp9499 wp9500 wp9501 ///
wp9502 REGION REGION2 ID_GADM_coarse NAME_1 move no_mig no_mig_pl no_mig_pr wp10496 ///
agesq
*/
********************************************************************************

***----------------------
* OECD = host country 
***----------------------

gen OECD_host=1 if iso3_cntrycurrent=="DEU"
replace OECD_host=1 if iso3_cntrycurrent=="AUS"
replace OECD_host=1 if iso3_cntrycurrent=="AUT"
replace OECD_host=1 if iso3_cntrycurrent=="BEL"
replace OECD_host=1 if iso3_cntrycurrent=="CAN"
replace OECD_host=1 if iso3_cntrycurrent=="CHL" & year>= 2010
replace OECD_host=1 if iso3_cntrycurrent=="KOR" & year>= 1996
replace OECD_host=1 if iso3_cntrycurrent=="DNK"
replace OECD_host=1 if iso3_cntrycurrent=="ESP"
replace OECD_host=1 if iso3_cntrycurrent=="EST" & year>= 2010
replace OECD_host=1 if iso3_cntrycurrent=="FIN"
replace OECD_host=1 if iso3_cntrycurrent=="FRA"
replace OECD_host=1 if iso3_cntrycurrent=="GRC"
replace OECD_host=1 if iso3_cntrycurrent=="HUN" & year>= 1996
replace OECD_host=1 if iso3_cntrycurrent=="IRL"
replace OECD_host=1 if iso3_cntrycurrent=="ISL"
replace OECD_host=1 if iso3_cntrycurrent=="ISR" & year>= 2010
replace OECD_host=1 if iso3_cntrycurrent=="ITA"
replace OECD_host=1 if iso3_cntrycurrent=="JPN"
replace OECD_host=1 if iso3_cntrycurrent=="LVA" & year>= 2016
replace OECD_host=1 if iso3_cntrycurrent=="LTU" & year>= 2018
replace OECD_host=1 if iso3_cntrycurrent=="LUX"
replace OECD_host=1 if iso3_cntrycurrent=="MEX" & year>= 1994
replace OECD_host=1 if iso3_cntrycurrent=="NOR"
replace OECD_host=1 if iso3_cntrycurrent=="NZL" & year>= 1973
replace OECD_host=1 if iso3_cntrycurrent=="NLD"
replace OECD_host=1 if iso3_cntrycurrent=="POL" & year>= 1996
replace OECD_host=1 if iso3_cntrycurrent=="PRT"
replace OECD_host=1 if iso3_cntrycurrent=="GBR"
replace OECD_host=1 if iso3_cntrycurrent=="SVK" & year>= 2000
replace OECD_host=1 if iso3_cntrycurrent=="CZE" & year>= 1995
replace OECD_host=1 if iso3_cntrycurrent=="SVN" & year>= 2010
replace OECD_host=1 if iso3_cntrycurrent=="CHE"
replace OECD_host=1 if iso3_cntrycurrent=="SWE"
replace OECD_host=1 if iso3_cntrycurrent=="TUR"
replace OECD_host=1 if iso3_cntrycurrent=="USA"
replace OECD_host=0 if OECD_host==.
* --> in total  14,072  OECD COUNTRIES observations; 33 countries 
* (OK, as Colombia (2020), Lithuania (2018), Ireland (we have no data), Japan (We have no data). 


***----------------------
* Worldbank income levels (for countrycurrent) = host country 
***----------------------
preserve
wbopendata, indicator(NY.GDP.MKTP.KD.ZG) long nometadata clear
drop if year<2009
drop if year>2016
keep year countryname incomelevel incomelevelname
rename countryname origin
replace origin="Bahamas" if origin=="Bahamas, The"
replace origin="Brunei" if origin=="Brunei Darussalam"
replace origin="Cape Verde" if origin=="Cabo Verde"
replace origin="Democratic Republic of the Congo" if origin=="Congo, Dem Rep"
replace origin="Republic of Congo" if origin=="Congo, Rep"
replace origin="Côte d'Ivoire" if origin=="Cote d'Ivoire"
replace origin="Curaçao" if origin=="Curacao"
replace origin="Egypt" if origin=="Egypt, Arab Rep"
replace origin="Gambia" if origin=="Gambia, The"
replace origin="Hong Kong" if origin=="Hong Kong SAR, China"
replace origin="Iran" if origin=="Iran, Islamic Rep"
replace origin="North Korea" if origin=="Korea, Dem People’s Rep"
replace origin="South Korea" if origin=="Korea, Rep"
replace origin="Kyrgyzstan" if origin=="Kyrgyz Republic"
replace origin="Laos" if origin=="Lao PDR"
replace origin="Macao" if origin=="Macao SAR, China"
replace origin="Micronesia" if origin=="Micronesia, Fed Sts"
replace origin="Macedonia" if origin=="North Macedonia"
replace origin="Russia" if origin=="Russian Federation"
replace origin="Slovakia" if origin=="Slovak Republic"
replace origin="Syria" if origin=="Syrian Arab Republic"
replace origin="Venezuela" if origin=="Venezuela, RB"
replace origin="Palestina" if origin=="West Bank and Gaza"
replace origin="Swaziland" if origin=="Eswatini"
replace origin="São Tomé and Príncipe" if origin=="Sao Tome and Principe"
replace origin="Sint Maarten" if origin=="Sint Maarten (Dutch part)"
replace origin="Saint Kitts and Nevis" if origin=="St Kitts and Nevis"
replace origin="Saint Lucia" if origin=="St Lucia"
replace origin="Saint-Martin" if origin=="St Martin (French part)"
replace origin="Saint Vincent and the Grenadines" if origin=="St Vincent and the Grenadines"
replace origin="Virgin Islands, U.S." if origin=="Virgin Islands (US)"
replace origin="Yemen" if origin=="Yemen, Rep"
rename origin cntrycurrent
rename incomelevel incomelevel_cc 
rename incomelevelname incomelevelname_cc
save "WDI/Clean/dta/WBincomegroups", replace
restore 

merge m:1 cntrycurrent year using "WDI/Clean/dta/WBincomegroups.dta"
drop if _merge==2 // Those we don't have in our sample (by year)
tab cntrycurrent if _merge==1 // Taiwan, is a HIC, do manually 
replace incomelevel_cc="HIC" if cntrycurrent =="Taiwan"
replace incomelevelname_cc="High income" if cntrycurrent =="Taiwan"
* --> in total  27,675  HIGH INCOME COUNTRIES observations; 45 countries 



/*
tab cntrycurrent if OECD_host==0 & incomelevel=="HIC"
 COUNTRYNEW Country Name |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                Bahrain |      1,410       10.24       10.24
                                Croatia |        164        1.19       11.44
                                 Cyprus |        840        6.10       17.54
                              Hong Kong |        537        3.90       21.44
                                 Kuwait |      3,553       25.82       47.26
                                 Latvia |        621        4.51       51.77    // only came to OECD in 2016 
                              Lithuania |        229        1.66       53.43
                                  Malta |        118        0.86       54.29
                                 Panama |        175        1.27       55.56
                                Romania |         14        0.10       55.66
                           Saudi Arabia |      1,460       10.61       66.27
                               Slovenia |         35        0.25       66.53   // Only came to OECD in 2010 
                                 Taiwan |         70        0.51       67.03
                    Trinidad and Tobago |         20        0.15       67.18
                   United Arab Emirates |      4,451       32.34       99.52
                                Uruguay |         66        0.48      100.00
								---------+-----------------------------------
                                  Total |     13,763      100.00
								  
Missing: Mexcio (UMC) and Turkey (UMC) 

*/

preserve
wbopendata, indicator(NY.GDP.MKTP.KD.ZG) long nometadata clear
drop if year<2009
drop if year>2016
keep year countryname incomelevel incomelevelname
rename countryname origin
replace origin="Bahamas" if origin=="Bahamas, The"
replace origin="Brunei" if origin=="Brunei Darussalam"
replace origin="Cape Verde" if origin=="Cabo Verde"
replace origin="Democratic Republic of the Congo" if origin=="Congo, Dem Rep"
replace origin="Republic of Congo" if origin=="Congo, Rep"
replace origin="Côte d'Ivoire" if origin=="Cote d'Ivoire"
replace origin="Curaçao" if origin=="Curacao"
replace origin="Egypt" if origin=="Egypt, Arab Rep"
replace origin="Gambia" if origin=="Gambia, The"
replace origin="Hong Kong" if origin=="Hong Kong SAR, China"
replace origin="Iran" if origin=="Iran, Islamic Rep"
replace origin="North Korea" if origin=="Korea, Dem People’s Rep"
replace origin="South Korea" if origin=="Korea, Rep"
replace origin="Kyrgyzstan" if origin=="Kyrgyz Republic"
replace origin="Laos" if origin=="Lao PDR"
replace origin="Macao" if origin=="Macao SAR, China"
replace origin="Micronesia" if origin=="Micronesia, Fed Sts"
replace origin="Macedonia" if origin=="North Macedonia"
replace origin="Russia" if origin=="Russian Federation"
replace origin="Slovakia" if origin=="Slovak Republic"
replace origin="Syria" if origin=="Syrian Arab Republic"
replace origin="Venezuela" if origin=="Venezuela, RB"
replace origin="Palestina" if origin=="West Bank and Gaza"
replace origin="Swaziland" if origin=="Eswatini"
replace origin="São Tomé and Príncipe" if origin=="Sao Tome and Principe"
replace origin="Sint Maarten" if origin=="Sint Maarten (Dutch part)"
replace origin="Saint Kitts and Nevis" if origin=="St Kitts and Nevis"
replace origin="Saint Lucia" if origin=="St Lucia"
replace origin="Saint-Martin" if origin=="St Martin (French part)"
replace origin="Saint Vincent and the Grenadines" if origin=="St Vincent and the Grenadines"
replace origin="Virgin Islands, U.S." if origin=="Virgin Islands (US)"
replace origin="Yemen" if origin=="Yemen, Rep"
rename origin cntrybirth
rename incomelevel incomelevel_cb 
rename incomelevelname incomelevelname_cb
save "WDI/Clean/dta/WBincomegroups_cb", replace
restore 

drop _merge
merge m:1 cntrybirth year using "WDI/Clean/dta/WBincomegroups_cb.dta"
drop if _merge==2 // Those we don't have in our sample (by year)
tab cntrybirth if _merge==1 // Taiwan, is a HIC, do manually 
replace incomelevel_cb="HIC" if cntrybirth =="Taiwan"
replace incomelevelname_cb="High income" if cntrybirth =="Taiwan"

* Dest (added 22.12.2022)
preserve
wbopendata, indicator(NY.GDP.MKTP.KD.ZG) long nometadata clear
drop if year<2009
drop if year>2016
keep year countryname incomelevel incomelevelname
rename countryname origin
replace origin="Bahamas" if origin=="Bahamas, The"
replace origin="Brunei" if origin=="Brunei Darussalam"
replace origin="Cape Verde" if origin=="Cabo Verde"
replace origin="Democratic Republic of the Congo" if origin=="Congo, Dem Rep"
replace origin="Republic of Congo" if origin=="Congo, Rep"
replace origin="Côte d'Ivoire" if origin=="Cote d'Ivoire"
replace origin="Curaçao" if origin=="Curacao"
replace origin="Egypt" if origin=="Egypt, Arab Rep"
replace origin="Gambia" if origin=="Gambia, The"
replace origin="Hong Kong" if origin=="Hong Kong SAR, China"
replace origin="Iran" if origin=="Iran, Islamic Rep"
replace origin="North Korea" if origin=="Korea, Dem People’s Rep"
replace origin="South Korea" if origin=="Korea, Rep"
replace origin="Kyrgyzstan" if origin=="Kyrgyz Republic"
replace origin="Laos" if origin=="Lao PDR"
replace origin="Macao" if origin=="Macao SAR, China"
replace origin="Micronesia" if origin=="Micronesia, Fed Sts"
replace origin="Macedonia" if origin=="North Macedonia"
replace origin="Russia" if origin=="Russian Federation"
replace origin="Slovakia" if origin=="Slovak Republic"
replace origin="Syria" if origin=="Syrian Arab Republic"
replace origin="Venezuela" if origin=="Venezuela, RB"
replace origin="Palestina" if origin=="West Bank and Gaza"
replace origin="Swaziland" if origin=="Eswatini"
replace origin="São Tomé and Príncipe" if origin=="Sao Tome and Principe"
replace origin="Sint Maarten" if origin=="Sint Maarten (Dutch part)"
replace origin="Saint Kitts and Nevis" if origin=="St Kitts and Nevis"
replace origin="Saint Lucia" if origin=="St Lucia"
replace origin="Saint-Martin" if origin=="St Martin (French part)"
replace origin="Saint Vincent and the Grenadines" if origin=="St Vincent and the Grenadines"
replace origin="Virgin Islands, U.S." if origin=="Virgin Islands (US)"
replace origin="Yemen" if origin=="Yemen, Rep"
rename origin dest
rename incomelevel incomelevel_dest 
rename incomelevelname incomelevelname_dest
save "WDI/Clean/dta/WBincomegroups_dest2", replace
restore 

drop _merge
merge m:1 dest year using "WDI/Clean/dta/WBincomegroups_dest2.dta"
drop if _merge==2 // Those we don't have in our sample (by year)
tab dest if _merge==1 // Taiwan, is a HIC, do manually 
replace incomelevel_dest="HIC" if dest =="Taiwan"
replace incomelevelname_dest="High income" if dest =="Taiwan"
* 

* Update labels individual controls 
label var age1835 "Age 18-35"
label var age3550 "Age 35-50"
label var age5065 "Age 50-65"
label var age6575 "Age 65-75"
label var male "Male"
label var HHsize "Household size"
label var mhskill "Secondary or tertiary education"
label var lskill "Elementary education"
label var mskill "Secondary education"
label var hskill "Tertiary education"
label var movelast5years "Duration in host < 5 years"
label var INDEX_PH "Personal Health index"
label var mabr "Network abroad"
*label var closesocialnetwork "Local network index"
label var closesocialnetwork1 "Local network index"
label var empl "Employed"
*label var wealth "Wealth Index"
label var BasicWealth "Basic wealth"
label var satisPP "Satisfaction with standard of living"
label var feelingsHHInc "Feelings about household income"
label var INDEX_DI "Diversity index"
label var INDEX_CB "Community Basics index"
*label var INDEX_CA "Community Attachment index"
* Update labels macro controls 
label var GDPgrowth_cntrycurrent "GDP growth (Host)"
label var GDPgrowth_cntrybirth "GDP growth (Birth)"
label var disaster_freqC12_cc "Disaster frequency (Host)"
label var disaster_freqC12_cb "Disaster frequency (Birth)"
label var PolInstab3y_cntrycurrent "Political instability (Host)"
label var PolInstab3y_cntrybirth "Political instability (Birth)"
label var wp119bis "Religious"


* Adding regions

gen OECD_dest = dest
foreach k in OECD_dest {
replace `k'="OECD" if `k'=="Australia" || `k'=="Austria" || `k'=="Belgium"|| `k'=="Canada"|| `k'=="Chile" || ///
`k'=="Czech Republic"|| `k'=="Denmark" || `k'=="Estonia" || `k'=="Finland" ||  `k'=="France" || ///
`k'=="Germany" || `k'=="Greece" || `k'=="Hungary" || `k'=="Iceland" || `k'=="Ireland" || `k'=="Israel" ||  ///
`k'=="Italy" || `k'=="Japan" ||  `k'=="Luxembourg" || `k'=="Mexico" ||`k'=="Netherlands" || ///
`k'=="New Zealand" || `k'=="Norway" || `k'=="Poland" || `k'=="Portugal" || `k'=="Slovakia" ||`k'=="Slovenia" || ///
`k'=="South Korea" || `k'=="Spain" || `k'=="Sweden" || `k'=="Switzerland" || `k'=="Turkey" || ///
`k'=="United Kingdom" || `k'=="United States"

replace `k'="non-OECD" if `k' !="OECD"
}
replace OECD_dest="" if dest=="" 

* Stay 
gen stay=. // (43,057 missing values generated)
replace stay=1 if migration==0 //  33,235
replace stay=0 if migration==1 | migration==2 //  9,822

/*
* mlogit all dest 
gen mlogit_alldest=. // (43,057 missing values generated)
replace mlogit_alldest=0 if  BMIG_in==0 // 
replace mlogit_alldest=1 if (BMIG_in==1 & dest==cntrybirth )  // (3,441 real changes made)
replace mlogit_alldest=2 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Afghanistan")  // 4 changes 
replace mlogit_alldest=3 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Albania")  // 2 changes 
replace mlogit_alldest=4 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Algeria")  // 5 changes 
replace mlogit_alldest=5 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Andorra")  // 2 changes 
replace mlogit_alldest=6 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Angola")  // 16 changes 
replace mlogit_alldest=7 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Argentina")  // 18 changes 
replace mlogit_alldest=8 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Armenia")  // 7 changes 
replace mlogit_alldest=9 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Australia")  // 420 changes 
replace mlogit_alldest=10 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Austria")  // 67 changes 
replace mlogit_alldest=11 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Azerbaijan")  // 1 changes 
replace mlogit_alldest=12 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Bahamas")  // 3 changes 
replace mlogit_alldest=13 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Bahrain")  // 7 changes 
replace mlogit_alldest=14 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Bangladesh")  // 6 changes 
replace mlogit_alldest=15 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Barbados")  // 3 changes 
replace mlogit_alldest=16 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Belarus")  // 14 changes 
replace mlogit_alldest=17 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Belgium")  // 67 changes 
replace mlogit_alldest=18 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Belize")  //  1 changes 
replace mlogit_alldest=19 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Benin")  // 5 changes 
replace mlogit_alldest=20 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Bolivia")  // 2 changes 
replace mlogit_alldest=21 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Bosnia and Herzegovina")  // 1 changes 
replace mlogit_alldest=22 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Botswana")  // 5 changes 
replace mlogit_alldest=23 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Brazil")  // 60 changes 
replace mlogit_alldest=24 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Brunei")  // 3 changes 
replace mlogit_alldest=25 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Bulgaria")  // 4 changes 
replace mlogit_alldest=26 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Burkina Faso")  // 2 changes 
replace mlogit_alldest=27 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Burundi")  // 3 changes 
replace mlogit_alldest=28 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Cambodia")  // 2 changes 
replace mlogit_alldest=29 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Cameroon")  // 5 changes 
replace mlogit_alldest=30 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Cape Verde")  // 3 changes 
replace mlogit_alldest=31 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Central African Republic")  // 1 changes 
replace mlogit_alldest=32 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Chad")  // 1 changes 
replace mlogit_alldest=33 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Chile")  // 9 changes 
replace mlogit_alldest=34 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="China")  // 23 changes 
replace mlogit_alldest=35 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Colombia")  // 6 changes 
replace mlogit_alldest=36 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Costa Rica")  // 8 changes 
replace mlogit_alldest=37 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Croatia")  // 4 changes 
replace mlogit_alldest=38 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Cuba")  // 10 changes 
replace mlogit_alldest=39 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Cyprus")  // 5 changes 
replace mlogit_alldest=40 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Czech Republic")  // 16 changes 
replace mlogit_alldest=41 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Côte d'Ivoire")  // 20 changes 
replace mlogit_alldest=42 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Democratic Republic of the Congo")  // 3 changes 
replace mlogit_alldest=43 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Denmark")  // 31 changes 
replace mlogit_alldest=44 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Djibouti")  // 4 changes 
replace mlogit_alldest=45 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Dominica")  // 4 changes 
replace mlogit_alldest=46 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Dominican Republic")  // 5 changes 
replace mlogit_alldest=47 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Ecuador")  // 3 changes 
replace mlogit_alldest=48 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Egypt")  // 50 changes 
replace mlogit_alldest=49 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="El Salvador")  // 1 changes 
replace mlogit_alldest=50 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Equatorial Guinea")  // 10 changes 
replace mlogit_alldest=51 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Estonia")  // 2 changes 
replace mlogit_alldest=52 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Eswatini")  // 1 changes 
replace mlogit_alldest=53 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Ethiopia")  // 6 changes 
replace mlogit_alldest=54 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Fiji")  // 1 changes 
replace mlogit_alldest=55 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Finland")  // 29 changes 
replace mlogit_alldest=56 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="France")  // 389 changes 
replace mlogit_alldest=57 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Gabon")  // 7 changes 
replace mlogit_alldest=58 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Gambia")  // 0 changes 
replace mlogit_alldest=59 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Georgia")  // 1 changes 
replace mlogit_alldest=60 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Germany")  // 492 changes 
replace mlogit_alldest=61 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Ghana")  // 16 changes 
replace mlogit_alldest=62 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Greece")  // 20 changes 
replace mlogit_alldest=63 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Grenada")  // 1 changes 
replace mlogit_alldest=64 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Guatemala")  // 2 changes 
replace mlogit_alldest=65 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Guinea")  // 3 changes 
replace mlogit_alldest=66 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Guinea-Bissau")  // 1 changes 
replace mlogit_alldest=67 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Guyana")  // 1 changes 
replace mlogit_alldest=68 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Haiti")  // 0 changes 
replace mlogit_alldest=69 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Honduras")  // 4 changes 
replace mlogit_alldest=70 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Hong Kong")  // 4 changes 
replace mlogit_alldest=71 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Hungary")  // 4 changes 
replace mlogit_alldest=72 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Iceland")  // 7 changes 
replace mlogit_alldest=73 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="India")  // 14 changes 
replace mlogit_alldest=74 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Indonesia")  // 16 changes 
replace mlogit_alldest=75 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Iran")  // 11 changes 
replace mlogit_alldest=76 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Iraq")  // 6 changes 
replace mlogit_alldest=77 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Ireland")  // 21 changes 
replace mlogit_alldest=78 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Israel")  // 15 changes 
replace mlogit_alldest=79 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Italy")  // 188 changes 
replace mlogit_alldest=80 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Jamaica")  // 4 changes 
replace mlogit_alldest=81 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Japan")  // 47 changes 
replace mlogit_alldest=82 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Jordan")  // 21 changes 
replace mlogit_alldest=83 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Kazakhstan")  // 7 changes 
replace mlogit_alldest=84 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Kenya")  // 7 changes 
replace mlogit_alldest=85 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Kosovo")  // 0 changes 
replace mlogit_alldest=86 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Kuwait")  // 44 changes 
replace mlogit_alldest=87 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Laos")  // 1 changes 
replace mlogit_alldest=88 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Latvia")  // 3 changes 
replace mlogit_alldest=89 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Lebanon")  // 9 changes 
replace mlogit_alldest=90 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Lesotho")  // 1 changes 
replace mlogit_alldest=91 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Liberia")  // 1 changes 
replace mlogit_alldest=92 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Libya")  // 11 changes 
replace mlogit_alldest=93 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Lithuania")  // 4 changes 
replace mlogit_alldest=94 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Luxembourg")  // 13 changes 
replace mlogit_alldest=95 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Macedonia")  // 0 changes 
replace mlogit_alldest=96 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Madagascar")  // 4 changes 
replace mlogit_alldest=97 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Malawi")  // 2 changes 
replace mlogit_alldest=98 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Malaysia")  // 13 changes 
replace mlogit_alldest=99 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Maldives")  // 3 changes 
replace mlogit_alldest=100 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Mali")  // 5 changes 
replace mlogit_alldest=101 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Malta")  // 6 changes 
replace mlogit_alldest=102 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Mauritania")  // 4 changes 
replace mlogit_alldest=103 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Mauritius")  // 0 changes 
replace mlogit_alldest=104 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Mexico")  // 19 changes 
replace mlogit_alldest=105 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Micronesia")  // 1 changes 
replace mlogit_alldest=106 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Moldova")  // 2 changes 
replace mlogit_alldest=107 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Monaco")  // 2 changes 
replace mlogit_alldest=108 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Mongolia")  // 1 changes 
replace mlogit_alldest=109 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Morocco")  // 23 changes 
replace mlogit_alldest=110 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Mozambique")  // 2 changes 
replace mlogit_alldest=111 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Myanmar")  // 1 changes 
replace mlogit_alldest=112 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Nagorno-Karabakh Republic")  // 0 changes 
replace mlogit_alldest=113 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Namibia")  // 4 changes 
replace mlogit_alldest=114 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Nepal")  // 2 changes 
replace mlogit_alldest=115 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Netherlands")  // 66 changes 
replace mlogit_alldest=116 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="New Zealand")  // 79 changes 
replace mlogit_alldest=117 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Nicaragua")  // 2 changes 
replace mlogit_alldest=118 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Niger")  // 1 changes 
replace mlogit_alldest=119 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Nigeria")  // 13 changes 
replace mlogit_alldest=120 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="North Korea")  // 2 changes 
replace mlogit_alldest=121 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Norway")  // 79 changes 
replace mlogit_alldest=122 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Oman")  // 6 changes 
replace mlogit_alldest=123 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Pakistan")  // 8 changes 
replace mlogit_alldest=124 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Palestina")  // 6 changes 
replace mlogit_alldest=125 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Panama")  // 20 changes 
replace mlogit_alldest=126 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Paraguay")  // 2 changes 
replace mlogit_alldest=127 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Peru")  // 2 changes 
replace mlogit_alldest=128 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Philippines")  // 3 changes 
replace mlogit_alldest=129 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Poland")  // 16 changes 
replace mlogit_alldest=130 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Portugal")  // 21 changes 
replace mlogit_alldest=131 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Puerto Rico")  // 3 changes 
replace mlogit_alldest=132 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Qatar")  // 61 changes 
replace mlogit_alldest=133 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Republic of Congo")  // 2 changes 
replace mlogit_alldest=134 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Romania")  // 7 changes 
replace mlogit_alldest=135 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Russia")  // 211 changes 
replace mlogit_alldest=136 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Rwanda")  // 0 changes 
replace mlogit_alldest=137 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Saint Lucia")  // 1 changes 
replace mlogit_alldest=138 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Samoa")  // 0 changes 
replace mlogit_alldest=139 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Saudi Arabia")  // 163 changes 
replace mlogit_alldest=140 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Senegal")  // 10 changes 
replace mlogit_alldest=141 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Serbia")  // 2 changes 
replace mlogit_alldest=142 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Seychelles")  // 2 changes 
replace mlogit_alldest=143 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Sierra Leone")  // 1 changes 
replace mlogit_alldest=144 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Singapore")  // 29 changes 
replace mlogit_alldest=145 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Slovakia")  // 1 changes 
replace mlogit_alldest=146 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Slovenia")  // 2 changes 
replace mlogit_alldest=147 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Somalia")  // 0 changes 
replace mlogit_alldest=148 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="South Africa")  // 52 changes 
replace mlogit_alldest=149 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="South Korea")  // 9 changes 
replace mlogit_alldest=150 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="South Sudan")  // 2 changes 
replace mlogit_alldest=151 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Spain")  // 237 changes 
replace mlogit_alldest=152 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Sri Lanka")  // 3 changes 
replace mlogit_alldest=153 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Sudan")  // 7 changes 
replace mlogit_alldest=154 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Suriname")  // 0 changes 
replace mlogit_alldest=155 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Swaziland")  // 6 changes 
replace mlogit_alldest=156 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Sweden")  // 150 changes 
replace mlogit_alldest=157 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Albania")  // 2 changes 
replace mlogit_alldest=158 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Afghanistan")  // 4 changes 
replace mlogit_alldest=159 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Switzerland")  // 158 changes 
replace mlogit_alldest=160 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Syria")  // 9 changes 
replace mlogit_alldest=161 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Taiwan")  // 4 changes 
replace mlogit_alldest=162 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Tajikistan")  // 0 changes 
replace mlogit_alldest=163 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Tanzania")  // 3 changes 
replace mlogit_alldest=164 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Thailand")  // 17 changes 
replace mlogit_alldest=165 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Togo")  // 9 changes 
replace mlogit_alldest=166 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Trinidad and Tobago")  // 1 changes 
replace mlogit_alldest=167 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Tunisia")  // 7 changes 
replace mlogit_alldest=168 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Turkey")  // 59 changes 
replace mlogit_alldest=169 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Turkmenistan")  //  1 changes 
replace mlogit_alldest=170 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Uganda")  // 7 changes 
replace mlogit_alldest=171 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Ukraine")  // 9 changes 
replace mlogit_alldest=172 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="United Arab Emirates")  // 277 changes 
replace mlogit_alldest=173 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="United Kingdom")  // 417 changes 
replace mlogit_alldest=174 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="United States")  // 1160 changes 
replace mlogit_alldest=175 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Uruguay")  // 5 changes 
replace mlogit_alldest=176 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Uzbekistan")  // 1 changes 
replace mlogit_alldest=177 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Venezuela")  // 2 changes 
replace mlogit_alldest=178 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Vietnam")  // 5 changes 
replace mlogit_alldest=179 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Yemen")  // 8 changes 
replace mlogit_alldest=180 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Zambia")  // 6 changes 
replace mlogit_alldest=181 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Zimbabwe")  // 4 changes 
replace mlogit_alldest=182 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & dest=="Canada")  // 660 changes 
tab mlogit_alldest 
*/

*** numbers do not add up: some countries not attributed a region??? Do not find back how it was constructed (ask killian?) 
tab region_cntrycurrent // 19 Regions // 43,057 obs  
tab region_cntrybirth // 19 Regions //  42,574 obs 
tab region_dest   // 19 Regions  // 9,758 obs 

tab cntrycurrent // 43,057  (OK) 
tab cntrybirth // 43,057   (483 obs not attributed a region) --> countries: 33 
tab dest  // 9,822 			(64 obs not attributed a region) 

/*
* create regions again manually: 
tab cntrycurrent if region_cntrycurrent=="Australia/New Zealand" // Australia, NZ 
tab cntrycurrent if region_cntrycurrent=="Caribbean" //  Dominican Republic;  Haiti; Trinidad and Tobago
tab cntrycurrent if region_cntrycurrent=="Central America" // Costa Rica; El Salvador; Guatemala; Honduras; Mexico; Nicaragua; Panama
tab cntrycurrent if region_cntrycurrent=="Northern America" // Canada, US
tab cntrycurrent if region_cntrycurrent=="South America" // Argentina, Bolivia, Brazil, Chile, Colombia, Ecuador, Paraguay, Peru, Uruguay, Venezuela 

tab cntrycurrent if region_cntrycurrent=="Central Asia" // Kazakhstan; Kyrgyzstan; Tajikistan; Turkmenistan; Uzbekistan
tab cntrycurrent if region_cntrycurrent=="Eastern Asia" // China, Hong Kong, Mongolia, South Korea, Taiwan 
tab cntrycurrent if region_cntrycurrent=="South Asia" // Afghanistan, Bangladesh, Bhutan, India, Nepal, Pakistan, Sri Lanka 
tab cntrycurrent if region_cntrycurrent=="South-Eastern Asia" // Cambodia, Indonesia, Laos, Malaysia, Myanmar, Thailand, Vietnam
tab cntrycurrent if region_cntrycurrent=="Western Asia" // Armenia, Azerbaijan, Bahrain, Georgia, Iran, Iraq, Israel, Jordan, Kuwait, Lebanon, Palestina, Saudi Arabia, Syria, Turkey, UAE, Yemen

tab cntrycurrent if region_cntrycurrent=="Eastern Africa" // Burundi; Djibouti; Ethiopia; Kenya; Malawi; Rwanda; Somalia; South Sudan,  Sudan
tab cntrycurrent if region_cntrycurrent=="Middle Africa" // Angola, Cameroon, Central African Republic, Chad, Democratic Republic of the Congo, Gabon, Republic of Congo 
tab cntrycurrent if region_cntrycurrent=="Nothern Africa" // Algeria, Egypt, Libya, Morocco, Tunisia
tab cntrycurrent if region_cntrycurrent=="Southern Africa" // Botswana, Lesotho, Madagascar, Mozambique, Namibia, Swaziland, Tanzania, Zambia 
tab cntrycurrent if region_cntrycurrent=="Western Africa" // Benin, Burkina Faso, Côte d'Ivoire, Ghana, Guinea, liberia, Mali, Mauritania, Niger, Nigeria, Senegal, Sierra Leone, Togo

tab cntrycurrent if region_cntrycurrent=="Eastern Europe" // Belarus, Bulgaria, Hungary, Moldova, Poland, Romania, Russia, Slovakia, Ukraine 
tab cntrycurrent if region_cntrycurrent=="Nothern Europe" // Denmark, Estonia, Finland, Iceland, Latvia, Lithuania, Norway, Sweden
tab cntrycurrent if region_cntrycurrent=="Southern Europe" // Albania, Bosnia and Herzegovina, Croatia, Cyprus, Greece, Italy, Kosovo, Macedonia, Malta, Montenegro, Portugal, Serbia, Slovenia, Spain
tab cntrycurrent if region_cntrycurrent=="Western Europe" // Austria, Belgium, Czech Republic, France, Germany, Luxembourg, Netherlands, Switzerland, UK
*/

tab cntrybirth if region_cntrybirth==""
/*
  Country of birth of the respondent if |
                             not native |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                Andorra |          7        1.45        1.45
                    Antigua and Barbuda |          4        0.83        2.28
                                Bahamas |          6        1.24        3.52
                               Barbados |         10        2.07        5.59
                                 Brunei |         24        4.97       10.56
                             Cape Verde |         33        6.83       17.39
                               Dominica |          6        1.24       18.63
                      Equatorial Guinea |         17        3.52       22.15
                                Eritrea |         32        6.63       28.78
                               Eswatini |         31        6.42       35.20
                                   Fiji |         62       12.84       48.03
                                 Gambia |         23        4.76       52.80
                                Grenada |          5        1.04       53.83
                          Guinea-Bissau |         31        6.42       60.25
                          Liechtenstein |          1        0.21       60.46
                                  Macao |          6        1.24       61.70
                               Maldives |          8        1.66       63.35
                                 Monaco |          5        1.04       64.39
              Nagorno-Karabakh Republic |         16        3.31       67.70
                            North Korea |         14        2.90       70.60
                       Papua New Guinea |          7        1.45       72.05
                                Reunion |          1        0.21       72.26
                  Saint Kitts and Nevis |         56       11.59       83.85
       Saint Vincent and the Grenadines |          8        1.66       85.51
                                  Samoa |         28        5.80       91.30
                             San Marino |          1        0.21       91.51
                             Seychelles |          3        0.62       92.13
                        Solomon Islands |          2        0.41       92.55
                  São Tomé and Príncipe |         16        3.31       95.86
                            Timor-Leste |          1        0.21       96.07
                                  Tonga |         16        3.31       99.38
                            US Hispanic |          1        0.21       99.59
                                Vanuatu |          2        0.41      100.00
----------------------------------------+-----------------------------------
                                  Total |        483      100.00
*/
* Add those countries to their subregion
replace region_cntrybirth="Australia/New Zealand" if cntrybirth=="Fiji" | cntrybirth=="Papua New Guinea" | cntrybirth=="Samoa" | cntrybirth=="Solomon Islands"| cntrybirth=="Tonga" | cntrybirth=="Vanuatu" 
replace region_cntrybirth="Caribbean" if cntrybirth=="Antigua and Barbuda" | cntrybirth=="Bahamas" | cntrybirth=="Barbados" | cntrybirth=="Dominica" | cntrybirth=="Grenada" | cntrybirth=="Saint Kitts and Nevis" | cntrybirth=="Saint Vincent and the Grenadines" 
replace region_cntrybirth="Eastern Asia" if cntrybirth=="Macao" | cntrybirth=="North Korea"  
replace region_cntrybirth="South Asia" if cntrybirth=="Maldives" 
replace region_cntrybirth="South-Eastern Asia" if cntrybirth=="Brunei" | cntrybirth=="Timor-Leste" 
replace region_cntrybirth="Western Asia" if cntrybirth=="Nagorno-Karabakh Republic"  
replace region_cntrybirth="Eastern Africa" if cntrybirth=="Eritrea" 
replace region_cntrybirth="Middle Africa" if cntrybirth=="Equatorial Guinea" 
replace region_cntrybirth="Southern Africa" if cntrybirth=="Eswatini" | cntrybirth=="Reunion" | cntrybirth=="Seychelles" 
replace region_cntrybirth="Western Africa" if cntrybirth=="Cape Verde" | cntrybirth=="Gambia" | cntrybirth=="Guinea-Bissau" | cntrybirth=="São Tomé and Príncipe"  
replace region_cntrybirth="Southern Europe" if cntrybirth=="Andorra" | cntrybirth=="San Marino" 
replace region_cntrybirth="Western Europe" if cntrybirth=="Liechtenstein" | cntrybirth=="Monaco" 

tab dest if region_dest==""
/*
           WP3120 Country Would Move To |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                Andorra |          2        3.12        3.12
                                Bahamas |          3        4.69        7.81
                               Barbados |          5        7.81       15.62
                                 Brunei |          3        4.69       20.31
                             Cape Verde |          5        7.81       28.12
                               Dominica |          5        7.81       35.94
                      Equatorial Guinea |         16       25.00       60.94
                               Eswatini |          2        3.12       64.06
                                   Fiji |          3        4.69       68.75
                                 Gambia |          2        3.12       71.88
                                Grenada |          1        1.56       73.44
                          Guinea-Bissau |          2        3.12       76.56
                               Maldives |          3        4.69       81.25
                             Micronesia |          1        1.56       82.81
                                 Monaco |          2        3.12       85.94
              Nagorno-Karabakh Republic |          1        1.56       87.50
                            North Korea |          2        3.12       90.62
                            Saint Lucia |          1        1.56       92.19
                                  Samoa |          1        1.56       93.75
                             Seychelles |          3        4.69       98.44
                            US Hispanic |          1        1.56      100.00
----------------------------------------+-----------------------------------
                                  Total |         64      100.00
*/ 
replace region_dest="Australia/New Zealand" if dest=="Fiji" | dest=="Papua New Guinea" | dest=="Samoa" | dest=="Solomon Islands"| dest=="Tonga" | dest=="Vanuatu" | dest=="Micronesia"
replace region_dest="Caribbean" if dest=="Antigua and Barbuda" | dest=="Bahamas" | dest=="Barbados" | dest=="Dominica" | dest=="Grenada" | dest=="Saint Kitts and Nevis" | dest=="Saint Vincent and the Grenadines" | dest=="Saint Lucia" 
replace region_dest="Eastern Asia" if dest=="Macao" | dest=="North Korea"  
replace region_dest="South Asia" if dest=="Maldives"
replace region_dest="South-Eastern Asia" if dest=="Brunei" | dest=="Timor-Leste" 
replace region_dest="Western Asia" if dest=="Nagorno-Karabakh Republic" 
replace region_dest="Eastern Africa" if dest=="Eritrea"  
replace region_dest="Middle Africa" if dest=="Equatorial Guinea" 
replace region_dest="Southern Africa" if dest=="Eswatini" | dest=="Reunion" | dest=="Seychelles" 
replace region_dest="Western Africa" if dest=="Cape Verde" | dest=="Gambia" | dest=="Guinea-Bissau" | dest=="São Tomé and Príncipe"  
replace region_dest="Southern Europe" if dest=="Andorra" | dest=="San Marino" 
replace region_dest="Western Europe" if dest=="Liechtenstein" | dest=="Monaco" 

/*
* Continental regions 
gen region_broad_cc= region_cntrycurrent
gen region_broad_cb= region_cntrybirth
gen region_broad_dest=region_dest
foreach k in region_broad_cc region_broad_cb region_broad_dest {
replace `k'="Africa" if `k'=="Eastern Africa"|| `k'=="Middle Africa"|| `k'=="Nothern Africa"|| `k'=="Southern Africa"|| `k'=="Western Africa"
replace `k'="America" if `k'=="Caribbean"|| `k'=="Central America"|| `k'=="Northern America"|| `k'=="South America"
replace `k'="Europe" if `k'=="Eastern Europe"|| `k'=="Nothern Europe"||  `k'=="Southern Europe"|| `k'=="Western Europe"
replace `k'="Asia" if `k'=="Central Asia"|| `k'=="Eastern Asia"|| `k'=="South Asia"|| `k'=="South-Eastern Asia"||`k'=="Western Asia"
replace `k'="Oceania" if `k'=="Australia/New Zealand" 
}
replace region_broad_cc="" if region_cntrycurrent ==""
replace region_broad_cb ="" if region_cntrybirth ==""
replace region_broad_dest="" if region_dest==""


* Schengen Area --> free movement (situation 2009 to 2016) : not yet Latvia (2016),Lithuania (2018)  
gen Europe_dest = dest
foreach k in Europe_dest {
replace `k'="Europe" if `k'=="Austria" || `k'=="Belgium"|| `k'=="Czech Republic"|| `k'=="Denmark" || `k'=="Estonia" || `k'=="Finland" ||  `k'=="France" || ///
`k'=="Germany" || `k'=="Greece" || `k'=="Hungary" || `k'=="Iceland" ||  `k'=="Italy" ||   `k'=="Luxembourg" ||  `k'=="Malta" || `k'=="Netherlands" || ///
`k'=="Norway" || `k'=="Poland" || `k'=="Portugal" || `k'=="Slovakia" ||`k'=="Slovenia" || `k'=="Spain" || `k'=="Sweden" || `k'=="Switzerland" || `k'=="United Kingdom"  ///

replace `k'="non-Europe" if `k' !="Europe"
}
replace Europe_dest="" if dest=="" 

* Small Island Developing States (SIDS)  as of December 2018 --> larger list, here only our destinations in sample 
gen SIDS_dest = dest
label var SIDS_dest "Small Island Developing States (SIDS)"
foreach k in SIDS_dest {
replace `k'="SIDS" if `k'=="Bahamas" || `k'=="Bahrain"|| `k'=="Barbados"|| `k'=="Belize" || `k'=="Cape Verde" || `k'=="Cuba" ||  `k'=="Dominica" || ///
`k'=="Dominican Republic" || `k'=="Fiji" || `k'=="Grenada" || `k'=="Guinea-Bissau" ||  `k'=="Guyana" ||   `k'=="Jamaica" ||  `k'=="Maldives" || `k'=="Micronesia" || ///
`k'=="Saint Lucia" || `k'=="Seychelles" || `k'=="Singapore" || `k'=="Trinidad and Tobago"  ///

replace `k'="non-SIDS" if `k' !="Europe"
}
replace SIDS_dest="" if dest=="" 

* Africa destination 
gen Afr_cc= cntrycurrent
gen Afr_cb= cntrybirth
gen Afr_dest=dest
foreach k in Afr_cc Afr_cb Afr_dest {
replace `k'="Africa" if `k'=="Algeria"|| `k'=="Angola"|| `k'=="Benin"|| `k'=="Botswana"|| ///
`k'=="Burkina Faso"|| `k'=="Burundi"|| `k'=="Cameroon"|| `k'=="Cape Verde"|| `k'=="Central African Republic"|| `k'=="Chad"|| ///
`k'=="Comoros"|| `k'=="Congo Brazzaville"|| `k'=="Congo Kinshasa"|| `k'=="Djibouti"|| `k'=="Egypt"|| ///
`k'=="Ethiopia"|| `k'=="Eritrea"|| `k'=="Equatorial Guinea"|| `k'=="Eswatini"||`k'=="Gambia"||`k'=="Gabon"|| `k'=="Ghana"|| `k'=="Guinea"|| `k'=="Guinea-Bissau" || `k'=="Ivory Coast"|| `k'=="Kenya"|| ///
`k'=="Lesotho"|| `k'=="Liberia"|| `k'=="Libya"|| `k'=="Madagascar"|| `k'=="Malawi"|| `k'=="Mali"|| ///
`k'=="Mauritania"|| `k'=="Mauritius"|| `k'=="Morocco"|| `k'=="Mozambique"||`k'=="Namibia"|| ///
`k'=="Niger"|| `k'=="Nigeria"|| `k'=="Reunion"||`k'=="Rwanda"|| `k'=="Senegal"||`k'=="Seychelles"|| `k'=="Sierra Leone"|| /// 
`k'=="Somalia"|| `k'=="Somaliland"|| `k'=="South Africa"|| `k'=="South Sudan"|| `k'=="Sudan"|| ///
`k'=="Swaziland"|| `k'=="Tanzania"|| `k'=="Gambia"|| `k'=="Guinea-Bissau"||`k'=="Togo"|| `k'=="Tunisia"|| `k'=="Uganda"|| `k'=="Zambia"|| ///
`k'=="Zimbabwe" || `k'=="São Tomé and Príncipe" 

replace `k'="other country" if `k' !="Africa"
}
replace Afr_cc="" if cntrycurrent ==""
replace Afr_cb ="" if cntrybirth ==""
replace Afr_dest="" if dest==""

*** AMERICAS WITHOUT NORTH AMERICA (Canada and United States) VS OTHER DESTINATION
****SO AMERICAS INCLUDES ONLY Central America, South America and Caribbean
gen Amer_cc= cntrycurrent
gen Amer_cb= cntrybirth
gen Amer_dest=dest
foreach k in Amer_cc Amer_cb Amer_dest {
replace `k'="Americas" if `k'=="Argentina" || `k'=="Antigua and Barbuda" ||`k'=="Bahamas"||`k'=="Barbados"||`k'=="Belize"|| `k'=="Bolivia"|| `k'=="Brazil"|| ///
`k'=="Chile"|| `k'=="Colombia"|| `k'=="Costa Rica"|| `k'=="Cuba"||`k'=="Dominica"||`k'=="Dominican Republic"|| ///
`k'=="Ecuador"|| `k'=="El Salvador"|| `k'=="Guatemala"|| `k'=="Guyana"|| `k'=="Grenada"||`k'=="Haiti"|| ///
`k'=="Honduras"|| `k'=="Jamaica"|| `k'=="Mexico"|| `k'=="Nicaragua"|| `k'=="Panama" || `k'=="Paraguay"|| `k'=="Peru"|| `k'=="Saint Lucia"|| ///
`k'=="Saint Kitts and Nevis"||`k'=="Saint Vincent and the Grenadines"||`k'=="Suriname"|| `k'=="Trinidad and Tobago"|| `k'=="Uruguay"|| `k'=="Venezuela"

replace `k'="other country" if `k' !="Americas"
}
replace Amer_cc="" if cntrycurrent ==""
replace Amer_cb ="" if cntrybirth ==""
replace Amer_dest="" if dest==""

** North America 
gen NorthAmer_cc= cntrycurrent
gen NorthAmer_cb= cntrybirth
gen NorthAmer_dest=dest
foreach k in NorthAmer_cc NorthAmer_cb NorthAmer_dest {
replace `k'="Northern America" if `k'=="United States" || `k'=="Canada" 
replace `k'="other country" if `k' !="Northern America"
}
replace NorthAmer_cc="" if cntrycurrent ==""
replace NorthAmer_cb ="" if cntrybirth ==""
replace NorthAmer_dest="" if dest==""

*** OTHER CATEGORIZATIONS*** 
*** ASIA-PACIFIC VS OTHER DESTINATION
gen Asiapacific_cc= cntrycurrent
gen Asiapacific_cb= cntrybirth
gen Asiapacific_dest=dest
foreach k in Asia_cc Asia_cb Asia_dest {
replace `k'="Asia-Pacific" if `k'=="Afghanistan" || `k'=="Australia"|| `k'=="Bangladesh"|| `k'=="Bhutan"|| `k'=="Cambodia"|| ///
`k'=="China"|| `k'=="Macao"||`k'=="Fiji"||`k'=="Hong Kong"|| `k'=="Kiribati"||`k'=="India"|| `k'=="Indonesia"|| `k'=="Maldives"||`k'=="Japan"|| ///
`k'=="Laos"|| `k'=="Malaysia"|| `k'=="Marshall Islands"||`k'=="Micronesia"||`k'=="Mongolia"|| `k'=="Myanmar"|| `k'=="Nauru"||`k'=="Nepal"|| ///
`k'=="New Zealand"|| `k'=="North Korea"||`k'=="Pakistan"|| `k'=="Palau"||`k'=="Papua New Guinea"||`k'=="Philippines"||`k'=="Samoa"||`k'=="Sao Tome & Principe"||  /// 
`k'=="Singapore"|| `k'=="South Korea" || `k'=="Sri Lanka"|| `k'=="Taiwan"|| `k'=="Solomon Islands"|| `k'=="Tonga"|| `k'=="Brunei"|| `k'=="Timor-Leste"||///
`k'=="Solomon Islands"||`k'=="Thailand"|| `k'=="Vanuatu"||`k'=="Vietnam"

replace `k'="other country" if `k' !="Asia-Pacific"
}
replace Asiapacific_cc="" if cntrycurrent ==""
replace Asiapacific_cb ="" if cntrybirth ==""
replace Asiapacific_dest="" if dest==""

**********STILL TO THIS *******
*** FORMER SOVIET UNION VS OTHER DESTINATION
gen FSUdest_int= dest_in
gen FSUdest_plan= dest_pl
gen FSUdest_final=finaldest
foreach k in FSUdest_int FSUdest_plan FSUdest_final {
replace `k'="Former Soviet Union" if `k'=="Armenia" || `k'=="Azerbaijan"|| `k'=="Belarus"|| `k'=="Georgia"|| ///
`k'=="Kazakhstan"|| `k'=="Kyrgyzstan"|| `k'=="Moldova"|| `k'=="Russia"|| `k'=="Tajikistan"|| ///
`k'=="Turkmenistan"|| `k'=="Ukraine"|| `k'=="Uzbekistan"

replace `k'="other country" if `k' !="Former Soviet Union"
}
replace FSUdest_int="" if dest_in ==""
replace FSUdest_plan ="" if dest_pl ==""
replace FSUdest_final="" if finaldest==""


 // Kazakhstan; Kyrgyzstan; Tajikistan; Turkmenistan; Uzbekistan
 cntrybirth=="Nagorno-Karabakh Republic"  
 // Armenia, Azerbaijan, Bahrain, Georgia, Iran, Iraq, Israel, Jordan, Kuwait, Lebanon, Palestina, Saudi Arabia, Syria, Turkey, UAE, Yemen

************************
*/


// --------- Added by Els 22/04/2022 --------
* Bilateral network variable 
gen netw_dest=. // (43,057 missing values generated)
replace netw_dest=1 if wp3333==1 & dest == destFF1 | dest == destFF2 | dest == destFF3 // 33,292 (need columns!!!!) 
replace netw_dest=0 if wp3333!=. & dest!=destFF1 & dest!=destFF2 & dest!=destFF3   // 7,119  but aren't we loosing mabr==0 then?
label var netw_dest "Network at aspired destination" 
tab netw_dest 

* Ilse on skype
gen netwdest= . // (43,057 missing values generated)
replace netwdest= 1 if wp3333 == 1 & destFF1 == dest | destFF2 == dest | destFF3 == dest // (33,292 real changes made)
replace netwdest= 0 if wp3333 != . & destFF1 != dest & destFF2 != dest & destFF3 != dest //(7,119 real changes made)

tab mabr  // same tab wp3333 
/*
   Network |
     abroad |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     12,383       39.41       39.41
          1 |     19,038       60.59      100.00
------------+-----------------------------------
      Total |     31,421      100.00
*/
tab wp3333 
/*
     WP3333 |
			|      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |     19,038       60.59       60.59
         No |     11,974       38.11       98.70
       (DK) |        294        0.94       99.63
  (Refused) |        115        0.37      100.00
------------+-----------------------------------
      Total |     31,421      100.00

*/ 

/*
gen netw_dest=. // (43,057 missing values generated)
replace netw_dest=1 if mabr==1 & dest == destFF1 | dest == destFF2 | dest == destFF3 // 33,292 (need columns!!!!) 
replace netw_dest=0 if mabr!=. & dest!=destFF1 & dest!=destFF2 & dest!=destFF3   // 7,119  but aren't we loosing mabr==0 then?
label var netw_dest "Network at aspired destination" 
tab netw_dest 

gen netw_dest=. // (43,057 missing values generated)
replace netw_dest=1 if mabr==1 & (dest == destFF1 | dest == destFF2 | dest == destFF3) // (14,121 real changes made) 
replace netw_dest=0 if mabr!=. & dest!=destFF1 & dest!=destFF2 & dest!=destFF3   // 7,119  but aren't we loosing mabr==0 then?
label var netw_dest "Network at aspired destination" 
tab netw_dest // 21,240 
*/

* ik 
gen netw_dest2=. // (43,057 missing values generated)
replace netw_dest2=1 if mabr==1 & (dest == destFF1 | dest == destFF2 | dest == destFF3) // (14,121 real changes made) 
replace netw_dest2=0 if mabr==0 | (mabr==1 & dest!=destFF1 & dest!=destFF2 & dest!=destFF3)   // (17,300 real changes made)
tab netw_dest2 //  31,421  (USE THIS ONE?) 
/*
 netw_dest2 |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     17,300       55.06       55.06
          1 |     14,121       44.94      100.00
------------+-----------------------------------
      Total |     31,421      100.00
*/
 
* Check  
gen checknetw = .  // (43,057 missing values generated)
replace checknetw = 1 if dest!="" & mabr==1 & (destFF1 == dest |  destFF2 == dest |  destFF3 == dest)  // (697 real changes made)
replace checknetw = 0 if dest!="" & ((mabr==0) | (mabr==1 & destFF1 != dest &  destFF2 != dest  &  destFF3 != dest)) // (6,479 real changes made)
* --> no, don't do if dest!=. 

gen checknetw2 = .  // (43,057 missing values generated)
replace checknetw2 = 1 if  mabr==1 & (destFF1 == dest |  destFF2 == dest |  destFF3 == dest)  // (14,121 real changes made)
replace checknetw2 = 0 if (mabr==0 | (mabr==1 & destFF1 != dest &  destFF2 != dest  &  destFF3 != dest)) // (17,300 real changes made)
tab checknetw2
* --> yes (USE THIS ONE?) 

gen netw_atdest=.
replace netw_atdest=1 if dest !="" & mabr ==1 & (destFF1 == dest | destFF2 == dest | destFF3 == dest)  //(697 real changes made)
replace netw_atdest=0 if dest !="" & mabr !=. & destFF1 !="" // (1,152 real changes made)
* --> no, don't do if dest!=. 


* new categorization 1
gen mlogit_cat1=. // (43,057 missing values generated)
replace mlogit_cat1=0 if  BMIG_in==0 //  Stay   (33,235 real changes made)
replace mlogit_cat1=1 if (BMIG_in==1 & dest==cntrybirth )  //  Return  (3,218 real changes made)
replace mlogit_cat1=2 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & region_dest==region_cntrycurrent)  //  withinregion  (1,172 real changes made)
replace mlogit_cat1=3 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & region_dest!=region_cntrycurrent & OECD_dest=="OECD" )  //  OECD outside region  (4,540 real changes made)
replace mlogit_cat1=4 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & region_dest!=region_cntrycurrent & OECD_dest=="non-OECD")  //  non-OECD outside region  (892 real changes made)
label var mlogit_cat1 "variable following destination migrant"


* new categorization 1
gen mlogit_catOECD=. // (43,057 missing values generated)
replace mlogit_catOECD=0 if  BMIG_in==0 //  Stay   (33,235 real changes made)
replace mlogit_catOECD=1 if (BMIG_in==1 & dest==cntrybirth )  //  Return  (3,218 real changes made)
replace mlogit_catOECD=2 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & OECD_dest=="OECD" )  //  OECD outside region  (4,540 real changes made)
replace mlogit_catOECD=3 if (BMIG_in==1 & dest!=cntrybirth & dest!= "" & OECD_dest=="non-OECD")  //  non-OECD outside region  (892 real changes made)
label var mlogit_catOECD "variable following destination migrant"


save "Merge/Clean/dta/Return database", replace
