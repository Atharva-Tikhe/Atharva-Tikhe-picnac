import pandas as pd

batch_meta = pd.read_csv("./assets/batch_records.csv")

paths = pd.read_csv("./b6_paths.csv", header=None)

paths.rename({0: "parent_folder"}, axis=1, inplace=True)
sample_ids = []
for idx, row in paths.iterrows():
    sample_ids.append(row["parent_folder"].split("/")[-1])

paths["sample_id"] = sample_ids
paths["id"] = paths.index + 1

paths = paths.iloc[:, [2, 1, 0]]

paths["platform"] = "Illumina"
paths["array"] = "CytoSNP 850K"
paths["batch"] = 6


result = paths.merge(batch_meta, on="batch")
result.to_csv("samplesheet_b6.csv", index=False)
