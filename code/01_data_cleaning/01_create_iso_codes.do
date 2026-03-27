********************************************************************************
* 01 - Create ISO3 Codes
* Bekaert, Constant, Foubert & Ruyssen (2024) - JEBO
********************************************************************************
*
* Purpose: Extracts ISO3 codes from GADM shapefile.
*
* Input:   GADM shapefile
*
* Output:  iso3.dta
*
* Note: These scripts were developed as part of a collaborative research workflow
* among co-authors over several years. Internal annotations, commented-out file
* paths, and exploratory code blocks reflect this iterative process and have been
* preserved for transparency and reproducibility.
********************************************************************************

shp2dta using "C:\Users\kifouber\Dropbox\Return Migration\Maps\Do & files\gadm36_0.shp", data(iso3) coordinates(worldcoorlvl0) genid(id) replace
