wget https://www2.census.gov/geo/tiger/TIGER_DP/2015ACS/ACS_2015_5YR_BG_24.gdb.zip
ogr2ogr -f "GeoJSON" ACS.geojson ACS_2015_5YR_BG_24.gdb.zip -sql "$(cat ./subset.sql)"