********************************************************************************
* 14 - Religion Dummies
* Bekaert, Constant, Foubert & Ruyssen (2024) - JEBO
********************************************************************************
*
* Purpose: Constructs major religion classification dummies (Christianity, Islam, Other, None) from GWP data.
*
* Input:   GWP religion variables
*
* Output:  Religion dummies
*
* Note: These scripts were developed as part of a collaborative research workflow
* among co-authors over several years. Internal annotations, commented-out file
* paths, and exploratory code blocks reflect this iterative process and have been
* preserved for transparency and reproducibility.
********************************************************************************

* Cleaning GWP - Return migration project

cls 
clear all 
set more off 
set scrollbufsize 500000 
set maxvar 10000
graph drop _all 
capture log close 

*cd "C:\Users\kifouber\Dropbox\Return Migration\Data\"
*cd "D:\Dropbox\Return Migration\Data\"
cd "/Users/elsbekaert/Dropbox/Return Migration/Data/" // Els 
*cd "/Users/ilseruyssen/Dropbox/Return Migration/Data/" // Ilse

use "GWP/Clean/dta/GWP2016 ID_GADM_fine cleaned.dta", clear // Ilse & Els 

**********************
* O/ Select DEPENDENT
**********************
*** Migration duration: tot, perm or temp
global duration perm
*** Strictness of definitions: "standard" or "strict"
global defstrict standard

// -----------------------------------------------------------------------------
// A/ Select required variables
// -----------------------------------------------------------------------------
rename WP* wp*

keep wpid wave wgt origin NAME_1 year wp1220 wp1219 wp3117 wp4657 EMP_2010 wp14 wp4656 wp4868 wp4869 wp7496 INDEX_LE wp119 ///
wp1225 income_2 INCOME_4 wp2319 wp1230 wp1233 wp1223 wp12 wp9042 wp1325 wp3120 wp9498 wp9455 wp4870 wp7624 INDEX_DI ///
wp9499 wp4633 wp3331 wp3333 wp3334 wp3335 wp3336 wp6880 wp10252 wp10253 wp9500 wp9501 wp9502 wp9048 wp7834 INDEX_DE ///
wp85 REGION REGION2 wp4 FIELD_DATE wp5889 wp37 wp39 wp40 wp43 wp44 wp12295 wp12721 wp1690 wp673 wp7837 INDEX_CR ///
wp1328 wp16 wp18 wp69 wp70 wp71 wp73 wp74 wp1418 wp10496 wp14732 wp9700 wp9701 wp17015 wp11356 ID_GADM_fine ID_GADM_coarse high_income ///
INDEX_CA INDEX_CB INDEX_FL INDEX_GWSOC INDEX_GWCOM INDEX_GWPHY INDEX_LO INDEX_NI INDEX_CM NAME_1 wp9039 wp7852 wp7873 ///
INDEX_NX INDEX_OT INDEX_PH INDEX_PX INDEX_ST INDEX_SU INDEX_TH /// 
wp9105 wp10963 wp10248 wp27 wp30 wp12316 wp36 wp38 wp10529 wp12451 wp10256

rename wp1220 age
rename wp1219 gender
rename wp1225 jobcat
rename income_2 hhinc
rename INCOME_4 hhincpc
rename wp1230 children
rename wp1233 relig
rename wp1223 maried
rename wp12 hhsize
rename wp9039 Trust


// -----------------------------------------------------------------------------
// A/ create original dummies for religion (from "Cleaning GWP IR_EB.do")
// -----------------------------------------------------------------------------
*** Create dummy for those born in the country of respondence 
gen native = 0
replace native = 1 if wp4657 ==1
gen nonnative = 0
replace nonnative = 1 if wp4657 ==2

* By Popularity
gen Christianity=1 if relig==1 | relig==2 | relig==3 | relig==28
replace Christianity=0 if Christianity==.
replace Christianity=. if relig==97 | relig==98 | relig==99 | relig==.

gen Islam=1 if relig==4 | relig==5 | relig==6 | relig==7
replace Islam=0 if Islam==.
replace Islam=. if relig==97 | relig==98 | relig==99 | relig==.

gen Judaism=1 if relig==15
replace Judaism=0 if Judaism==.
replace Judaism=. if relig==97 | relig==98 | relig==99 | relig==.

gen NoReligion=1 if relig==26
replace NoReligion=0 if NoReligion==.
replace NoReligion=. if relig==97 | relig==98 | relig==99 | relig==.

gen OtherReligions=1 if relig==0 | relig==8 | relig==9 | relig==11 | relig==18 | relig==21 | relig==29 | relig==10 | relig==12 | relig==13 | relig==14 | relig==16 | relig==17 | relig==19 | relig==20 | relig==22 | relig==23 | relig==24| relig==25
replace OtherReligions=0 if OtherReligions==.
replace OtherReligions=. if relig==97 | relig==98 | relig==99 | relig==.

gen OtherReligionsAndJudaism=1 if relig==0 | relig==8 | relig==9 | relig==11 | relig==15 | relig==18 | relig==21 | relig==29 | relig==10 | relig==12 | relig==13 | relig==14 | relig==16 | relig==17 | relig==19 | relig==20 | relig==22 | relig==23 | relig==24| relig==25
replace OtherReligionsAndJudaism=0 if OtherReligionsAndJudaism==.
replace OtherReligionsAndJudaism=. if relig==97 | relig==98 | relig==99 | relig==.

preserve
drop if native == 0
collapse (sum) sum_NoReligion=NoReligion sum_Christianity=Christianity sum_Islam=Islam sum_Other=OtherReligionsAndJudaism, by(origin)
gen total = sum_NoReligion + sum_Christianity + sum_Islam + sum_Other
gen pct_NoReligion = sum_NoReligion / total * 100
gen pct_Christianity = sum_Christianity / total * 100
gen pct_Islam = sum_Islam / total * 100
gen pct_Other = sum_Other / total * 100
format pct_NoReligion %9.2f
format pct_Christianity %9.2f
format pct_Islam %9.2f
format pct_Other %9.2f
list origin pct_NoReligion pct_Christianity pct_Islam pct_Other in 1/10
export excel using "/Users/elsbekaert/Dropbox/Return Migration/Estimations/Results/Results JEBO/Sharesnativessreligion.xlsx", firstrow(variables) replace
restore


// -----------------------------------------------------------------------------
// B/ Compute by country the share of respondents adhering to each religion
// C/ And then rank for each country those religions and create a dummy for when they together make up the first 50% of the sample
// -----------------------------------------------------------------------------

drop if relig==. | relig==27 | relig==97 | relig==98 | relig==99 // drop those with undefined religion (the 27 is one person without information on what religion it stands for)

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
* Creating a new categorical variable for major religions directly from the 'relig' variable
gen majorReligion = .

* Assigning values based on the codes in the 'relig' variable (see do-file "Cleaning GWP IR_EB")
replace majorReligion = 1 if inlist(relig, 1, 2, 3, 28)   // Christian
replace majorReligion = 2 if inlist(relig, 4, 5, 6, 7)    // Islam/Muslim
replace majorReligion = 3 if relig == 8                   // Hinduism
replace majorReligion = 4 if relig == 9                   // Buddhist
replace majorReligion = 5 if relig == 15                  // Judaism
replace majorReligion = 6 if relig == 26                  // Secular/nonreligious/agnostic/atheist
replace majorReligion = 7 if inlist(relig, 0, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 29) // Other (smaller) religions
/*
                        WP1233 Religion 
----------------------------------------+-----------------------------------
0                           Other (list) 			7
1 Christianity: Roman Catholic, Catholic 			1
2 Christianity: Protestant, Anglican, Eva 			1
3 Christianity: Eastern Orthodox, Orthodo 			1
4                           Islam/Muslim 			2
5                  Islam/Muslim (Shiite) 			2
6                   Islam/Muslim (Sunni) 			2
7                                  Druze 			2
8                               Hinduism 			3
9                               Buddhist 			4
10 Primal-indigenous/African Traditional a 			7
11 Chinese Traditional Religion/Confuciani 			7
12                                Sikhism 			7
13                                  Juche 			7
14                              Spiritism 			7
15                                Judaism 			5
16                                  Bahai 			7	
17                                Jainism 			7
18                                 Shinto 			7
19                                Cao Dai 			7
20                         Zoroastrianism 			7
21                               Tenrikyo 			7
22                           Neo-Paganism 			7
23                 Unitarian-Universalism 			7
24                         Rastafarianism 			7
25                            Scientology 			7
26 Secular/Nonreligious/Agnostic/Atheist/N 			6
27                                      1 			.
28                              Christian     		1
29                          Taoism/Daoism 			7
97        (No response)(2011 and earlier) 			.
98                                   (DK) 			.
99                              (Refused) 			.
----------------------------------------+-----------------------------------
*/
replace majorReligion = . if inlist(relig, 97, 98, 99, .)
label define majorReligion 1 "Christian" ///
                            2 "Islam/Muslim" ///
                            3 "Hinduism" ///
                            4 "Buddhist" ///
                            5 "Judaism" ///
                            6 "Secular/Nonreligious/Agnostic/Atheist" /// 
							7 "Other" 
label values majorReligion majorReligion
tab majorReligion
list majorReligion in 1/10
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

** Create a variable "Freq" to count the frequency of each religion within each country **
gen Freq = 1
collapse (sum) Freq, by(origin majorReligion)

** Sort the data by country and total adherence in descending order
gsort origin -Freq majorReligion

by origin: egen TotalAdh = total(Freq)
by origin: gen cum_Freq = sum(Freq)

*** Generate the percentages
gen AdhPerc = (Freq/TotalAdh) * 100
gen AdhCumPerc = (cum_Freq/TotalAdh) * 100

*** Generate dummy for when this cumulative percentage exceeds 50 or 80 for the first time
gen min50 = 0
gen min80 = 0

replace min50 = 1 if AdhCumPerc >=50
replace min80 = 1 if AdhCumPerc >=80

by origin: gen min50cum = sum(min50)
by origin: gen min80cum = sum(min80)

gen min50first = 0
gen min80first = 0

replace min50first = 1 if min50cum < 2
replace min80first = 1 if min80cum < 2

*** Store this for the 50 percent treshold
preserve 
keep origin majorReligion min50first
keep if min50first == 1
drop min50first 

rename majorReligion Major50Religion

by origin: gen rank = _n
reshape wide Major50Religion, i(origin) j(rank)
duplicates drop origin, force // (0 observations are duplicates)

save "GWP/Clean/dta/Major Religions by country50_categories.dta", replace
/*
*** Checking if the category "Other" which is not a country-specific category appears in the top 50% --> NO so good! 
tab Major50Religion1

                    1 Major50Religion |      Freq.     Percent        Cum.
--------------------------------------+-----------------------------------
                            Christian |         91       62.33       62.33
                         Islam/Muslim |         41       28.08       90.41
                             Hinduism |          2        1.37       91.78
                             Buddhist |          8        5.48       97.26
                              Judaism |          1        0.68       97.95
Secular/Nonreligious/Agnostic/Atheist |          3        2.05      100.00
--------------------------------------+-----------------------------------
                                Total |        146      100.00

tab Major50Religion2

                    2 Major50Religion |      Freq.     Percent        Cum.
--------------------------------------+-----------------------------------
                            Christian |          1       33.33       33.33
Secular/Nonreligious/Agnostic/Atheist |          2       66.67      100.00
--------------------------------------+-----------------------------------
                                Total |          3      100.00
*/
restore

*** Store this for the 80 percent treshold
preserve 
keep origin majorReligion min80first
keep if min80first == 1
drop min80first 

rename majorReligion Major80Religion

*Els
bysort origin: gen rank = _n
reshape wide Major80Religion, i(origin) j(rank)
duplicates drop origin, force // (0 observations are duplicates)

save "GWP/Clean/dta/Major Religions by country80_categories.dta", replace
/*
*** Checking if the category "Other" which is not a country-specific category appears in the top 50% --> YES so tricky!!!!
tab Major80Religion1

                    1 Major80Religion |      Freq.     Percent        Cum.
--------------------------------------+-----------------------------------
                            Christian |         91       62.33       62.33
                         Islam/Muslim |         41       28.08       90.41
                             Hinduism |          2        1.37       91.78
                             Buddhist |          8        5.48       97.26
                              Judaism |          1        0.68       97.95
Secular/Nonreligious/Agnostic/Atheist |          3        2.05      100.00
--------------------------------------+-----------------------------------
                                Total |        146      100.00
								
tab Major80Religion2	
								
                    2 Major80Religion |      Freq.     Percent        Cum.
--------------------------------------+-----------------------------------
                            Christian |          9       19.57       19.57
                         Islam/Muslim |         11       23.91       43.48
                             Hinduism |          3        6.52       50.00
                             Buddhist |          2        4.35       54.35
Secular/Nonreligious/Agnostic/Atheist |         21       45.65      100.00
--------------------------------------+-----------------------------------
                                Total |         46      100.00

tab Major80Religion3

                    3 Major80Religion |      Freq.     Percent        Cum.
--------------------------------------+-----------------------------------
                             Buddhist |          1       50.00       50.00
                                Other |          1       50.00      100.00
--------------------------------------+-----------------------------------
                                Total |          2      100.00


*/
restore


/* 
*** Has to be merged with the GWP dataset:
merge m:1 origin using "GWP/Clean/dta/Major Religions by country_categories.dta", nogen

*** And then there should be the following dummy created to identify whether individuals' religion is one of the major ones in the host country:
gen MajorReligionMatch = .
replace MajorReligionMatch = 1 if relig == MajorReligion
replace MajorReligionMatch = 0 if relig != MajorReligion & relig != .

*** Then this dummy can be used in to replace the religion dummy we have now in our benchmark


*/

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

