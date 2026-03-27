********************************************************************************
* 08 - Natural Disasters (EM-DAT)
* Bekaert, Constant, Foubert & Ruyssen (2024) - JEBO
********************************************************************************
*
* Purpose: Constructs disaster occurrence frequency for host and home countries from the EM-DAT database.
*
* Input:   EM-DAT data
*
* Output:  Disaster frequency (host/home).dta
*
* Note: These scripts were developed as part of a collaborative research workflow
* among co-authors over several years. Internal annotations, commented-out file
* paths, and exploratory code blocks reflect this iterative process and have been
* preserved for transparency and reproducibility.
********************************************************************************

clear all

*cd "/Users/elsbekaert/Dropbox/Return Migration/Data/EMDAT"
*cd "/Users/ilseruyssen/Dropbox/Return Migration/Data/EMDAT"
cd "C:\Users\kifouber\Dropbox\Return Migration\Data\EMDAT" // Killian laptop
use "Data EMDAT.dta", clear

/*
* Get ISO Code 
keep ISO Countryname
sort ISO Countryname
duplicates drop
replace Countryname = "Bolivia" if Countryname=="Bolivia (Plurinational State of)"
replace Countryname = "Czech Republic" if Countryname=="Czech Republic (the)"
replace Countryname = "Dominican Republic" if Countryname=="Dominican Republic (the)"
replace Countryname = "South Korea" if Countryname=="Korea (the Republic of)"
replace Countryname = "Moldova" if Countryname=="Moldova (the Republic of)"
replace Countryname = "Netherlands" if Countryname=="Netherlands (the)"
replace Countryname = "Niger" if Countryname=="Niger (the)"
replace Countryname = "Palestinian Territories" if Countryname=="Palestine, State of"
replace Countryname = "Philippines" if Countryname=="Philippines (the)"
replace Countryname = "Russia" if Countryname=="Russian Federation (the)"
replace Countryname = "Sudan" if Countryname=="Sudan (the)"
replace Countryname = "Tanzania" if Countryname=="Tanzania, United Republic of"
replace Countryname = "United Arab Emirates" if Countryname=="United Arab Emirates (the)"
replace Countryname = "United Kingdom" if Countryname=="United Kingdom of Great Britain and Northern Ireland (the)"
replace Countryname = "United States" if Countryname=="United States of America (the)"
replace Countryname = "Venezuela" if Countryname=="Venezuela (Bolivarian Republic of)"
replace Countryname = "Vietnam" if Countryname=="Viet Nam"
replace Countryname = "Comoros" if Countryname=="Comoros (the)"
replace Countryname = "Macedonia" if Countryname=="Macedonia (the former Yugoslav Republic of)"
replace Countryname = "Syria" if Countryname=="Syrian Arab Republic"
replace Countryname = "Taiwan" if Countryname=="Taiwan (Province of China)"
replace Countryname = "Serbia and Montenegro" if Countryname=="Serbia Montenegro"
replace Countryname = "Congo Kinshasa" if Countryname=="Congo (the Democratic Republic of the)"
replace Countryname = "Congo Brazzaville" if Countryname=="Congo (the)"
replace Countryname = "Iran" if Countryname=="Iran (Islamic Republic of)"
replace Countryname = "Laos" if Countryname=="Lao People's Democratic Republic (the)"
rename Countryname origin
drop ISO if ISO==.
save "ISOcodes.dta", replace  
*/

gen year = real(Year) 
drop Year
drop if year < 2008
drop if year > 2016

encode Countryname, gen(countryname)  // encode countryname as Countryname is a string variable 
drop Countryname
keep if Group=="Natural"  // 465 observations deleted 
drop if Subgroup=="Biological" // 90 observations deleted 

keep ISO countryname year Group Subgroup Type Totaldeaths Numinjured Numaffected Totalaffected
order ISO countryname year Group Subgroup Type Totaldeaths Numinjured Numaffected Totalaffected

*-------------- Create dummy var's for extreme temp, drought and flood -------- 
egen dis_nr = group(Type)
tab Type, gen(dis_)
rename dis_1 Drought
rename dis_2 Earthquake
rename dis_3 Extreme_temperature
rename dis_4 Flood
rename dis_5 Landslide
rename dis_6 Dry_mass_movement
rename dis_7 Storm
rename dis_8 Volcanic_activity
rename dis_9 Wildfire

collapse (sum) Drought Earthquake Extreme_temperature Flood Landslide Dry_mass_movement Storm Volcanic_activity Wildfire, by(countryname year)
global VarsYearlyFreq Drought Earthquake Extreme_temperature Flood Landslide Dry_mass_movement Storm Volcanic_activity Wildfire

egen disaster_freq = rowtotal($VarsYearlyFreq)
sum disaster_freq

//------------------------------------------
// Create full matrix and replace missings by zeros
//------------------------------------------
tsset countryname year 
tsfill, full 

foreach k in $VarsYearlyFreq disaster_freq {
	replace `k'=0 if `k'==.
}

//------------------------------------------
// Create overall disaster indicators: Occurrence 
//------------------------------------------
foreach k in $VarsYearlyFreq {
	gen `k'_occ = 0
	replace `k'_occ = 1 if `k'>0
}

global VarsOccurrence Drought_occ Earthquake_occ Extreme_temperature_occ Flood_occ Landslide_occ Dry_mass_movement_occ Storm_occ Volcanic_activity_occ Wildfire_occ

egen disaster_occ = rowmax ($VarsOccurrence)
sum *_occ // gives:
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
 Drought_occ |      1,683    .0926916     .290086          0          1
Earthquake~c |      1,683     .083779    .2771384          0          1
Extreme_te~c |      1,683      .09388    .2917484          0          1
   Flood_occ |      1,683    .4266191    .4947329          0          1
Landslide_~c |      1,683    .0005942    .0243757          0          1
-------------+---------------------------------------------------------
Dry_mass_m~c |      1,683    .0629828    .2430042          0          1
   Storm_occ |      1,683    .0041592     .064377          0          1
Volcanic_a~c |      1,683    .2204397    .4146664          0          1
Wildfire_occ |      1,683    .0172311    .1301702          0          1
disaster_occ |      1,683    .5965538    .4907346          0          1
*/

decode countryname, gen(Countryname)
drop countryname
order Countryname year

*** Merge prepare 
replace Countryname = "Bolivia" if Countryname=="Bolivia (Plurinational State of)"
replace Countryname = "Czech Republic" if Countryname=="Czech Republic (the)"
replace Countryname = "Dominican Republic" if Countryname=="Dominican Republic (the)"
replace Countryname = "South Korea" if Countryname=="Korea (the Republic of)"
replace Countryname = "Moldova" if Countryname=="Moldova (the Republic of)"
replace Countryname = "Netherlands" if Countryname=="Netherlands (the)"
replace Countryname = "Niger" if Countryname=="Niger (the)"
replace Countryname = "Palestinian Territories" if Countryname=="Palestine, State of"
replace Countryname = "Philippines" if Countryname=="Philippines (the)"
replace Countryname = "Russia" if Countryname=="Russian Federation (the)"
replace Countryname = "Sudan" if Countryname=="Sudan (the)"
replace Countryname = "Tanzania" if Countryname=="Tanzania, United Republic of"
replace Countryname = "United Arab Emirates" if Countryname=="United Arab Emirates (the)"
replace Countryname = "United Kingdom" if Countryname=="United Kingdom of Great Britain and Northern Ireland (the)"
replace Countryname = "United States" if Countryname=="United States of America (the)"
replace Countryname = "Venezuela" if Countryname=="Venezuela (Bolivarian Republic of)"
replace Countryname = "Vietnam" if Countryname=="Viet Nam"
replace Countryname = "Comoros" if Countryname=="Comoros (the)"
replace Countryname = "Macedonia" if Countryname=="Macedonia (the former Yugoslav Republic of)"
replace Countryname = "Syria" if Countryname=="Syrian Arab Republic"
replace Countryname = "Taiwan" if Countryname=="Taiwan (Province of China)"
replace Countryname = "Serbia and Montenegro" if Countryname=="Serbia Montenegro"
replace Countryname = "Congo Kinshasa" if Countryname=="Congo (the Democratic Republic of the)"
replace Countryname = "Congo Brazzaville" if Countryname=="Congo (the)"
replace Countryname = "Iran" if Countryname=="Iran (Islamic Republic of)"
replace Countryname = "Laos" if Countryname=="Lao People's Democratic Republic (the)"
 
rename Countryname origin 

*Add ISO code back
merge m:1 origin using "ISOcodes.dta"
order ISO origin 
sort origin year
drop if _merge==2
drop if ISO==""

/*

    Result                           # of obs.
    -----------------------------------------
    not matched                            44
        from master                         0  (_merge==1)
        from using                         44  (_merge==2)

    matched                             1,683  (_merge==3)
    -----------------------------------------

*/ 

replace year = year+1 
keep ISO origin year disaster_freq disaster_occ
save "Disaster_Occurrance_Freq.dta", replace

rename ISO iso3_cntrycurrent
rename disaster_freq disaster_freq_cntrycurrent
rename disaster_occ disaster_occ_cntrycurrent
save "Disaster_Occurrance_Freq - Current country", replace

rename iso3_cntrycurrent iso3_cntrybirth
rename disaster_freq_cntrycurrent disaster_freq_cntrybirth
rename disaster_occ_cntrycurrent disaster_occ_cntrybirth
save "Disaster_Occurrance_Freq - Birth country", replace

rename iso3_cntrybirth iso3_dest
rename disaster_freq_cntrybirth disaster_freq_dest
rename disaster_occ_cntrybirth disaster_occ_dest
save "Disaster_Occurrance_Freq - Dest", replace

*---------------------------------------------------------
**  change field_date dataset to match mdate emdat 
*---------------------------------------------------------
