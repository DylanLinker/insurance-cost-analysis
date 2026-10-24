-- Average billed charges by age band and smoking status.
-- Bands are 18-29, 30-44, and 45-64.

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
