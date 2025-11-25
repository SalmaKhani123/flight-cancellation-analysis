-- ============================================
-- U.S. FLIGHT CANCELLATION ANALYSIS
-- Snowflake SQL Scripts
-- Author: Salma Khani
-- ============================================


-- ============================================
-- SCRIPT 1: DATABASE SETUP
-- Purpose: Create database and schema structure
-- ============================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

-- Create database
CREATE OR REPLACE DATABASE FLIGHT_DELAY_DB;

-- Create schema
CREATE OR REPLACE SCHEMA FLIGHT_DELAY_DB.RAW_DATA;

USE DATABASE FLIGHT_DELAY_DB;
USE SCHEMA RAW_DATA;


-- ============================================
-- SCRIPT 2: CREATE TABLES
-- Purpose: Create table structure for raw flight data
-- ============================================

-- Create table for raw flight data (22 columns)
CREATE OR REPLACE TABLE flights_raw (
    DAY_OF_MONTH INT,
    DAY_OF_WEEK INT,
    OP_UNIQUE_CARRIER VARCHAR(10),
    OP_CARRIER VARCHAR(10),
    OP_CARRIER_FL_NUM VARCHAR(20),
    TAIL_NUM VARCHAR(20),
    OP_CARRIER_CODE VARCHAR(10),
    ORIGIN_AIRPORT_ID INT,
    ORIGIN_AIRPORT_SEQ_ID INT,
    ORIGIN VARCHAR(10),
    DEST_AIRPORT_ID INT,
    DEST_AIRPORT_SEQ_ID INT,
    DEST VARCHAR(10),
    DEP_TIME VARCHAR(10),
    DEP_DELAY FLOAT,
    DEP_TIME_BLK VARCHAR(20),
    ARR_TIME VARCHAR(10),
    ARR_DELAY FLOAT,
    CANCELLED INT,
    DIVERTED INT,
    DISTANCE INT,
    EXTRA_COL VARCHAR(10)
);


-- ============================================
-- SCRIPT 3: LOAD DATA
-- Purpose: Create stage and load CSV files
-- ============================================

-- Create stage for file uploads
CREATE OR REPLACE STAGE FLIGHT_STAGE;

-- Load Jan 2019 data
COPY INTO flights_raw
FROM @FLIGHT_STAGE/Jan_2019_ontime.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- Load Jan 2020 data
COPY INTO flights_raw
FROM @FLIGHT_STAGE/Jan_2020_ontime.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- Verify data loaded
SELECT COUNT(*) as total_flights FROM flights_raw;
-- Expected: 1,191,331 rows


-- ============================================
-- SCRIPT 4: CREATE AGGREGATED VIEW
-- Purpose: Create aggregated view for Tableau
-- ============================================

-- Aggregate flight data by route and day
CREATE OR REPLACE VIEW FLIGHTS_CLEAN AS
SELECT 
    DAY_OF_WEEK,
    OP_UNIQUE_CARRIER as CARRIER_CODE,
    ORIGIN,
    DEST,
    
    -- Performance metrics
    AVG(DEP_DELAY) as AVG_DEP_DELAY,
    AVG(ARR_DELAY) as AVG_ARR_DELAY,
    COUNT(*) as FLIGHT_COUNT,
    SUM(CASE WHEN ARR_DELAY > 0 THEN 1 ELSE 0 END) as DELAYED_FLIGHTS,
    SUM(CANCELLED) as CANCELLED_FLIGHTS,
    SUM(DIVERTED) as DIVERTED_FLIGHTS,
    AVG(DISTANCE) as AVG_DISTANCE,
    
    -- On-time percentage
    ROUND(SUM(CASE WHEN ARR_DELAY <= 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as ON_TIME_PCT
    
FROM flights_raw
GROUP BY DAY_OF_WEEK, CARRIER_CODE, ORIGIN, DEST;

-- Verify aggregation
SELECT COUNT(*) as aggregated_routes FROM FLIGHTS_CLEAN;
-- Expected: 480,979 rows


-- ============================================
-- SCRIPT 5: CREATE ML TRAINING DATA
-- Purpose: Create balanced dataset for ML training
-- ============================================

-- Check cancellation distribution
SELECT 
    CANCELLED,
    COUNT(*) as flight_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM flights_raw), 2) as percentage
FROM flights_raw
GROUP BY CANCELLED;

-- Create balanced ML training dataset (50/50 split)
CREATE OR REPLACE TABLE flights_ml_data AS
WITH cancelled_flights AS (
    SELECT 
        DAY_OF_WEEK,
        OP_UNIQUE_CARRIER as CARRIER,
        ORIGIN,
        DEST,
        DISTANCE,
        1 as IS_CANCELLED
    FROM flights_raw
    WHERE CANCELLED = 1
),
not_cancelled_flights AS (
    SELECT 
        DAY_OF_WEEK,
        OP_UNIQUE_CARRIER as CARRIER,
        ORIGIN,
        DEST,
        DISTANCE,
        0 as IS_CANCELLED
    FROM flights_raw
    WHERE CANCELLED = 0
    ORDER BY RANDOM()
    LIMIT 23654  -- Match cancelled flight count
)
SELECT * FROM cancelled_flights
UNION ALL
SELECT * FROM not_cancelled_flights;

-- Verify balance
SELECT 
    IS_CANCELLED,
    COUNT(*) as count
FROM flights_ml_data
GROUP BY IS_CANCELLED;
-- Expected: ~23,654 each (total 47,308)


-- ============================================
-- SCRIPT 6: CREATE PREDICTIONS TABLE
-- Purpose: Store ML predictions after Python processing
-- ============================================

-- Create table for ML predictions
CREATE OR REPLACE TABLE flights_with_predictions (
    DAY_OF_WEEK INT,
    CARRIER VARCHAR(10),
    ORIGIN VARCHAR(10),
    DEST VARCHAR(10),
    DISTANCE FLOAT,
    FLIGHT_COUNT INT,
    CANCELLED_FLIGHTS INT,
    AVG_DEP_DELAY FLOAT,
    AVG_ARR_DELAY FLOAT,
    ON_TIME_PCT FLOAT,
    CARRIER_ENCODED INT,
    ORIGIN_ENCODED INT,
    DEST_ENCODED INT,
    CANCELLATION_PREDICTION INT,
    CANCELLATION_PROBABILITY FLOAT
);

-- Load predictions from stage (after running Python ML script)
COPY INTO flights_with_predictions
FROM @FLIGHT_STAGE/flights_with_ml_predictions.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- Verify predictions loaded
SELECT COUNT(*) FROM flights_with_predictions;


-- ============================================
-- ANALYTICAL QUERIES
-- Purpose: Example queries for data exploration
-- ============================================

-- Top 10 airports by cancellation rate
SELECT 
    ORIGIN,
    COUNT(*) as total_flights,
    SUM(CANCELLED) as cancellations,
    ROUND(SUM(CANCELLED) * 100.0 / COUNT(*), 2) as cancellation_rate
FROM flights_raw
GROUP BY ORIGIN
HAVING COUNT(*) > 1000
ORDER BY cancellation_rate DESC
LIMIT 10;

-- Cancellation rate by carrier
SELECT 
    OP_UNIQUE_CARRIER as carrier,
    COUNT(*) as total_flights,
    SUM(CANCELLED) as cancellations,
    ROUND(SUM(CANCELLED) * 100.0 / COUNT(*), 2) as cancellation_rate
FROM flights_raw
GROUP BY carrier
ORDER BY cancellation_rate DESC;

-- Cancellation rate by day of week
SELECT 
    CASE DAY_OF_WEEK
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
        WHEN 7 THEN 'Sunday'
    END as day_name,
    COUNT(*) as total_flights,
    SUM(CANCELLED) as cancellations,
    ROUND(SUM(CANCELLED) * 100.0 / COUNT(*), 2) as cancellation_rate
FROM flights_raw
GROUP BY DAY_OF_WEEK
ORDER BY DAY_OF_WEEK;
