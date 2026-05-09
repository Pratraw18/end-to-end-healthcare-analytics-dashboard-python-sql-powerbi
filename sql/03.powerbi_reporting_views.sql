

--- View 1: Encounters Overview

CREATE OR ALTER VIEW vw_encounters_overview AS
SELECT
    Id AS encounter_id,
    PATIENT AS patient_id,
    ORGANIZATION AS organization_id,
    PAYER AS payer_id,
    TRY_CONVERT(DATETIME2, LEFT(START, 19)) AS start_datetime,
    TRY_CONVERT(DATETIME2, LEFT(STOP, 19)) AS stop_datetime,
    encounter_year,
    encounter_month,
    encounter_month_name,
    encounter_year_month,
    ENCOUNTERCLASS AS encounter_class,
    DESCRIPTION AS encounter_description,
    BASE_ENCOUNTER_COST AS base_encounter_cost,
    TOTAL_CLAIM_COST AS total_claim_cost,
    PAYER_COVERAGE AS payer_coverage,
    patient_out_of_pocket_cost,
    length_of_stay_hours,
    length_of_stay_days,
    CASE
        WHEN length_of_stay_hours > 24 THEN 'Over 24 Hours'
        ELSE '24 Hours or Less'
    END AS stay_duration_category,
    is_covered_by_insurance,
    day_of_week
FROM encounters;

SELECT TOP 10 *
FROM vw_encounters_overview;


-- View 2: Cost and Coverage Insights
CREATE OR ALTER VIEW vw_cost_coverage_insights AS
SELECT
    Id AS encounter_id,
    PATIENT AS patient_id,
    payer_name,
    ENCOUNTERCLASS AS encounter_class,
    TOTAL_CLAIM_COST AS total_claim_cost,
    PAYER_COVERAGE AS payer_coverage,
    patient_out_of_pocket_cost,
    CASE
        WHEN PAYER_COVERAGE = 0 THEN 'Zero Payer Coverage'
        ELSE 'Covered by Payer'
    END AS coverage_status,
    CAST(
        CASE
            WHEN TOTAL_CLAIM_COST = 0 THEN 0
            ELSE PAYER_COVERAGE * 100.0 / TOTAL_CLAIM_COST
        END AS DECIMAL(10,2)
    ) AS coverage_ratio_percent,
    encounter_year,
    encounter_month,
    encounter_year_month,
    TRY_CONVERT(DATETIME2, LEFT(START, 19)) AS start_datetime
FROM encounters_payer;

SELECT TOP 10 *
FROM vw_cost_coverage_insights;


-- View 3: Procedure Analysis
CREATE OR ALTER VIEW vw_procedure_analysis AS
SELECT
    PATIENT AS patient_id,
    ENCOUNTER AS encounter_id,
    TRY_CONVERT(DATETIME2, LEFT(START, 19)) AS procedure_start_datetime,
    TRY_CONVERT(DATETIME2, LEFT(STOP, 19)) AS procedure_stop_datetime,
    CODE AS procedure_code,
    DESCRIPTION AS procedure_name,
    BASE_COST AS procedure_base_cost,
    REASONCODE AS reason_code,
    REASONDESCRIPTION AS reason_description
FROM procedures;

SELECT TOP 10 *
FROM vw_procedure_analysis;


-- View 4: Patient Behavior and Readmission

CREATE OR ALTER VIEW vw_patient_behavior AS
SELECT
    ep.Id AS encounter_id,
    ep.PATIENT AS patient_id,
    p.FIRST AS first_name,
    p.LAST AS last_name,
    p.GENDER AS gender,
    p.RACE AS race,
    p.ETHNICITY AS ethnicity,
    p.MARITAL AS marital_status,
    ep.age_at_encounter,
    ep.age_group,
    TRY_CONVERT(DATETIME2, LEFT(er.START, 19)) AS start_datetime,
    TRY_CONVERT(DATETIME2, LEFT(er.STOP, 19)) AS stop_datetime,
    er.ENCOUNTERCLASS AS encounter_class,
    er.TOTAL_CLAIM_COST AS total_claim_cost,
    er.PAYER_COVERAGE AS payer_coverage,
    er.length_of_stay_hours,
    er.length_of_stay_days,
    TRY_CONVERT(DATETIME2, LEFT(er.previous_encounter_date, 19)) AS previous_encounter_datetime,
    er.days_since_previous_visit,
    er.is_readmission,
    er.is_30_day_readmission
FROM encounters_readmission er
LEFT JOIN encounters_patient ep
    ON er.Id = ep.Id
LEFT JOIN patients p
    ON er.PATIENT = p.Id;

SELECT TOP 10 * FROM vw_patient_behavior;



-- View 5: Payer Summary
CREATE OR ALTER VIEW vw_payer_summary AS
SELECT
    payer_name,
    COUNT(*) AS total_encounters,
    COUNT(DISTINCT PATIENT) AS unique_patients,
    CAST(SUM(TOTAL_CLAIM_COST) AS DECIMAL(18,2)) AS total_claim_cost,
    CAST(AVG(TOTAL_CLAIM_COST) AS DECIMAL(18,2)) AS avg_claim_cost,
    CAST(SUM(PAYER_COVERAGE) AS DECIMAL(18,2)) AS total_payer_coverage,
    CAST(AVG(PAYER_COVERAGE) AS DECIMAL(18,2)) AS avg_payer_coverage,
    CAST(SUM(patient_out_of_pocket_cost) AS DECIMAL(18,2)) AS total_patient_cost,
    CAST(AVG(patient_out_of_pocket_cost) AS DECIMAL(18,2)) AS avg_patient_cost,
    CAST(
        CASE
            WHEN SUM(TOTAL_CLAIM_COST) = 0 THEN 0
            ELSE SUM(PAYER_COVERAGE) * 100.0 / SUM(TOTAL_CLAIM_COST)
        END AS DECIMAL(10,2)
    ) AS coverage_ratio_percent
FROM encounters_payer
GROUP BY payer_name;

SELECT top 10 *
FROM vw_payer_summary
ORDER BY total_payer_coverage DESC;


-- View 6: Quarterly Patient Trend
CREATE OR ALTER VIEW vw_quarterly_patient_trend AS
SELECT
    YEAR(TRY_CONVERT(DATETIME2, LEFT(START, 19))) AS encounter_year,
    DATEPART(QUARTER, TRY_CONVERT(DATETIME2, LEFT(START, 19))) AS encounter_quarter,
    CONCAT(
        YEAR(TRY_CONVERT(DATETIME2, LEFT(START, 19))),
        '-Q',
        DATEPART(QUARTER, TRY_CONVERT(DATETIME2, LEFT(START, 19)))
    ) AS year_quarter,
    COUNT(*) AS total_encounters,
    COUNT(DISTINCT PATIENT) AS unique_patients
FROM encounters
WHERE TRY_CONVERT(DATETIME2, LEFT(START, 19)) IS NOT NULL
GROUP BY
    YEAR(TRY_CONVERT(DATETIME2, LEFT(START, 19))),
    DATEPART(QUARTER, TRY_CONVERT(DATETIME2, LEFT(START, 19)));

SELECT top 10 *
FROM vw_quarterly_patient_trend
ORDER BY encounter_year, encounter_quarter;