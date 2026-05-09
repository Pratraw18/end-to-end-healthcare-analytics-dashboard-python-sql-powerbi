
-- SQL Objective 1: Encounters Overview
-- 1. How many total encounters occurred each year?
SELECT
    encounter_year,
    COUNT(*) AS total_encounters
FROM encounters
GROUP BY encounter_year
ORDER BY encounter_year;

-- 2. For each year, what percentage of encounters belonged to each encounter class?
WITH yearly_class_counts AS (
    SELECT
        encounter_year,
        ENCOUNTERCLASS,
        COUNT(*) AS class_encounters
    FROM encounters
    GROUP BY encounter_year, ENCOUNTERCLASS
),
yearly_totals AS (
    SELECT
        encounter_year,
        COUNT(*) AS total_yearly_encounters
    FROM encounters
    GROUP BY encounter_year
)
SELECT
    ycc.encounter_year,
    ycc.ENCOUNTERCLASS,
    ycc.class_encounters,
    yt.total_yearly_encounters,
    CAST(
        ycc.class_encounters * 100.0 / yt.total_yearly_encounters
        AS DECIMAL(10,2)
    ) AS encounter_class_percentage
FROM yearly_class_counts ycc
JOIN yearly_totals yt
    ON ycc.encounter_year = yt.encounter_year
ORDER BY
    ycc.encounter_year,
    encounter_class_percentage DESC;

-- 3. What percentage of encounters were over 24 hours versus under 24 hours?
WITH stay_category AS (
    SELECT
        CASE
            WHEN length_of_stay_hours > 24 THEN 'Over 24 Hours'
            ELSE '24 Hours or Less'
        END AS stay_duration_category,
        COUNT(*) AS total_encounters
    FROM encounters
    GROUP BY
        CASE
            WHEN length_of_stay_hours > 24 THEN 'Over 24 Hours'
            ELSE '24 Hours or Less'
        END
),
total_count AS (
    SELECT COUNT(*) AS all_encounters
    FROM encounters
)
SELECT
    sc.stay_duration_category,
    sc.total_encounters,
    CAST(
        sc.total_encounters * 100.0 / tc.all_encounters
        AS DECIMAL(10,2)
    ) AS encounter_percentage
FROM stay_category sc
CROSS JOIN total_count tc
ORDER BY sc.total_encounters DESC;

-- By Encounter Class Duration Output
SELECT
    ENCOUNTERCLASS,
    CASE
        WHEN length_of_stay_hours > 24 THEN 'Over 24 Hours'
        ELSE '24 Hours or Less'
    END AS stay_duration_category,
    COUNT(*) AS total_encounters,
    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY ENCOUNTERCLASS)
        AS DECIMAL(10,2)
    ) AS percentage_within_encounter_class
FROM encounters
GROUP BY
    ENCOUNTERCLASS,
    CASE
        WHEN length_of_stay_hours > 24 THEN 'Over 24 Hours'
        ELSE '24 Hours or Less'
    END
ORDER BY
    ENCOUNTERCLASS,
    percentage_within_encounter_class DESC;


    -- ### SQL Objective 1: Encounters Overview

-- The SQL analysis shows that the hospital recorded the highest annual encounter volume in 2014, with 3,885 encounters, followed by 2021 with 3,530 encounters. The year 2022 should be interpreted carefully because the dataset contains only partial-year records.

-- Encounter class analysis shows that ambulatory and outpatient encounters form the largest share of total hospital visits. For example, in 2011, ambulatory encounters represented 49.93% of all encounters, while outpatient encounters represented 24.48%.

-- Length-of-stay classification shows that 99.73% of all encounters lasted 24 hours or less, while only 0.27% lasted over 24 hours. This confirms that the dataset is dominated by short-duration visits.

-- By encounter class, inpatient care has the highest share of long-duration encounters, with 5.11% of inpatient encounters lasting over 24 hours. Urgent care and wellness encounters were entirely short-duration visits.



------------------------ OBJECTIVE 2----------------------------------------

-- 2a. How many encounters had zero payer coverage, and what percentage of total encounters does this represent?
WITH coverage_summary AS (
    SELECT
        CASE
            WHEN PAYER_COVERAGE = 0 THEN 'Zero Payer Coverage'
            ELSE 'Covered by Payer'
        END AS coverage_status,
        COUNT(*) AS total_encounters
    FROM encounters
    GROUP BY
        CASE
            WHEN PAYER_COVERAGE = 0 THEN 'Zero Payer Coverage'
            ELSE 'Covered by Payer'
        END
),
total_count AS (
    SELECT COUNT(*) AS all_encounters
    FROM encounters
)
SELECT
    cs.coverage_status,
    cs.total_encounters,
    CAST(
        cs.total_encounters * 100.0 / tc.all_encounters
        AS DECIMAL(10,2)
    ) AS encounter_percentage
FROM coverage_summary cs
CROSS JOIN total_count tc
ORDER BY cs.total_encounters DESC;

-- 2b. What are the top 10 most frequent procedures performed and the average base cost for each?
SELECT TOP 10
    DESCRIPTION AS procedure_name,
    COUNT(*) AS procedure_count,
    CAST(AVG(BASE_COST) AS DECIMAL(18,2)) AS avg_base_cost
FROM procedures
GROUP BY DESCRIPTION
ORDER BY procedure_count DESC;

-- 2c. What are the top 10 procedures with the highest average base cost and the number of times they were performed?
SELECT TOP 10
    DESCRIPTION AS procedure_name,
    COUNT(*) AS procedure_count,
    CAST(AVG(BASE_COST) AS DECIMAL(18,2)) AS avg_base_cost,
    CAST(SUM(BASE_COST) AS DECIMAL(18,2)) AS total_base_cost
FROM procedures
GROUP BY DESCRIPTION
ORDER BY avg_base_cost DESC;


-- only procedures performed at least 10 times.
SELECT TOP 10
    DESCRIPTION AS procedure_name,
    COUNT(*) AS procedure_count,
    CAST(AVG(BASE_COST) AS DECIMAL(18,2)) AS avg_base_cost,
    CAST(SUM(BASE_COST) AS DECIMAL(18,2)) AS total_base_cost
FROM procedures
GROUP BY DESCRIPTION
HAVING COUNT(*) >= 10
ORDER BY avg_base_cost DESC;

-- What is the average total claim cost for encounters, broken down by payer?

SELECT
    payer_name,
    COUNT(*) AS total_encounters,
    CAST(AVG(TOTAL_CLAIM_COST) AS DECIMAL(18,2)) AS avg_total_claim_cost,
    CAST(SUM(TOTAL_CLAIM_COST) AS DECIMAL(18,2)) AS total_claim_cost,
    CAST(SUM(PAYER_COVERAGE) AS DECIMAL(18,2)) AS total_payer_coverage,
    CAST(SUM(patient_out_of_pocket_cost) AS DECIMAL(18,2)) AS total_patient_cost
FROM encounters_payer
GROUP BY payer_name
ORDER BY avg_total_claim_cost DESC;


-- SQL Objective 2: Cost and Coverage Insights

--The SQL analysis shows that 13,586 encounters had zero payer coverage, representing 48.71% of all encounters. This indicates that nearly half of hospital encounters may create patient-side financial burden or reimbursement risk.

--The most frequent procedures are mainly assessment, screening, care-management, and chronic care related. Assessment of health and social care needs is the most frequent procedure, with 4,596 records, followed by hospice care, depression screening, substance use assessment, and renal dialysis.

--The highest average base cost procedure is Admit to ICU, with an average base cost of 206,260.40, although it appears only 5 times. This shows why procedure count must be considered along with average cost. Electrical cardioversion is especially important because it combines high procedure volume with very high total base cost.

--By payer, Medicaid has the highest average total claim cost per encounter at 6,205.22. However, NO_INSURANCE has the highest total claim cost at 49.25 million and zero payer coverage, making it the biggest financial risk group in the dataset.

--For hospital finance teams, these findings highlight the need to monitor zero-coverage encounters, high-cost procedures, and payer-wise claim patterns.

-- Electrical cardioversion is the strongest procedure financially because it has both high average cost and high frequency.




--------------------- 3rd OBJECTIVE-----------------------------
-- 3a. How many unique patients were admitted each quarter over time?
-- START and STOP datatype is in text datatype that's why we use TRY_CONVERT keyword
SELECT
    YEAR(TRY_CONVERT(DATETIME2, LEFT(START, 19))) AS encounter_year,
    DATEPART(QUARTER, TRY_CONVERT(DATETIME2, LEFT(START, 19))) AS encounter_quarter,
    COUNT(DISTINCT PATIENT) AS unique_patients
FROM encounters
WHERE TRY_CONVERT(DATETIME2, LEFT(START, 19)) IS NOT NULL
GROUP BY
    YEAR(TRY_CONVERT(DATETIME2, LEFT(START, 19))),
    DATEPART(QUARTER, TRY_CONVERT(DATETIME2, LEFT(START, 19)))
ORDER BY
    encounter_year,
    encounter_quarter;

-- Quarterly unique patient volume increased strongly from 2011 to 2014, with 2014 Q1 showing a visible peak.



-- 3b. How many patients were readmitted within 30 days of a previous encounter?
SELECT
    COUNT(DISTINCT PATIENT) AS patients_with_30_day_readmission
FROM encounters_readmission
WHERE is_30_day_readmission = 'Yes';
-- 770 unique patients had at least one 30-day repeat encounter
-- 79.06% of patients had at least one 30-day repeat encounter


-- This gives number of 30-day repeat encounters
SELECT
    COUNT(*) AS total_30_day_readmission_encounters
FROM encounters_readmission
WHERE is_30_day_readmission = 'Yes';
-- 16,234 total 30-day repeat encounters



-- readmission percentage output

-- 30-day readmission percentage

WITH readmission_summary AS (
    SELECT
        CASE
            WHEN is_30_day_readmission = 'Yes' THEN '30-Day Readmission'
            ELSE 'Not 30-Day Readmission'
        END AS readmission_status,
        COUNT(*) AS total_encounters
    FROM encounters_readmission
    GROUP BY
        CASE
            WHEN is_30_day_readmission = 'Yes' THEN '30-Day Readmission'
            ELSE 'Not 30-Day Readmission'
        END
),
total_count AS (
    SELECT COUNT(*) AS all_encounters
    FROM encounters_readmission
)
SELECT
    rs.readmission_status,
    rs.total_encounters,
    CAST(rs.total_encounters * 100.0 / tc.all_encounters AS DECIMAL(10,2)) AS encounter_percentage
FROM readmission_summary rs
CROSS JOIN total_count tc
ORDER BY rs.total_encounters DESC;

-- 58.21% of all encounters were repeat encounters within 30 days of a previous encounter.



-- 3c. Which patients had the most readmissions?

SELECT TOP 10
    PATIENT,
    COUNT(*) AS total_readmissions
FROM encounters_readmission
WHERE is_readmission = 'Readmission'
GROUP BY PATIENT
ORDER BY total_readmissions DESC;

-- 1,380 total readmissions
-- 1,211 30-day readmissions
-- Average gap: 2.76 days


-- Top 10 patients with most readmissions
SELECT TOP 10
    er.PATIENT,
    p.FIRST,
    p.LAST,
    p.GENDER,
    p.RACE,
    p.ETHNICITY,
    COUNT(*) AS total_readmissions,
    SUM(CASE WHEN er.is_30_day_readmission = 'Yes' THEN 1 ELSE 0 END) AS thirty_day_readmissions,
    CAST(AVG(er.days_since_previous_visit) AS DECIMAL(10,2)) AS avg_days_since_previous_visit
FROM encounters_readmission er
LEFT JOIN patients p
    ON er.PATIENT = p.Id
WHERE er.is_readmission = 'Readmission'
GROUP BY
    er.PATIENT,
    p.FIRST,
    p.LAST,
    p.GENDER,
    p.RACE,
    p.ETHNICITY
ORDER BY total_readmissions DESC;

-- ### SQL Objective 3: Patient Behavior Analysis

-- Quarterly patient analysis shows that unique patient volume increased from 2011 to 2014, with 2014 Q1 showing a visible peak. This confirms the earlier yearly encounter trend where 2014 was the highest-load year.

-- The analysis also shows that 770 unique patients had at least one 30-day repeat encounter. In total, 16,234 encounters were classified as 30-day repeat encounters, representing 58.21% of all encounters.

-- This metric should be interpreted as a 30-day repeat encounter rate rather than strict clinical readmission because the dataset includes outpatient, ambulatory, wellness, emergency, urgent care, and inpatient encounters.

-- Patient-level analysis shows that a small group of patients has extremely high repeat encounter counts. The top patient had 1,380 repeat encounters, including 1,211 within 30 days, with an average gap of only 2.76 days between visits.

-- For hospital management, this suggests that high-utilization patients should be monitored separately through care coordination, follow-up planning, and chronic disease management programs.


