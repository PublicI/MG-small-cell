select
    aas.b01001e1 as totalpopulation,
    aas.b01001m1 as totalpopulationerr,
    fs.b22010e1 as foodstamps,
    fs.b22010m1 as foodstampserr,
    inc.b19013e1 as medianincome,
    inc.b19013m1 as medianincomeerr,
    pov.b17010e1 as povertystatus,
    pov.b17010m1 as povertystatuserr,
    aas.b01001e1/meta.aland as popDensity,
    meta.*
from acs_2015_5yr_bg_24_maryland meta
join x01_age_and_sex aas
    on meta.geoid_data=aas.geoid
join x22_food_stamps fs
    on meta.geoid_data=fs.geoid
join x19_income inc
    on meta.geoid_data=inc.geoid
join x17_poverty pov
    on meta.geoid_data=pov.geoid
where meta.countyfp = "031"