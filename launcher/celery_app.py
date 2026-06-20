from celery import Celery
import redis
import json
import subprocess
import pandas as pd
from submit_samples import SampleSubmitter
from pathlib import Path
import os

celery = Celery(
    "pipeline", broker="redis://localhost:6379/0", backend="redis://localhost:6379/1"
)

celery.conf.update(task_track_started=True, result_expires=3600)


@celery.task
def run_pipeline(pipeline_id, sample_id, sample_path, work_dir):
    # queue_emit(pipeline_id, "submitted")

    cwd = os.getcwd()

    print(f"submitting {sample_id}")

    os.chdir(sample_path)

    sample_path = Path(sample_path)

    command = f"/usr/bin/bash nextflow /home/atharva/dev/pipeline/Atharva-Tikhe-picnac/main.nf --outdir {sample_path} -work-dir {work_dir}  --pipeline_id '{pipeline_id}' --input {sample_path / 'samplesheet.csv'} "

    process = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        shell=True,
    )

    # queue_emit(pipeline_id, "running")

    for line in process.stderr:  # type: ignore
        print(f"CELERY WORKER ERROR: {line}")

    process.wait()
    os.chdir(cwd)

    # queue_emit(pipeline_id, "completed", {"exit_code": process.returncode})
