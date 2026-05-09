CREATE DATABASE Hospital_Analytics_DB;
GO

USE Hospital_Analytics_DB;
GO


USE Hospital_Analytics_DB;
GO

CREATE TABLE patients (
    Id VARCHAR(100) PRIMARY KEY,
    BIRTHDATE DATE,
    DEATHDATE DATE NULL,
    PREFIX VARCHAR(20),
    FIRST VARCHAR(100),
    LAST VARCHAR(100),
    SUFFIX VARCHAR(50),
    MAIDEN VARCHAR(100),
    MARITAL VARCHAR(50),
    RACE VARCHAR(50),
    ETHNICITY VARCHAR(50),
    GENDER VARCHAR(10),
    BIRTHPLACE VARCHAR(255),
    ADDRESS VARCHAR(255),
    CITY VARCHAR(100),
    STATE VARCHAR(100),
    COUNTY VARCHAR(100),
    ZIP VARCHAR(20),
    LAT FLOAT,
    LON FLOAT
);
GO

CREATE TABLE encounters (
    Id VARCHAR(100) PRIMARY KEY,
    START DATETIMEOFFSET,
    STOP DATETIMEOFFSET,
    PATIENT VARCHAR(100),
    ORGANIZATION VARCHAR(100),
    PAYER VARCHAR(100),
    ENCOUNTERCLASS VARCHAR(50),
    CODE BIGINT,
    DESCRIPTION VARCHAR(255),
    BASE_ENCOUNTER_COST DECIMAL(18,2),
    TOTAL_CLAIM_COST DECIMAL(18,2),
    PAYER_COVERAGE DECIMAL(18,2),
    REASONCODE VARCHAR(100),
    REASONDESCRIPTION VARCHAR(255),
    length_of_stay_hours FLOAT,
    length_of_stay_days FLOAT,
    encounter_year INT,
    encounter_month INT,
    encounter_month_name VARCHAR(20),
    encounter_year_month VARCHAR(20),
    is_covered_by_insurance VARCHAR(50),
    patient_out_of_pocket_cost DECIMAL(18,2)
);
GO

CREATE TABLE procedures (
    START DATETIMEOFFSET,
    STOP DATETIMEOFFSET,
    PATIENT VARCHAR(100),
    ENCOUNTER VARCHAR(100),
    CODE BIGINT,
    DESCRIPTION VARCHAR(255),
    BASE_COST DECIMAL(18,2),
    REASONCODE VARCHAR(100),
    REASONDESCRIPTION VARCHAR(255)
);
GO

CREATE TABLE payers (
    Id VARCHAR(100) PRIMARY KEY,
    NAME VARCHAR(100),
    ADDRESS VARCHAR(255),
    CITY VARCHAR(100),
    STATE_HEADQUARTERED VARCHAR(100),
    ZIP VARCHAR(20),
    PHONE VARCHAR(50)
);
GO

CREATE TABLE organizations (
    Id VARCHAR(100) PRIMARY KEY,
    NAME VARCHAR(255),
    ADDRESS VARCHAR(255),
    CITY VARCHAR(100),
    STATE VARCHAR(100),
    ZIP VARCHAR(20),
    LAT FLOAT,
    LON FLOAT
);
GO

CREATE TABLE encounters_readmission (
    Id VARCHAR(100),
    START DATETIMEOFFSET,
    STOP DATETIMEOFFSET,
    PATIENT VARCHAR(100),
    ORGANIZATION VARCHAR(100),
    PAYER VARCHAR(100),
    ENCOUNTERCLASS VARCHAR(50),
    CODE BIGINT,
    DESCRIPTION VARCHAR(255),
    BASE_ENCOUNTER_COST DECIMAL(18,2),
    TOTAL_CLAIM_COST DECIMAL(18,2),
    PAYER_COVERAGE DECIMAL(18,2),
    REASONCODE VARCHAR(100),
    REASONDESCRIPTION VARCHAR(255),
    length_of_stay_hours FLOAT,
    length_of_stay_days FLOAT,
    encounter_year INT,
    encounter_month INT,
    encounter_month_name VARCHAR(20),
    encounter_year_month VARCHAR(20),
    is_covered_by_insurance VARCHAR(50),
    previous_encounter_date DATETIMEOFFSET NULL,
    days_since_previous_visit FLOAT NULL,
    is_readmission VARCHAR(50),
    is_30_day_readmission VARCHAR(10)
);
GO

CREATE TABLE encounters_patient (
    Id VARCHAR(100),
    START DATETIMEOFFSET,
    STOP DATETIMEOFFSET,
    PATIENT VARCHAR(100),
    ORGANIZATION VARCHAR(100),
    PAYER VARCHAR(100),
    ENCOUNTERCLASS VARCHAR(50),
    CODE BIGINT,
    DESCRIPTION VARCHAR(255),
    BASE_ENCOUNTER_COST DECIMAL(18,2),
    TOTAL_CLAIM_COST DECIMAL(18,2),
    PAYER_COVERAGE DECIMAL(18,2),
    REASONCODE VARCHAR(100),
    REASONDESCRIPTION VARCHAR(255),
    length_of_stay_hours FLOAT,
    length_of_stay_days FLOAT,
    encounter_year INT,
    encounter_month INT,
    encounter_month_name VARCHAR(20),
    encounter_year_month VARCHAR(20),
    is_covered_by_insurance VARCHAR(50),
    patient_out_of_pocket_cost DECIMAL(18,2),
    Id_patient VARCHAR(100),
    BIRTHDATE DATE,
    GENDER VARCHAR(10),
    RACE VARCHAR(50),
    ETHNICITY VARCHAR(50),
    MARITAL VARCHAR(50),
    age_at_encounter INT,
    age_group VARCHAR(20)
);
GO

CREATE TABLE encounters_payer (
    Id VARCHAR(100),
    START DATETIMEOFFSET,
    STOP DATETIMEOFFSET,
    PATIENT VARCHAR(100),
    ORGANIZATION VARCHAR(100),
    PAYER VARCHAR(100),
    ENCOUNTERCLASS VARCHAR(50),
    CODE BIGINT,
    DESCRIPTION VARCHAR(255),
    BASE_ENCOUNTER_COST DECIMAL(18,2),
    TOTAL_CLAIM_COST DECIMAL(18,2),
    PAYER_COVERAGE DECIMAL(18,2),
    REASONCODE VARCHAR(100),
    REASONDESCRIPTION VARCHAR(255),
    length_of_stay_hours FLOAT,
    length_of_stay_days FLOAT,
    encounter_year INT,
    encounter_month INT,
    encounter_month_name VARCHAR(20),
    encounter_year_month VARCHAR(20),
    is_covered_by_insurance VARCHAR(50),
    patient_out_of_pocket_cost DECIMAL(18,2),
    Id_payer VARCHAR(100),
    payer_name VARCHAR(100)
);
GO

CREATE TABLE procedures_coverage (
    START DATETIMEOFFSET,
    STOP DATETIMEOFFSET,
    PATIENT VARCHAR(100),
    ENCOUNTER VARCHAR(100),
    CODE BIGINT,
    DESCRIPTION VARCHAR(255),
    BASE_COST DECIMAL(18,2),
    REASONCODE VARCHAR(100),
    REASONDESCRIPTION VARCHAR(255),
    Id_encounter VARCHAR(100),
    PAYER VARCHAR(100),
    PAYER_COVERAGE DECIMAL(18,2),
    TOTAL_CLAIM_COST DECIMAL(18,2),
    is_covered_by_insurance VARCHAR(50)
);
GO


SELECT 
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;


SELECT TOP 5 * FROM patients;

SELECT TOP 5 * FROM encounters;

SELECT TOP 5 * FROM procedures;

SELECT TOP 5 * FROM encounters_readmission;

SELECT TOP 5 * FROM encounters_payer;

SELECT TOP 5 * FROM procedures_coverage;

SELECT TOP 10
    Id,
    START,
    STOP,
    TRY_CONVERT(DATETIME2, LEFT(START, 19)) AS start_datetime,
    TRY_CONVERT(DATETIME2, LEFT(STOP, 19)) AS stop_datetime
FROM encounters;

-- Check null in core fields
SELECT
    SUM(CASE WHEN Id IS NULL THEN 1 ELSE 0 END) AS null_encounter_id,
    SUM(CASE WHEN PATIENT IS NULL THEN 1 ELSE 0 END) AS null_patient_id,
    SUM(CASE WHEN START IS NULL THEN 1 ELSE 0 END) AS null_start,
    SUM(CASE WHEN STOP IS NULL THEN 1 ELSE 0 END) AS null_stop,
    SUM(CASE WHEN ENCOUNTERCLASS IS NULL THEN 1 ELSE 0 END) AS null_encounter_class,
    SUM(CASE WHEN TOTAL_CLAIM_COST IS NULL THEN 1 ELSE 0 END) AS null_total_claim_cost
FROM encounters;

SELECT
    ENCOUNTERCLASS,
    COUNT(*) AS total_encounters
FROM encounters
GROUP BY ENCOUNTERCLASS
ORDER BY total_encounters DESC;


SELECT
    payer_name,
    COUNT(*) AS total_encounters
FROM encounters_payer
GROUP BY payer_name
ORDER BY total_encounters DESC;


SELECT
    COUNT(*) AS total_procedures,
    COUNT(DISTINCT PATIENT) AS unique_patients,
    COUNT(DISTINCT ENCOUNTER) AS unique_encounters
FROM procedures;