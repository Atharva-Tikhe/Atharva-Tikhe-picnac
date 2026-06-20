from submit_samples import SampleSubmitter
from celery_app import run_pipeline
import sys
import pandas as pd

input_path = sys.argv[1]

df = pd.read_csv(input_path)

submitter = SampleSubmitter(input_path, "/home/atharva/dev/executions/")

for index, row in df.iterrows():
    sample_path, work_dir = submitter.make_output_dir(row["sample_id"])

    task = run_pipeline.delay(f"p_{index}", str(row["sample_id"]), str(sample_path), str(work_dir))  # type: ignore

    print(task.id)
