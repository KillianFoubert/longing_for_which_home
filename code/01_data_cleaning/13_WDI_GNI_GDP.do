********************************************************************************
* 13 - WDI: GNI and GDP
* Bekaert, Constant, Foubert & Ruyssen (2024) - JEBO
********************************************************************************
*
* Purpose: Downloads and cleans GDP growth and GNI per capita from the World Bank for host and home countries. Constructs income group thresholds.
*
* Input:   World Bank API (wbopendata)
*
* Output:  GNIpc.dta, GDPgrowth.dta
*
* Note: These scripts were developed as part of a collaborative research workflow
* among co-authors over several years. Internal annotations, commented-out file
* paths, and exploratory code blocks reflect this iterative process and have been
* preserved for transparency and reproducibility.
********************************************************************************

* GNI per capita, Atlas method (current US$)
clear
wbopendata, indicator(NY.GNP.PCAP.CD) long nometadata clear

drop if year<2006
drop if year>2015

drop lendingtypename lendingtype incomelevelname incomelevel adminregionname adminregion regionname region
rename countryname origin
rename countrycode iso3o
tostring year, replace
rename ny_gnp_pcap_cd GNIpcOr
label variable GNIpc "GNI per capita, Atlas method (current US$) NY.GNP.PCAP.CD"

save "D:\Dropbox\Return Migration\Data\WDI\Clean\dta\GNIpc.dta", replace
*save "C:\Users\kifouber\Dropbox\Return Migration\Data\WDI\Clean\dta\GNIpc.dta", replace

* Source http://databank.worldbank.org/data/download/site-content/OGHIST.xls --> I'm just not sure about what US$ they use to classify the countries (current? 2017 constant?)
gen LowIncome_zzzzz= 905 if year=="2006"
replace LowIncome_zzzzz= 935 if year=="2007"
replace LowIncome_zzzzz= 975 if year=="2008"
replace LowIncome_zzzzz= 995 if year=="2009"
replace LowIncome_zzzzz= 1005 if year=="2010"
replace LowIncome_zzzzz= 1025 if year=="2011"
replace LowIncome_zzzzz= 1035 if year=="2012"
replace LowIncome_zzzzz= 1045 if year=="2013"
replace LowIncome_zzzzz= 1045 if year=="2014"
replace LowIncome_zzzzz= 1025 if year=="2015"

gen LowerMiddleIncome_zzzzz= 3595 if year=="2006"
replace LowerMiddleIncome_zzzzz= 3705 if year=="2007"
replace LowerMiddleIncome_zzzzz= 3855 if year=="2008"
replace LowerMiddleIncome_zzzzz= 3945 if year=="2009"
replace LowerMiddleIncome_zzzzz= 3975 if year=="2010"
replace LowerMiddleIncome_zzzzz= 4035 if year=="2011"
replace LowerMiddleIncome_zzzzz= 4085 if year=="2012"
replace LowerMiddleIncome_zzzzz= 4125 if year=="2013"
replace LowerMiddleIncome_zzzzz= 4125 if year=="2014"
replace LowerMiddleIncome_zzzzz= 4035 if year=="2015"

gen UpperMiddleIncome_zzzzz= 11115 if year=="2006"
replace UpperMiddleIncome_zzzzz= 11455 if year=="2007"
replace UpperMiddleIncome_zzzzz= 11905 if year=="2008"
replace UpperMiddleIncome_zzzzz= 12195 if year=="2009"
replace UpperMiddleIncome_zzzzz= 12275 if year=="2010"
replace UpperMiddleIncome_zzzzz= 12475 if year=="2011"
replace UpperMiddleIncome_zzzzz= 12615 if year=="2012"
replace UpperMiddleIncome_zzzzz= 12745 if year=="2013"
replace UpperMiddleIncome_zzzzz= 12735 if year=="2014"
replace UpperMiddleIncome_zzzzz= 12475 if year=="2015"

* For high income it has to be strictly superior to the previous limit
gen HighIncome_zzzzz= 11115 if year=="2006"
replace HighIncome_zzzzz= 11455 if year=="2007"
replace HighIncome_zzzzz= 11905 if year=="2008"
replace HighIncome_zzzzz= 12195 if year=="2009"
replace HighIncome_zzzzz= 12275 if year=="2010"
replace HighIncome_zzzzz= 12475 if year=="2011"
replace HighIncome_zzzzz= 12615 if year=="2012"
replace HighIncome_zzzzz= 12745 if year=="2013"
replace HighIncome_zzzzz= 12735 if year=="2014"
replace HighIncome_zzzzz= 12475 if year=="2015"

destring year, replace
replace year=year+1
tostring year, replace

rename GNIpcOr GNIpc_zzzzz

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

drop iso3o
merge m:1 origin using "D:\Dropbox\Return Migration\Data\iso3 codes\Clean\iso3clean.dta"
*merge m:1 origin using "C:\Users\kifouber\Dropbox\Return Migration\Data\iso3 codes\Clean\iso3clean.dta"

drop if _merge!=3 & iso3o==""
drop _merge

destring year, replace
keep year GNIpc_zzzzz LowIncome_zzzzz LowerMiddleIncome_zzzzz UpperMiddleIncome_zzzzz HighIncome_zzzzz iso3o
duplicates drop 
rename *zzzzz *cntrycurrent
rename iso3o iso3_cntrycurrent

save "D:\Dropbox\Return Migration\Data\WDI\Clean\dta\GNIpc_cntrycurrent", replace
*save "C:\Users\kifouber\Dropbox\Return Migration\Data\WDI\Clean\dta\GNIpc_cntrycurrent", replace

rename *cntrycurrent *cntrybirth

save "D:\Dropbox\Return Migration\Data\WDI\Clean\dta\GNIpc_cntrybirth", replace
*save "C:\Users\kifouber\Dropbox\Return Migration\Data\WDI\Clean\dta\GNIpc_cntrybirth", replace

rename *cntrybirth *dest

save "D:\Dropbox\Return Migration\Data\WDI\Clean\dta\GNIpc_dest", replace
*save "C:\Users\kifouber\Dropbox\Return Migration\Data\WDI\Clean\dta\GNIpc_dest", replace


********************************************************************************
**** GDP per capita, PPP (constant 2017 US$)
********************************************************************************
clear
wbopendata, indicator(NY.GDP.PCAP.PP.KD) long nometadata clear

drop if year<2006
drop if year>2015

drop lendingtypename lendingtype incomelevelname incomelevel adminregionname adminregion regionname region
rename countryname origin
rename countrycode iso3o
rename ny_gdp_pcap_pp_kd GDPpc
label variable GDPpc "GDP per capita, (constant 2017 US$) NY.GDP.PCAP.PP.KD"

replace year=year+1
tostring year, replace

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

drop iso3o
merge m:1 origin using "D:\Dropbox\Return Migration\Data\iso3 codes\Clean\iso3clean.dta"
*merge m:1 origin using "C:\Users\kifouber\Dropbox\Return Migration\Data\iso3 codes\Clean\iso3clean.dta"

drop if _merge!=3 & iso3o=="" // (520 observations deleted)
drop _merge
destring year, replace
keep year origin iso3o GDPpc
duplicates drop
rename iso3o iso3_cntrycurrent

rename GDPpc GDPpc_cntrycurrent

save "D:\Dropbox\Return Migration\Data\WDI\Clean\dta\GDPpc_cntrycurrent", replace
*save "C:\Users\kifouber\Dropbox\Return Migration\Data\WDI\Clean\dta\GDPpc_cntrycurrent", replace

rename *cntrycurrent *cntrybirth

save "D:\Dropbox\Return Migration\Data\WDI\Clean\dta\GDPpc_cntrybirth", replace
*save "C:\Users\kifouber\Dropbox\Return Migration\Data\WDI\Clean\dta\GDPpc_cntrybirth", replace

rename *cntrybirth *dest

save "D:\Dropbox\Return Migration\Data\WDI\Clean\dta\GDPpc_dest", replace
*save "C:\Users\kifouber\Dropbox\Return Migration\Data\WDI\Clean\dta\GDPpc_dest", replace


********************************************************************************
*** GDP growth (annual %)
********************************************************************************
clear
wbopendata, indicator(NY.GDP.MKTP.KD.ZG) long nometadata clear

drop if year<2006
drop if year>2015

rename countryname origin
rename countrycode iso3o
rename ny_gdp_mktp_kd_zg GDPgrowth
drop lendingtypename lendingtype incomelevelname incomelevel adminregionname adminregion regionname region
label variable GDPgrowth "GDP growth (annual %), NY.GDP.MKTP.KD.ZG"

replace year=year+1
tostring year, replace

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

drop iso3o
merge m:1 origin using "D:\Dropbox\Return Migration\Data\iso3 codes\Clean\iso3clean.dta"
*merge m:1 origin using "C:\Users\kifouber\Dropbox\Return Migration\Data\iso3 codes\Clean\iso3clean.dta"

drop if _merge!=3 & iso3o=="" // (500 observations deleted)
drop _merge
destring year, replace
keep year origin iso3o GDPgrowth
duplicates drop
rename iso3o iso3_cntrycurrent

rename GDPgrowth GDPgrowth_cntrycurrent

save "D:\Dropbox\Return Migration\Data\WDI\Clean\dta\GDPgrowth_cntrycurrent", replace
*save "C:\Users\kifouber\Dropbox\Return Migration\Data\WDI\Clean\dta\GDPgrowth_cntrycurrent", replace

rename *cntrycurrent *cntrybirth

save "D:\Dropbox\Return Migration\Data\WDI\Clean\dta\GDPgrowth_cntrybirth", replace
*save "C:\Users\kifouber\Dropbox\Return Migration\Data\WDI\Clean\dta\GDPgrowth_cntrybirth", replace

rename *cntrybirth *dest

save "D:\Dropbox\Return Migration\Data\WDI\Clean\dta\GDPgrowth_dest", replace
*save "C:\Users\kifouber\Dropbox\Return Migration\Data\WDI\Clean\dta\GDPgrowth_dest", replace
