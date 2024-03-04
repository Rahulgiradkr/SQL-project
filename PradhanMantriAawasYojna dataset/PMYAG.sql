use eda;

CREATE TABLE `PMAYG` (
        `Sl. No.` VARCHAR(5) NOT NULL,
        `State/UT` VARCHAR(40) NOT NULL,
        `Targets Allocated by Ministry` DECIMAL(38, 0) NOT NULL,
        `Houses Sanctioned by States/UTs` DECIMAL(38, 0) NOT NULL,
        `Houses Completed` DECIMAL(38, 0) NOT NULL
);

LOAD DATA INFILE  
'D:\RS_Session_260_AU_1552_1.csv'
into table `PMAYG`
FIELDS TERMINATED by ','
ENCLOSED by '"'
lines terminated by '\n'
IGNORE 1 ROWS;

select * from PMAYG;

SELECT 
    `Sl. No.`,
    `State/UT`,
    `Targets Allocated by Ministry`,
    `Houses Sanctioned by States/UTs`,
    `Houses Completed`
FROM 
    `pmayg`
ORDER BY 
    `Sl. No.` ASC;
# thus we analyse how much house is completed vs Targeted

SELECT
    `Sl. No.`,
    `State/UT`,
    `Targets Allocated by Ministry` AS `Targets Allocated by Ministry`,
    `Houses Sanctioned by States/UTs` AS `Sanctioned by States/UTs Houses`,
    `Houses Completed`,
    CONCAT(ROUND((`Houses Sanctioned by States/UTs` / `Targets Allocated by Ministry`) * 100, 2), '%') AS `SANCTIONED VS TARGET (%)`,
    CONCAT(ROUND((`Houses Completed` / `Targets Allocated by Ministry`) * 100, 2), '%') AS `COMPLETED VS TARGET (%)`
FROM
    `pmayg`
ORDER BY
    `COMPLETED VS TARGET (%)` DESC, `SANCTIONED VS TARGET (%)` DESC;

#1.Ranking States by Performance
WITH RANKEDSTATE AS(
SELECT 
	`State/UT`,
	`Targets Allocated by Ministry`,
	`Houses Completed`,
    ROUND((`Houses Completed`/`Targets Allocated by Ministry`)*100,2) AS `COMPLETION RATE`,
    RANK() OVER(ORDER BY ROUND((`Houses Completed`/`Targets Allocated by Ministry`)*100,2)DESC)AS `RANK`
FROM 
	`PMAYG`
)
SELECT * ,
CONCAT(`COMPLETION RATE`,'%') AS `COMPLETION RATE(%)`
FROM 
`RANKEDSTATE`
ORDER BY
`RANK`;

#2.Identifying States with a High Sanction but Low Completion Rate

SELECT
    `Sl. No.`,
    `State/UT`,
    `Targets Allocated by Ministry` AS `Targets Allocated by Ministry`,
    `Houses Sanctioned by States/UTs` AS `Sanctioned by States/UTs Houses`,
    `Houses Completed`,
    CONCAT(ROUND((`Houses Sanctioned by States/UTs` / `Targets Allocated by Ministry`) * 100, 2), '%') AS `SANCTIONED VS TARGET (%)`,
    CONCAT(ROUND((`Houses Completed` / `Targets Allocated by Ministry`) * 100, 2), '%') AS `COMPLETED VS TARGET (%)`
FROM
    `pmayg`
WHERE (`Houses Sanctioned by States/UTs` / `Targets Allocated by Ministry`)>0.75 AND (`Houses Completed` / `Targets Allocated by Ministry`)<0.5
ORDER BY (`Houses Completed` / `Targets Allocated by Ministry`);

#3.Aggregating Data at a Higher Level
SELECT
    `State/UT`,
    SUM(`Targets Allocated by Ministry`) AS `Total Targets by Ministry`,
    SUM(`Houses Sanctioned by States/UTs`) AS `Total Houses Sanctioned`,
    SUM(`Houses Completed`) AS `Total Houses Completed`,
    CONCAT(ROUND((SUM(`Houses Completed`) / SUM(`Targets Allocated by Ministry`)) * 100, 2), '%') AS `Overall Completion Rate (%)`
FROM
    `pmayg`
GROUP BY
    `State/UT`
ORDER BY
    `Overall Completion Rate (%)` DESC;
    
    #4.Performance Threshold Analysis
    SELECT
		`State/UT`,
        `Targets Allocated by Ministry`,
        `Houses Completed`,
        ROUND((`Houses Completed`/`Targets Allocated by Ministry`)*100,2) AS `COMPLETION RATE`,
        CASE
			WHEN ROUND((`Houses Completed`/`Targets Allocated by Ministry`)*100,2) >= 75 THEN 'PERFORMANCE_HIGH'
            WHEN ROUND((`Houses Completed`/`Targets Allocated by Ministry`)*100,2) BETWEEN 50 AND 75 THEN 'MODERATE PERFORMANCE'
            ELSE 'LOW PERFORMANCE'
		END AS 'PERFORMANCE CATEGORY'
FROM 
	`PMAYG`
ORDER BY 
	`COMPLETION RATE` DESC;

#5.Gap Analysis Between Sanctioned and Completed Houses
SELECT
    `State/UT`,
    `Houses Sanctioned by States/UTs`,
    `Houses Completed`,
    (`Houses Sanctioned by States/UTs` - `Houses Completed`) AS `Sanctioned-Completed Gap`,
    RANK() OVER (ORDER BY (`Houses Sanctioned by States/UTs` - `Houses Completed`) DESC) AS `Gap Rank`
FROM
    `pmayg`
ORDER BY
    `Gap Rank`;

#6.Utilization Ratio of Sanctioned Houses
SELECT
	`State/UT`,
    `Houses Sanctioned by States/UTs`,
    `Houses Completed`,
    CONCAT(ROUND((`Houses Completed`/`Houses Sanctioned by States/UTs`)*100,2),'%') AS UTILIZATION_RATIO
FROM
	`PMAYG`
WHERE
	`Houses Sanctioned by States/UTs`>0
ORDER BY
	`UTILIZATION_RATIO` DESC;
	
    #7.Anomaly Detection in Completion Rates
    WITH StateAverages AS (
    SELECT
        `State/UT`,
        AVG(`Houses Completed` / `Targets Allocated by Ministry`) AS `AvgCompletionRate`
    FROM
        `pmayg`
    GROUP BY
        `State/UT`
),
OverallAverage AS (
    SELECT
        AVG(`AvgCompletionRate`) AS `OverallAvgCompletionRate`
    FROM
        StateAverages
)
SELECT
    a.`State/UT`,
    a.`AvgCompletionRate`,
    o.`OverallAvgCompletionRate`,
    CASE
        WHEN a.`AvgCompletionRate` > (o.`OverallAvgCompletionRate` * 1.5) THEN 'Significantly Above Average'
        WHEN a.`AvgCompletionRate` < (o.`OverallAvgCompletionRate` / 1.5) THEN 'Significantly Below Average'
        ELSE 'Within Normal Range'
    END AS `AnomalyStatus`
FROM
    StateAverages a, OverallAverage o;
    
    
#8.Advanced Statistical Functions for Outlier Detection
SELECT 
    `State/UT`,
    (`Houses Completed` - AVG(`Houses Completed`) OVER()) / STDDEV(`Houses Completed`) OVER() AS `CompletionRateZScore`
FROM 
    `pmayg`;
    
#9.Analyze Outliers
SELECT 
    *,
    (`Houses Completed` - avg_comp) / std_dev AS `CompletionRateZScore`
FROM 
    (
        SELECT 
            `State/UT`,
            `Targets Allocated by Ministry`,
            `Houses Completed`,
            AVG(`Houses Completed`) OVER() AS avg_comp,
            STD(`Houses Completed`) OVER() AS std_dev
        FROM 
            `pmayg`
    ) AS subquery
WHERE 
    (`Houses Completed` - avg_comp) / std_dev > 2 OR (`Houses Completed` - avg_comp) / std_dev < -2;

#10.Understand Implications
SELECT 
    AVG(`CompletionRate`) AS `AvgCompletionRateExcludingOutliers`
FROM 
    (
        SELECT 
            `State/UT`,
            `Targets Allocated by Ministry`,
            `Houses Completed`,
            `Houses Completed` / `Targets Allocated by Ministry` AS `CompletionRate`,
            AVG(`Houses Completed`) OVER() AS avg_comp,
            STD(`Houses Completed`) OVER() AS std_dev
        FROM 
            `pmayg`
    ) AS subquery
WHERE 
    (`CompletionRate` - avg_comp) / std_dev BETWEEN -2 AND 2;




    

	
    
    
    








    
