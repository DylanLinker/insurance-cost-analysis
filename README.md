# Insurance cost analysis

Which policyholder trait concentrates cost, and what should be reviewed first?

The file is a public set of 1,338 policyholders with age, sex, BMI, children, smoking status, region, and billed charges. One script cleans that file and writes the same table for pandas, SQL, and Excel.

## Result

Smokers average **$32,050** in charges. Non-smokers average **$8,434**. That is **3.8x**.

Region is a much smaller gap. Among non-smokers, regional averages run from about $8,019 to $9,166. Among smokers, the southeast is highest at $34,845 and the northeast is lowest at $29,674.

Review smoking status before region. A regional price change would miss the gap that drives the average.

## Run it

```powershell
python -m pip install -r requirements.txt
python analyze.py
```

That does three things:

- Loads and cleans the file with pandas.
- Writes a SQLite database and runs `sql/cost_by_smoker.sql` and `sql/cost_by_region.sql`.
- Writes `output/policies.csv` and `output/policies.xlsx`. The workbook's summary sheet uses `COUNTIF` and `AVERAGEIF` on the policy table, plus a column chart of average charges.

## Layout

- `analyze.py` cleans the file and builds the database, CSV, and workbook.
- `sql/` holds the queries.
- `output/` is the cleaned table and the Excel workbook.

Power BI and Snowflake are not part of this project.
