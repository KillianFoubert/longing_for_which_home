********************************************************************************
* 15 - Additional GWP Variables
* Bekaert, Constant, Foubert & Ruyssen (2024) - JEBO
********************************************************************************
*
* Purpose: Extracts and adds supplementary variables from the GWP (community wellbeing indices, additional controls) to the return migration database.
*
* Input:   GWP raw data
*
* Output:  Additional GWP variables
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
cd "/Users/elsbekaert/Dropbox/Return Migration/Data/" // Els 
*cd "/Users/ilseruyssen/Dropbox/Return Migration/Data/" // Ilse

*use "GWP\Clean\dta\GWP2016 ID_GADM_fine cleaned.dta" // Killian
use "GWP/Clean/dta/GWP2016 ID_GADM_fine cleaned.dta", clear // Ilse & Els 

// -----------------------------------------------------------------------------
// A/ Select variables GWP to add 
// -----------------------------------------------------------------------------
rename WP* wp*
keep wpid wave wgt origin NAME_1 year wp9105 wp9042 wp10963 wp10248 wp27 wp30 wp12316 wp36 wp38 wp37 wp39 wp40 wp43 wp44

** Clear wp9105 - (Which country are you a national of? (Total sample.)) 
decode wp9105, generate(nationality) 
replace nationality="" if nationality=="(DK)" // (67 real changes made)

** Clear wp9042 - Did you move to this country within the last five years?
tab wp9042
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

** Clear wp10963 -  Have you been living in this country for more than 12 months, or not? (asked only of those who have moved to this country within the last 5 years
tab wp10963  // (only 112 answers)
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


** Clear wp12316 - In the past 12 months, did this household send help in the form of money or goods to another individual to another individual living inside this country, living in another country, both, or neither?
tab wp12316
/*
    WP12316 Sent Financial |
                      Help |      Freq.     Percent        Cum.
---------------------------+-----------------------------------
Living inside this country |    112,797       16.24       16.24
 Living in another country |     23,756        3.42       19.66
                      Both |     16,845        2.43       22.09
                   Neither |    525,345       75.65       97.74
                      (DK) |     11,700        1.68       99.42
                 (Refused) |      4,016        0.58      100.00
---------------------------+-----------------------------------
                     Total |    694,459      100.00
*/


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

** Clear wp43 - Have there been times in the past 12 months when you did not have enough money  to provide adequate shelter or housing for you and your family? 
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
computed using polychoric principal component analysis (see Online Appendix C for a 
description of the method). Sample weights are applied in the estimation. A higher 
value of an index indicates a better situation. Proportion of variance explained 
by the first component is 0.58.
*/
foreach k in WP37 WP38 WP39 WP40 WP43 WP44 {
	replace `k'=. if `k'>2
	replace `k'=0 if `k'==2 // Recode so that dummy is 0 for no and 1 for yes
}
sum WP37 WP38 WP39 WP40 WP43 WP44

polychoricpca WP37 WP39 WP40 WP43 WP44, score(pc_orig) nscore(1)
polychoricpca WP37 WP39 WP40 WP43, score(pc) nscore(1)
rename pc1 welfare
** Add variable welfare to controls 
