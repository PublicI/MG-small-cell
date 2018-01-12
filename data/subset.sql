SELECT aas.b01001e1              AS totalpopulation, 
       aas.b01001m1              AS totalpopulationerr, 
       fs.b22010e1               AS foodstamps, 
       fs.b22010m1               AS foodstampserr, 
       inc.b19013e1              AS medianincome, 
       inc.b19013m1              AS medianincomeerr, 
       pov.b17010e1              AS povertystatus, 
       pov.b17010m1              AS povertystatuserr, 
       aas.b01001e1 / meta.aland AS popDensity, 
       meta.*, 
       brd.* 
FROM   acs_2015_5yr_bg_24_maryland meta 
       JOIN x01_age_and_sex aas 
         ON meta.geoid_data = aas.geoid 
       JOIN x22_food_stamps fs 
         ON meta.geoid_data = fs.geoid 
       JOIN x19_income inc 
         ON meta.geoid_data = inc.geoid 
       JOIN x17_poverty pov 
         ON meta.geoid_data = pov.geoid 
       JOIN (SELECT Substr(blockcode, 0, 13)    AS blockgroup, 
                    COUNT(DISTINCT frn)         AS numProviders, 
                    AVG(CAST(maxadup AS FLOAT)) AS avgDown, 
                    AVG(CAST(maxadup AS FLOAT)) AS avgUp 
             FROM   broadband 
             WHERE  consumer = 1 AND CAST(maxaddown AS FLOAT) >= 25 AND CAST(maxadup AS FLOAT) >= 3
             GROUP  BY blockgroup) brd 
         ON meta.geoid = brd.blockgroup 
WHERE  meta.countyfp = "031"