-- Average billed charges by region and smoking status.

SELECT region,
       smoker,
       COUNT(*) AS policies,
       ROUND(AVG(charges), 2) AS avg_charges
FROM policies
GROUP BY region, smoker
ORDER BY avg_charges DESC;
