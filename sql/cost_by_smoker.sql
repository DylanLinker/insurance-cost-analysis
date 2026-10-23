-- Average billed charges by smoking status.

SELECT smoker,
       COUNT(*) AS policies,
       ROUND(AVG(charges), 2) AS avg_charges
FROM policies
GROUP BY smoker
ORDER BY avg_charges DESC;
