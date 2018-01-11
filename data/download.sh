wget https://www2.census.gov/geo/tiger/TIGER_DP/2015ACS/ACS_2015_5YR_BG_24.gdb.zip -O ACS_2015_5YR_BG_24.gdb.zip
rm ACS_5yr.sqlite
ogr2ogr --debug ON -dsco SPATIALITE=YES -f "SQLite" ACS_5yr.sqlite ACS_2015_5YR_BG_24.gdb.zip ACS_2015_5YR_BG_24_MARYLAND X01_AGE_AND_SEX X22_FOOD_STAMPS X19_INCOME X17_POVERTY
ogr2ogr -update -append -f SQLite ACS_5yr.sqlite -nln "broadband" montgomery_county_speeds.csv
rm ACS.geojson
ogr2ogr --debug ON -f "GeoJSON" ACS.geojson ACS_5yr.sqlite -sql "$(cat ./subset.sql)"