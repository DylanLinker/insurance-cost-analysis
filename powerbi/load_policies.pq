let
    Source = Csv.Document(
        File.Contents("output/policies.csv"),
        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    Typed = Table.TransformColumnTypes(
        Promoted,
        {
            {"age", Int64.Type},
            {"sex", type text},
            {"bmi", type number},
            {"children", Int64.Type},
            {"smoker", type text},
            {"region", type text},
            {"charges", type number}
        }
    ),
    Banded = Table.AddColumn(
        Typed,
        "age_band",
        each if [age] <= 29 then "18-29" else if [age] <= 44 then "30-44" else "45-64",
        type text
    )
in
    Banded
