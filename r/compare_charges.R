# Compare billed charges by smoking status.
# From the project folder, after python analyze.py:
#   Rscript r/compare_charges.R
#
# t.test uses the Welch two-sample test. Smoker and non-smoker means
# should land near $32,050 and $8,434, a ratio of about 3.8.

policies <- read.csv("output/policies.csv", stringsAsFactors = FALSE)
policies$smoker <- tolower(trimws(policies$smoker))

summary_by_smoker <- aggregate(
  charges ~ smoker,
  policies,
  function(charges) c(policies = length(charges), avg_charges = round(mean(charges), 2))
)
print(summary_by_smoker)

smokers <- policies$charges[policies$smoker == "yes"]
others <- policies$charges[policies$smoker == "no"]
cat(sprintf("smoker_to_nonsmoker_ratio %.2f\n", mean(smokers) / mean(others)))

nonsmokers <- subset(policies, smoker == "no")
region_avg <- aggregate(charges ~ region, nonsmokers, mean)
region_span <- max(region_avg$charges) - min(region_avg$charges)
cat(sprintf("nonsmoker_region_span %.0f\n", region_span))

result <- t.test(smokers, others)
print(result)
