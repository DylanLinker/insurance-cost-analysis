"""Analyze a public insurance-cost file with pandas, SQL, and Excel.

Each row is one policyholder: age, sex, bmi, children, smoker, region, charges.
"""

import sqlite3
import urllib.request
from pathlib import Path

import pandas as pd
from openpyxl import Workbook
from openpyxl.chart import BarChart, Reference
from openpyxl.chart.label import DataLabelList
from openpyxl.styles import Font
from openpyxl.utils.dataframe import dataframe_to_rows
from openpyxl.worksheet.table import Table, TableStyleInfo

ROOT = Path(__file__).resolve().parent
DATA = ROOT / "data" / "insurance.csv"
DB = ROOT / "data" / "policies.sqlite"
OUTPUT = ROOT / "output"
SOURCE = (
    "https://raw.githubusercontent.com/stedy/"
    "Machine-Learning-with-R-datasets/master/insurance.csv"
)

SUMMARY_SQL = """
SELECT smoker,
       COUNT(*) AS policies,
       ROUND(AVG(charges), 2) AS avg_charges
FROM policies
GROUP BY smoker
ORDER BY avg_charges DESC
"""

REGION_SQL = """
SELECT region,
       smoker,
       COUNT(*) AS policies,
       ROUND(AVG(charges), 2) AS avg_charges
FROM policies
GROUP BY region, smoker
ORDER BY avg_charges DESC
"""


def load_policies() -> pd.DataFrame:
    DATA.parent.mkdir(parents=True, exist_ok=True)
    if not DATA.exists():
        urllib.request.urlretrieve(SOURCE, DATA)
    frame = pd.read_csv(DATA)
    expected = {"age", "sex", "bmi", "children", "smoker", "region", "charges"}
    missing = expected - set(frame.columns)
    if missing:
        raise SystemExit(f"Unexpected columns, missing {sorted(missing)}")
    frame["smoker"] = frame["smoker"].str.lower().str.strip()
    frame["region"] = frame["region"].str.lower().str.strip()
    frame["sex"] = frame["sex"].str.lower().str.strip()
    return frame


def write_database(frame: pd.DataFrame) -> None:
    if DB.exists():
        DB.unlink()
    with sqlite3.connect(DB) as connection:
        frame.to_sql("policies", connection, index=False)


def query(sql: str) -> pd.DataFrame:
    with sqlite3.connect(DB) as connection:
        return pd.read_sql_query(sql, connection)


def write_outputs(frame: pd.DataFrame) -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    frame.to_csv(OUTPUT / "policies.csv", index=False)
    write_excel(frame, OUTPUT / "policies.xlsx")


def write_excel(frame: pd.DataFrame, path: Path) -> None:
    workbook = Workbook()
    policies = workbook.active
    policies.title = "policies"
    for row in dataframe_to_rows(frame, index=False, header=True):
        policies.append(row)
    table = Table(displayName="Policies", ref=f"A1:G{len(frame) + 1}")
    table.tableStyleInfo = TableStyleInfo(name="TableStyleMedium2", showRowStripes=True)
    policies.add_table(table)
    for column in policies.columns:
        policies.column_dimensions[column[0].column_letter].width = 14

    summary = workbook.create_sheet("summary", 0)
    summary["A1"] = "Insurance cost summary"
    summary["A1"].font = Font(bold=True, size=14)
    summary["A3"] = "smoker"
    summary["B3"] = "policies"
    summary["C3"] = "average charges"
    for cell in ("A3", "B3", "C3"):
        summary[cell].font = Font(bold=True)
    summary["A4"] = "yes"
    summary["B4"] = '=COUNTIF(Policies[smoker],"yes")'
    summary["C4"] = '=AVERAGEIF(Policies[smoker],"yes",Policies[charges])'
    summary["A5"] = "no"
    summary["B5"] = '=COUNTIF(Policies[smoker],"no")'
    summary["C5"] = '=AVERAGEIF(Policies[smoker],"no",Policies[charges])'
    summary["A7"] = "smoker multiple"
    summary["C7"] = "=C4/C5"
    summary["C4"].number_format = '"$"#,##0.00'
    summary["C5"].number_format = '"$"#,##0.00'
    summary["C7"].number_format = "0.00"
    summary.column_dimensions["A"].width = 20
    summary.column_dimensions["B"].width = 14
    summary.column_dimensions["C"].width = 20

    chart = BarChart()
    chart.type = "col"
    chart.title = "Average charges by smoking status"
    chart.y_axis.title = "Average charges"
    data = Reference(summary, min_col=3, min_row=3, max_row=5)
    categories = Reference(summary, min_col=1, min_row=4, max_row=5)
    chart.add_data(data, titles_from_data=True)
    chart.set_categories(categories)
    chart.shape = 4
    chart.dataLabels = DataLabelList()
    chart.dataLabels.showVal = False
    chart.legend = None
    summary.add_chart(chart, "A9")
    workbook.save(path)


def main() -> None:
    frame = load_policies()
    write_database(frame)
    write_outputs(frame)
    by_smoker = query(SUMMARY_SQL)
    by_region = query(REGION_SQL)

    yes = by_smoker.loc[by_smoker["smoker"] == "yes", "avg_charges"].iloc[0]
    no = by_smoker.loc[by_smoker["smoker"] == "no", "avg_charges"].iloc[0]
    print(f"policies {len(frame)}")
    print(by_smoker.to_string(index=False))
    print(f"smoker_to_nonsmoker_ratio {yes / no:.2f}")
    print(by_region.to_string(index=False))
    print(f"wrote {OUTPUT / 'policies.csv'}")
    print(f"wrote {OUTPUT / 'policies.xlsx'}")


if __name__ == "__main__":
    main()
