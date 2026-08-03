import pandas as pd

paths = pd.read_csv("./b1_paths.txt", header=None)

batch_meta = pd.read_csv("./assets/batch_records.csv")

sample_id = []
for index, row in paths.iterrows():
    sample_id.append(row[0].split("/")[-1])

pd.concat([paths, sample_id])
paths["sample_id"] = sample_id
paths["batch"] = 1
paths.rename({0: "parent_folder"}, axis=1, inplace=True)
batch_meta.merge(paths, on="batch")
paths.merge(batch_meta, on="batch")
result = paths.merge(batch_meta, on="batch")
result["id"] = result.index
result.to_csv("samplesheet_b1.csv", index=False)
result["id"] = result.index + 1
result.drop("id", inplace=True)
result.drop("id", inplace=True, axis=1)
result["id"] = result.index + 1
result["platform"] = "Illumina"
result["array"] = "CytoSNP-850Kv1"
result.to_csv("samplesheet_b1.csv", index=False)
