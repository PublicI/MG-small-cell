SELECT
    aas.B01001e1 as totalPopulation,
    aas.B01001m1 as totalPopulationerr,
    fs.B22010e1 as foodStamps,
    fs.B22010m1 as foodStampserr,
    inc.B19013e1 as medianIncome,
    inc.B19013m1 as medianIncomeerr,
    pov.B17010e1 as povertyStatus,
    pov.B17010m1 as povertyStatuserr,
    meta.*
from ACS_2015_5YR_BG_24_MARYLAND meta
JOIN X01_AGE_AND_SEX aas
    ON meta.GEOID=aas.GEOID
JOIN X22_FOOD_STAMPS fs 
    ON meta.GEOID=fs.GEOID 
JOIN X19_INCOME inc 
    ON meta.GEOID=inc.GEOID 
JOIN X17_POVERTY pov 
    ON meta.GEOID=pov.GEOID