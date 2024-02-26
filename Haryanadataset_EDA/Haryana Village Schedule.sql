use eda;

CREATE TABLE `HRVillageSchedule` (
        state_name VARCHAR(7) NOT NULL,
        district_name VARCHAR(13) NOT NULL,
        block_tehsil_name VARCHAR(16) NOT NULL,
        village_name VARCHAR(24) NOT NULL,
        ref_village_type_name VARCHAR(10) NOT NULL,
        major_medium_scheme varchar(25),
        major_medium_scheme_name VARCHAR(33),
        geographical_area DECIMAL(38, 0) NOT NULL,
        cultivable_area DECIMAL(38, 0) NOT NULL,
        net_sown_area DECIMAL(38, 0) NOT NULL,
        gross_irrigated_area_kharif_season DECIMAL(38, 0) NOT NULL,
        gross_irrigated_area_rabi_season DECIMAL(38, 0) NOT NULL,
        gross_irrigated_area_perennial_season DECIMAL(38, 0) NOT NULL,
        gross_irrigated_area_other_season DECIMAL(38, 0) NOT NULL,
        gross_irrigated_area_total DECIMAL(38, 0) NOT NULL,
        net_irrigated_area DECIMAL(38, 0) NOT NULL,
        avg_ground_water_level_pre_monsoon DECIMAL(38, 0) NOT NULL,
        avg_ground_water_level_post_monsoon DECIMAL(38, 0) NOT NULL,
        ref_selection_wua_exists_name VARCHAR(9) NOT NULL
);

LOAD DATA INFILE  
'D:\HRVillageSchedule.csv'
into table HRVillageSchedule
FIELDS TERMINATED by ','
ENCLOSED by '"'
lines terminated by '\n'
IGNORE 1 ROWS;

select * from hrvillageschedule;

# thus we start our data exploration process

#I wonder what is the shape of our table, i.e, the number of columns and rows. Let’s see:

select count(*) as rownum from hrvillageschedule;
select count(*) as cols_num from information_schema.columns where table_name ="hrvillageschedule";
# thus there is 7038 rows and 19 columns

select district_name,block_tehsil_name,village_name,geographical_area from hrvillageschedule order by geographical_area desc;
# thus district_name Mewat,mahendtagarh,hisar have highest geographical area

select district_name,block_tehsil_name,village_name,cultivable_area  from hrvillageschedule order by cultivable_area desc;
# mahendragarh,hissar,fatehbad have highest cultivablearea

select district_name,block_tehsil_name,village_name,cultivable_area  from hrvillageschedule order by net_sown_area desc;
# mahendragarh(malra),hissar(bir hisar),mahendragargh(nimbira)

SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

SELECT 
  MAX(district_name) AS district_name, 
  MAX(block_tehsil_name) AS block_tehsil_name, 
  MAX(village_name) AS village_name,
  gross_irrigated_area_kharif_season
FROM hrvillageschedule
GROUP BY gross_irrigated_area_kharif_season
ORDER BY cultivable_area;

SELECT 
  MAX(district_name) AS district_name, 
  MAX(block_tehsil_name) AS block_tehsil_name, 
  MAX(village_name) AS village_name, 
  gross_irrigated_area_kharif_season,
  MAX(cultivable_area) AS max_cultivable_area
FROM hrvillageschedule
GROUP BY gross_irrigated_area_kharif_season
ORDER BY max_cultivable_area desc;

#Summary Statistics:
SELECT 
    MIN(cultivable_area) AS min_cultivable_area,
    MAX(cultivable_area) AS max_cultivable_area,
    AVG(cultivable_area) AS avg_cultivable_area,
    SUM(cultivable_area) AS total_cultivable_area
FROM HRVillageSchedule;

#Distribution of Village Types
SELECT 
    ref_village_type_name,
    COUNT(*) AS village_count
FROM HRVillageSchedule
GROUP BY ref_village_type_name;
#thus there is Non-Tribal village is 6702 and tribal village is 336

#Comparison of Irrigated Areas Across Seasons:
SELECT 
    SUM(gross_irrigated_area_kharif_season) AS total_kharif_irrigated_area,
    SUM(gross_irrigated_area_rabi_season) AS total_rabi_irrigated_area,
    SUM(gross_irrigated_area_perennial_season) AS total_perennial_irrigated_area,
    SUM(gross_irrigated_area_other_season) AS total_other_irrigated_area
FROM HRVillageSchedule;

#Average Groundwater Levels:
SELECT 
    AVG(avg_ground_water_level_pre_monsoon) AS avg_pre_monsoon_groundwater_level,
    AVG(avg_ground_water_level_post_monsoon) AS avg_post_monsoon_groundwater_level
FROM HRVillageSchedule;

#Major Medium Schemes Analysis:
SELECT 
    major_medium_scheme_name,
    COUNT(*) AS scheme_count
FROM HRVillageSchedule
WHERE major_medium_scheme IS NOT NULL
GROUP BY major_medium_scheme_name;

#1. Analysis of Cultivable vs Irrigated Areas
SELECT 
    district_name, 
    SUM(cultivable_area) AS total_cultivable_area, 
    SUM(net_irrigated_area) AS total_irrigated_area,
    (SUM(net_irrigated_area) / SUM(cultivable_area)) * 100 AS irrigation_efficiency_percentage
FROM HRVillageSchedule
GROUP BY district_name
ORDER BY irrigation_efficiency_percentage DESC;

#thus district Rohtak have high irrigation efficiency


#2.Groundwater Level Fluctuations
SELECT 
    district_name, 
    AVG(avg_ground_water_level_pre_monsoon) AS avg_pre_monsoon_groundwater, 
    AVG(avg_ground_water_level_post_monsoon) AS avg_post_monsoon_groundwater,
    AVG(avg_ground_water_level_post_monsoon) - AVG(avg_ground_water_level_pre_monsoon) AS avg_groundwater_change
FROM HRVillageSchedule
GROUP BY district_name
ORDER BY avg_groundwater_change ;
# thus Panipat is having huge change in groundwater

#3.Impact of Major Medium Schemes
SELECT 
    major_medium_scheme_name,
    COUNT(*) AS number_of_villages_under_scheme,
    SUM(gross_irrigated_area_total) AS total_irrigated_area_under_scheme
FROM HRVillageSchedule
WHERE major_medium_scheme IS NOT NULL
GROUP BY major_medium_scheme_name
ORDER BY total_irrigated_area_under_scheme DESC;
# thus on we get to know majority of village name is not in this scheme

#. Village Type and Agricultural Land Use
SELECT 
    ref_village_type_name, 
    AVG(geographical_area) AS avg_geographical_area, 
    AVG(cultivable_area) AS avg_cultivable_area, 
    AVG(net_sown_area) AS avg_net_sown_area
FROM HRVillageSchedule
GROUP BY ref_village_type_name;

#thus geographical area,culyivable area,net sown area is high in triball village
 #Seasonal Irrigation Analysis
 
SELECT 
    AVG(gross_irrigated_area_kharif_season) AS avg_kharif_irrigation, 
    AVG(gross_irrigated_area_rabi_season) AS avg_rabi_irrigation, 
    AVG(gross_irrigated_area_perennial_season) AS avg_perennial_irrigation,
    AVG(gross_irrigated_area_other_season) AS avg_other_season_irrigation
FROM HRVillageSchedule;
# thus we get to know that Kharif is hugley cultivated

#6. Analysis of Irrigated Area by Season and Village Type
SELECT 
    ref_village_type_name,
    AVG(gross_irrigated_area_kharif_season) AS avg_kharif_irrigation,
    AVG(gross_irrigated_area_rabi_season) AS avg_rabi_irrigation,
    AVG(gross_irrigated_area_perennial_season) AS avg_perennial_irrigation,
    AVG(gross_irrigated_area_other_season) AS avg_other_season_irrigation
FROM HRVillageSchedule
GROUP BY ref_village_type_name;
# thus season wise Tribal village cultivated more than non tribal

#7. District-Wise Water Use Association Presence and Irrigation Area

SELECT 
    district_name,
    ref_selection_wua_exists_name,
    AVG(net_irrigated_area) AS avg_net_irrigated_area
FROM HRVillageSchedule
GROUP BY district_name, ref_selection_wua_exists_name
ORDER BY district_name, avg_net_irrigated_area DESC;




#6. Analysis of Irrigated Area by Season and Village Type

SELECT 
    ref_village_type_name,
    AVG(gross_irrigated_area_kharif_season) AS avg_kharif_irrigation,
    AVG(gross_irrigated_area_rabi_season) AS avg_rabi_irrigation,
    AVG(gross_irrigated_area_perennial_season) AS avg_perennial_irrigation,
    AVG(gross_irrigated_area_other_season) AS avg_other_season_irrigation
FROM HRVillageSchedule
GROUP BY ref_village_type_name;

#7.Efficiency of Major Medium Schemes Across Village Types

SELECT 
    ref_village_type_name,
    major_medium_scheme_name,
    AVG(gross_irrigated_area_total) AS avg_irrigation_area_under_scheme
FROM HRVillageSchedule
WHERE major_medium_scheme IS NOT NULL
GROUP BY ref_village_type_name, major_medium_scheme_name
ORDER BY avg_irrigation_area_under_scheme DESC;
# thus Bhakhra Jal schai jojna scheme is most successfull on Tribal village and CHANDRAVAL MINOR KHJURI MINORb scheme is most suceeful in non-tribal



#8. Analysis of Geographical vs Cultivable Area
SELECT 
    block_tehsil_name,
    SUM(geographical_area) AS total_geographical_area,
    SUM(cultivable_area) AS total_cultivable_area,
    (SUM(cultivable_area) / SUM(geographical_area)) * 100 AS cultivable_area_percentage
FROM HRVillageSchedule
GROUP BY block_tehsil_name
ORDER BY cultivable_area_percentage DESC;

# Gohana tehsil have highest geographical area,cultivable area 

#9. Major Medium Scheme Effectiveness by District
SELECT 
    district_name,
    major_medium_scheme_name,
    COUNT(*) AS number_of_villages,
    SUM(gross_irrigated_area_total) AS total_irrigation_under_scheme
FROM HRVillageSchedule
WHERE major_medium_scheme IS NOT NULL
GROUP BY district_name, major_medium_scheme_name
ORDER BY district_name, total_irrigation_under_scheme DESC;


#10. Pre and Post Monsoon Groundwater Level Changes by Village Type
SELECT 
    ref_village_type_name,
    AVG(avg_ground_water_level_pre_monsoon) AS avg_pre_monsoon_groundwater,
    AVG(avg_ground_water_level_post_monsoon) AS avg_post_monsoon_groundwater,
    AVG(avg_ground_water_level_post_monsoon) - AVG(avg_ground_water_level_pre_monsoon) AS avg_groundwater_change
FROM HRVillageSchedule
GROUP BY ref_village_type_name
ORDER BY avg_groundwater_change DESC;
# thus ground water is more depledted on Non -Tribal village than Tribal Village

#11. Comparison of Cultivable Area to Irrigated Area
SELECT 
    state_name,
    (SUM(net_irrigated_area) / SUM(cultivable_area)) * 100 AS irrigation_coverage_percentage
FROM HRVillageSchedule
GROUP BY state_name;

# thus Haryana State have 86.7874 % area under irrigation

#12. Identifying Regions with High and Low Groundwater Recharge
SELECT 
    district_name,
    AVG(avg_ground_water_level_post_monsoon - avg_ground_water_level_pre_monsoon) AS avg_groundwater_recharge
FROM HRVillageSchedule
GROUP BY district_name
ORDER BY avg_groundwater_recharge DESC;
# thus fatehabad district have very low ground water level 

#13. Agricultural Intensity Analysis
SELECT 
    block_tehsil_name,
    (SUM(net_sown_area) / SUM(cultivable_area)) * 100 AS agricultural_intensity_percentage
FROM HRVillageSchedule
GROUP BY block_tehsil_name
ORDER BY agricultural_intensity_percentage DESC;
# Uchana have high agricultural _intensity_percentage


#14. Analysis of Seasonal Irrigation Dependency
SELECT 
    (SUM(gross_irrigated_area_kharif_season) / SUM(gross_irrigated_area_total)) * 100 AS kharif_season_dependency,
    (SUM(gross_irrigated_area_rabi_season) / SUM(gross_irrigated_area_total)) * 100 AS rabi_season_dependency,
    (SUM(gross_irrigated_area_perennial_season) / SUM(gross_irrigated_area_total)) * 100 AS perennial_season_dependency
FROM HRVillageSchedule;

#thus rabi have highe dependancy
#15.Correlation Between Groundwater Levels and Irrigated Areas
SELECT 
    district_name,
    AVG(avg_ground_water_level_post_monsoon) AS avg_post_monsoon_groundwater,
    AVG(net_irrigated_area) AS avg_net_irrigated_area
FROM HRVillageSchedule
GROUP BY district_name
ORDER BY avg_post_monsoon_groundwater, avg_net_irrigated_area DESC;
#Hissar is only district with low_post monsson groundwater and huge irrigate area and rest of district have ground water and irrigation area directly proportional to each other.



























