# Insurance cost analysis

Which policyholder trait concentrates cost, and what should be reviewed first?

The file is a public set of 1,338 policyholders with age, sex, BMI, children, smoking status, region, and billed charges. One script cleans that file and writes the same table for pandas, SQL, Excel, Power BI, and Snowflake.

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

## Power BI

1. In Power BI Desktop, get data from `output/policies.csv`. Name the table `policies`.
2. Paste `powerbi/load_policies.pq` into the Advanced Editor if you want the typed query. Point `File.Contents` at that CSV.
3. Create the measures in `powerbi/measures.dax`. `Smoker Multiple` should be about 3.8. Put smoking status on a bar chart of average charges.

## Snowflake

Upload `output/policies.csv` to a stage named `insurance_stage`, then run `snowflake/analysis.sql`. The two selects match the SQLite queries: smokers near $32,050, non-smokers near $8,434.

## Layout

- `analyze.py` cleans the file and builds the database, CSV, and workbook.
- `sql/` holds the SQLite queries.
- `output/` is the cleaned table and the Excel workbook.
- `powerbi/` holds the Power Query and DAX measures.
- `snowflake/analysis.sql` is the warehouse script.
