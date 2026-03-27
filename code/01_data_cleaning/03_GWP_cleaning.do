********************************************************************************
* 03 - Gallup World Poll Cleaning
* Bekaert, Constant, Foubert & Ruyssen (2024) - JEBO
********************************************************************************
*
* Purpose: Cleans GWP microdata for first-generation immigrants (18-75). Constructs dependent variable (stay/return/onwards), individual controls, network proxies, and wellbeing indicators.
*
* Input:   GWP raw data (2009-2016)
*
* Output:  GallupCleaned.dta
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

*** Clear wp12295  // (Thinking about yesterday, approximately how many hours did you interact with your close relatives, either in person, over the phone, or using Skype?)  
decode wp12295, gen (wp12295bis)
drop wp12295
rename wp12295bis wp12295
replace wp12295="0" if wp12295=="(None)"
replace wp12295="." if wp12295=="(Less than 1 hour)"
replace wp12295="." if wp12295=="(DK)"
replace wp12295="." if wp12295=="(Refused)"
destring wp12295, replace

*** Clear wp12721   //  (How many hours did you spend with your spouse, parents, and/or children yesterday?) 
gen wp12721bis = .
replace wp12721bis=0 if wp12721==0
replace wp12721bis=1 if wp12721==1
replace wp12721bis=2 if wp12721==2
replace wp12721bis=3 if wp12721==3
replace wp12721bis=4 if wp12721==4
replace wp12721bis=5 if wp12721==5
replace wp12721bis=6 if wp12721==6
replace wp12721bis=7 if wp12721==7
replace wp12721bis=8 if wp12721==8
replace wp12721bis=9 if wp12721==9
replace wp12721bis=10 if wp12721==10
replace wp12721bis=11 if wp12721==11
replace wp12721bis=12 if wp12721==12
replace wp12721bis=13 if wp12721==13
replace wp12721bis=14 if wp12721==14
replace wp12721bis=15 if wp12721==15
replace wp12721bis=16 if wp12721==16
replace wp12721bis=17 if wp12721==17
replace wp12721bis=18 if wp12721==18
replace wp12721bis=19 if wp12721==19
replace wp12721bis=20 if wp12721==20
replace wp12721bis=21 if wp12721==21
replace wp12721bis=22 if wp12721==22
replace wp12721bis=23 if wp12721==23
replace wp12721bis=24 if wp12721==24
drop wp12721
rename wp12721bis wp12721

*** Clear wp18 // (Please imagine a ladder with steps numbered from 0 at the bottom to 10 at the top. 
*Suppose we say that the top of the ladder represents the best possible life for you, and the bottom of the ladder represents the worst possible life for you. 
*Just your best guess, on which step do you think you will stand on in the future, say about five years from now?) 
gen wp18bis=.
replace wp18bis=0 if wp18==0
replace wp18bis=1 if wp18==1
replace wp18bis=2 if wp18==2
replace wp18bis=3 if wp18==3
replace wp18bis=4 if wp18==4
replace wp18bis=5 if wp18==5
replace wp18bis=6 if wp18==6
replace wp18bis=7 if wp18==7
replace wp18bis=8 if wp18==8
replace wp18bis=9 if wp18==9
replace wp18bis=10 if wp18==10
drop wp18
rename wp18bis wp18

*** Clear wp1690  // (Would you tell me how you feel about various aspects of your life today? Would you say you are very satisfied, somewhat satisfied, 
* neither satisfied nor dissatisfied, somewhat dissatisfied, or very dissatisfied with the following? Your family life) 
decode wp1690, gen (wp1690bis)
drop wp1690
rename wp1690bis wp1690
replace wp1690="1" if wp1690=="Very dissatisfied"
replace wp1690="2" if wp1690=="Somewhat dissatisfied"
replace wp1690="3" if wp1690=="Neither satisfied nor dissatisfied"
replace wp1690="4" if wp1690=="Somewhat satisfied"
replace wp1690="5" if wp1690=="Very satisfied"
replace wp1690="." if wp1690=="(DK)"
replace wp1690="." if wp1690=="(Refused)"
replace wp1690="." if wp1690==""

*** Clear wp4656  // (All things considered, how satisfied are you with your life as a whole these days? Use a 0 to 10 scale, where 0 is dissatisfied and 10 is satisfied.) 
gen wp4656bis = .
replace wp4656bis=0 if wp4656==0
replace wp4656bis=1 if wp4656==1
replace wp4656bis=2 if wp4656==2
replace wp4656bis=3 if wp4656==3
replace wp4656bis=4 if wp4656==4
replace wp4656bis=5 if wp4656==5
replace wp4656bis=6 if wp4656==6
replace wp4656bis=7 if wp4656==7
replace wp4656bis=8 if wp4656==8
replace wp4656bis=9 if wp4656==9
replace wp4656bis=10 if wp4656==10
drop wp4656
rename wp4656bis wp4656

*** Clear wp4868 // Had to recode the variable -> 0 not at all, 4 extremely strongly
/*(How strongly do you identify with each of the following groups -- 1 being extremely strongly and 5 being not at all? Your ethnic background (i.e., Arab, Kurd, Pashtun).)*/ 
gen wp4868bis = .
replace wp4868bis=0 if wp4868==5
replace wp4868bis=1 if wp4868==4
replace wp4868bis=2 if wp4868==3
replace wp4868bis=3 if wp4868==2
replace wp4868bis=4 if wp4868==1
replace wp4868bis=. if wp4868==6
replace wp4868bis=. if wp4868==7
drop wp4868
rename wp4868bis wp4868

*** Clear wp4869 // Had to recode the variable -> 0 not at all, 4 extremely strongly
* (How strongly do you identify with each of the following groups -- 1 being extremely strongly and 5 being not at all? Your religious sect) 
gen wp4869bis = .
replace wp4869bis=0 if wp4869==5
replace wp4869bis=1 if wp4869==4
replace wp4869bis=2 if wp4869==3
replace wp4869bis=3 if wp4869==2
replace wp4869bis=4 if wp4869==1
replace wp4869bis=. if wp4869==6
replace wp4869bis=. if wp4869==7
drop wp4869
rename wp4869bis wp4869

*** Clear wp4870 // Had to recode the variable -> 0 not at all, 4 extremely strongly
* (How strongly do you identify with each of the following groups -- 1 being extremely strongly and 5 being not at all? Your tribe.) 
gen wp4870bis = .
replace wp4870bis=0 if wp4870==5
replace wp4870bis=1 if wp4870==4
replace wp4870bis=2 if wp4870==3
replace wp4870bis=3 if wp4870==2
replace wp4870bis=4 if wp4870==1
replace wp4870bis=. if wp4870==6
replace wp4870bis=. if wp4870==7
drop wp4870
rename wp4870bis wp4870

*** Clear wp673 // Had to recode the variable -> 0 not at all, 4 extremely strongly
* (How strongly do you identify with each of the following groups (1 being extremely strongly and 5 being not at all)? Your country.)
gen wp673bis = .
replace wp673bis=0 if wp673==5
replace wp673bis=1 if wp673==4
replace wp673bis=2 if wp673==3
replace wp673bis=3 if wp673==2
replace wp673bis=4 if wp673==1
replace wp673bis=. if wp673==6
replace wp673bis=. if wp673==7
drop wp673
rename wp673bis wp673

*** Clear wp7496
* (Which of the following statement describes your attitude toward life for the next 10 years? 
*My career is the most important thing, my family is the most important thing, both career and family are equally important.) 
gen wp7496bis = .
replace wp7496bis=1 if wp7496==1
replace wp7496bis=2 if wp7496==2
replace wp7496bis=3 if wp7496==3
replace wp7496bis=4 if wp7496==4
replace wp7496bis=. if wp7496==8
replace wp7496bis=. if wp7496==9
drop wp7496
rename wp7496bis wp7496

*** Clear wp7624
* (People have different views about themselves and how they relate to the world. 
* Please tell me which of the following statements best represents your point of view.)
gen wp7624bis = .
replace wp7624bis=1 if wp7624==1
replace wp7624bis=2 if wp7624==2
replace wp7624bis=3 if wp7624==3
replace wp7624bis=4 if wp7624==4
replace wp7624bis=. if wp7624==8
replace wp7624bis=. if wp7624==9
drop wp7624
rename wp7624bis wp7624

*** Clear wp7834 // Had to recode the variable -> 0 not at all, 4 extremely strongly
* (How strongly do you identify with each of the following groups: Extremely strongly, very strongly, moderately strongly, only a little, not at all. Your country.) 
gen wp7834bis = .
replace wp7834bis=0 if wp7834==5
replace wp7834bis=1 if wp7834==4
replace wp7834bis=2 if wp7834==3
replace wp7834bis=3 if wp7834==2
replace wp7834bis=4 if wp7834==1
replace wp7834bis=. if wp7834==6
replace wp7834bis=. if wp7834==7
drop wp7834
rename wp7834bis wp7834

*** Clear wp7837 // Had to recode the variable -> 0 not at all, 4 extremely strongly
* (How strongly do you identify with each of the following groups: Extremely strongly, very strongly, moderately strongly, only a little, not at all? Your nationality)
gen wp7837bis = .
replace wp7837bis=0 if wp7837==5
replace wp7837bis=1 if wp7837==4
replace wp7837bis=2 if wp7837==3
replace wp7837bis=3 if wp7837==2
replace wp7837bis=4 if wp7837==1
replace wp7837bis=. if wp7837==6
replace wp7837bis=. if wp7837==7
drop wp7837
rename wp7837bis wp7837

*** Clear wp7852 // Had to recode the variable -> 0 not at all, 4 extremely strongly
* (How strongly do you identify with each of the following groups: Extremely strongly, very strongly, moderately strongly, only a little, not at all. Your religious sect.)
gen wp7852bis = .
replace wp7852bis=0 if wp7852==5
replace wp7852bis=1 if wp7852==4
replace wp7852bis=2 if wp7852==3
replace wp7852bis=3 if wp7852==2
replace wp7852bis=4 if wp7852==1
replace wp7852bis=. if wp7852==6
replace wp7852bis=. if wp7852==7
drop wp7852
rename wp7852bis wp7852

*** Clear wp7873 // Had to recode the variable -> 1 = right direction, 0 wrong
* (In your opinion, and all things considered, are things currently in this country going in the right direction, or in the wrong direction?) 
gen wp7873bis = .
replace wp7873bis=1 if wp7873==1
replace wp7873bis=0 if wp7873==2
replace wp7873bis=. if wp7873==3
replace wp7873bis=. if wp7873==4
drop wp7873
rename wp7873bis wp7873

*** Clear wp119  // (Is religion an important part of your daily life?) 
gen wp119bis = .
replace wp119bis=1 if wp119==1
replace wp119bis=0 if wp119==2
replace wp119bis=. if wp119==3
replace wp119bis=. if wp119==4

*** Clear INDEX_GWCOM // Had to recode the variable -> 0 = suffering, 1 = struggling, 2 = thriving
* (A component of well-being that includes liking where you live, feeling safe and having pride in your community) 
gen INDEX_GWCOMbis = .
replace INDEX_GWCOMbis=0 if INDEX_GWCOM==3
replace INDEX_GWCOMbis=1 if INDEX_GWCOM==2
replace INDEX_GWCOMbis=2 if INDEX_GWCOM==1
drop INDEX_GWCOM
rename INDEX_GWCOMbis INDEX_GWCOM

*** Clear INDEX_GWSOC // Had to recode the variable -> 0 = suffering, 1 = struggling, 2 = thriving
* (A component of well-being that includes having supportive relationships and love in your life.) 
gen INDEX_GWSOCbis = .
replace INDEX_GWSOCbis=0 if INDEX_GWSOC==3
replace INDEX_GWSOCbis=1 if INDEX_GWSOC==2
replace INDEX_GWSOCbis=2 if INDEX_GWSOC==1
drop INDEX_GWSOC
rename INDEX_GWSOCbis INDEX_GWSOC

*** Clear INDEX_CA
* (The Community Attachment Index measures respondents' satisfaction with the city where they live and their likelihood to move away or recommend that city to a friend.) 
// Double check the definition of the variable
gen INDEX_CAbis = .
replace INDEX_CAbis=0 if INDEX_CA==0
replace INDEX_CAbis=33.33 if INDEX_CA==33.33333333333333
replace INDEX_CAbis=50 if INDEX_CA==50
replace INDEX_CAbis=66.67 if INDEX_CA>66 & INDEX_CA<67
replace INDEX_CAbis=100 if INDEX_CA==100
drop INDEX_CA
rename INDEX_CAbis INDEX_CA

*** Clear INDEX_CB
* (The Community Basics Index measures satisfaction with aspects of everyday life in a community, including education, environment, healthcare, housing, and infrastructure.)
// Double check the definition of the variable
gen INDEX_CBbis = .
replace INDEX_CBbis=0 if INDEX_CB==0
replace INDEX_CBbis=14.29 if INDEX_CB>14 & INDEX_CB<15
replace INDEX_CBbis=16.67 if INDEX_CB>16 & INDEX_CB<17
replace INDEX_CBbis=20 if INDEX_CB==20
replace INDEX_CBbis=28.57 if INDEX_CB>28 & INDEX_CB<29
replace INDEX_CBbis=33.33 if INDEX_CB>33 & INDEX_CB<34
replace INDEX_CBbis=40 if INDEX_CB==40
replace INDEX_CBbis=42.86 if INDEX_CB>42 & INDEX_CB<43
replace INDEX_CBbis=50 if INDEX_CB==50
replace INDEX_CBbis=57.14 if INDEX_CB>57 & INDEX_CB<58
replace INDEX_CBbis=60 if INDEX_CB==60
replace INDEX_CBbis=66.67 if INDEX_CB>66 & INDEX_CB<67
replace INDEX_CBbis=71.43 if INDEX_CB>71 & INDEX_CB<72
replace INDEX_CBbis=80 if INDEX_CB==80
replace INDEX_CBbis=83.33 if INDEX_CB>83 & INDEX_CB<84
replace INDEX_CBbis=85.71 if INDEX_CB>85 & INDEX_CB<86
replace INDEX_CBbis=100 if INDEX_CB==100
drop INDEX_CB
rename INDEX_CBbis INDEX_CB

*** Clear INDEX_GWFIN // Had to recode the variable -> 0 = suffering, 1 = struggling, 2 = thriving 
* (A component of well-being that includes managing your economic life to reduce stress and increase security.)
/*gen INDEX_GWFINbis = .
replace INDEX_GWFINbis=0 if INDEX_GWFIN==3
replace INDEX_GWFINbis=1 if INDEX_GWFIN==2
replace INDEX_GWFINbis=2 if INDEX_GWFIN==1
drop INDEX_GWFIN
rename INDEX_GWFINbis INDEX_GWFIN
*/

*** Clear INDEX_GWPHY // Had to recode the variable -> 0 = suffering, 1 = struggling, 2 = thriving
*(A component of well-being that includes having good health and enough energy to get things done daily.)
gen INDEX_GWPHYbis = .
replace INDEX_GWPHYbis=0 if INDEX_GWPHY==3
replace INDEX_GWPHYbis=1 if INDEX_GWPHY==2
replace INDEX_GWPHYbis=2 if INDEX_GWPHY==1
drop INDEX_GWPHY
rename INDEX_GWPHYbis INDEX_GWPHY

*** Clear INDEX_LO
/* The Law and Order Index measures security levels that respondents report for themselves and their families.
 Two elements make up this index: one composed of respondents' reported confidence in local police and feeling safe
 walking alone at night, and the other of two questions about respondents' experiences with crime.*/
// Double check the definition of the variable
gen INDEX_LObis = .
replace INDEX_LObis=0 if INDEX_LO==0
replace INDEX_LObis=25 if INDEX_LO==25
replace INDEX_LObis=33.33 if INDEX_LO>33 & INDEX_LO<34
replace INDEX_LObis=50 if INDEX_LO==50
replace INDEX_LObis=66.67 if INDEX_LO>66 & INDEX_LO<67
replace INDEX_LObis=75 if INDEX_LO==75
replace INDEX_LObis=100 if INDEX_LO==100
drop INDEX_LO
rename INDEX_LObis INDEX_LO

*** Clear INDEX_NI
*The National Institutions Index measures confidence in key national institutions prominent in leading a country: 
* the military, the judicial system, the national government, and the honesty of elections.	
// Double check the definition of the variable
gen INDEX_NIbis = .
replace INDEX_NIbis=0 if INDEX_NI==0
replace INDEX_NIbis=25 if INDEX_NI==25
replace INDEX_NIbis=33.33 if INDEX_NI>33 & INDEX_NI<34
replace INDEX_NIbis=50 if INDEX_NI==50
replace INDEX_NIbis=66.67 if INDEX_NI>66 & INDEX_NI<67
replace INDEX_NIbis=75 if INDEX_NI==75
replace INDEX_NIbis=100 if INDEX_NI==100
drop INDEX_NI
rename INDEX_NIbis INDEX_NI

*** Clear trust variable
* wp9039:(Generally speaking, would you say that most people can be trusted or that you have to be careful in dealing with people?) 
replace Trust = 0 if Trust==2
replace Trust = 1 if Trust==1
replace Trust = . if Trust==3 | Trust==4

*** Rescale education (distinguish between low skilled, medium skilled and high skilled)
gen educ = .
replace educ = 0 if wp3117== 1 
replace educ = 1 if wp3117== 2
replace educ = 2 if wp3117== 3
drop wp3117

*Create highskilled and mediumskilled dummy from educ (coded 0 or 1 instead of 1 or 2)
gen hskill = .
replace hskill = 1 if educ==2
replace hskill = 0 if educ==0 | educ==1

gen mskill = .
replace mskill = 1 if educ==1
replace mskill = 0 if educ==2 | educ==0

gen lskill = .
replace lskill = 1 if educ==0
replace lskill = 0 if educ==1 | educ==2

gen mhskill = .
replace mhskill = 1 if educ==1 | educ==2
replace mhskill = 0 if educ==0 

*** Rescale rural/urban (combine "A rural area or on a farm (1)" and "A small town or village (2)" 
*** into "rural (1)" and "A large city (3)" and "A suburb of a large city (6)" into "urban (2)" 
gen urban = .
replace urban = 0 if wp14==1 | wp14==2
replace urban = 1 if wp14==3 | wp14==6
drop wp14

*** Rescale employment status (combine employed for employer and selfemployed, 
*** both part time or full time and combine unemployed and out of workforce into "0"
gen empl = .
replace empl = 1 if EMP_2010==1 | EMP_2010==2 | EMP_2010==3  | EMP_2010==5
replace empl = 0 if EMP_2010==4 | EMP_2010==6 
*drop EMP_2010

tab EMP_2010

gen selfempl=.
replace selfempl=1 if  EMP_2010==2 
replace selfempl=0 if  EMP_2010==4 | EMP_2010==6 | EMP_2010==1 | EMP_2010==3 | EMP_2010==5

gen employee=. 
replace employee=1 if  EMP_2010==1 | EMP_2010==3 | EMP_2010==5
replace employee=0 if  EMP_2010==2 |EMP_2010==4 | EMP_2010==6 

/* Share of migrants in the entire sample
gen native = 0
replace native = 1 if wp4657 ==1
gen nonnative = 0
replace nonnative = 1 if wp4657 ==2
* keep if nonnative==1 --> 67830 obs (08/03/2021)
* Total number obs in database: 1,271,492
* Share migrants in GWP: 67,830/1,271,492 = 0.0533 (5.33%) (08/03/2021)
*/

*** Replace those who refused to answer (="100") and those who 99 and over (cause there's no specific age after 98, just "99+")
keep if age>=15
replace age=. if age>98

*** Replace number of children of those don't know (="98) or refused to answer (="99")
*** For now we keep those who say they have more than 97 children (79 people)
replace children=. if children==98 | children==99

*** Create dummy for those born in the country of respondence 
gen native = 0
replace native = 1 if wp4657 ==1
gen nonnative = 0
replace nonnative = 1 if wp4657 ==2

order nonnative educ urban empl, after(relig)

*** Generate id variables 
egen o = group(origin)               
order o, before(origin)

** Clear wp9105 - (Which country are you a national of? (Total sample.)) 
decode wp9105, generate(nationality) 
replace nationality="" if nationality=="(DK)" // (67 real changes made)

** Clear wp9042 - Did you move to this country within the last five years?
/*
WP9042 Move |
 to Country |
  in Last 5 |
      Years |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |     14,888       23.71       23.71
         No |     44,676       71.14       94.84
       (DK) |      1,398        2.23       97.07
  (Refused) |      1,841        2.93      100.00
------------+-----------------------------------
      Total |     62,803      100.00
*/
* RECODE 
gen wp9042bis = .
replace wp9042bis=1 if wp9042==1
replace wp9042bis=0 if wp9042==2
replace wp9042bis=. if wp9042==3
replace wp9042bis=. if wp9042==4
drop wp9042
rename wp9042bis wp9042

** Clear wp10963 -  Have you been living in this country for more than 12 months, or not? (asked only of those who have moved to this country within the last 5 years
tab wp10963  // (only 112 answers) ----> NOT RELEVANT TO USE THEN 
/*
. tab wp10963  // (only 112 answers)

    WP10963 |
  Living in |
    Country |
  More Than |
  12 Months |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |        100       89.29       89.29
         No |         11        9.82       99.11
  (Refused) |          1        0.89      100.00
------------+-----------------------------------
      Total |        112      100.00
*/

** Clear wp10248 - In the city or area where you live, are you satisfied or dissatisfied with __________? The opportunities to meet people and make friends
tab wp10248 
/*     WP10248 |
Opportunitie |
   s to Make |
     Friends |      Freq.     Percent        Cum.
-------------+-----------------------------------
   Satisfied |    670,786       73.80       73.80
Dissatisfied |    202,266       22.25       96.05
        (DK) |     33,418        3.68       99.73
   (Refused) |      2,489        0.27      100.00
-------------+-----------------------------------
       Total |    908,959      100.00
*/ 
* RECODE 
gen wp10248bis = .
replace wp10248bis=1 if wp10248==1 // Satisfied 
replace wp10248bis=0 if wp10248==2 // dissatisfied 
replace wp10248bis=. if wp10248==3
replace wp10248bis=. if wp10248==4
drop wp10248
rename wp10248bis wp10248

** Clear wp27 - If you were in trouble, do you have relatives or friends you can count on to help you whenever you need them, or not?
tab wp27
/*
 WP27 Count |
 On to Help |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |    899,867       78.81       78.81
         No |    227,194       19.90       98.71
       (DK) |     13,090        1.15       99.86
  (Refused) |      1,621        0.14      100.00
------------+-----------------------------------
      Total |  1,141,772      100.00
*/
* RECODE 
gen wp27bis = .
replace wp27bis=1 if wp27==1  // Yes
replace wp27bis=0 if wp27==2  // No 
replace wp27bis=. if wp27==3
replace wp27bis=. if wp27==4
drop wp27
rename wp27bis wp27

** Manchin and Orazbayev (2019) combine WP27 and WP10248 based on PCA as a proxy for “close local networks”
* Close social networks - Principal Component Analysis 
/*
The Close-social-networks index is the first principal component of the listed GWP survey questions (WP27 and WP10248), 
computed using polychoric principal component analysis. Sample weights are applied in the estimation. A higher 
value of an index indicates a better situation. Proportion of variance explained 
by the first component is 0.60
*/
sum wp27 wp10248 
polychoricpca wp27 wp10248 [pweight=wgt], score(pc) nscore(1)
rename pc1 closesocialnetwork

egen maxpc1=max(closesocialnetwork)
egen minpc1=min(closesocialnetwork)

* newvalue= (max'-min')/(max-min)*(value-max)+max'
gen closesocialnetwork1=1/(maxpc1-minpc1)
replace closesocialnetwork1=closesocialnetwork1*(closesocialnetwork-maxpc1)
replace closesocialnetwork1=closesocialnetwork1+1
sum closesocialnetwork1
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
closesocia~1 |    859,487    .7857944     .306103          0          1
*/

* Els tried to do this: normalized = (x-min(x))/(max(x)-min(x)) --> stil negative range 
*gen closesocialnetwork_final = (closesocialnetwork-minpc1)/(maxpc1-minpc1)

drop minpc1
drop maxpc1

** Clear wp30 - Are you satisfied or dissatisfied with your standard of living, all the things you can buy and do?  
tab wp30
/*
        WP30 |
 Standard of |
      Living |      Freq.     Percent        Cum.
-------------+-----------------------------------
   Satisfied |    699,987       60.48       60.48
Dissatisfied |    438,732       37.91       98.39
        (DK) |     16,104        1.39       99.78
   (Refused) |      2,514        0.22      100.00
-------------+-----------------------------------
       Total |  1,157,337      100.00
*/
gen wp30bis = .
replace wp30bis=1 if wp30==1 // Satisfied 
replace wp30bis=0 if wp30==2 // Dissatisfied 
replace wp30bis=. if wp30==3
replace wp30bis=. if wp30==4
drop wp30
rename wp30bis wp30
rename wp30 satisPP

** Clear wp12316 - In the past 12 months, did this household send help in the form of money or goods to another individual to another individual living inside this country, living in another country, both, or neither?
tab wp12316
/*
    WP12316 Sent Financial |
                      Help |      Freq.     Percent        Cum.
---------------------------+-----------------------------------
Living inside this country |    112,797       16.24       16.24
 Living in another country |     23,756        3.42       19.66    --> But we don't know if it is towards origin country or not. 
                      Both |     16,845        2.43       22.09
                   Neither |    525,345       75.65       97.74
                      (DK) |     11,700        1.68       99.42
                 (Refused) |      4,016        0.58      100.00
---------------------------+-----------------------------------
                     Total |    694,459      100.00
*/
gen remit_cc=1 if wp12316==1 | wp12316==3
replace remit_cc=0 if wp12316==2 | wp12316==4

gen remit_abroad=1 if wp12316==2 | wp12316==3
replace remit_abroad=0 if wp12316==1 | wp12316==4

gen remit_any=1 if wp12316==1 | wp12316==2 | wp12316==3
replace remit_any=0 if wp12316==4

*Generate wealth index à la Dustmann and Okatenko (2014)
** Clear wp36 - (-2009): Does your home have electricity?
tab wp36
/*  WP36 Home |
        Has |
Electricity |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |     92,824       85.95       85.95
         No |     15,065       13.95       99.90
       (DK) |         53        0.05       99.95
  (Refused) |         51        0.05      100.00
------------+-----------------------------------
      Total |    107,993      100.00
*/

** Clear wp38 - (-2010): Does your home have a computer?
tab wp38
/*  WP38 Home |
        Has |
   Computer |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |     52,681       38.95       38.95
         No |     82,163       60.75       99.70
       (DK) |        198        0.15       99.85
  (Refused) |        205        0.15      100.00
------------+-----------------------------------
      Total |    135,247      100.00
*/

** Clear wp37 - (full sample): Does your home have a television? 
tab wp37
/*  WP37 Home |
        Has |
 Television |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |    928,115       84.57       84.57
         No |    168,070       15.31       99.88
       (DK) |        634        0.06       99.94
  (Refused) |        655        0.06      100.00
------------+-----------------------------------
      Total |  1,097,474      100.00
*/

** Clear wp39 - wp39 (full sample): Does your home have access to the Internet?
tab wp39
/*
  WP39 Home |
 Has Access |
to Internet |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |    440,793       39.91       39.91
         No |    657,864       59.56       99.47
       (DK) |      4,348        0.39       99.87
  (Refused) |      1,475        0.13      100.00
------------+-----------------------------------
      Total |  1,104,480      100.00
*/

** Clear wp40 - : Have there been times in the past 12 months when you did not have enough money to buy food you and your family needed?
tab wp40
/*
   WP40 Not |
     Enough |
Money: Food |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |    359,104       28.74       28.74
         No |    881,872       70.59       99.33
       (DK) |      5,629        0.45       99.78
  (Refused) |      2,699        0.22      100.00
------------+-----------------------------------
      Total |  1,249,304      100.00
*/ 

** Clear wp43 - Have there been times in the past 12 months when you did not have enough money to provide adequate shelter or housing for you and your family? 
tab wp43
/*   WP43 Not |
     Enough |
     Money: |
    Shelter |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |    269,137       21.53       21.53
         No |    967,265       77.36       98.89
       (DK) |      9,789        0.78       99.67
  (Refused) |      4,074        0.33      100.00
------------+-----------------------------------
      Total |  1,250,265      100.00
*/

** Clear wp44 - : Have there been times in the past 12 months when you or your family have gone hungry?
tab wp44 
/*  WP44 Gone |
     Hungry |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |     27,993        9.39        9.39
         No |    267,532       89.73       99.11
       (DK) |      1,741        0.58       99.70
  (Refused) |        901        0.30      100.00
------------+-----------------------------------
      Total |    298,167      100.00

*/ 

*Generate wealth index à la Dustmann and Okatenko (2014)
/*
The wealth index is the first principal component of the listed GWP survey questions, 
computed using polychoric principal component analysis. Sample weights are applied in the estimation. A higher 
value of an index indicates a better situation. Proportion of variance explained 
by the first component is 0.55 (0.61 with no wp44).
*/

foreach k in wp36 wp37 wp38 wp39 wp40 wp43 wp44 {
	replace `k'=. if `k'>2
	replace `k'=0 if `k'==2 // Recode so that dummy is 0 for no and 1 for yes
}
sum wp36 wp37 wp38 wp39 wp40 wp43 wp44

*----------------------------------------------------------------------------------------------
*--> there is something wrong with this: dummy for wp40, wp43, wp44 --> shouldn't they be transformed otherwise? with 1 indicating a better situation? 

gen wp40_d = . 
replace wp40_d=1 if wp40==0
replace wp40_d=0 if wp40==1
tab wp40_d
tab wp40
drop wp40
rename wp40_d wp40
label var wp40 "Not enough money food" 

gen wp43_d = . 
replace wp43_d=1 if wp43==0
replace wp43_d=0 if wp43==1
tab wp43_d
tab wp43
drop wp43
rename wp43_d wp43
label var wp43 "Not enough money Shelter" 

gen wp44_d = . 
replace wp44_d=1 if wp44==0
replace wp44_d=0 if wp44==1
tab wp44_d
tab wp44
drop wp44
rename wp44_d wp44
label var wp44 "Gone hungry" 
*----------------------------------------------------------------------------------------------

*polychoricpca wp37 wp39 wp40 wp43 wp44, score(pc_orig) nscore(1)
polychoricpca wp37 wp39 wp40 wp43 [pweight=wgt], score(pc) nscore(1)
rename pc1 wealth

* Normalization between 0 & 1
/* 
zi= xi - min(x) / (max(x)-min(x))
*/

*gen wealth1= (wealth-min(wealth))/(max(wealth)-min(wealth))
// Not sure why that command does not work, so I am doing it manually

egen maxwealth=max(wealth)
egen minwealth=min(wealth)
* newvalue= (max'-min')/(max-min)*(value-max)+max'
gen BasicWealth=1/(maxwealth-minwealth)
replace BasicWealth=BasicWealth*(wealth-maxwealth)
replace BasicWealth=BasicWealth+1

sum BasicWealth
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
     wealth1 |  1,061,711    .3064227    .2887417   5.96e-08          1
*/
drop minwealth
drop maxwealth

tab wp2319
/*
 WP2319 Feelings About Household Income |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
   Living comfortably on present income |     15,079       26.23       26.23
           Getting by on present income |     22,234       38.68       64.91
 Finding it difficult on present income |     12,116       21.08       85.99
Finding it very difficult on present in |      6,916       12.03       98.02
                                   (DK) |        473        0.82       98.85
                              (Refused) |        663        1.15      100.00
----------------------------------------+-----------------------------------
                                  Total |     57,481      100.00
*/ 
* HOW RECODE?   (When OK, we will include it in the finite return database)
gen feelingsHHInc = . 
replace feelingsHHInc=1 if wp2319==4
replace feelingsHHInc=2 if wp2319==3
replace feelingsHHInc=3 if wp2319==2
replace feelingsHHInc=4 if wp2319==1
replace feelingsHHInc=. if wp2319==5
replace feelingsHHInc=. if wp2319==6
drop wp2319

gen feelingsHHinc_comfortably=1 if feelingsHHInc==4
replace feelingsHHinc_comfortably=0 if feelingsHHInc==1 | feelingsHHInc==2 | feelingsHHInc==3

gen feelingsHHinc_gettingby=1 if feelingsHHInc==3
replace feelingsHHinc_gettingby=0 if feelingsHHInc==1 | feelingsHHInc==2 | feelingsHHInc==4

gen feelingsHHinc_difficult=1 if feelingsHHInc==2
replace feelingsHHinc_difficult=0 if feelingsHHInc==1 | feelingsHHInc==3 | feelingsHHInc==4

gen feelingsHHinc_vdifficult=1 if feelingsHHInc==1
replace feelingsHHinc_vdifficult=0 if feelingsHHInc==2 | feelingsHHInc==3 | feelingsHHInc==4

tab wp10256
gen environprobl = .
replace environprobl = 1 if wp10256==1
replace environprobl = 0 if wp10256==2 

// -----------------------------------------------------------------------------
// B/ RECODE BILATERAL MIGRATION QUESTIONS
// -----------------------------------------------------------------------------
*** Identify destperm country names (desire to move)   // To which country would you like to move? (Asked only of those who would like to move to another country.) (FIRST RESPONSE)	
decode wp3120, generate(destperm) 
*** Identify desttemp country names (desire to move)  // To which country? (Asked only of those who would like to work in another country temporarily.)	
decode wp9499, generate(desttemp) 
*** Identify destperm_pl country names (planning to move in next 12 months) // To which country are you planning to move in the next 12 months? (asked only of those who are planning to move to another country in the next 12 months)	
decode wp10253, generate(destperm_pl) 
*** Identify desttemp_pl country names (planning to move in next 24 months) // To which country? (Asked only of those who plan to go to another country for temporary work in the next 24 months.)	
decode wp9501, generate(desttemp_pl) 
*** Identify destination of HH members abroad  // In which country does/did he/she live? (Asked only of those who have a member of household who lives in another country.)	
decode wp3331, generate(destHH) 
*** Identify destination of family or friends abroad who respondent can count on when needed
*** 1/ First
decode wp3334, generate(destFF1) 
*** 2/ Second
decode wp3335, generate(destFF2) 
*** 3/ Third
decode wp3336, generate(destFF3) 
*** Identify country of birth
decode wp9048, generate(cntrybirth) // In which country were you born? (asked only of those who were not born in this country)	

order cntrybirth destperm desttemp destperm_pl desttemp_pl destHH destFF1 destFF2 destFF3 , after(o)

*** Set cntrybirth to missing if it mistakenly has a value
replace cntrybirth="" if cntrybirth=="(DK)" // (1,559 real changes made)
replace cntrybirth="" if native==1 // (0 real changes made)

// -----------------------------------------------------------------------------
// C/ RECODE UNILATERAL MIGRATION QUESTIONS
// -----------------------------------------------------------------------------

*** Fill in missing responses to the unilateral migration questions when one of 
*** the followup questions (plans, preparations, or a destination has been mentioned 
*** (ie interviewer failed to indicate "yes" for these respondents)
replace wp1325 = 1 if wp1325!=1 & wp10252==1 // permanent intention no but plan yes: 0 real changes made
replace wp1325 = 1 if wp1325!=1 & wp9455==1 // permanent intention no but preparation yes: 0 real changes made
replace wp10252 = 1 if wp10252!=1 & wp9455==1 // permanent plan no but preparation yes: 176 real changes made --> note that for these we don't have a destination, though!!!

*** Identify the country-waves where some people have missing values for the question 
*** on whether they want to move abroad while they do mention a destination and replace 
*** for these country-waves the missing value for wp1325 to zero when they did not mention
*** a destination (assuming that all those received the question AND do not want/plan to move)
preserve
	gen ow_in_perm_miss = 0
	replace ow_in_perm_miss = 1 if wp1325!=1 & destperm !=""
	keep if ow_in_perm_miss ==1
	keep origin wave year ow_in_perm_miss
	duplicates drop	
	save "GWP/Old/dta/Temp/OriginWave_int_perm.dta", replace
restore
preserve
	gen ow_in_temp_miss = 0
	replace ow_in_temp_miss = 1 if wp9498!=1 & desttemp !=""
	keep if ow_in_temp_miss ==1
	keep origin wave year ow_in_temp_miss
	capture duplicates drop
	save "GWP/Old/dta/Temp/OriginWave_int_temp.dta", replace
restore
preserve
	gen ow_pl_perm_miss = 0
	replace ow_pl_perm_miss = 1 if wp10252!=1 & destperm_pl !=""
	keep if ow_pl_perm_miss ==1
	keep origin wave year ow_pl_perm_miss
	capture duplicates drop
	save "GWP/Old/dta/Temp/OriginWave_pl_perm.dta", replace
restore
preserve
	gen ow_pl_temp_miss = 0
	replace ow_pl_temp_miss = 1 if wp9500!=1 & desttemp_pl !=""
	keep if ow_pl_temp_miss ==1
	keep origin wave year ow_pl_temp_miss
	capture duplicates drop
	save "GWP/Old/dta/Temp/OriginWave_pl_temp.dta", replace
restore

merge m:1 origin wave using "GWP/Old/dta/Temp/OriginWave_int_perm.dta", keep(match master) nogen
merge m:1 origin wave using "GWP/Old/dta/Temp/OriginWave_int_temp.dta", keep(match master) nogen
merge m:1 origin wave using "GWP/Old/dta/Temp/OriginWave_pl_perm.dta", keep(match master) nogen
merge m:1 origin wave using "GWP/Old/dta/Temp/OriginWave_pl_temp.dta", keep(match master) nogen

/* // Note: changes suggested by Joel Jan2018
replace wp1325 = 0 if wp1325 ==. & destperm =="" & ow_in_perm_miss ==1
replace wp9498 = 0 if wp9498 ==. & desttemp =="" & ow_in_temp_miss ==1
replace wp10252 = 0 if wp10252 ==. & destperm_pl =="" & ow_pl_perm_miss ==1 
replace wp9500 = 0 if wp9500 ==. & desttemp_pl =="" & ow_pl_temp_miss ==1 
*/

replace wp1325 = 5 if wp1325 ==. & destperm =="" & ow_in_perm_miss ==1 // 13,849 real changes made
replace wp9498 = 5 if wp9498 ==. & desttemp =="" & ow_in_temp_miss ==1 // 0 real changes made
replace wp10252 = 5 if wp10252 ==. & destperm_pl =="" & ow_pl_perm_miss ==1 // 0 real changes made
replace wp9500 = 5 if wp9500 ==. & desttemp_pl =="" & ow_pl_temp_miss ==1 // 0 real changes made

replace wp1325 = 1 if wp1325!=1 & (destperm !="" & destperm !=origin) | (destperm_pl !="" & destperm_pl != origin) // permanent intention no but destination mentioned: 5,056 real changes made
replace wp10252 = 1 if wp10252!=1 & destperm_pl!="" // permanent plan no but destination mentioned: 0 real changes made

replace wp9498 = 1 if wp9498!=1 & wp9500==1 // temporary intention no but plan yes: 0 real changes made
replace wp9498 = 1 if wp9498!=1 & wp9502==1 // temporary intention no but preparation yes: 0 real changes made
replace wp9500 = 1 if wp9500!=1 & wp9502==1 // temporary plan no but preparation yes: 0 real changes made 
replace wp9498 = 1 if wp9498!=1 & (desttemp !="" & desttemp !=origin) | (desttemp_pl !="" & desttemp_pl != origin) // temporary intention no but destination mentioned: 0 real changes made
replace wp9500 = 1 if wp9500!=1 & desttemp_pl!="" // temporary plan no but destination mentioned: 0 real changes made

*** Set destination to missing for those respondents who didn't properly answer the destination question
foreach k in destperm destperm_pl desttemp desttemp_pl {
	replace `k'="" if `k' == "(Refused)" | `k' == "(DK)" | `k' == "HOLD" | `k' == "hold" | `k' == "(None)" | `k' == "None" ///
	| `k' == "Other Country" | `k' == "African Country" | `k' == "Arab Country" | `k' == "Island Nations (11)" | `k' == "Other Islamic Country"
}
/*
(20,368 real changes made)
(1,211 real changes made)
(5,142 real changes made)
(75 real changes made)
*/

*** Set migration intention/plan to zero and destination to missing for those respondents who say they want to move but mention the country where 
*** they are interviewed as preferred destination (as we don't know which answer is true in this case: 258 people)
replace wp1325 = 0 if (wp1325==1 & destperm==origin) // 275 real changes made
replace wp10252 = 0 if (wp10252==1 & destperm_pl==origin) // 40 real changes made
replace wp9498 = 0 if (wp9498 ==1 & desttemp==origin) // 57 real changes made
replace wp9500 = 0 if (wp9500 ==1 & desttemp_pl==origin) // 1 real changes made
foreach k in destperm destperm_pl desttemp desttemp_pl {
	replace `k'="" if `k'==origin
}
/*
(278 real changes made)
(40 real changes made)
(57 real changes made)
(1 real change made)
*/

// -----------------------------------------------------------------------------
// D/ GENERATE MIGRATION VARIABLES
// -----------------------------------------------------------------------------

************************
*** 0/ LIKELY TO MOVE QUESTION wp85 
************************
*QUESTION wp85 READS :In the next 12 months, are you likely or unlikely to move away from the city or area where you live?
gen move=.
replace move=1 if wp85==1
replace move=0 if wp85==2
label var move "likely to move away from the city or area where living in next 12m"

************************
*** 1/ PERMANENT 
************************
*** Create desire to move dummies
* UNILATERALLY desiring to move: 1 if respondent says he wants to migrate 
* permanently, 0 if he answers the question "do you want to move" with 2, 3 or 4
/* Q wp 1325: Ideally, if you had the opportunity, would you like to move PERMANENTLY to another country, or would you prefer to continue living in this country?*/ 
gen udm_perm = .
replace udm_perm = 1 if wp1325 == 1 
replace udm_perm = 0 if wp1325 == 2 | wp1325 == 3 | wp1325 == 4  | wp1325 == 5 
* BILATERALLY desiring to move to specific country: 1 if respondent says he wants to migrate 
* permanently and identifies a specific country, 0 if he does not indicate a country 
/* Q: To which country would you like to move? (Asked only of those who would like to move to another country.) (FIRST RESPONSE)	*/
gen bdm_perm = .
replace bdm_perm = 1 if destperm !="" 
replace bdm_perm = 0 if destperm =="" 

label var udm_perm "desire to migrate permanently to another country"
label var bdm_perm "desire to migrate permanently to another country and destination mentioned"

*** Create planning to move dummies
* UNILATERALLY planning to move: 1 if respondent says he is planning to migrate 
* permanently abroad in the next 12 months, 0 if he does not 
/* Q: Are you planning to move permanently to another country in the next 12 months, or not? (asked only of those who would like to move to another country)*/
gen udmpl_perm = .
replace udmpl_perm = 1 if wp10252 == 1 
replace udmpl_perm = 0 if wp10252 == 2 | wp10252 == 3 | wp10252 == 4 | wp10252 == 5 
* BILATERALLY planning to move to a country: 1 if respondent says he wants to and is planning to migrate 
* permanently to a specific country in the next 12 months, 0 if he does not mention a country
/* Q: To which country are you planning to move in the next 12 months? (asked only of those who are planning to move to another country in the next 12 months)	*/
gen bdmpl1_perm = .
replace bdmpl1_perm = 1 if destperm_pl!=""
replace bdmpl1_perm = 0 if destperm_pl=="" 
* Alternative:
* Planning to move to this country: 1 if respondent says he is planning to migrate 
* permanently to the country he desires to migrate to in the next 12 months, 0 if he says he 
* is not planning to migrate or he is planning to migrate but not to this country
gen bdmpl2_perm = .
replace bdmpl2_perm = 1 if destperm_pl!="" & destperm == destperm_pl
replace bdmpl2_perm = 0 if destperm_pl=="" | destperm != destperm_pl

label var udmpl_perm "plan to migrate permanently to another country in the next 12m "
label var bdmpl1_perm "plan to migrate permanently to another country in the next 12m and destination mentioned"
label var bdmpl2_perm "plan to migrate permanently to the country mentioned as intended destination in the next 12m "

*** Create preparing to move dummies
* UNILATERALLY preparing to move: 1 if respondent says he has made preparations to migrate 
* permanently abroad, 0 if he does not 
* Q: Have you done any preparation for this move (asked only of those who are planning to move to another country in the next 12 months)	
gen udmpr_perm = .
replace udmpr_perm = 1 if wp9455 == 1
replace udmpr_perm = 0 if wp9455 == 2 | wp9455 == 3 | wp9455 == 4 
* BILATERALLY preparing to move to a country: 1 if respondent says he has made 
* preparations for his move to the destination he is planning to move to, zero if not
gen destperm_pr=""
replace destperm_pr = destperm_pl if wp9455 == 1
gen bdmpr1_perm = .
replace bdmpr1_perm = 1 if destperm_pr!=""
replace bdmpr1_perm = 0 if destperm_pr=="" 
* Alternative:
* Preparing to move to this country: 1 if respondent says he is preparing to migrate 
* permanently to the country he desires to migrate to; zero if not
gen bdmpr2_perm = .
replace bdmpr2_perm = 1 if destperm_pr!="" & destperm == destperm_pr
replace bdmpr2_perm = 0 if destperm_pr=="" | destperm != destperm_pr

label var udmpr_perm "prepare to migrate permanently to another country in the next 12m"
label var bdmpr1_perm "prepare to migrate permanently to another country in the next 12m and destination mentioned"
label var bdmpr2_perm "prepare to migrate permanently to the country mentioned as intended destination in the next 12m"

************************
*** 2/ TEMPORARY 
************************
*** IMPORTANT NOTE: BECAUSE WE TAKE THE ROWMAX AFTER TO GET TOTAL WILLINGNESS TO MIGRATE,
*** AND BECAUSE WE ARE WORKING WITH INDIVIDUAL DATA, THERE IS NO PROBLEM OF DOUBLECOUNTING!!!!
***********************
*** Create desire to move dummies
* UNILATERALLY desiring to move: 1 if respondent says he wants to migrate 
* temporarily for work, 0 if he answers the question "do you want to move" with 2, 3 or 4
* (Q: Ideally, if you had the opportunity, would you like to go to another country for temporary work, or not?) 
gen udm_temp = .
replace udm_temp = 1 if wp9498 == 1 
replace udm_temp = 0 if wp9498 == 2 | wp9498 == 3 | wp9498 == 4 | wp9498 == 5
* BILATERAL desire to move to specific country: 1 if respondent says he wants to migrate 
* temporarily for work to a specific country, 0 if not
* (Q: To which country? (Asked only of those who would like to work in another country temporarily.)) 
gen bdm_temp = .
replace bdm_temp = 1 if desttemp !="" 
replace bdm_temp = 0 if desttemp =="" 

label var udm_temp "desire to migrate temporarily to another country "
label var bdm_temp "desire to migrate temporarily to another country and destination mentioned"

*** Create planning to move dummies
* UNILATERALLY planning to move: 1 if respondent says he is planning to migrate 
* temporarily for work in the next 24 months, 0 if he does not 
* (Q: Are you planning to go to another country for temporarily work in the next 24 months? (Asked only of those who would like to work in another country temporarily.)) 
gen udmpl_temp = .
replace udmpl_temp = 1 if wp9500 == 1 
replace udmpl_temp = 0 if wp9500 == 2 | wp9500 == 3 | wp9500 == 4 | wp9500 == 5
* BILATERALLY planning to move to a country: 1 if respondent says he is planning to migrate 
* temporarily for work to a specific country in the next 24 months, 0 if not
* (Q: To which country? (Asked only of those who plan to go to another country for temporary work in the next 24 months.)	) 
gen bdmpl1_temp = .
replace bdmpl1_temp = 1 if desttemp_pl !=""
replace bdmpl1_temp = 0 if desttemp_pl =="" 
* Alternative:
* Planning to move to this country: 1 if respondent says he is planning to migrate 
* temporarily for work to the country he desires to migrate to in the next 24 months, 0 if not
gen bdmpl2_temp = .
replace bdmpl2_temp = 1 if desttemp_pl!="" & desttemp == desttemp_pl
replace bdmpl2_temp = 0 if desttemp_pl!="" | desttemp != desttemp_pl

label var udmpl_temp "plan to migrate temporarily to another country in the next 24m "
label var bdmpl1_temp "plan to migrate temporarily to another country in the next 24m and destination mentioned"
label var bdmpl2_temp "plan to migrate temporarily to the country mentioned as intended destination in the next 24m"

*** Create preparing to move dummies
* UNILATERALLY preparing to move: 1 if respondent says he is preparing to migrate 
* temporarily abroad, 0 if he does not 
* (Q: Have you done any preparation for this; for example, found a job, applied for a visa, purchased the ticket, or saved money for the ticket, etc.? (Asked only of those who plan to go to another country for temporary work in the next 24 months.)	) 
gen udmpr_temp = .
replace udmpr_temp = 1 if wp9502 == 1
replace udmpr_temp = 0 if wp9502 == 2 | wp9502 == 3 | wp9502 == 4
* BILATERALLY preparing to move to a country: 1 if respondent says he is preparing to migrate 
* temporarily to a specific country and 0 if not
gen desttemp_pr = ""
replace desttemp_pr = desttemp_pl if wp9502 == 1
gen bdmpr1_temp = .
replace bdmpl1_temp = 1 if desttemp_pr !=""
replace bdmpl1_temp = 0 if desttemp_pr =="" 
* Preparing to move to this country: 1 if respondent says he is preparing to migrate 
* temporarily to the country he desires to migrate to; zero if not
gen bdmpr2_temp = .
replace bdmpr2_temp = 1 if desttemp_pr!="" & desttemp == desttemp_pr
replace bdmpr2_temp = 0 if desttemp_pr=="" | desttemp != desttemp_pr

label var udmpl_temp "prepare to migrate temporarily to another country in the next 24m "
label var bdmpl1_temp "prepare to migrate temporarily to another country in the next 24m and destination mentioned"
label var bdmpl2_temp "prepare to migrate temporarily to the country mentioned as intended destination in the next 24m"

************************
*** 3/ COMBINE PERMANENT AND TEMPORARY 
************************
gen desttot = desttemp
replace desttot = destperm if destperm!=""
order desttot, after(desttemp)

gen desttot_pl = desttemp_pl
replace desttot_pl = destperm_pl if destperm_pl!=""
order desttot_pl, after(desttemp_pl)

gen desttot_pr = desttemp_pr
replace desttot_pr = destperm_pr if destperm_pr!=""
order desttot_pr, after(desttemp_pr)

*** Create desire to move dummies
egen udm_tot = rowmax(udm_perm udm_temp)
egen bdm_tot = rowmax(bdm_perm bdm_temp)

*** Create planning to move dummies
egen udmpl_tot = rowmax(udmpl_perm udmpl_temp)
egen bdmpl1_tot = rowmax(bdmpl1_perm bdmpl1_temp)
egen bdmpl2_tot = rowmax(bdmpl2_perm bdmpl2_temp)

*** Create preparing to move dummies
egen udmpr_tot = rowmax(udmpr_perm udmpr_temp)
egen bdmpr1_tot = rowmax(bdmpr1_perm bdmpr1_temp)
egen bdmpr2_tot = rowmax(bdmpr2_perm bdmpr2_temp)

order udm_perm udm_temp udm_tot udmpl_perm udmpl_temp udmpl_tot udmpr_perm udmpr_temp udmpr_tot ///
bdm_perm bdm_temp bdm_tot bdmpl1_perm bdmpl1_temp bdmpl1_tot bdmpl2_perm bdmpl2_temp bdmpl2_tot ///
bdmpr1_perm bdmpr1_temp bdmpr1_tot bdmpr2_perm bdmpr2_temp bdmpr2_tot, before(empl)

************************
*** NETWORK DATA
************************
*** Create network dummies
* HH member abroad: 1 if question is answered positively   // Have any members of your household gone to live in a foreign country permanently or temporarily in the past five years?
* ... and 0 if question is answered negatively 
gen HHmabr = .
replace HHmabr = 1 if wp4633 == 1 
replace HHmabr = 0 if wp4633 == 2 | wp4633 == 3 | wp4633 == 4
* Friends or family member abroad: 1 if question is answered positively 
* ... and 0 if question is answered negatively 
gen FFmabr = . // Do you have relatives or friends who are living in another country whom you can count on to help you when you need them, or not?
replace FFmabr = 1 if wp3333 == 1 
replace FFmabr = 0 if wp3333 == 2 | wp3333 == 3 | wp3333 == 4

*egen mabr = rowmax(HHmabr FFmabr)
rename FFmabr mabr


// --------- Adjusted by Ilse 13/10/2020 --------
*** Bilateral network variable: equal to one if the former migrant has a friend or relative residing in his/her country of birth where (s)he can count on if needed.
*** Takes the value zero if people have mentioned a country of birth but they either (i) don't have a network abroad or (ii) their network is not located in their country of birth
gen netwFF = .
replace netwFF = 0 if cntrybirth!="" & ((mabr==0) | (mabr==1 & destFF1 != cntrybirth &  destFF2 != cntrybirth  &  destFF3 != cntrybirth))
replace netwFF = 1 if cntrybirth!="" & mabr==1 & (destFF1 == cntrybirth |  destFF2 == cntrybirth |  destFF3 == cntrybirth) 
*replace netwFFb = 1 if cntrybirth!="" & (destFF1 == cntrybirth |  destFF2 == cntrybirth |  destFF3 == cntrybirth) // Gives exactly the same as line above

*** We want to justify why we continue after the regression with the bilateral variable using again the unilateral one
*** To do so we need to show that they are not so much different. Specifically: we want to show that the majority of former migrants
*** who have a network abroad actually mention their cntry of birth. To check this we need to compute the share of
*** former migrants who mention they have friends or family in their country of birth among all the former migrants with a network abroad who mention a destination 
*** Variable takes the value zero if former migrant has mentioned birth country, has answered the questions on having a network abroad and in which country
*** It's one if they mention among the destinations their network at home.
gen netw_atcntrybirth=.
replace netw_atcntrybirth=0 if cntrybirth !="" & mabr !=. & destFF1 !=""
replace netw_atcntrybirth=1 if cntrybirth !="" & mabr ==1 & (destFF1 == cntrybirth | destFF2 == cntrybirth | destFF3 == cntrybirth) 

sum netw_atcntry
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
netw_atcnt~h |      4,813    .6135466    .4869871          0          1
*/
// mean(the share) is .6135466 

********************************
*** Construction index proximity
********************************
gen prox=1 if wp14732==1 | wp9700==1 | wp9701==1 | wp17015==1
replace prox=0 if wp14732==2 | wp9700==2 | wp9701==2 | wp17015==2

************************************
*** Construction risk aversion index
************************************
gen riskaverse=1 if wp11356==2
replace riskaverse=0 if wp11356==1 

*drop wp1325-wp85 wp9042-wp9501 wp9502 wp10252 wp10253

// -----------------------------------------------------------------------------
// E/ CHOOSE SETTING
// -----------------------------------------------------------------------------

*** Rename variables accordingly
* 1/ Analysis for permanent migration desire
if "$duration"== "perm" {
		rename destperm dest_in
		rename destperm_pl dest_pl
		rename destperm_pr dest_pr

		rename bdm_perm BMIG_in
		if "$defstrict" == "standard" {
			rename bdmpl1_perm BMIG_pl
			rename bdmpr1_perm BMIG_pr
		}
		else if "$defstrict" == "strict" {
			rename bdmpl2_perm BMIG_pl	
			rename bdmpr2_perm BMIG_pr		
		}

		rename udm_perm UMIG_in
		rename udmpl_perm UMIG_pl
		rename udmpr_perm UMIG_pr

}
* 2/ Analysis for temporary migration desire only
else if "$duration"== "temp" {
		rename desttemp dest_in
		rename desttemp_pl dest_pl
		rename desttemp_pr dest_pr

		rename bdm_temp BMIG_in
		if "$defstrict" == "standard" {
			rename bdmpl1_temp BMIG_pl
			rename bdmpr1_temp BMIG_pr
		}
		else if "$defstrict" == "strict" {
			rename bdmpl2_temp BMIG_pl	
			rename bdmpr2_temp BMIG_pr		
		}

		rename udm_temp UMIG_in
		rename udmpl_temp UMIG_pl
		rename udmpr_temp UMIG_pr

}
* 3/ Analysis for permanent and temporary migration desire combined
else if "$duration"== "tot" {
		rename desttot dest_in
		rename desttot_pl dest_pl
		rename desttot_pr dest_pr

		rename bdm_tot BMIG_in
		if "$defstrict" == "standard" {
			rename bdmpl1_tot BMIG_pl
			rename bdmpr1_tot BMIG_pr
		}
		else if "$defstrict" == "strict" {
			rename bdmpl2_tot BMIG_pl	
			rename bdmpr2_tot BMIG_pr		
		}

		rename udm_tot UMIG_in
		rename udmpl_tot UMIG_pl
		rename udmpr_tot UMIG_pr

}
capture drop *perm *perm_pl *perm_pr 
capture drop *temp *temp_pl *temp_pr
capture drop *tot *tot_pl *tot_pr 
drop bdm*

// -----------------------------------------------------------------------------
// F/ KEEP ONLY COUNTRY-WAVE PAIRS WHERE MIGRATION QUESTIONS WERE ASKED
// -----------------------------------------------------------------------------
*** Generate dummies to know where questions were asked
gen mig=0
replace mig=1 if BMIG_in==1
gen mig_pl=0
replace mig_pl=1 if BMIG_pl==1
gen mig_pr=0
replace mig_pr=1 if BMIG_pr==1
gen mabr2=0
replace mabr2=1 if mabr==1
// ------- Added by Ilse 25/09/2020 ---------
gen ff=0
replace ff=1 if destFF1!=""
replace ff=1 if destFF2!=""
replace ff=1 if destFF3!=""
// ------------------------------------------

preserve
collapse (mean) mig mig_pl mig_pr mabr2 ff, by (origin wave)  // Adjusted by Ilse 25/09/2020 (included ff)
count //  1,217
count if mig==0 // 104
count if mig_pl==0 // 491
count if mig_pr==0 // 522
count if mabr2==0 // 323
count if ff==0 // 926 Added by Ilse 25/09/2020
gen no_mig=0
replace no_mig=1 if mig==0
gen no_mig_pl=0
replace no_mig_pl=1 if mig_pl==0
gen no_mig_pr=0
replace no_mig_pr=1 if mig_pr==0
gen no_mabr=0 
replace no_mabr=1 if mabr2==0 
gen no_ff=0  // Added by Ilse 25/09/2020
replace no_ff=1 if ff==0 // Added by Ilse 25/09/2020

keep origin wave no_mig no_mig_pl no_mig_pr no_mabr no_ff
label variable no_mig "Missing intentions (if 1)"
label variable no_mig_pl "Missing plans (if 1)"
label variable no_mig_pr "Missing preparations (if 1)"
label variable no_mabr "Missing mabr FF (if 1)"
label variable no_ff "Missing ff (if 1)" // Added by Ilse 25/09/2020

save "GWP/Old/dta/Temp/data_check_IR.dta", replace
restore

merge m:1 origin wave using "GWP/Old/dta/Temp/data_check_IR.dta", nogen

keep if no_mig==0 // drops 125,523 observations // 2006 lost HERE

// Overview of the number of observations:
// ---------------------------------------
count // 1,145,968 (=original sample)
count if no_mig_pl==0 // 758,541
count if no_mig_pr==0 // 730,689
count if no_mabr==0 // 902,075
count if no_ff==0 // 285,043 Added by Ilse 25/09/2020
save "GWP/Old/dta/Temp/MigTerrorism_Gallup_$duration.dta", replace

// -----------------------------------------------------------------------------
// G/ ADD UNIQUE DESTINATION CODES
// -----------------------------------------------------------------------------
*** Match country names for destinations with those for origins
keep o origin
rename origin dest
rename o d
duplicates drop
save "GWP/Old/dta/Temp/OriginCodes.dta", replace

foreach k in _in _pl _pr {

	use "GWP/Old/dta/Temp/MigTerrorism_Gallup_$duration.dta", clear
	keep dest`k'
	rename dest`k' dest
	duplicates drop
	drop if dest==""
	*drop if dest == "African Country" // KEEP THIS!
	
	save "GWP/Old/dta/Temp/Dest`k'Names.dta", replace
}

*** Create one big file containing all destination names ever mentioned and create a unique destination code
use "GWP/Old/dta/Temp/OriginCodes.dta", clear
merge 1:1 dest using "GWP/Old/dta/Temp/Dest_inNames.dta"
drop _merge
merge 1:1 dest using "GWP/Old/dta/Temp/Dest_plNames.dta"
drop _merge
merge 1:1 dest using "GWP/Old/dta/Temp/Dest_prNames.dta"
sort d _merge dest
replace d = d[_n-1]+1 if missing(d) 
drop _merge

save "GWP/Old/dta/Temp/DestNames.dta", replace

*** Copy the file three times (for destinations for intentions, plans and preparations)
use "GWP/Old/dta/Temp/DestNames.dta", clear
rename d d_in
rename dest dest_in
save "GWP/Old/dta/Temp/Dest_inCodes.dta", replace
use "GWP/Old/dta/Temp/DestNames.dta", clear
rename d d_pl
rename dest dest_pl

save "GWP/Old/dta/Temp/Dest_plCodes.dta", replace
use "GWP/Old/dta/Temp/DestNames.dta", clear
rename d d_pr
rename dest dest_pr
save "GWP/Old/dta/Temp/Dest_prCodes.dta", replace

*** Add the unique destination codes to the Gallup data
use "GWP/Old/dta/Temp/MigTerrorism_Gallup_$duration.dta", clear
merge m:1 dest_in using "GWP/Old/dta/Temp/Dest_inCodes.dta"
drop _merge
merge m:1 dest_pl using "GWP/Old/dta/Temp/Dest_plCodes.dta"
drop if _merge == 2
drop _merge
merge m:1 dest_pr using "GWP/Old/dta/Temp/Dest_prCodes.dta"
drop if _merge == 2
drop _merge

order origin, before(o) 
order year wave wpid wgt, after(o)
order empl UMIG_in UMIG_pl UMIG_pr BMIG_in BMIG_pl BMIG_pr d_in d_pl d_pr dest_in ///
dest_pl dest_pr HHmabr mabr destHH destFF1 destFF2 destFF3 , after(urban)
order native, before(cntrybirth)

label variable cntrybirth "Country of birth of the respondent if not native"
label variable native "Dummy =1 if the respondent is born in the country where he is living"
label variable educ "Level of educ low skilled=0, medium skilled=1 and high skilled=2"
label variable urban "Urban dummy=1 if city, 0 otherwise"
label variable empl "Employment dummy=1 if employed (working), 0 otherwise"
label variable dest_pr "Country where prepared to move permanently"
label variable HHmabr "=1 if any members of your household live in a foreign country in the past five years"
label variable mabr "=1 if any friend or family live in a foreign country in the past five years"
*label variable mabr "rowmax of HHmabr and FFmabr, =1 if one of the two =1"
label variable mig "=1 if BMIG_in==1"
label variable mig_pl "=1 if BMIG_pl==1"
label variable mig_pr "=1 if BMIG_pr==1"
label variable mabr2 "=1 if FFmabr==1"

gen xx= INDEX_CM
drop INDEX_CM
rename xx INDEX_CM
label variable INDEX_CM "INDEX_CM Communications index"

gen xx= INDEX_CR
drop INDEX_CR
rename xx INDEX_CR
label variable INDEX_CR "INDEX_CR Corruption index"

gen xx= INDEX_DE
drop INDEX_DE
rename xx INDEX_DE
label variable INDEX_DE "INDEX_DE Daily Experience index"

gen xx= INDEX_DI
drop INDEX_DI
rename xx INDEX_DI
label variable INDEX_DI "INDEX_DI Diversity index"

gen xx= INDEX_LE
drop INDEX_LE
rename xx INDEX_LE
label variable INDEX_LE "INDEX_LE Life Evaluation index"

gen xx= INDEX_NX
drop INDEX_NX
rename xx INDEX_NX
label variable INDEX_NX "INDEX_NX Negative Experience index"

gen xx= INDEX_OT
drop INDEX_OT
rename xx INDEX_OT
label variable INDEX_OT "INDEX_OT Optimism index"

gen xx= INDEX_PH
drop INDEX_PH
rename xx INDEX_PH
label variable INDEX_PH "INDEX_PH Personal Health index"

gen xx= INDEX_PX
drop INDEX_PX
rename xx INDEX_PX
label variable INDEX_PX "INDEX_PX Positive Experience index"

gen xx= INDEX_ST
drop INDEX_ST
rename xx INDEX_ST
label variable INDEX_ST "INDEX_ST Struggling index"

gen xx= INDEX_SU
drop INDEX_SU
rename xx INDEX_SU
label variable INDEX_SU "INDEX_SU Suffering index"

gen xx= INDEX_TH
drop INDEX_TH
rename xx INDEX_TH
label variable INDEX_TH "INDEX_TH Thriving index"

gen xx= wp10496
drop wp10496
rename xx wp10496
label variable wp10496 "Muslim/west =1 can live together"
replace wp10496=0 if wp10496==2
replace wp10496= . if wp10496==3 | wp10496==4

gen xx= hhsize
drop hhsize
rename xx hhsize
label variable hhsize "Residents 15+ in household"

gen xx= gender
drop gender
rename xx gender

gen xx= age
drop age
rename xx age

* problem with this * 
/*gen xx= maried
drop maried
rename xx married
label variable married "WP1223 =1 married, =0 otherwise"
replace married = 1 if married==2
replace married = 0 if married==1 | married==3 | married==4 | married==5 | married==6 | married==7 | married==8
*/ 

* Redone by Els like this 
* + what does Domestic partner mean?  (is this a partner whith whom that person lives together, in that case we should maybe not include it with =0 ? 
tab maried
/*
    WP1223 Marital Status |      Freq.     Percent        Cum.
--------------------------+-----------------------------------
Single/Never been married |    318,737       28.05       28.05
                  Married |    618,397       54.41       82.46 // =2
                Separated |     23,427        2.06       84.52
                 Divorced |     40,275        3.54       88.06
                  Widowed |     79,029        6.95       95.02
                     (DK) |      3,351        0.29       95.31
                (Refused) |      3,310        0.29       95.60
         Domestic partner |     49,965        4.40      100.00
--------------------------+-----------------------------------
                    Total |  1,136,491      100.00
*/

gen Cohabitation = . 
replace Cohabitation = 1 if maried==2 | maried==8
replace Cohabitation = 0 if maried==1 | maried==3 | maried==4 | maried==5 
label variable Cohabitation "Married or domestic partner"

gen Single = .
replace Single = 1 if maried==1
replace Single = 0 if maried==2 | maried==3 | maried==4 | maried==5 | maried==8
label variable Single "Single"

gen Married = . 
replace Married = 1 if maried==2
replace Married = 0 if maried==1 | maried==3 | maried==4 | maried==5 | maried==8
label variable Married "Married"

gen SeparatedDivorcedWidowed = .
replace SeparatedDivorcedWidowed = 1 if maried==3 | maried==4 | maried==5
replace SeparatedDivorcedWidowed = 0 if maried==1 | maried==2 | maried==8
label variable SeparatedDivorcedWidowed "Separated, divorced, or widowed"

gen DivorcedWidowed = .
replace DivorcedWidowed = 1 if maried==4 | maried==5
replace DivorcedWidowed = 0 if maried==1 | maried==2 | maried==3 | maried==8
label variable DivorcedWidowed "Divorced or widowed"

gen xx= jobcat
drop jobcat
rename xx jobcat
label variable jobcat "WP1225 type of job"

gen xx= children
drop children
rename xx children
label variable children "WP1230 Children under 15"

tab relig
/*
                        WP1233 Religion |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                           Other (list) |      6,411        0.63        0.63 // Others
 Christianity: Roman Catholic, Catholic |    251,242       24.69       25.32
Christianity: Protestant, Anglican, Eva |    136,943       13.46       38.77
Christianity: Eastern Orthodox, Orthodo |     94,975        9.33       48.10
                           Islam/Muslim |    202,267       19.87       67.98
                  Islam/Muslim (Shiite) |     18,340        1.80       69.78
                   Islam/Muslim (Sunni) |     66,756        6.56       76.34
                                  Druze |      1,234        0.12       76.46 // Monotheists
                               Hinduism |     44,174        4.34       80.80 // Polytheists
                               Buddhist |     49,979        4.91       85.71 // Other form of religion
Primal-indigenous/African Traditional a |      3,128        0.31       86.02 // Others // Other form of religion
Chinese Traditional Religion/Confuciani |        406        0.04       86.06 // Other form of religion
                                Sikhism |        884        0.09       86.15 // Others // Monotheism
                                  Juche |         40        0.00       86.15 // Others // Other form of religion
                              Spiritism |        816        0.08       86.23 // Others // Other form of religion
                                Judaism |      8,780        0.86       87.09
                                  Bahai |        188        0.02       87.11 // Others // Monotheism
                                Jainism |         72        0.01       87.12 // Others // Other form of religion
                                 Shinto |         22        0.00       87.12 // Polytheists
                                Cao Dai |        149        0.01       87.14 // Others // Other form of religion
                         Zoroastrianism |         56        0.01       87.14 // Others // Monotheism
                               Tenrikyo |         45        0.00       87.15 // Monotheism
                           Neo-Paganism |        200        0.02       87.17 // Others // Other form of religion
                 Unitarian-Universalism |        123        0.01       87.18 // Others // Other form of religion
                         Rastafarianism |        122        0.01       87.19 // Others // Other form of religion
                            Scientology |         78        0.01       87.20 // Others // Other form of religion
Secular/Nonreligious/Agnostic/Atheist/N |     66,449        6.53       93.73
                                     27 |          1        0.00       93.73
                              Christian |     38,883        3.82       97.55
                          Taoism/Daoism |      1,498        0.15       97.69 // Other form of religion
        (No response)(2011 and earlier) |      6,656        0.65       98.35
                                   (DK) |      6,438        0.63       98.98
                              (Refused) |     10,376        1.02      100.00
----------------------------------------+-----------------------------------
                                  Total |  1,017,731      100.00
*/

gen xx= relig
drop relig
rename xx relig
label variable relig "WP1233 Religion"

/*
     WP1233 |
   Religion |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      6,411        0.63        0.63 
          1 |    251,242       24.69       25.32
          2 |    136,943       13.46       38.77
          3 |     94,975        9.33       48.10
          4 |    202,267       19.87       67.98
          5 |     18,340        1.80       69.78
          6 |     66,756        6.56       76.34
          7 |      1,234        0.12       76.46
          8 |     44,174        4.34       80.80
          9 |     49,979        4.91       85.71
         10 |      3,128        0.31       86.02
         11 |        406        0.04       86.06
         12 |        884        0.09       86.15
         13 |         40        0.00       86.15
         14 |        816        0.08       86.23
         15 |      8,780        0.86       87.09
         16 |        188        0.02       87.11
         17 |         72        0.01       87.12
         18 |         22        0.00       87.12
         19 |        149        0.01       87.14
         20 |         56        0.01       87.14
         21 |         45        0.00       87.15
         22 |        200        0.02       87.17
         23 |        123        0.01       87.18
         24 |        122        0.01       87.19
         25 |         78        0.01       87.20
         26 |     66,449        6.53       93.73
         27 |          1        0.00       93.73
         28 |     38,883        3.82       97.55
         29 |      1,498        0.15       97.69
         97 |      6,656        0.65       98.35
         98 |      6,438        0.63       98.98
         99 |     10,376        1.02      100.00
------------+-----------------------------------
      Total |  1,017,731      100.00
*/

replace relig=97 if relig==27

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

* By number of gods
gen Monotheism=1 if relig==1 | relig==2 | relig==3 | relig==4 | relig==5 | relig==6 | relig==7 | relig==12 | relig==15 | relig==16 | relig==20 | relig==21 | relig==28
replace Monotheism=0 if Monotheism==.
replace Monotheism=. if relig==97 | relig==98 | relig==99 | relig==.

gen Polytheism=1 if relig==8 | relig==18
replace Polytheism=0 if Polytheism==.
replace Polytheism=. if relig==97 | relig==98 | relig==99 | relig==.

gen OtherFormsReligions=1 if relig==9 | relig==10 | relig==11 | relig==13 | relig==17 | relig==19 | relig==22 | relig==23 | relig==24 | relig==25 | relig==29
replace OtherFormsReligions=0 if OtherFormsReligions==.
replace OtherFormsReligions=. if relig==97 | relig==98 | relig==99 | relig==.

* Dummy religious or not
gen ReligDummy = .
replace ReligDummy=0 if relig==26
replace ReligDummy=1 if relig>=0 & relig<26
replace ReligDummy=1 if relig>26 & relig<97
replace ReligDummy=. if relig==97 | relig==98 | relig==99 | relig==.

// ----------------------------------------
// DATA TRANSFORMATIONS
// ----------------------------------------

* Age categories: 18-75 years  
gen agesq = age*age
keep if age>=18  // (61,510 observations deleted)
drop if age>75  //(40,815 observations deleted)
gen age1835 = 0
gen age3550 = 0
gen age5065 = 0
gen age6575 = 0
replace age1835 = 1 if age>=18 & age<35  // (373,707 real changes made)
replace age3550 = 1 if age>=35 & age<50   // (305,083 real changes made)
replace age5065 = 1 if age>=50 & age < 65 // (192,736 real changes made)
replace age6575 = 1 if age>=65 & age<=75 // (94,796 real changes made)
label var age1835 "aged 18 to 34"
label var age3550 "aged 35 to 49"
label var age5065 "aged 50 to 64"
label var age6575 "aged 65 to 75"


/* OLD  
gen agesq = age*age
gen age1519 = 0
gen age2029 = 0
gen age3039 = 0
gen age4049 = 0
gen age5098 = 0

replace age1519 = 1 if age<20
replace age2029 = 1 if age>19 & age<30
replace age3039 = 1 if age>29 & age<40
replace age4049 = 1 if age>39 & age<50
replace age5098 = 1 if age>49 

label var agesq "square of age"
label var age1519 "aged 15 to 19"
label var age2029 "aged 20 to 29"
label var age3039 "aged 30 to 39"
label var age4049 "aged 40 to 49"
label var age5098 "aged 50 to 98"

* Age categories
* I would indeed keep those aged 18-19 just to see how many observations do we recuperate?
gen age1835 = 0 
replace age1835 = 1 if age>=18 & age<35  // (15,193 real changes made)
label var age1835 "aged 18 to 34"
gen age1819 = 0 
replace age1819 = 1 if age>=18 & age<20  // (1,112 real changes made)

*  It would be interesting to know how many of our former migrants are between 15-17 and above 75…
gen age1517 = 0 
replace age1517 = 1 if age>=15 & age<18  //  (1,225 real changes made)
gen age75plus = 0 
replace age75plus = 1 if age>75  // (2,373 real changes made)

* old age categories: age1519 age2029 age3039 age4049 age5064 age6598
tab age1519  // 2,337 obs 

* Option 1 keep 20-75 years  --> distribution is okay for me
keep if age>=18  // (2,337 observations deleted)    QUESTION= ARE WE TAKING 20 OR 18 NOW AS CUT OFF? 
drop if age>75  // (2,373 observations deleted)
gen age2035 = 0
gen age3550 = 0
gen age5075 = 0
replace age2035 = 1 if age>=20 & age<35  // (14,081 real changes made)
replace age3550 = 1 if age>=35 & age<50   // (13,901 real changes made)
replace age5075 = 1 if age>=50 & age<=75  // (14,151 real changes made)
label var age2035 "aged 20 to 34"
label var age3550 "aged 35 to 49"
label var age5075 "aged 50 to 75"

* Further split
gen age5065 = 0
replace age5065 = 1 if age >=50 & age<65
gen age6575 = 0
replace age6575 = 1 if age >=65 & age<75
*/ 

*** Take logarithms
*gen lhhincpc=ln(hhincpc)
gen lnhhincpc = ln(hhincpc + 1)

* OECD vs non-OECD  (problem with new-entering members during the years we cover 2009-2016, so take ref category, which year?)
* Chile, Estonia, Slovenia & Israel in 2010; ==> Added those 
* Colombia (2020); Latvia (2016); Lithuania (2018); ==> not 
gen OECD_cb = cntrybirth
foreach k in OECD_cb {
replace `k'="OECD" if `k'=="Australia" || `k'=="Austria" || `k'=="Belgium"|| `k'=="Canada"|| `k'=="Chile" || ///
`k'=="Czech Republic"|| `k'=="Denmark" || `k'=="Estonia" || `k'=="Finland" ||  `k'=="France" || ///
`k'=="Germany" || `k'=="Greece" || `k'=="Hungary" || `k'=="Iceland" || `k'=="Ireland" || `k'=="Israel" ||  ///
`k'=="Italy" || `k'=="Japan" ||  `k'=="Luxembourg" || `k'=="Mexico" ||`k'=="Netherlands" || ///
`k'=="New Zealand" || `k'=="Norway" || `k'=="Poland" || `k'=="Portugal" || `k'=="Slovakia" ||`k'=="Slovenia" || ///
`k'=="South Korea" || `k'=="Spain" || `k'=="Sweden" || `k'=="Switzerland" || `k'=="Turkey" || ///
`k'=="United Kingdom" || `k'=="United States"

replace `k'="non-OECD" if `k' !="OECD"
}
replace OECD_cb="" if cntrybirth=="" 

gen OECD_cc = origin
foreach k in OECD_cc {
replace `k'="OECD" if `k'=="Australia" || `k'=="Austria" || `k'=="Belgium"|| `k'=="Canada"|| `k'=="Chile" || ///
`k'=="Czech Republic"|| `k'=="Denmark" || `k'=="Estonia" || `k'=="Finland" ||  `k'=="France" || ///
`k'=="Germany" || `k'=="Greece" || `k'=="Hungary" || `k'=="Iceland" || `k'=="Ireland" || `k'=="Israel" ||  ///
`k'=="Italy" || `k'=="Japan" ||  `k'=="Luxembourg" || `k'=="Mexico" ||`k'=="Netherlands" || ///
`k'=="New Zealand" || `k'=="Norway" || `k'=="Poland" || `k'=="Portugal" || `k'=="Slovakia" ||`k'=="Slovenia" || ///
`k'=="South Korea" || `k'=="Spain" || `k'=="Sweden" || `k'=="Switzerland" || `k'=="Turkey" || ///
`k'=="United Kingdom" || `k'=="United States"

replace `k'="non-OECD" if `k' !="OECD"
}
replace OECD_cc="" if origin=="" 

* Clean wp4633
replace wp4633=. if wp4633==4 | wp4633==5

* Clean wp71
replace wp71=. if wp71==3 | wp71==4

* Clean wp9105
replace wp9105=. if wp9105>=900 // it replaces either countries of origin which are not countries (like "arab country") or answer for which we don't have any info

* Clean wp10963
replace wp10963=. if wp10963==3 | wp10963==4

* Create dummy to work with 
gen oecd_cb = . 
replace oecd_cb=1 if OECD_cb=="OECD" 
replace oecd_cb=0 if OECD_cb=="non-OECD" 

gen oecd_cc = . 
replace oecd_cc=1 if OECD_cc=="OECD" 
replace oecd_cc=0 if OECD_cc=="non-OECD" 

*** Rescale other variables
gen male = .
replace male=0 if gender==2
replace male=1 if gender==1

label var male "male"
label var lnhhincpc "ln of hhincpc +1"
label var age "age"
label var hhsize "HH size"
label var mhskill "sec or tert educ"
label var hskill "tert educ"

drop ow_in_perm_miss ow_in_temp_miss ow_pl_perm_miss ow_pl_temp_miss d_in d_pr d_pl mig mig_pl mig_pr mabr2
rename hhsize adults
replace adults=. if adults>=97 // 97=Not available, 98=(DK), 99=(Refused)

keep if native==0
drop if children==97
drop if missing(cntrybirth)
drop if cntrybirth==""
drop if cntrybirth=="(None)"
drop if cntrybirth=="(Refused)"
drop if cntrybirth=="(hold)"
drop if cntrybirth=="Other Country"

/*
*gen return = cntrybirth == dest_in // 1 = return, 0 = do not return
gen return =1 if (BMIG_in==1 & cntrybirth == dest_in) 
replace return =0 if BMIG_in==0  //  (only stay) 
replace return=. if (BMIG_in==1 & dest_in=="" | (BMIG_in==1 & dest_in!="" & dest_in!=cntrybirth))
gen movetoanother = 1 if cntrybirth != dest_in & dest_in != "" // 1 = move to another, 0 = do not move to another
replace movetoanother=0 if (BMIG_in==1 & dest_in!="" & cntrybirth == dest_in)
rename origin cntrycurrent
* Build dependent variable for mlogit
gen migration=.
replace migration=1 if return==1
replace migration=2 if movetoanother==1
replace movetoanother=0 if return==0
replace migration=0 if return==0 & movetoanother==0
* Need to make sure we dont replace by 0 observations for which we know either they return or they movetoanother
* migration=1 -> return or stay, migration=2 -> movetoanother, migration=0 -> neither return nor movetoanother
*/
rename origin cntrycurrent

* Creation Return and Movetoanother with stay=0 as baseline  
gen return=.  // (46,817 missing values generated)
replace return=1 if (BMIG_in==1 & dest_in==cntrybirth )  // (3,441 real changes made)
replace return=0 if BMIG_in==0  // only stay = 0  // (36,305 real changes made)
tab return // 39,746 

gen movetoanother=.  // (46,817 missing values generated)
replace movetoanother=1 if (BMIG_in==1 & dest_in!=cntrybirth & dest_in!= "")  // (7,071 real changes made)
replace movetoanother=0 if  BMIG_in==0 // only stay = 0  // (36,305 real changes made)
tab movetoanother //  43,376

* mlogit creation 
gen migration=. // (46,817 missing values generated)
replace migration=1 if (BMIG_in==1 & dest_in==cntrybirth )  // (3,441 real changes made)
replace migration=2 if (BMIG_in==1 & dest_in!=cntrybirth & dest_in!= "")  // (7,071 real changes made)
replace migration=0 if  BMIG_in==0 // 
tab migration // 46,817 observations 

* Creation Return with stay=0 & Movetoanother==0 as baseline  
gen return2=. 
replace return2=1 if (BMIG_in==1 & dest_in==cntrybirth ) 
replace return2=0 if BMIG_in==0 | (BMIG_in==1 & dest_in!=cntrybirth & dest_in!="") // stay and move onwards = 0 

* Creation Movetoanother with stay=0 & Return==0 as baseline  
gen movetoanother2=. 
replace movetoanother2=1 if (BMIG_in==1 & dest_in!=cntrybirth & dest_in!= "") 
replace movetoanother2=0 if  BMIG_in==0 |(BMIG_in==1 & dest_in==cntrybirth )  // stay and move onwards = 0 

*binomial logit between return and move onwards
gen binomial =. 
replace binomial=1 if return==1
replace binomial=0 if movetoanother==1 


* Add GADM level 0 (iso3) to destination countries
rename dest_in NAME_0
replace NAME_0="Antigua and Barbuda" if NAME_0=="Antigua & Barbuda"
replace NAME_0="Democratic Republic of the Congo" if NAME_0=="Congo (Kinshasa)"
replace NAME_0="Republic of Congo" if NAME_0=="Congo Brazzaville"
replace NAME_0="Côte d'Ivoire" if NAME_0=="Ivory Coast"
replace NAME_0="Macao" if NAME_0=="Macau"
replace NAME_0="Liechtenstein" if NAME_0=="Lichtenstein"
replace NAME_0="Palestina" if NAME_0=="Palestinian Territories"
replace NAME_0="Reunion" if NAME_0=="Reunion Island"
replace NAME_0="São Tomé and Príncipe" if NAME_0=="Sao Tome & Principe"
replace NAME_0="Saint Kitts and Nevis" if NAME_0=="St. Kitts & Nevis"
replace NAME_0="Saint Vincent and the Grenadines" if NAME_0=="St. Vincent & Grenadines"
replace NAME_0="Gambia" if NAME_0=="The Gambia"
replace NAME_0="Timor-Leste" if NAME_0=="Timor Leste"
replace NAME_0="Trinidad and Tobago" if NAME_0=="Trinidad & Tobago"
replace NAME_0="Eswatini" if NAME_0=="Somaliland region"

merge m:1 NAME_0 using "GADM/Clean/dta/worlddata.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                        36,387
        from master                    36,309  (_merge==1)
        from using                         78  (_merge==2)

    matched                            10,508  (_merge==3)
    -----------------------------------------
*/

//_merge==1 corresponds to observations without info on destination
drop if _merge==2
drop _merge
rename NAME_0 dest  
rename GID_0 iso3_dest
rename id id_dest

* Add GADM level 0 (iso3) to current countries
rename cntrycurrent NAME_0
replace NAME_0="Antigua and Barbuda" if NAME_0=="Antigua & Barbuda"
replace NAME_0="Democratic Republic of the Congo" if NAME_0=="Congo (Kinshasa)"
replace NAME_0="Republic of Congo" if NAME_0=="Congo Brazzaville"
replace NAME_0="Côte d'Ivoire" if NAME_0=="Ivory Coast"
replace NAME_0="Macao" if NAME_0=="Macau"
replace NAME_0="Liechtenstein" if NAME_0=="Lichtenstein"
replace NAME_0="Palestina" if NAME_0=="Palestinian Territories"
replace NAME_0="Reunion" if NAME_0=="Reunion Island"
replace NAME_0="São Tomé and Príncipe" if NAME_0=="Sao Tome & Principe"
replace NAME_0="Saint Kitts and Nevis" if NAME_0=="St. Kitts & Nevis"
replace NAME_0="Saint Vincent and the Grenadines" if NAME_0=="St. Vincent & Grenadines"
replace NAME_0="Gambia" if NAME_0=="The Gambia"
replace NAME_0="Timor-Leste" if NAME_0=="Timor Leste"
replace NAME_0="Trinidad and Tobago" if NAME_0=="Trinidad & Tobago"
replace NAME_0="Eswatini" if NAME_0=="Somaliland region"

merge m:1 NAME_0 using "GADM/Clean/dta/worlddata.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           110
        from master                         0  (_merge==1)
        from using                        110  (_merge==2)

    matched                            46,817  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2
drop _merge
rename NAME_0 cntrycurrent
rename GID_0 iso3_cntrycurrent
rename id id_cntrycurrent

* Add GADM level 0 (iso3) to birth countries
rename cntrybirth NAME_0
replace NAME_0="Antigua and Barbuda" if NAME_0=="Antigua & Barbuda"
replace NAME_0="Democratic Republic of the Congo" if NAME_0=="Congo (Kinshasa)"
replace NAME_0="Republic of Congo" if NAME_0=="Congo Brazzaville"
replace NAME_0="Côte d'Ivoire" if NAME_0=="Ivory Coast"
replace NAME_0="Macao" if NAME_0=="Macau"
replace NAME_0="Liechtenstein" if NAME_0=="Lichtenstein"
replace NAME_0="Palestina" if NAME_0=="Palestinian Territories"
replace NAME_0="Reunion" if NAME_0=="Reunion Island"
replace NAME_0="São Tomé and Príncipe" if NAME_0=="Sao Tome & Principe"
replace NAME_0="Saint Kitts and Nevis" if NAME_0=="St. Kitts & Nevis"
replace NAME_0="Saint Vincent and the Grenadines" if NAME_0=="St. Vincent & Grenadines"
replace NAME_0="Gambia" if NAME_0=="The Gambia"
replace NAME_0="Timor-Leste" if NAME_0=="Timor Leste"
replace NAME_0="Trinidad and Tobago" if NAME_0=="Trinidad & Tobago"
replace NAME_0="Eswatini" if NAME_0=="Somaliland region"

merge m:1 NAME_0 using "GADM/Clean/dta/worlddata.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           312
        from master                       252  (_merge==1)
        from using                         60  (_merge==2)

    matched                            46,565  (_merge==3)
    -----------------------------------------
*/
// _merge==1 corresponds to some areas which are not real countries

drop if _merge==2
drop _merge
rename NAME_0 cntrybirth
rename GID_0 iso3_cntrybirth
rename id id_cntrybirth

* gen HHsize=adults+children
gen HHsize=adults+children

* Replace wp9105 by a dummy=1 if the respondent has the nationality of his/her current country (note: wp9105 = nationality)
gen wp9105bis = .
// Now I make sure the variables "nationality" and "cntrycurrent" use the same countries name
replace nationality="Dominican Republic" if nationality=="Dominica"
replace nationality="Palestina" if nationality=="Palestinian Territories"
replace wp9105bis = 1 if nationality==cntrycurrent
replace wp9105bis = 0 if nationality!=cntrycurrent & nationality!=""

rename wp9042 movelast5years

drop if cntrybirth=="None" // 27 obs
drop if cntrybirth=="Other Islamic Country" // 20 obs
drop if cntrybirth=="African Country" // 109 obs
drop if cntrybirth=="Island Nations (11)" // 5 obs
drop if cntrybirth=="Arab Country" // 27 obs
// even if the destination is the same, we are not sure they want to move to the exact same country or move to another country in that same group of countries --> drop!

drop if dest=="" & cntrybirth=="" // 0 obs


save "GWP/Clean/dta/GallupCleaned.dta", replace
