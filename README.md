# Insurance cost analysis

Which policyholder trait concentrates cost, and what should be reviewed first?

The file is a public set of 1,338 policyholders with age, sex, BMI, children, smoking status, region, and billed charges. One script cleans that file and writes the same table for pandas, SQL, Excel, Power BI, Snowflake, R, and SAS.

## Result

Smokers average **$32,050** in charges. Non-smokers average **$8,434**. That is **3.8x**.

Region is a much smaller gap. Among non-smokers, regional averages run from about $8,019 to $9,166. Among smokers, the southeast is highest at $34,845 and the northeast is lowest at $29,674.

Review smoking status before region. A regional price change would miss the gap that drives the average.

A Welch two-sample test on the same file gives t = 32.75 on about 312 degrees of freedom. The smoker mean sits about $23,616 above the non-smoker mean. Among non-smokers, the regional averages span about $1,146. The smoking gap is the one that holds up.

Medians are farther apart than the means: about $34,456 for smokers and $7,345 for non-smokers. A few large bills do not create the gap.

The same gap shows up in every age band. Average charges:

| Age | Non-smoker | Smoker |
| --- | ---: | ---: |
| 18–29 | $4,419 (331) | $27,518 (86) |
| 30–44 | $6,945 (301) | $30,834 (91) |
| 45–64 | $12,549 (432) | $37,209 (97) |

A linear model holding age, BMI, sex, children, and region constant still prices smoking at about $23,849. Ten more years of age add about $2,569. The model explains about 75% of the variation in charges. Northeast is the region baseline.

## Run it

```powershell
python -m pip install -r requirements.txt
python analyze.py
```

That does three things:

- Loads and cleans the file with pandas.
- Writes a SQLite database and runs `sql/cost_by_smoker.sql` and `sql/cost_by_region.sql`.
- Writes `output/policies.csv` and `output/policies.xlsx`. The summary sheet uses `COUNTIF` and `AVERAGEIF`, plus a column chart. The age-band sheet uses `COUNTIFS` and `AVERAGEIFS`. The script also prints the regression: smoking near $23,849, and about $2,569 for 10 years of age.

## Power BI

1. In Power BI Desktop, get data from `output/policies.csv`. Name the table `policies`.
2. Paste `powerbi/load_policies.pq` into the Advanced Editor if you want the typed query. Point `File.Contents` at that CSV.
3. Create the measures in `powerbi/measures.dax`. `Smoker Multiple` should be about 3.8. Put smoking status on a bar chart of average charges. The query also adds `age_band` for a matrix of average charges by age and smoking status.

## Snowflake

Upload `output/policies.csv` to a stage named `insurance_stage`, then run `snowflake/analysis.sql`. The selects match the SQLite queries, including average charges by age band.

## R

From the project folder, after `analyze.py`:

```powershell
Rscript r/compare_charges.R
```

`t.test` runs the Welch comparison. `lm` then holds age, BMI, sex, children, and region constant. The smoking coefficient should land near $23,849.

## SAS

Open `sas/compare_charges.sas` in SAS Studio or the local client, with the working folder set to this project. `PROC TTEST` prints the pooled and Satterthwaite rows. Use the Satterthwaite row. It is the same Welch test. `PROC GLM` fits the same adjusted model.

## Layout

- `analyze.py` cleans the file and builds the database, CSV, and workbook.
- `sql/` holds the SQLite queries, including age band.
- `output/` is the cleaned table and the Excel workbook.
- `powerbi/` holds the Power Query and DAX measures.
- `snowflake/analysis.sql` is the warehouse script.
- `r/compare_charges.R` is the Welch comparison.
- `sas/compare_charges.sas` is the same comparison in PROC TTEST.
