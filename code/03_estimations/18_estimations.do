********************************************************************************
* 18 - Estimations
* Bekaert, Constant, Foubert & Ruyssen (2024) - JEBO
********************************************************************************
*
* Purpose: Runs all multinomial logit and binomial logit estimations: benchmark (Table 1), dominance analysis (Table 2), return vs onwards (Table 3), heterogeneity by development level (Table 4), and robustness checks (Tables B1-B2).
*
* Input:   Return database.dta
*
* Output:  LaTeX tables and Stata output
*
* Note: These scripts were developed as part of a collaborative research workflow
* among co-authors over several years. Internal annotations, commented-out file
* paths, and exploratory code blocks reflect this iterative process and have been
* preserved for transparency and reproducibility.
********************************************************************************

********************************************************************************
************** Clean descriptives, regressions & appendices ********************
********************************************************************************

***---------
*** Set-up 
***---------

cls 
clear all 
set more off 
set scrollbufsize 500000 
set maxvar 10000
graph drop _all 
capture log close 
set matsize 11000

*cd "D:\Dropbox\Return Migration\" // Killian fix PC
*cd "C:\Users\kifouber\Dropbox\Return Migration\" // Killian laptop
cd "/Users/elsbekaert/Dropbox/Return Migration/" // Els 
*cd "/Users/ilseruyssen/Dropbox/Return Migration/" // Ilse  
use "Data/Merge/Clean/dta/Return database.dta"

* Individual controls 
global demographics "age3550 age5065 age6575 male Cohabitation HHsize"
global humancaptial "mskill hskill movelast5years INDEX_PH Christianity Islam OtherReligionsAndJudaism" 
global network "mabr closesocialnetwork1" // remit_abroad
global economic "empl BasicWealth  feelingsHHinc_comfortably  satisPP"
global wellbeing "INDEX_DI INDEX_CB"  

* Macro controls  
global gdpgrowth "GDPgrowth_cntrycurrent GDPgrowth_cntrybirth"
global macrovars "disaster_freqC12_cc disaster_freqC12_cb PolInstab3y_cntrycurrent PolInstab3y_cntrybirth"  

***------------------------------
** Table 1: Descriptive Statistics 
***------------------------------
qui mlogit migration $demographics $humancaptial i.cc i.y, rrr robust cluster(cc) diff tech(nr dfp) 
est store Tdesc
sum2docx stay return2 movetoanother2 age age1835 $demographics lskill $humancaptial NoReligion $network $economic $wellbeing $gdpgrowth $macrovars /// 
	if e(sample)==1 using "Estimations/Results/Results JEBO/Descriptive_Statistics.docx", ///
	replace stats(N mean(%9.3f) sd min(%9.0g) median(%9.0g) max(%9.0g)) title("Table: Summary statistics benchmark") 

* Stay
est restore Tdesc
sum2docx stay return2 movetoanother2 age age1835 $demographics lskill $humancaptial NoReligion $network $economic $wellbeing $gdpgrowth $macrovars /// 
	if e(sample)==1 & migration==0 using "Estimations/Results/Results JEBO/Descriptive_Statistics_stay.docx", ///
	replace stats(N mean(%9.3f) sd min(%9.0g) median(%9.0g) max(%9.0g)) title("Table: Summary statistics Stay") 
* Return
est restore Tdesc
sum2docx stay return2 movetoanother2 age age1835 $demographics lskill $humancaptial NoReligion $network $economic $wellbeing $gdpgrowth $macrovars ///
	if e(sample)==1 & migration==1 using "Estimations/Results/Results JEBO/Descriptive_Statistics_return.docx", ///
	replace stats(N mean(%9.3f) sd min(%9.0g) median(%9.0g) max(%9.0g)) title("Table: Summary statistics Return") 
* Move to another 
est restore Tdesc
sum2docx stay return2 movetoanother2 age age1835 $demographics lskill $humancaptial NoReligion $network $economic $wellbeing $gdpgrowth $macrovars ///
	if e(sample)==1 & migration==2 using "Estimations/Results/Results JEBO/Descriptive_Statistics_movetoanother.docx", ///
	replace stats(N mean(%9.3f) sd min(%9.0g) median(%9.0g) max(%9.0g)) title("Table: Summary statistics Move to another") 

* Correlations 
qui mlogit migration $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) 
est store Tdesc_full
pwcorr age $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars if e(sample)==1 , star(0.01)
estpost corr age $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars if e(sample)==1, matrix
esttab . using "Estimations/Results/Results JEBO/pwcorrelation.xls", not unstack compress noobs replace booktabs page label
!texify -p -c -b --run-viewer pwcorrelation_return.xls 

*JEBO_REFEREE1 - COMMENT 1: age distributions
* new categorical variable
gen agegroup = .
replace agegroup = 1 if age1835 == 1
replace agegroup = 2 if age3550 == 1
replace agegroup = 3 if age5065 == 1
replace agegroup = 4 if age6575 == 1
label define agegroup 1 "18-34" 2 "35-49" 3 "50-64" 4 "65-75"
label values agegroup agegroup

* Now cross-tabulate the agegroup variable with the migration variable
tab agegroup migration if e(sample) == 1, chi2
tab agegroup migration if e(sample) == 1, chi2 row nofreq

* Create lineplot for migration (aggregate shares) against age if e(sample)
preserve
keep if e(sample)
keep age migration
gen migasp = .
replace migasp = 1 if (migration == 1 | migration == 2)
replace migasp = 0 if migration == 0
gen retasp = .
replace retasp = 1 if migration == 1
replace retasp = 0 if (migration == 0 | migration == 2)
gen migasp_pos = migasp
gen migasp_nresp = migasp
gen retasp_pos = retasp
gen retasp_nresp = retasp
collapse (sum) migasp_pos retasp_pos (count) migasp_nresp retasp_nresp, by(age)
gen migasp_share = migasp_pos/migasp_nresp
gen retasp_share = retasp_pos/retasp_nresp
set scheme s1color  
twoway (line migasp_share age, lcolor(blue)), ytitle(Share of migration aspirations) xtitle(Age)
*graph export "Results/Results JEBO/migasp_share.eps", name(Share of migration aspirations by age) replace // My graph window gives an error message lately so stored it manually
twoway (line retasp_share age, lcolor(blue)), ytitle(Share of migration aspirations) xtitle(Age)
*graph export "Results/Results JEBO/retasp_share.eps", name(Share of return aspirations by age) replace // My graph window gives an error message lately so stored it manually
restore


***------------------------------
*** Benchmark  
***------------------------------

* Table 2: Benchmark   
mlogit migration $demographics $humancaptial i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) 
est store T2_a 
mlogit migration $demographics $humancaptial $network i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp)
est store T2_b
mlogit migration $demographics $humancaptial $network $economic i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp)
est store T2_c
mlogit migration $demographics $humancaptial $network $economic $wellbeing i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork
est store T2_d
mlogit migration $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork // 1,106 jews in total, 1,072 of them in Israel
est store T2_e
esttab T2_a T2_b T2_c T2_d T2_e using "Estimations/Results/Results JEBO/Table 2_benchmark.xls", ///
	label title("Table 2: Relative risk ratios to aspire to return or move onwards versus stay") ///
	mtitles("Demographics, human and spiritual capital" "Networks" "Individual Economic Indicators" "Community Wellbeing" "Macroeconomics, Environment, Polity") ///
	eform nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") ///
	obslast addnotes("Standard errors are robust to within host country correlation.")

	
* Hausman test for IIA 
*full mlogit 
mlogit migration $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) 
estimates store allcats
* Reduced mlogit
mlogit migration $demographics $humancapital $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.y if migration != 1, rrr robust cluster(cc) base(0) diff tech(nr dfp)
estimates store reduced
* Hausman
hausman allcats reduced, alleqs constant
/*
. hausman allcats reduced, alleqs constant
hausman cannot be used with vce(robust), vce(cluster cvar), or p-weighted data
r(198);

STATA MANUAL: The assumption that one of the estimators is efficient (that is, has minimal asymptotic
    variance) is a demanding one.  It is violated, for instance, if your observations are
    clustered or pweighted, or if your model is somehow misspecified.  Moreover, even if the
    assumption is satisfied, there may be a "small sample" problem with the Hausman test.
    Hausman's test is based on estimating the variance var(b-B) of the difference of the
    estimators by the difference var(b)-var(B) of the variances.  Under the assumptions (1)
    and (3), var(b)-var(B) is a consistent estimator of var(b-B), but it is not necessarily
    positive definite "in finite samples", that is, in your application.  If this is the
    case, the Hausman test is undefined.  Unfortunately, this is not a rare event.  Stata
    supports a generalized Hausman test that overcomes both of these problems.  See [R] suest
    for details.
*/

* Alternative: suest //https://www.stata.com/manuals/rsuest.pdf
* Note
 //   estimators should be estimated without vce(robust) or vce(cluster clustvar) options.
 //   suest returns the robust VCE, allows the vce(cluster clustvar) option,
qui mlogit migration $demographics $humancapital $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.y, rrr base(0) diff tech(nr dfp)
estimates store mlfull
* Excluding return
qui mlogit migration $demographics $humancapital $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.y if migration != 1, rrr base(0) diff tech(nr dfp)
estimates store mlnoreturn
* Excluding move onwards 
qui mlogit migration $demographics $humancapital $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.y if migration != 2, rrr base(0) diff tech(nr dfp)
estimates store mlnomoveonw

*Suest (return removed) 
suest mlfull mlnoreturn, cluster(cc)
test [mlfull_2 = mlnoreturn_2], cons common
*test [mlfull_2]age3550 = [mlnoreturn_2]age3550
*  chi2(117) = 1.6e+11
*         Prob > chi2 =    0.0000
*--> IIA is a problem

* Suest (move onwards)removed 
suest mlfull mlnomoveonw, cluster(cc)
test [mlfull_1 = mlnomoveonw_1], cons common
*    chi2(111) = 1.7e+14
*         Prob > chi2 =    0.0000
* --> IIA is a problem


qui mlogit migration $demographics $humancapital $network $economic $wellbeing, rrr base(0) diff tech(nr dfp)
estimates store ml1
* Excluding return
qui mlogit migration $demographics $humancapital $network $economic $wellbeing if migration != 1, rrr base(0) diff tech(nr dfp)
estimates store ml2
*Suest (return removed) 
suest ml1 ml2, cluster(cc)
test [ml1_2 = ml2_2], cons common
*    chi2( 15) =    8.69
*         Prob > chi2 =    0.8931
* -->no significant difference between the full model and the reduced model, 
*--> the IIA assumption holds when the 'Return' option is excluded

* Excluding move onwards 
qui mlogit migration $demographics $humancapital $network $economic $wellbeing if migration != 2, rrr base(0) diff tech(nr dfp)
estimates store ml3
* Suest (move onwards)removed 
suest ml1 ml3, cluster(cc)
test [ml1_1 = ml3_1], cons common
*          chi2( 15) =   33.70
*         Prob > chi2 =    0.0038
* --> significant difference btw full and reduced model
* --> IIA does not hold when 'move onwards' option is excluded/not considered. 
* --> suggests that the presence of the moveo onwards option influences individuals' migration decisions relative to the other choices in the model 


	
*JEBO_REFEREE1 - COMMENT 7: robustness age 
** Adapt age because it's 50-64, not 65. 
gen age5065new = 0
replace age5065new = 1 if age>=50 & age <= 65 
label var age5065new "aged 50 to 65"
global demographics_age "age3550 age5065new male Cohabitation HHsize"
gen working_age = (age >= 18 & age <= 65)
* Re-running the benchmark models with the condition for working age
mlogit migration $demographics_age $humancaptial i.cc i.y if working_age == 1, rrr robust cluster(cc) base(0) diff tech(nr dfp) 
est store T2_a 
mlogit migration $demographics_age $humancaptial $network i.cc i.y if working_age == 1, rrr robust cluster(cc) base(0) diff tech(nr dfp)
est store T2_b
mlogit migration $demographics_age $humancaptial $network $economic i.cc i.y if working_age == 1, rrr robust cluster(cc) base(0) diff tech(nr dfp)
est store T2_c
mlogit migration $demographics_age $humancaptial $network $economic $wellbeing i.cc i.y if working_age == 1, rrr robust cluster(cc) base(0) diff tech(nr dfp)
est store T2_d
mlogit migration $demographics_age $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.y if working_age == 1, rrr robust cluster(cc) base(0) diff tech(nr dfp)
est store T2_e
esttab T2_a T2_b T2_c T2_d T2_e using "Estimations/Results/Results JEBO/Table2_benchmark_working_age.xls", ///
    label title("Table 2: Relative risk ratios to aspire to return or move onwards versus stay (Working Age 18-65)") ///
    mtitles("Demographics, human and spiritual capital" "Networks" "Individual Economic Indicators" "Community Wellbeing" "Macroeconomics, Environment, Polity") ///
    eform nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") ///
    obslast addnotes("Analysis is restricted to individuals aged 18-65. Standard errors are robust to within host country correlation.")

*JEBO_REFEREE1 - COMMENT 4: religion 
***  wp119  // (Is religion an important part of your daily life?) 
global religionimportant "mskill hskill movelast5years INDEX_PH wp119bis" 

mlogit migration $demographics $religionimportant i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) 
est store T2_a 
mlogit migration $demographics $religionimportant $network i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp)
est store T2_b
mlogit migration $demographics $religionimportant $network $economic i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp)
est store T2_c
mlogit migration $demographics $religionimportant $network $economic $wellbeing i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork
est store T2_d
mlogit migration $demographics $religionimportant $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork // 1,106 jews in total, 1,072 of them in Israel
est store T2_e
esttab T2_a T2_b T2_c T2_d T2_e using "Estimations/Results/Results JEBO/Table 2_benchmark_religionimportant.xls", ///
	label title("Table 2: Relative risk ratios to aspire to return or move onwards versus stay") ///
	mtitles("Demographics, human and spiritual capital" "Networks" "Individual Economic Indicators" "Community Wellbeing" "Macroeconomics, Environment, Polity") ///
	eform nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") ///
	obslast addnotes("Standard errors are robust to within host country correlation.")
est restore T2_a
tab wp119bis if e(sample)==1

** Descriptives Religion 23Nov
preserve
collapse (sum) sum_NoReligion=NoReligion sum_Christianity=Christianity sum_Islam=Islam sum_Other=OtherReligionsAndJudaism, by(cntrycurrent)
gen total = sum_NoReligion + sum_Christianity + sum_Islam + sum_Other
gen pct_NoReligion = sum_NoReligion / total * 100
gen pct_Christianity = sum_Christianity / total * 100
gen pct_Islam = sum_Islam / total * 100
gen pct_Other = sum_Other / total * 100
format pct_NoReligion %9.2f
format pct_Christianity %9.2f
format pct_Islam %9.2f
format pct_Other %9.2f
list cntrycurrent pct_NoReligion pct_Christianity pct_Islam pct_Other in 1/10
export excel using "Estimations/Results/Results JEBO/Sharesmigrantsreligionhost.xlsx", firstrow(variables) replace
restore

** Descriptives Religion 24Nov: outmigration (return & move onwards)
preserve
collapse (sum) sum_NoReligion=NoReligion sum_Christianity=Christianity sum_Islam=Islam sum_Other=OtherReligionsAndJudaism, by(cntrycurrent)
gen total = sum_NoReligion + sum_Christianity + sum_Islam + sum_Other
gen pct_NoReligion = sum_NoReligion / total * 100
gen pct_Christianity = sum_Christianity / total * 100
gen pct_Islam = sum_Islam / total * 100
gen pct_Other = sum_Other / total * 100
format pct_NoReligion %9.2f
format pct_Christianity %9.2f
format pct_Islam %9.2f
format pct_Other %9.2f
list cntrycurrent migration pct_NoReligion pct_Christianity pct_Islam pct_Other if migration ==1 | migration ==2 in 1/10
export excel using "Estimations/Results/Results JEBO/Sharesmigrantsreligionintent.xlsx", firstrow(variables) replace
restore


*** MAJOR RELIGION DUMMY (treshold 50 percent):
*** Has to be merged with the GWP dataset:
merge m:1 origin using "Data/GWP/Clean/dta/Major Religions by country50_categories.dta", nogen
tab origin relig if _merge==1

* Generating a variable identifying the broader category of religion, assigning values based on the codes in the 'relig' variable (see do-file "Cleaning GWP IR_EB")
gen religcategory = .
replace religcategory = 1 if inlist(relig, 1, 2, 3, 28)   // Christian
replace religcategory = 2 if inlist(relig, 4, 5, 6, 7)    // Islam/Muslim
replace religcategory = 3 if relig == 8                   // Hinduism
replace religcategory = 4 if relig == 9                   // Buddhist
replace religcategory = 5 if relig == 15                  // Judaism
replace religcategory = 6 if relig == 26                  // Secular/nonreligious/agnostic/atheist
replace religcategory = 7 if inlist(relig, 0, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 29) // Other (smaller) religions
replace religcategory = . if inlist(relig, 97, 98, 99, .)

*** And then there should be the following dummy created to identify whether individuals' religion is one of the major ones in the host country:
gen MajorReligionMatch = .
replace MajorReligionMatch = 1 if religcategory == Major50Religion1 | religcategory == Major50Religion2 
replace MajorReligionMatch = 0 if (religcategory != Major50Religion1 & religcategory != Major50Religion2) & religcategory != .

*** Then this dummy can be used in to replace the religion dummy we have now in our benchmark
global majorreligioncontrols "mskill hskill movelast5years INDEX_PH MajorReligionMatch" 
mlogit migration $demographics $majorreligioncontrols i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) 
est store T2_a 
mlogit migration $demographics $majorreligioncontrols $network i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp)
est store T2_b
mlogit migration $demographics $majorreligioncontrols $network $economic i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp)
est store T2_c
mlogit migration $demographics $majorreligioncontrols $network $economic $wellbeing i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork
est store T2_d
mlogit migration $demographics $majorreligioncontrols $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork // 1,106 jews in total, 1,072 of them in Israel
est store T2_e
esttab T2_a T2_b T2_c T2_d T2_e using "Estimations/Results/Results JEBO/Table 2_benchmark_majorreligion50.xls", ///
	label title("Table 2: Relative risk ratios to aspire to return or move onwards versus stay") ///
	mtitles("Demographics, human and spiritual capital" "Networks" "Individual Economic Indicators" "Community Wellbeing" "Macroeconomics, Environment, Polity") ///
	eform nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") ///
	obslast addnotes("Standard errors are robust to within host country correlation.")


*** MAJOR RELIGION DUMMY (treshold 80 percent):
*** Has to be merged with the GWP dataset:
merge m:1 origin using "Data/GWP/Clean/dta/Major Religions by country80_categories.dta", nogen
tab origin relig if _merge==1

*** And then there should be the following dummy created to identify whether individuals' religion is one of the major ones in the host country:
gen MajorReligionMatch80 = .
replace MajorReligionMatch80 = 1 if religcategory == Major80Religion1 | religcategory == Major80Religion2 | religcategory == Major80Religion3
replace MajorReligionMatch80 = 0 if (religcategory != Major80Religion1 & religcategory != Major80Religion2  & religcategory != Major80Religion3) & religcategory != .
*** Then this dummy can be used in to replace the religion dummy we have now in our benchmark

global majorreligioncontrols "mskill hskill movelast5years INDEX_PH MajorReligionMatch80" 
mlogit migration $demographics $majorreligioncontrols i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) 
est store T2_a 
mlogit migration $demographics $majorreligioncontrols $network i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp)
est store T2_b
mlogit migration $demographics $majorreligioncontrols $network $economic i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp)
est store T2_c
mlogit migration $demographics $majorreligioncontrols $network $economic $wellbeing i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork
est store T2_d
mlogit migration $demographics $majorreligioncontrols $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork // 1,106 jews in total, 1,072 of them in Israel
est store T2_e
esttab T2_a T2_b T2_c T2_d T2_e using "Estimations/Results/Results JEBO/Table 2_benchmark_majorreligion80.xls", ///
	label title("Table 2: Relative risk ratios to aspire to return or move onwards versus stay") ///
	mtitles("Demographics, human and spiritual capital" "Networks" "Individual Economic Indicators" "Community Wellbeing" "Macroeconomics, Environment, Polity") ///
	eform nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") ///
	obslast addnotes("Standard errors are robust to within host country correlation.")

	
	
	
	
*JEBO_REFEREE1 - COMMENT 5: local networks 
global networknopca "mabr wp10248" 
mlogit migration $demographics $humancaptial i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) 
est store T2_a 
mlogit migration $demographics $humancaptial $networknopca i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp)
est store T2_b
mlogit migration $demographics $humancaptial $networknopca $economic i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp)
est store T2_c
mlogit migration $demographics $humancaptial $networknopca $economic $wellbeing i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork
est store T2_d
mlogit migration $demographics $humancaptial $networknopca $economic $wellbeing $gdpgrowth $macrovars i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork // 1,106 jews in total, 1,072 of them in Israel
est store T2_e
esttab T2_a T2_b T2_c T2_d T2_e using "Estimations/Results/Results JEBO/Table 2_benchmark_networknopca.xls", ///
	label title("Table 2: Relative risk ratios to aspire to return or move onwards versus stay") ///
	mtitles("Demographics, human and spiritual capital" "Networks" "Individual Economic Indicators" "Community Wellbeing" "Macroeconomics, Environment, Polity") ///
	eform nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") ///
	obslast addnotes("Standard errors are robust to within host country correlation.")



* Table 3: Dominance analysis
* --> to analayse relative importance of independent variables 
* domin command //Determining relative importance in Stata using dominance analysis: domin and domme  by Joseph N. Luchman, Fors Marsh Group
// install package  + ssc install moremata
* Macro vars  DA 
domin migration, reg(mlogit) fitstat(e(r2_p)) ///
sets((age3550 age5065 age6575 male Cohabitation HHsize) ///
(mskill hskill movelast5years INDEX_PH Christianity Islam OtherReligionsAndJudaism) ///
(mabr closesocialnetwork1) /// 
(empl BasicWealth  feelingsHHinc_comfortably  satisPP) ///
(INDEX_DI INDEX_CB) /// 
(GDPgrowth_cntrycurrent GDPgrowth_cntrybirth) ///
(disaster_freqC12_cc disaster_freqC12_cb PolInstab3y_cntrycurrent PolInstab3y_cntrybirth)) 
/// 127 regressions: OK 

*JEBO_REFEREE1 - COMMENT 5: seperate disaster vs political situation
domin migration, reg(mlogit) fitstat(e(r2_p)) ///
sets((age3550 age5065 age6575 male Cohabitation HHsize) ///
(mskill hskill movelast5years INDEX_PH Christianity Islam OtherReligionsAndJudaism) ///
(mabr closesocialnetwork1) /// 
(empl BasicWealth  feelingsHHinc_comfortably  satisPP) ///
(INDEX_DI INDEX_CB) /// 
(GDPgrowth_cntrycurrent GDPgrowth_cntrybirth) ///
(disaster_freqC12_cc disaster_freqC12_cb) /// 
(PolInstab3y_cntrycurrent PolInstab3y_cntrybirth)) 
/// 255 regressions 



** Table 4: Relative risk ratios on Aspirations to Return versus Migrating Onwards (logit) 
*** To be correct this should be sample selection  *** 
* New results: logit return vs move onwards   (binomial=1 if return==1 & binomial=0 if movetoanother==1) 
logit binomial $demographics $humancaptial i.cc i.y, robust cluster(cc) diff tech(nr dfp)
est store T4_a 
logit binomial $demographics $humancaptial $network i.cc i.y, robust cluster(cc) diff tech(nr dfp)
est store T4_b
logit binomial $demographics $humancaptial $network $economic i.cc i.y, robust cluster(cc) diff tech(nr dfp) 
est store T4_c
display %18.0g _b[empl]/_se[empl]
logit binomial $demographics $humancaptial $network $economic $wellbeing i.cc i.y, robust cluster(cc) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork
est store T4_d
display %18.0g _b[empl]/_se[empl] 
logit binomial $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.y, robust cluster(cc) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork
est store T4_e
display %18.0g _b[empl]/_se[empl]
esttab T4_a T4_b T4_c T4_d T4_e using "Estimations/Results/Results JEBO/Table 4_logit_binomial.xls", label title("Table B2: Relative risk ratios on aspirations to return versus migrating onwards") mtitles("Demographics, human and spiritual capital" "Networks" "Individual Economic Indicators" "Community Wellbeing" "Macroeconomics, Environment, Polity") ///
eform nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")



**JEBO: MULTIVARIATE PROBIT	
* In a multivariate probit model --> analyze the impacts of various independent variables on multiple binary dependent variables 
* simultaneously, which could offer insights into the correlations among the different binary outcomes.
/*qui ssc install mvprobit


qui mvprobit (return = $demographics $humancapital i.cc i.y) ///
             (movetoanother = $demographics $humancapital i.cc i.y), robust cluster(cc)
*factor-variable and time-series operators not allowed // r(101);
tabulate cc, generate(country)
tabulate y, generate(year)

qui mvprobit (return = $demographics $humancapital country* year*) ///
             (movetoanother = $demographics $humancapital country* year*), robust cluster(cc) // 
/*return is always zero
r(2000);
*/

*simplest model 
qui mvprobit (return = $demographics) (movetoanother = $demographics), robust cluster(cc)
/*return is always zero
r(2000);
*/
qui mvprobit (return = male) (movetoanother = male), robust cluster(cc)
/*return is always zero
r(2000);
*/
tabulate return
/*
. tabulate return

     return |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     33,235       91.17       91.17
          1 |      3,218        8.83      100.00
------------+-----------------------------------
      Total |     36,453      100.00
*/
summarize male if cc == 1
tabulate return if cc == 1
***---> error not caused by a lack of variation!!! 
tabulate movetoanother // ok

qui mvprobit (stay = male) (return = male) (movetoanother = male) //error

** https://cran.r-project.org/web/packages/mvProbit/mvProbit.pdf
** https://www.uab.cat/Document/6/683/sj3-3.pdf 

probit return male  // this works
qui mvprobit (return = male) (movetoanother = male) // error


Tligt niet aan jou, ik denk dat je dit eigenlijk niet kan gebruiken als alternatief voor
multinomial waarbij je eigenlijk één dep var hebt, maar het wordt gebruikt voor modellen
waarbij je meerdere modellen tegelijk schat (dus voor twee variabelen die niets met elkaar
te maken hebben). Bijvoorbeeld:

"mvprobit  (return = male) (mskill = male)" lukt wel!


*** Chatgpt proposed to use gsem: (produces estiamted coefs, not RRRs!!!

In an MVP model, you are modeling the joint probabilities of multiple binary outcomes 
(e.g., returning and moving onward) as correlated outcomes. The coefficients in a 
multivariate probit model do not have a straightforward interpretation in terms of 
relative risk ratios, as they relate to the underlying latent variables rather than 
directly to the observed outcomes.

In a multivariate probit model, the focus is on estimating the correlations between 
the latent variables that generate the observed binary outcomes. The coefficients 
represent the effect of predictor variables on the latent variables. The magnitude 
and direction of these effects are not easily interpretable as relative risk ratios.

To interpret the results of a multivariate probit model, researchers often rely on 
the signs and statistical significance of the coefficients to understand the 
relationships between predictor variables and the latent variables. However, 
they do not have a direct, easily interpretable relative risk ratio interpretation 
as in multinomial logit models.

If you are interested in relative risk ratios, it's more appropriate to use a 
multinomial logit model for your analysis, provided that the assumptions of 
the model are met and the choice set aligns with your research question.*/

*** For some reason humancapital vars need to be included as such otherwise those variables aren't considered...
gsem (Return: return = $demographics mskill hskill movelast5years INDEX_PH Christianity Islam OtherReligionsAndJudaism i.cc i.y) ///
       (Onward: movetoanother = $demographics mskill hskill movelast5years INDEX_PH Christianity Islam OtherReligionsAndJudaism i.cc i.y), ///
       family(binomial) link(probit) nocapslatent
est store T2_a
gsem (Return: return = $demographics mskill hskill movelast5years INDEX_PH Christianity Islam OtherReligionsAndJudaism $network  i.cc i.y) ///
       (Onward: movetoanother = $demographics mskill hskill movelast5years INDEX_PH Christianity Islam OtherReligionsAndJudaism $network  i.cc i.y), ///
       family(binomial) link(probit) nocapslatent
est store T2_b 
gsem (Return: return = $demographics mskill hskill movelast5years INDEX_PH Christianity Islam OtherReligionsAndJudaism $network $economic i.cc i.y) ///
       (Onward: movetoanother = $demographics mskill hskill movelast5years INDEX_PH Christianity Islam OtherReligionsAndJudaism $network $economic i.cc i.y), ///
       family(binomial) link(probit) nocapslatent
est store T2_c 
gsem (Return: return = $demographics mskill hskill movelast5years INDEX_PH Christianity Islam OtherReligionsAndJudaism $network $economic $wellbeing i.cc i.y) ///
       (Onward: movetoanother = $demographics mskill hskill movelast5years INDEX_PH Christianity Islam OtherReligionsAndJudaism $network $economic $wellbeing  i.cc i.y), ///
       family(binomial) link(probit) nocapslatent
est store T2_d 
gsem (Return: return = $demographics mskill hskill movelast5years INDEX_PH Christianity Islam OtherReligionsAndJudaism $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.y) ///
       (Onward: movetoanother = $demographics mskill hskill movelast5years INDEX_PH Christianity Islam OtherReligionsAndJudaism $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.y), ///
       family(binomial) link(probit) nocapslatent
est store T2_e 
esttab T2_a T2_b T2_c T2_d T2_e using "Estimations/Results/Results JEBO/MLPROBIT_GSEM.xls", ///
     label title("Table 2: Multinomial probit for aspiring to return or migrate versus stay") ///
     nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") ///
     obslast addnotes("Standard errors are robust to within host country correlation.")


***------------------------------
*** Heterogeneity   
***------------------------------

* Table 5: Results by Countries of Residence Development Level
mlogit migration $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars  i.cc i.y if incomelevel_cc!="HIC", robust cluster(cc) diff tech(nr dfp) 
est store T5_a
mlogit migration $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars  i.cc i.y if incomelevel_cc=="HIC", robust cluster(cc) diff tech(nr dfp)
est store T5_b
esttab T5_a T5_b using "Estimations/Results/Results JEBO/Table 5_bydevelopment_cc.xls", label title("Table 3: Results by development level") mtitles("non-HIC" "HIC") ///
eform unstack nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")

* Table 6: Results by Countries of Birth Development Level 
mlogit migration $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars  i.cc i.y if incomelevel_cb!="HIC", robust cluster(cc) diff tech(nr dfp) 
est store T6_a
tab cntrybirth if incomelevel_cb!="HIC" & e(sample)==1, nofreq
mlogit migration $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars  i.cc i.y if incomelevel_cb=="HIC", robust cluster(cc) diff tech(nr dfp)
est store T6_b
tab cntrybirth if e(sample)==1
egen count_HIC = total(cntrybirth), by(cntrybirth) if incomelevel_cb == "HIC" & e(sample) == 1
count if count_HIC == 1


esttab T6_a T6_b using "Estimations/Results/Results JEBO/Table 6_bydevelopment_cb.xls", label title("Table 6: Results by development level: Birth country") mtitles("non-HIC" "HIC") ///
eform unstack nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")


*Schengen migrants in Schengen
* Schengen Area --> free movement (situation 2009 to 2016) : 
* Croatia: signed 2011, first implementation 2023 ?
* +  Common Travel Area (UK, IE)?

* Schengen CC/CB/Dest (26 countries) 
gen Schengen_cc= cntrycurrent
gen Schengen_cb= cntrybirth
gen Schengen_dest=dest
foreach k in Schengen_cc Schengen_cb Schengen_dest {
replace `k'="Schengen" if `k'=="Austria" || `k'=="Belgium"|| `k'=="Czech Republic"|| `k'=="Denmark" || ///
`k'=="Estonia" || `k'=="Latvia" || `k'=="Liechtenstein" || `k'=="Lithuania" || `k'=="Finland" ||  `k'=="France" || `k'=="Germany" || ///
`k'=="Greece" || `k'=="Hungary" || `k'=="Iceland" ||  `k'=="Italy" ||   `k'=="Luxembourg" || ///
`k'=="Malta" || `k'=="Netherlands" || `k'=="Norway" || `k'=="Poland" || `k'=="Portugal" || `k'=="Slovakia" || /// 
`k'=="Slovenia" || `k'=="Spain" || `k'=="Sweden" || `k'=="Switzerland"  

replace `k'="non-Schengen" if `k' !="Schengen"
}
replace Schengen_cc="" if cntrycurrent ==""
replace Schengen_cb ="" if cntrybirth ==""
replace Schengen_dest="" if dest==""

* Table 5: Schengen by ORIGIN + HOST 
mlogit migration $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars  i.cc i.y if ///
		Schengen_cc=="Schengen", robust cluster(cc) diff tech(nr dfp)
		est store T5_a
mlogit migration $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars  i.cc i.y if ///
		(Schengen_cc=="Schengen" & Schengen_cb=="Schengen"), robust cluster(cc) diff tech(nr dfp) 
		est store T5_b
mlogit migration $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars  i.cc i.y if ///
		(Schengen_cc=="Schengen" & Schengen_cb=="Schengen" & Schengen_dest=="Schengen"), robust cluster(cc) diff tech(nr dfp) 
		est store T5_c
esttab T5_a T5_b T5_c using "Estimations/Results/Results JEBO/Table 5_Schengen.xls", label title("Table 3: Results by development level") ///
 mtitles("Schengen_cc" "Schengen_cc+cb" "Schengen_cc+cb+dest") eform unstack nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) /// 
 nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")

* Complete Benchmark Schengen 
mlogit migration $demographics $humancaptial i.cc i.y if (Schengen_cc=="Schengen" & Schengen_cb=="Schengen"), robust cluster(cc) base(0) diff tech(nr dfp) 
est store T2_a 
mlogit migration $demographics $humancaptial $network i.cc i.y if (Schengen_cc=="Schengen" & Schengen_cb=="Schengen"), robust cluster(cc) base(0) diff tech(nr dfp)
est store T2_b
mlogit migration $demographics $humancaptial $network $economic i.cc i.y if (Schengen_cc=="Schengen" & Schengen_cb=="Schengen"), robust cluster(cc) base(0) diff tech(nr dfp)
est store T2_c
mlogit migration $demographics $humancaptial $network $economic $wellbeing i.cc i.y if (Schengen_cc=="Schengen" & Schengen_cb=="Schengen"), robust cluster(cc) base(0) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork
est store T2_d
mlogit migration $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.y if (Schengen_cc=="Schengen" & Schengen_cb=="Schengen"), robust cluster(cc) base(0) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork // 1,106 jews in total, 1,072 of them in Israel
est store T2_e
esttab T2_a T2_b T2_c T2_d T2_e using "Estimations/Results/Results JEBO/Benchmark_Schengen.xls", ///
	label title("Table 2: Relative risk ratios to aspire to return or move onwards versus stay") ///
	mtitles("Demographics, human and spiritual capital" "Networks" "Individual Economic Indicators" "Community Wellbeing" "Macroeconomics, Environment, Polity") ///
	eform nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") ///
	obslast addnotes("Standard errors are robust to within host country correlation.")

 
 
* REFEREE1: domin for host & birth Schengen country 
domin migration if (Schengen_cc=="Schengen" & Schengen_cb=="Schengen"), reg(mlogit) fitstat(e(r2_p)) ///
sets((age3550 age5065 age6575 male Cohabitation HHsize) ///
(mskill hskill movelast5years INDEX_PH Christianity Islam OtherReligionsAndJudaism) ///
(mabr closesocialnetwork1) /// 
(empl BasicWealth  feelingsHHinc_comfortably  satisPP) ///
(INDEX_DI INDEX_CB) /// 
(GDPgrowth_cntrycurrent GDPgrowth_cntrybirth) ///
(disaster_freqC12_cc disaster_freqC12_cb PolInstab3y_cntrycurrent PolInstab3y_cntrybirth)) 
/// 127 regressions: OK 



***------------------------------
*** Robustness checks   
***------------------------------

** See Appendix 

***----------------------
*** Appendix regressions   
***----------------------

* Appendix A: Figures 
* Appendix B: Tables 
** Table B1: Descriptive Statistics (narrow categorization) 
*** Descriptives 
gen stayHIC=. 
replace stayHIC=1 if mlogit_cat_dest==0 & incomelevel_cc=="HIC" // (9,822 real changes made)
replace stayHIC=0 if mlogit_cat_dest==1 | mlogit_cat_dest==2 | mlogit_cat_dest==3 | mlogit_cat_dest==4 // (33,235 real changes made)
gen stayLMIC=. 
replace stayLMIC=1 if mlogit_cat_dest==0 & incomelevel_cc!="HIC"  // (9,822 real changes made)
replace stayLMIC=0 if mlogit_cat_dest==1 | mlogit_cat_dest==1 | mlogit_cat_dest==3 | mlogit_cat_dest==4 // (33,235 real changes made)
gen returnHIC=. 
replace returnHIC=1 if mlogit_cat_dest==1   // (9,822 real changes made)
replace returnHIC=0 if mlogit_cat_dest==0 | mlogit_cat_dest==2 | mlogit_cat_dest==3 | mlogit_cat_dest==4 // (33,235 real changes made)
gen returnLMIC=. 
replace returnLMIC=1 if mlogit_cat_dest==2   // (9,822 real changes made)
replace returnLMIC=0 if mlogit_cat_dest==0 | mlogit_cat_dest==1 | mlogit_cat_dest==3 | mlogit_cat_dest==4 // (33,235 real changes made)
gen moveonwardsHIC=. 
replace moveonwardsHIC=1 if mlogit_cat_dest==3   // (9,822 real changes made)
replace moveonwardsHIC=0 if mlogit_cat_dest==0 | mlogit_cat_dest==1 | mlogit_cat_dest==2 | mlogit_cat_dest==4 // (33,235 real changes made)
gen moveonwardsLMIC=. 
replace moveonwardsLMIC=1 if mlogit_cat_dest==4   // (9,822 real changes made)
replace moveonwardsLMIC=0 if mlogit_cat_dest==0 | mlogit_cat_dest==1 | mlogit_cat_dest==2 | mlogit_cat_dest==3 // (33,235 real changes made)
qui mlogit mlogit_cat_dest $demographics $humancaptial i.cc i.y, rrr robust cluster(cc) diff tech(nr dfp) 
est store Tdesc2
est restore Tdesc2  
sum2docx mlogit_cat_dest stay returnHIC returnLMIC moveonwardsHIC  moveonwardsLMIC age age1835 $demographics lskill $humancaptial NoReligion $network $economic $wellbeing $gdpgrowth $macrovars if e(sample)==1 using "Estimations/Results/Results 10062022/Descriptive_Statistics.docx", replace stats(N mean(%9.3f) sd min(%9.0g) median(%9.0g) max(%9.0g)) title("Table: Summary statistics benchmark") 
estpost sum stay returnHIC returnLMIC moveonwardsHIC  moveonwardsLMIC age age1835 $demographics lskill $humancaptial NoReligion $network $economic $wellbeing $gdpgrowth $macrovars if e(sample)==1 
esttab using "Estimations/Results/Results 14102022/Descriptive_Statistics2.tex", cells("count(fmt(0)) mean(fmt(3)) sd(fmt(3)) min(fmt(0)) max(fmt(0))") nomtitle nonumber replace label
* Descriptive by dependent var choice 
est restore Tdesc2  
sum2docx stay stayHIC stayLMIC returnHIC returnLMIC moveonwardsHIC  moveonwardsLMIC age age1835 $demographics lskill $humancaptial NoReligion $network $economic $wellbeing $gdpgrowth $macrovars if e(sample)==1 using "Estimations/Results/Results 10062022/Descriptive_Statistics_complete.docx", replace stats(N mean(%9.3f) sd min(%9.0g) median(%9.0g) max(%9.0g)) title("Table: Summary statistics Stay") 
* stay
est restore Tdesc2
sum2docx stay stayHIC stayLMIC returnHIC returnLMIC moveonwardsHIC  moveonwardsLMIC age age1835 $demographics lskill $humancaptial NoReligion $network $economic $wellbeing $gdpgrowth $macrovars if e(sample)==1 & mlogit_cat_dest==0 using "Estimations/Results/Results 14102022/Descriptive_Statistics_stay.docx", replace stats(N mean(%9.3f) sd min(%9.0g) median(%9.0g) max(%9.0g)) title("Table: Summary statistics Stay") 
sum2docx stay stayHIC stayLMIC returnHIC returnLMIC moveonwardsHIC  moveonwardsLMIC age age1835 $demographics lskill $humancaptial NoReligion $network $economic $wellbeing $gdpgrowth $macrovars if e(sample)==1 & stayHIC==1 using "Estimations/Results/Results 14102022/Descriptive_Statistics_stayHIC.docx", replace stats(N mean(%9.3f) sd min(%9.0g) median(%9.0g) max(%9.0g)) title("Table: Summary statistics Stay") 
sum2docx stay stayHIC stayLMIC returnHIC returnLMIC moveonwardsHIC  moveonwardsLMIC age age1835 $demographics lskill $humancaptial NoReligion $network $economic $wellbeing $gdpgrowth $macrovars if e(sample)==1 & stayLMIC==1 using "Estimations/Results/Results 14102022/Descriptive_Statistics_stayLMIC.docx", replace stats(N mean(%9.3f) sd min(%9.0g) median(%9.0g) max(%9.0g)) title("Table: Summary statistics Stay") 
* return 
est restore Tdesc2
sum2docx stay stayHIC stayLMIC returnHIC returnLMIC moveonwardsHIC  moveonwardsLMIC age age1835 $demographics lskill $humancaptial NoReligion $network $economic $wellbeing $gdpgrowth $macrovars if e(sample)==1 & mlogit_cat_dest==1 using "Estimations/Results/Results 14102022/Descriptive_Statistics_returnHIC.docx", replace stats(N mean(%9.3f) sd min(%9.0g) median(%9.0g) max(%9.0g)) title("Table: Summary statistics Return") 
est restore Tdesc2
sum2docx stay stayHIC stayLMIC returnHIC returnLMIC moveonwardsHIC  moveonwardsLMIC age age1835 $demographics lskill $humancaptial NoReligion $network $economic $wellbeing $gdpgrowth $macrovars if e(sample)==1 & mlogit_cat_dest==2 using "Estimations/Results/Results 14102022/Descriptive_Statistics_returnLMIC.docx", replace stats(N mean(%9.3f) sd min(%9.0g) median(%9.0g) max(%9.0g)) title("Table: Summary statistics Return") 
* move to another 
est restore Tdesc2
sum2docx stay stayHIC stayLMIC returnHIC returnLMIC moveonwardsHIC  moveonwardsLMIC age age1835 $demographics lskill $humancaptial NoReligion $network $economic $wellbeing $gdpgrowth $macrovars if e(sample)==1 & mlogit_cat_dest==3 using "Estimations/Results/Results 14102022/Descriptive_Statistics_movetoanotherHIC.docx", replace stats(N mean(%9.3f) sd min(%9.0g) median(%9.0g) max(%9.0g)) title("Table: Summary statistics Move to another") 
est restore Tdesc2
sum2docx stay stayHIC stayLMIC returnHIC returnLMIC moveonwardsHIC  moveonwardsLMIC age age1835 $demographics lskill $humancaptial NoReligion $network $economic $wellbeing $gdpgrowth $macrovars if e(sample)==1 & mlogit_cat_dest==4 using "Estimations/Results/Results 14102022/Descriptive_Statistics_movetoanotherLMIC.docx", replace stats(N mean(%9.3f) sd min(%9.0g) median(%9.0g) max(%9.0g)) title("Table: Summary statistics Move to another") 

** Table B3: Robustness– Sample Modifications 
*** Table B3a: Estimation results after dropping countries with few observations  --> Incidental parameter robustness
preserve
sort cntrycurrent
by cntrycurrent: gen ncntrycurrent=_N
drop if ncntrycurrent<16 // drop 114 observations //  https://www.jstor.org/stable/25791657?seq=1
mlogit migration $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork // 1,106 jews in total, 1,072 of them in Israel
est store TB3a_a
esttab TB3a_a using "Estimations/Results/Results 14102022/Table B3_drop_few_obs.xls", label title("Table B4: Estimation results after dropping countries with few observations") mtitles("Demographics, human and spiritual capital" "Networks" "Individual Economic Indicators" "Community Wellbeing" "Macroeconomics, Environment, Polity") ///
eform unstack nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")
esttab TB3a_a using "Estimations/Results/Results 14102022/Table B3_drop_few_obs.tex", unstack noomitted label title("Table B4: Relative risk ratios on aspirations to stay versus go abroad") mtitles("Demographics, human and spiritual capital" "Networks" "Individual Economic Indicators" "Community Wellbeing" "Macroeconomics, Environment, Polity") ///
eform nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")
tab cntrycurrent if e(sample)==1
restore 
*** Table B3b: Estimation results after dropping the top10 transit countries 
*(https://www.un.org/sites/un2.un.org/files/wmr_2020.pdf p56)
preserve
drop if cntrycurrent=="Germany" | dest=="Germany"
drop if cntrycurrent=="Niger" | dest=="Niger"
drop if cntrycurrent=="Greece" | dest=="Greece"
drop if cntrycurrent=="Austria" | dest=="Austria"
drop if cntrycurrent=="Djibouti" | dest=="Djibouti"
drop if cntrycurrent=="Belgium" | dest=="Belgium"
drop if cntrycurrent=="Netherlands" | dest=="Netherlands"
drop if cntrycurrent=="Morocco" | dest=="Morocco"
drop if cntrycurrent=="Turkey" | dest=="Turkey"
drop if cntrycurrent=="Italy" | dest=="Italy"
mlogit migration $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork // 1,106 jews in total, 1,072 of them in Israel
est store TB3b_a
esttab TB3b_a using "Estimations/Results/Results 14102022/Table B3_drop_transit.xls", label title("Table B4: Estimation results after dropping transit countries from residence and tier") mtitles("Demographics, human and spiritual capital" "Networks" "Individual Economic Indicators" "Community Wellbeing" "Macroeconomics, Environment, Polity") ///
eform unstack nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")
esttab TB3b_a using "Estimations/Results/Results 14102022/Table B3_drop_transit.tex", unstack noomitted label title("Table B4: Relative risk ratios on aspirations to stay versus go abroad") mtitles("Demographics, human and spiritual capital" "Networks" "Individual Economic Indicators" "Community Wellbeing" "Macroeconomics, Environment, Polity") ///
eform nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")
restore 
** Table B4: Robustness – Alternative Estimation Techniques 
*** Table B4a: Separate Logits with Country Birth FE 
logit return $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars  i.cb i.cc i.y, robust cluster(cc) diff tech(nr dfp) 
est store TB4a_a
logit movetoanother $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars  i.cc i.y, robust cluster(cc) diff tech(nr dfp)
est store TB4a_b
esttab TB4a_a TB4a_b using "Estimations/Results/Results 14102022/Table B4_separatelogits.xls", label title("Table A2: Relative risk ratios on aspirations to out-migrate versus stay") mtitles("Demographics, human and spiritual capital" "Networks" "Individual Economic Indicators" "Community Wellbeing" "Macroeconomics, Environment, Polity") ///
eform unstack nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cb *.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")
esttab TB4a_a TB4a_b using "Estimations/Results/Results 14102022/Table B4_separatelogits.tex", unstack noomitted label title("Table B4: Relative risk ratios on aspirations to stay versus go abroad") mtitles("Demographics, human and spiritual capital" "Networks" "Individual Economic Indicators" "Community Wellbeing" "Macroeconomics, Environment, Polity") ///
eform nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.cb *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")


*** Table B3: Heckman Probit results 
gen go_abroad=. 
replace go_abroad=1 if stay==0  // 33,235
replace go_abroad=0 if stay==1  // 9,822
global indivcntrls "age3550 age5065 age6575 male Cohabitation HHsize mskill hskill movelast5years INDEX_PH Christianity Islam OtherReligionsAndJudaism mabr empl BasicWealth  feelingsHHinc_comfortably  satisPP INDEX_DI INDEX_CB "
heckprob binomial $indivcntrls $gdpgrowth $macrovars i.cc i.y , select(go_abroad = $indivcntrls $gdpgrowth $macrovars closesocialnetwork1 i.cc i.y) difficult robust cluster(cc) 
est store TB3a
esttab TB3a using "Estimations/Results/Results final/Table_Heckman.xls", label title("Table B4: Heckman") mtitles("Step 1" "Step 2") ///
eform nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")
esttab TB3a using "Estimations/Results/Results final/Table_Heckman.tex", noomitted label title("Table Heckman: Relative risk ratios to aspire to return or move onwards versus stay") mtitles("Demographics, human and spiritual capital" "Networks" "Individual Economic Indicators" "Community Wellbeing" "Macroeconomics, Environment, Polity") ///
eform nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")
*Wald test of indep. eqns. (rho = 0): chi2(1) =     0.51   Prob > chi2 = 0.4745 
*** Validity of exclusion restriction
probit go_abroad closesocialnetwork1 $indivcntrls $gdpgrowth $macrovars i.cc i.y, robust cluster(cc) 
est store TA1_a
probit binomial closesocialnetwork1 $indivcntrls $gdpgrowth $macrovars i.cc i.y, robust cluster(cc)
est store TA1_b
esttab TA1_a TA1_b using "Estimations/Results/Results final/ExlusionRestriction.tex", label title("Validity of exclusion restriction \label{TableA5}") mtitles("Aspirations" "Preparations") ///
eform nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers b(3) t(2) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")
esttab TA1_a TA1_b using "Estimations/Results/Results final/ExlusionRestriction.xls", label title("Validity of exclusion restriction \label{TableA5}") mtitles("Aspirations" "Preparations") ///
eform nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers b(3) t(2) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")
* logit instead of probit 
logit go_abroad $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.y, robust cluster(cc) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork
est store TB3_5
esttab TB3_5  using "Estimations/Results/Results final/Table B3_logit.xls", label title("Table B3 (5): Relative risk ratios on aspirations to out-migrate versus stay") mtitles("Demographics, human and spiritual capital" "Networks" "Individual Economic Indicators" "Community Wellbeing" "Macroeconomics, Environment, Polity") ///
eform nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")

probit go_abroad $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.y, robust cluster(cc) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork


***----------------------
*** Tables not in paper   
***----------------------
* Table B6: alternative FE structure: i.ccy 
mlogit migration $demographics $humancaptial $network $economic $wellbeing i.ccy, rrr robust cluster(cc) base(0) diff tech(nr dfp) //
est store TB6_a
esttab TB6_a  using "Estimations/Results/Results 10062022/Table B6_i.ccy.xls", label title("Table 2: Relative risk ratios to aspire to return or move onwards versus stay") mtitles() ///
eform unstack nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.ccy) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")
esttab TB6_a  using "Estimations/Results/Results 10062022/Table B6_i.ccy.tex", unstack noomitted label title("Table B4: Relative risk ratios on aspirations to stay versus go abroad") mtitles("Demographics, human and spiritual capital" "Networks" "Individual Economic Indicators" "Community Wellbeing" "Macroeconomics, Environment, Polity") ///
eform nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.ccy) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")

* Table B2: Logit on aspirations to return versus migrating onwards  (binomial=1 if return==1 & binomial=0 if movetoanother==1) 
logit go_abroad $demographics $humancaptial i.cc i.y, robust cluster(cc) diff tech(nr dfp)
est store TB2_a 
logit go_abroad $demographics $humancaptial $network i.cc i.y, robust cluster(cc) diff tech(nr dfp)
est store TB2_b
logit go_abroad $demographics $humancaptial $network $economic i.cc i.y, robust cluster(cc) diff tech(nr dfp) 
est store TB2_c
logit go_abroad $demographics $humancaptial $network $economic $wellbeing i.cc i.y, robust cluster(cc) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork
est store TB2_d
logit go_abroad $demographics $humancaptial $network $economic $wellbeing GDPgrowth_cntrycurrent disaster_freqC12_cc PolInstab3y_cntrycurrent i.cc i.y, robust cluster(cc) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork
est store TB2_e
esttab TB2_a TB2_b TB2_c TB2_d TB2_e using "Estimations/Results/Results 27052022/Table B2_logit1.xls", label title("Table A2: Relative risk ratios on aspirations to out-migrate versus stay") mtitles("Demographics, human and spiritual capital" "Networks" "Individual Economic Indicators" "Community Wellbeing" "Macroeconomics, Environment, Polity") ///
eform nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")

******* Begin: Alternatives ** 

* Table 2: Benchmark  (cc, y FE's) + cb FE's 
mlogit mlogit_cat1 $demographics $humancaptial $network $economic $wellbeing i.cc i.cb i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork // 1,106 jews in total, 1,072 of them in Israel
est store T2_a
mlogit mlogit_cat1 $demographics $humancaptial $network $economic $wellbeing $gdpgrowth $macrovars i.cc i.cb i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork // 1,106 jews in total, 1,072 of them in Israel
est store T2_b
esttab T2_a T2_b  using "Estimations/Results/Results 24052022/Table 2_benchmark_cb.xls", label title("Table 2: Relative risk ratios to aspire to return or move onwards versus stay") mtitles() ///
eform unstack nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.cb *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")
** Warning:  variance matrix is nonsymmetric or highly singular 

* with self-employed 
mlogit mlogit_cat1 $demographics $humancaptial $network selfempl employee BasicWealth  feelingsHHinc_comfortably  satisPP $wellbeing i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork // 1,106 jews in total, 1,072 of them in Israel
est store T2_aab
mlogit mlogit_cat1 $demographics $humancaptial $network selfempl employee BasicWealth  feelingsHHinc_comfortably  satisPP $wellbeing $gdpgrowth $macrovars i.cc i.y, rrr robust cluster(cc) base(0) diff tech(nr dfp) // Lose year=2009 when including closesocialnetwork // 1,106 jews in total, 1,072 of them in Israel
est store T2_aac
esttab T2_aab T2_aac using "Estimations/Results/Results 24052022/Table 2_benchmark_self-employed.xls", label title("Table 2: Relative risk ratios to aspire to return or move onwards versus stay") mtitles() ///
eform unstack nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.cc *.y) nonumbers t(2) b(3) nogaps scalars("ll Log likelihood") obslast addnotes("Standard errors are robust to within host country correlation.")

******* End: Alternatives ** 

