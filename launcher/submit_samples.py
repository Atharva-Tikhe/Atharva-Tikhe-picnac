import os
from pathlib import Path
import pandas as pd


class SampleSubmitter:
    def __init__(self, csv_path, output_root):
        self.csv_path = Path(csv_path)
        self.df = pd.read_csv(self.csv_path)
        self.output_root = Path(output_root)

    def make_output_dir(self, sample_id):
        sample_row = self.df[self.df["sample_id"] == sample_id]
        sample_path = Path(self.output_root / str(sample_row["sample_id"].values[0]))
        work_dir = Path(
            self.output_root / str(sample_row["sample_id"].values[0]) / "work"
        )

        os.makedirs(sample_path, exist_ok=True)
        os.makedirs(work_dir, exist_ok=True)
        sample_row.to_csv(sample_path / "samplesheet.csv", index=False)

        return sample_path, work_dir


# obj = SampleSubmitter(
#     "./test_csv.csv", "/Users/atharvatikhe/Dev/pipeline_launcher/outputs/"
# )
# obj.make_output_dir(2207)
