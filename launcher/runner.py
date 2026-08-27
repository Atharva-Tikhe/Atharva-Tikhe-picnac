from submit_samples import SampleSubmitter
from celery_app import run_pipeline
import sys
import pandas as pd
import uuid

input_path = sys.argv[1]
output_path = sys.argv[2]
threshold = sys.argv[3]
cohort_id = uuid.UUID(sys.argv[4])


df = pd.read_csv(input_path)

submitter = SampleSubmitter(input_path, f"/home/atharva/dev/executions/{output_path}/")

for index, row in df.iterrows():
    sample_path, work_dir = submitter.make_output_dir(row["sample_id"])

    if threshold == "default":
        task = run_pipeline.delay(f"p_{index}", str(row["sample_id"]), str(sample_path), str(work_dir), "-0.2", str(cohort_id))  # type: ignore
    else:
        task = run_pipeline.delay(f"p_{index}", str(row["sample_id"]), str(sample_path), str(work_dir), threshold, str(cohort_id))  # type: ignore

    print(row["sample_id"], task.id, sep="\t")
