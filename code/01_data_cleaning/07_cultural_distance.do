********************************************************************************
* 07 - Cultural Distance
* Bekaert, Constant, Foubert & Ruyssen (2024) - JEBO
********************************************************************************
*
* Purpose: Constructs bilateral cultural distance measures between host-home country pairs.
*
* Input:   Cultural distance raw data
*
* Output:  Cultural distance.dta
*
* Note: These scripts were developed as part of a collaborative research workflow
* among co-authors over several years. Internal annotations, commented-out file
* paths, and exploratory code blocks reflect this iterative process and have been
* preserved for transparency and reproducibility.
********************************************************************************

* Note that I replaced "Great Britain" by "United Kingdom". In any case, the cultural distance in the United Kingdom is likely to be very low
* Do not forget to replace values by . in final dataset for years 2015 2016 since we have info on 2005-2014

clear all
import delimited "C:\Users\kifouber\Dropbox\Return Migration\Data\Cultural distance\Old\dta\download_matrix.csv", varnames(1)
gen countryA=""
gen n=_n
replace countryA="Algeria" if n==1
replace countryA="Andorra" if n==2
replace countryA="Argentina" if n==3
replace countryA="Armenia" if n==4
replace countryA="Australia" if n==5
replace countryA="Azerbaijan" if n==6
replace countryA="Bahrain" if n==7
replace countryA="Belarus" if n==8
replace countryA="Brazil" if n==9
replace countryA="Bulgaria" if n==10
replace countryA="Burkina Faso" if n==11
replace countryA="Canada" if n==12
replace countryA="Chile" if n==13
replace countryA="China" if n==14
replace countryA="Colombia" if n==15
replace countryA="Cyprus" if n==16
replace countryA="Ecuador" if n==17
replace countryA="Egypt" if n==18
replace countryA="Estonia" if n==19
replace countryA="Ethiopia" if n==20
replace countryA="Finland" if n==21
replace countryA="France" if n==22
replace countryA="Georgia" if n==23
replace countryA="Germany" if n==24
replace countryA="Ghana" if n==25
replace countryA="United Kingdom" if n==26
replace countryA="Guatemala" if n==27
replace countryA="Hong Kong" if n==28
replace countryA="Hungary" if n==29
replace countryA="India" if n==30
replace countryA="Indonesia" if n==31
replace countryA="Iran" if n==32
replace countryA="Iraq" if n==33
replace countryA="Italy" if n==34
replace countryA="Japan" if n==35
replace countryA="Jordan" if n==36
replace countryA="Kazakhstan" if n==37
replace countryA="Kuwait" if n==38
replace countryA="Kyrgyzstan" if n==39
replace countryA="Lebanon" if n==40
replace countryA="Libya" if n==41
replace countryA="Malaysia" if n==42
replace countryA="Mali" if n==43
replace countryA="Mexico" if n==44
replace countryA="Moldova" if n==45
replace countryA="Morocco" if n==46
replace countryA="Netherlands" if n==47
replace countryA="New Zealand" if n==48
replace countryA="Nigeria" if n==49
replace countryA="Norway" if n==50
replace countryA="Pakistan" if n==51
replace countryA="Palestina" if n==52
replace countryA="Peru" if n==53
replace countryA="Philippines" if n==54
replace countryA="Poland" if n==55
replace countryA="Qatar" if n==56
replace countryA="Romania" if n==57
replace countryA="Russia" if n==58
replace countryA="Rwanda" if n==59
replace countryA="Serbia and Montenegro" if n==60
replace countryA="Singapore" if n==61
replace countryA="Slovenia" if n==62
replace countryA="South Africa" if n==63
replace countryA="South Korea" if n==64
replace countryA="Spain" if n==65
replace countryA="Sweden" if n==66
replace countryA="Switzerland" if n==67
replace countryA="Taiwan" if n==68
replace countryA="Thailand" if n==69
replace countryA="Trinidad and Tobago" if n==70
replace countryA="Tunisia" if n==71
replace countryA="Turkey" if n==72
replace countryA="Ukraine" if n==73
replace countryA="United States" if n==74
replace countryA="Uruguay" if n==75
replace countryA="Uzbekistan" if n==76
replace countryA="Vietnam" if n==77
replace countryA="Yemen" if n==78
replace countryA="Zambia" if n==79
replace countryA="Zimbabwe" if n==80

replace algeria20052014="." if algeria20052014=="NA"
replace andorra20052014="." if andorra20052014=="NA"
replace argentina20052014="." if argentina20052014=="NA"
replace armenia20052014="." if armenia20052014=="NA"
replace australia20052014="." if australia20052014=="NA"
replace azerbaijan20052014="." if azerbaijan20052014=="NA"
replace bahrain20052014="." if bahrain20052014=="NA"
replace belarus20052014="." if belarus20052014=="NA"
replace brazil20052014="." if brazil20052014=="NA"
replace bulgaria20052014="." if bulgaria20052014=="NA"
replace burkinafaso20052014="." if burkinafaso20052014=="NA"
replace canada20052014="." if canada20052014=="NA"
replace chile20052014="." if chile20052014=="NA"
replace china20052014="." if china20052014=="NA"
replace colombia20052014="." if colombia20052014=="NA"
replace cyprus20052014="." if cyprus20052014=="NA"
replace ecuador20052014="." if ecuador20052014=="NA"
replace egypt20052014="." if egypt20052014=="NA"
replace estonia20052014="." if estonia20052014=="NA"
replace ethiopia20052014="." if ethiopia20052014=="NA"
replace finland20052014="." if finland20052014=="NA"
replace france20052014="." if france20052014=="NA"
replace georgia20052014="." if georgia20052014=="NA"
replace germany20052014="." if germany20052014=="NA"
replace ghana20052014="." if ghana20052014=="NA"
replace greatbritain20052014="." if greatbritain20052014=="NA"
replace guatemala20052014="." if guatemala20052014=="NA"
replace hongkong20052014="." if hongkong20052014=="NA"
replace hungary20052014="." if hungary20052014=="NA"
replace india20052014="." if india20052014=="NA"
replace indonesia20052014="." if indonesia20052014=="NA"
replace iran20052014="." if iran20052014=="NA"
replace iraq20052014="." if iraq20052014=="NA"
replace italy20052014="." if italy20052014=="NA"
replace japan20052014="." if japan20052014=="NA"
replace jordan20052014="." if jordan20052014=="NA"
replace kazakhstan20052014="." if kazakhstan20052014=="NA"
replace kuwait20052014="." if kuwait20052014=="NA"
replace kyrgyzstan20052014="." if kyrgyzstan20052014=="NA"
replace lebanon20052014="." if lebanon20052014=="NA"
replace libya20052014="." if libya20052014=="NA"
replace malaysia20052014="." if malaysia20052014=="NA"
replace mali20052014="." if mali20052014=="NA"
replace mexico20052014="." if mexico20052014=="NA"
replace moldova20052014="." if moldova20052014=="NA"
replace morocco20052014="." if morocco20052014=="NA"
replace netherlands20052014="." if netherlands20052014=="NA"
replace newzealand20052014="." if newzealand20052014=="NA"
replace nigeria20052014="." if nigeria20052014=="NA"
replace norway20052014="." if norway20052014=="NA"
replace pakistan20052014="." if pakistan20052014=="NA"
replace palestine20052014="." if palestine20052014=="NA"
replace peru20052014="." if peru20052014=="NA"
replace philippines20052014="." if philippines20052014=="NA"
replace poland20052014="." if poland20052014=="NA"
replace qatar20052014="." if qatar20052014=="NA"
replace romania20052014="." if romania20052014=="NA"
replace russia20052014="." if russia20052014=="NA"
replace rwanda20052014="." if rwanda20052014=="NA"
replace serbiaandmontenegro20052014="." if serbiaandmontenegro20052014=="NA"
replace singapore20052014="." if singapore20052014=="NA"
replace slovenia20052014="." if slovenia20052014=="NA"
replace southafrica20052014="." if southafrica20052014=="NA"
replace southkorea20052014="." if southkorea20052014=="NA"
replace spain20052014="." if spain20052014=="NA"
replace sweden20052014="." if sweden20052014=="NA"
replace switzerland20052014="." if switzerland20052014=="NA"
replace taiwan20052014="." if taiwan20052014=="NA"
replace thailand20052014="." if thailand20052014=="NA"
replace trinidadandtobago20052014="." if trinidadandtobago20052014=="NA"
replace tunisia20052014="." if tunisia20052014=="NA"
replace turkey20052014="." if turkey20052014=="NA"
replace ukraine20052014="." if ukraine20052014=="NA"
replace unitedstates20052014="." if unitedstates20052014=="NA"
replace uruguay20052014="." if uruguay20052014=="NA"
replace uzbekistan20052014="." if uzbekistan20052014=="NA"
replace vietnam20052014="." if vietnam20052014=="NA"
replace yemen20052014="." if yemen20052014=="NA"
replace zambia20052014="." if zambia20052014=="NA"
replace zimbabwe20052014="." if zimbabwe20052014=="NA"

destring *, replace
rename * kkk_*
drop kkk_n
rename kkk_countryA countryA
reshape long kkk_, i(countryA) j(countryB) string
drop if kkk_==.
rename kkk_ culturaldist

replace countryB="Algeria" if countryB=="algeria20052014"
replace countryB="Andorra" if countryB=="andorra20052014"
replace countryB="Argentina" if countryB=="argentina20052014"
replace countryB="Armenia" if countryB=="armenia20052014"
replace countryB="Australia" if countryB=="australia20052014"
replace countryB="Azerbaijan" if countryB=="azerbaijan20052014"
replace countryB="Bahrain" if countryB=="bahrain20052014"
replace countryB="Belarus" if countryB=="belarus20052014"
replace countryB="Brazil" if countryB=="brazil20052014"
replace countryB="Bulgaria" if countryB=="bulgaria20052014"
replace countryB="Burkina Faso" if countryB=="burkinafaso20052014"
replace countryB="Canada" if countryB=="canada20052014"
replace countryB="Chile" if countryB=="chile20052014"
replace countryB="China" if countryB=="china20052014"
replace countryB="Colombia" if countryB=="colombia20052014"
replace countryB="Cyprus" if countryB=="cyprus20052014"
replace countryB="Ecuador" if countryB=="ecuador20052014"
replace countryB="Egypt" if countryB=="egypt20052014"
replace countryB="Estonia" if countryB=="estonia20052014"
replace countryB="Ethiopia" if countryB=="ethiopia20052014"
replace countryB="Finland" if countryB=="finland20052014"
replace countryB="France" if countryB=="france20052014"
replace countryB="Georgia" if countryB=="georgia20052014"
replace countryB="Germany" if countryB=="germany20052014"
replace countryB="Ghana" if countryB=="ghana20052014"
replace countryB="United Kingdom" if countryB=="greatbritain20052014"
replace countryB="Guatemala" if countryB=="guatemala20052014"
replace countryB="Hong Kong" if countryB=="hongkong20052014"
replace countryB="Hungary" if countryB=="hungary20052014"
replace countryB="India" if countryB=="india20052014"
replace countryB="Indonesia" if countryB=="indonesia20052014"
replace countryB="Iran" if countryB=="iran20052014"
replace countryB="Iraq" if countryB=="iraq20052014"
replace countryB="Italy" if countryB=="italy20052014"
replace countryB="Japan" if countryB=="japan20052014"
replace countryB="Jordan" if countryB=="jordan20052014"
replace countryB="Kazakhstan" if countryB=="kazakhstan20052014"
replace countryB="Kuwait" if countryB=="kuwait20052014"
replace countryB="Kyrgyzstan" if countryB=="kyrgyzstan20052014"
replace countryB="Lebanon" if countryB=="lebanon20052014"
replace countryB="Libya" if countryB=="libya20052014"
replace countryB="Malaysia" if countryB=="malaysia20052014"
replace countryB="Mali" if countryB=="mali20052014"
replace countryB="Mexico" if countryB=="mexico20052014"
replace countryB="Moldova" if countryB=="moldova20052014"
replace countryB="Morocco" if countryB=="morocco20052014"
replace countryB="Netherlands" if countryB=="netherlands20052014"
replace countryB="New Zealand" if countryB=="newzealand20052014"
replace countryB="Nigeria" if countryB=="nigeria20052014"
replace countryB="Norway" if countryB=="norway20052014"
replace countryB="Pakistan" if countryB=="pakistan20052014"
replace countryB="Palestina" if countryB=="palestine20052014"
replace countryB="Peru" if countryB=="peru20052014"
replace countryB="Philippines" if countryB=="philippines20052014"
replace countryB="Poland" if countryB=="poland20052014"
replace countryB="Qatar" if countryB=="qatar20052014"
replace countryB="Romania" if countryB=="romania20052014"
replace countryB="Russia" if countryB=="russia20052014"
replace countryB="Rwanda" if countryB=="rwanda20052014"
replace countryB="Serbia and Montenegro" if countryB=="serbiaandmontenegro20052014"
replace countryB="Singapore" if countryB=="singapore20052014"
replace countryB="Slovenia" if countryB=="slovenia20052014"
replace countryB="South Africa" if countryB=="southafrica20052014"
replace countryB="South Korea" if countryB=="southkorea20052014"
replace countryB="Spain" if countryB=="spain20052014"
replace countryB="Sweden" if countryB=="sweden20052014"
replace countryB="Switzerland" if countryB=="switzerland20052014"
replace countryB="Taiwan" if countryB=="taiwan20052014"
replace countryB="Thailand" if countryB=="thailand20052014"
replace countryB="Trinidad and Tobago" if countryB=="trinidadandtobago20052014"
replace countryB="Tunisia" if countryB=="tunisia20052014"
replace countryB="Turkey" if countryB=="turkey20052014"
replace countryB="Ukraine" if countryB=="ukraine20052014"
replace countryB="United States" if countryB=="unitedstates20052014"
replace countryB="Uruguay" if countryB=="uruguay20052014"
replace countryB="Uzbekistan" if countryB=="uzbekistan20052014"
replace countryB="Vietnam" if countryB=="vietnam20052014"
replace countryB="Yemen" if countryB=="yemen20052014"
replace countryB="Zambia" if countryB=="zambia20052014"
replace countryB="Zimbabwe" if countryB=="zimbabwe20052014"

* Add iso3 codes - country A

rename countryA origin
expand 2 if origin=="Serbia and Montenegro"
gen n=_n
replace origin="Montenegro" if origin=="Serbia and Montenegro" & n>=6321
drop n
replace origin="Serbia" if origin=="Serbia and Montenegro"
sort origin

merge m:1 origin using "C:\Users\kifouber\Dropbox\Return Migration\Data\iso3 codes\Clean\iso3clean.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           175
        from master                         0  (_merge==1)
        from using                        175  (_merge==2)

    matched                             6,399  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2
drop _merge
rename origin countryA
rename iso3o iso3A

* Add iso3 codes - country B

rename countryB origin
sort origin
expand 2 if origin=="Serbia and Montenegro"
gen n=_n
replace origin="Montenegro" if origin=="Serbia and Montenegro" & n>=6400
drop n
replace origin="Serbia" if origin=="Serbia and Montenegro"
sort origin

merge m:1 origin using "C:\Users\kifouber\Dropbox\Return Migration\Data\iso3 codes\Clean\iso3clean.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           175
        from master                         0  (_merge==1)
        from using                        175  (_merge==2)

    matched                             6,478  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2
drop _merge
rename origin countryB
rename iso3o iso3B
order countryA iso3A countryB iso3B

* Create bilateral database for countries of residence - birth

rename countryA cntrycurrent
rename iso3A iso3_cntrycurrent
rename countryB cntrybirth
rename iso3B iso3_cntrybirth
rename culturaldist culturaldist_current_birth

save "C:\Users\kifouber\Dropbox\Return Migration\Data\Cultural distance\Clean\dta\Cultural distance - Residence Birth.dta", replace

* Create bilateral database for countries of residence - destination

rename cntrybirth dest
rename iso3_cntrybirth iso3_dest
rename culturaldist_current_birth culturaldist_current_dest

save "C:\Users\kifouber\Dropbox\Return Migration\Data\Cultural distance\Clean\dta\Cultural distance - Residence Dest.dta", replace

* Create bilateral database for countries of birth - destination

rename cntrycurrent cntrybirth
rename iso3_cntrycurrent iso3_cntrybirth
rename culturaldist_current_dest culturaldist_birth_dest

save "C:\Users\kifouber\Dropbox\Return Migration\Data\Cultural distance\Clean\dta\Cultural distance - Birth Dest.dta", replace
