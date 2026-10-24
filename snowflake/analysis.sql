-- Same cost comparison as the SQLite queries, written for Snowflake.
-- Upload output/policies.csv to a stage named insurance_stage, then run this.

CREATE OR REPLACE TABLE policies (
    age NUMBER,
    sex STRING,
    bmi FLOAT,
    children NUMBER,
    smoker STRING,
    region STRING,
    charges FLOAT
);

COPY INTO policies
FROM @insurance_stage/policies.csv
FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    EMPTY_FIELD_AS_NULL = TRUE
);

SELECT smoker,
       COUNT(*) AS policies,
       ROUND(AVG(charges), 2) AS avg_charges
FROM policies
GROUP BY smoker
ORDER BY avg_charges DESC;

SELECT region,
       smoker,
       COUNT(*) AS policies,
       ROUND(AVG(charges), 2) AS avg_charges
FROM policies
GROUP BY region, smoker
ORDER BY avg_charges DESC;

SELECT CASE
           WHEN age <= 29 THEN '18-29'
           WHEN age <= 44 THEN '30-44'
           ELSE '45-64'
       END AS age_band,
       smoker,
       COUNT(*) AS policies,
       ROUND(AVG(charges), 2) AS avg_charges
FROM policies
GROUP BY age_band, smoker
ORDER BY age_band, avg_charges DESC;
