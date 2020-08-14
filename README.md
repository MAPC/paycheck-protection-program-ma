# paycheck-protection-program-ma
 Cleaning and visualizing SBA-PPP data for Massachusetts

 **Note:** To successfully run the R script, you'll need a `.env` file in the repo's root directory with appropriate database credentials.
 
**Data Source** is from SBA (Last update date when download was July 7th 2020): https://home.treasury.gov/policy-issues/cares-act/assistance-for-small-businesses/sba-paycheck-protection-program-loan-level-data. The data which is self-reported from borrowers and was released differently for loans over 150k as it was for loans under 150k. Loans over 150K included business names and addresses and a range of money requested.  While loans under the threshold did not include names or address but did include loan amounts. Not all data fields were required and not all borrowers provided all information. This means important information for programmatic evaluating like demographic information of business owners was not fully captured.  For example, only 10% of Massachusetts borrowers in this data indicated race/ethnicity. The SBA over and under 150K were combined in Excel into one file. 

**Cleaning**
That combined file was then cleaned using Open Refine, project files found [here](https://github.com/MAPC/paycheck-protection-program-ma/blob/master/PPP-data-up-to-and-over-150K-MA-city-clean.tar.gz). The <Neighborhood / Area> field is the original data's <City> field. We went through the data standardizing spellings of town names and zip code data. Example: from "WOCESTER" to "WORCESTER". Listings of neighborhood in the city fields like Allston or Dorchester where updated in <City> to be the correct a municipality like Boston. This open refine edits can be seen [here](https://github.com/MAPC/paycheck-protection-program-ma/blob/master/SBA%20CITY%20Clean.json) and are available for future use on other projects:  The ouput from that work created a [cleaned file](https://github.com/MAPC/paycheck-protection-program-ma/blob/master/PPP-data-up-to-and-over-150K-MA-city-clean.csv)

**Joins**
 For our analysis purposes we were interested in the percentage of establishments by industry sector in each municipality that applied for a PPP loan.  To do this analysis we combined the [2 Digit Sector: Employment data](https://datacommon.mapc.org/browser/datasets/387) from ES-202 along with the [municipal data keys](https://datacommon.mapc.org/browser/datasets/415) to provide supplementary regional info. That work was done in R and can be found [here](https://github.com/MAPC/paycheck-protection-program-ma/blob/master/PPP-data-join-script.R). The output from that work can be found in [MA-PPP-R-result.csv](https://github.com/MAPC/paycheck-protection-program-ma/blob/master/MA-PPP-R-Result.csv)

 Total establishment data from [Annual Average Employment and Wages All Published Industries by town all ownership (ES-202 2018, saved here as "Source Data/2018towntotalEMPwagesbytownallown.xlsx")](https://lmi.dua.eol.mass.gov/lmi/MunicipalEmploymentData/ExcelFile/2018townindEMPwagesbytownallown.xlsx) was joined in with Excel using a `VLOOKUP` on capitalized municaplity names. We also performed the following final data cleaning steps using Excel filters:
- Change `City` values "Manchester-by-the-Sea" to "Manchester" to unify data and eventually match into the spatial data
- Remove rows with non-MA `STATE` values
- Remove rows where `City` equals "Keene" (in New Hampshire) or "Pawtucket" (in Rhode Island)
- Remove rows where the value for `City` was a ZIP code (one was updated from "02339" to "Hanover," as that ZIP code does not cross any other municipal lines. 4 rows were removed in total)
- Remove rows where `City` equals "Devens" (28 rows; unclear whether to attribute these rows to Ayer or Shirley on the municipal map)
- Remove many unused columns for easier reading into the map

Unique numeric IDs were assigned to each row to keep track of which rows were removed.

All Excel work took place in the workbook `PPP-202-join.xlsx`. It has four sheets:
1. `Raw data`: A copy of the data from `MA-PPP-R-Result.csv` with unique IDs added
2. `MA-PPP-choropleth`: The filtered and cleaned data that can be found in `MA-PPP-choropleth.csv` (the final result that is read into the map)
3. `ES-202`: A copy of the ES-202 data as found in `2018towntotalEMPwagesbytownallown.xlsx`
4. `Counts of NAICS codes`: Breakdowns from `MA-PPP-choropleth` for the percentage of establishments covered by 2-digit NAICS code


 As mentioned about, the final data product read into the map is located at [MA-PPP-choropleth.csv ](https://github.com/MAPC/paycheck-protection-program-ma/blob/master/MA-PPP-choropleth.csv)
