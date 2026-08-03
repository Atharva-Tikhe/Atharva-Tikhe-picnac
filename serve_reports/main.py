from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse, FileResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import pandas as pd
import json
from datetime import datetime
import os

BASE_REPORTS_DIR = os.path.abspath(r"/home/atharva/dev/executions/2026-06-20/")


class MetadataRequest(BaseModel):
    target: str


class InterpretationRequest(BaseModel):
    sample_id: str
    interpretation: str


app = FastAPI()

app.mount("/static", StaticFiles(directory="static"), name="static")

origins = [
    "http://localhost:5173",  # Your Vite React app's local address
    "http://daedalus.ncl.ac.uk:5173",
    "http://daedalus.ncl.ac.uk:3000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],  # Allows all HTTP methods (GET, POST, PUT, DELETE, etc.)
    allow_headers=["*"],  # Allows all headers
)


@app.get("/executions/{sample_id}/reports/html")
async def get_execution_report(sample_id: str):
    # 1. Construct the absolute path to the requested HTML file
    file_path = os.path.join(BASE_REPORTS_DIR, sample_id, "report", "report.html")
    print(file_path)

    # Security Check: Prevent Directory Traversal attacks (e.g., sample_id = "../../../etc/passwd")
    if not os.path.abspath(file_path).startswith(BASE_REPORTS_DIR):
        raise HTTPException(status_code=400, detail="Invalid sample_id")

    # 2. Check if the file actually exists on the disk
    if not os.path.exists(file_path):
        raise HTTPException(
            status_code=404, detail="Report not found for this sample ID"
        )

    # 3. Return the file directly. FastAPI will handle the correct Content-Type (text/html)
    return FileResponse(file_path)


@app.get("/executions/{sample_id}/reports/tsv")
async def get_execution_report_tsv(sample_id: str):
    # 1. Construct the absolute path to the requested HTML file
    file_path = os.path.join(BASE_REPORTS_DIR, sample_id, "report", "results.tsv")

    # Security Check: Prevent Directory Traversal attacks (e.g., sample_id = "../../../etc/passwd")
    if not os.path.abspath(file_path).startswith(BASE_REPORTS_DIR):
        raise HTTPException(status_code=400, detail="Invalid sample_id")

    # 2. Check if the file actually exists on the disk
    if not os.path.exists(file_path):
        raise HTTPException(
            status_code=404, detail="Report not found for this sample ID"
        )

    # 3. Return the file directly. FastAPI will handle the correct Content-Type (text/html)
    return FileResponse(file_path)


@app.get("/version")
def send_ver():
    return JSONResponse({"version": "0.0.1"})


@app.post("/sample/metadata")
def send_meta(target: MetadataRequest):
    print(target)
    df = pd.read_csv("./b1_CIMS.csv")
    meta = df[df["RegId"] == int(target.target)].to_json()
    return {"meta": meta}


@app.get("/samples")
def send_sample():
    df = pd.read_csv("./b1_CIMS.csv")
    meta = df["RegId"].unique().tolist()
    print(meta)
    return {"samples": meta}


@app.get("/samples/batch/1")
def send_batch_wise():
    return JSONResponse(json.load(open("./samples_b1.json", "r")))


@app.post("/samples/interpretation/")
def get_interpretation(req: InterpretationRequest):
    sample = req.sample_id
    data = req.interpretation
    print(data, sample)

    with open(f"./static/interpretations/{sample}.txt", "a") as f:
        f.writelines([str(datetime.now()), "\t", data, str("\n")])

    return JSONResponse({"status": "ok"})
