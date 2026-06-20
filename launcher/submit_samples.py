import os
from datetime import datetime
from pathlib import Path
import pandas as pd


class SampleSubmitter:
    def __init__(self, csv_path, output_root):
        self.csv_path = Path(csv_path)
        self.df = pd.read_csv(self.csv_path)
        self.output_root = Path(output_root)

        # for sample in self.df["sample_id"]:
        #     # print(sample)
        #     sample_path = self.make_output_dir(sample)
        #     print(sample_path / "work")

    def make_output_dir(self, sample_id):
        date = str(datetime.today().date())
        sample_row = self.df[self.df["sample_id"] == sample_id]
        sample_path = Path(
            self.output_root / date / str(sample_row["sample_id"].values[0])
        )
        work_dir = Path(
            self.output_root / date / str(sample_row["sample_id"].values[0]) / "work"
        )

        os.makedirs(sample_path, exist_ok=True)
        os.makedirs(work_dir, exist_ok=True)
        sample_row.to_csv(sample_path / "samplesheet.csv", index=False)

        return sample_path, work_dir


# obj = SampleSubmitter(
#     "./test_csv.csv", "/Users/atharvatikhe/Dev/pipeline_launcher/outputs/"
# )
# obj.make_output_dir(2207)


# def run_pipeline(pipeline_id, input):
#     # queue_emit(pipeline_id, "submitted")
#
#     df = pd.read_csv(input)
#     submitter = SampleSubmitter(input, "/home/atharva/dev/executions/")
#     cwd = os.getcwd()
#
#     for index, row in df.iterrows():
#         print(f'submitting {row["sample_id"]}')
#         sample_path, work_dir = submitter.make_output_dir(row["sample_id"])
#
#         os.chdir(sample_path)
#
#         command = f"/usr/bin/bash nextflow /home/atharva/dev/pipeline/Atharva-Tikhe-picnac/main.nf --outdir {sample_path} -work-dir {work_dir}  --pipeline_id '{pipeline_id}' --input {sample_path / 'samplesheet.csv'} "
#
#         os.chdir(cwd)
#

# run_pipeline(
#     "1234", "/home/atharva/dev/pipeline/Atharva-Tikhe-picnac/samplesheet_w_batch.csv"
# )
