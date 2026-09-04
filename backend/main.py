import os
from contextlib import asynccontextmanager
from typing import Any

import psycopg
from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel, Field
from psycopg.types.json import Jsonb


DATABASE_URL = os.environ["DATABASE_URL"]


class DetectionCreate(BaseModel):
    source_name: str | None = None
    frame_number: int | None = Field(default=None, ge=0)
    model_name: str = "yolo26n"
    class_id: int = Field(ge=0)
    class_name: str
    confidence: float = Field(ge=0, le=1)
    bbox: dict[str, float]
    metadata: dict[str, Any] = Field(default_factory=dict)


def row_to_detection(row: tuple[Any, ...]) -> dict[str, Any]:
    return {
        "id": row[0],
        "source_name": row[1],
        "frame_number": row[2],
        "model_name": row[3],
        "class_id": row[4],
        "class_name": row[5],
        "confidence": row[6],
        "bbox": row[7],
        "detected_at": row[8].isoformat(),
        "metadata": row[9],
    }


@asynccontextmanager
async def lifespan(_: FastAPI):
    with psycopg.connect(DATABASE_URL) as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
    yield


app = FastAPI(title="Detector de objetos API", version="1.0.0", lifespan=lifespan)


@app.get("/")
def root() -> dict[str, Any]:
    return {
        "service": "detector-objetos-backend",
        "status": "ok",
        "docs": "/docs",
        "health": "/api/health",
        "detections": "/api/detections",
    }


@app.get("/api/health")
def health() -> dict[str, str]:
    try:
        with psycopg.connect(DATABASE_URL) as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
    except psycopg.Error as error:
        raise HTTPException(status_code=503, detail="PostgreSQL no disponible") from error
    return {"status": "ok", "database": "connected"}


@app.post("/api/detections", status_code=201)
def create_detection(detection: DetectionCreate) -> dict[str, Any]:
    query = """
        INSERT INTO detections (
            source_name, frame_number, model_name, class_id, class_name,
            confidence, bbox, metadata
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        RETURNING id, source_name, frame_number, model_name, class_id,
                  class_name, confidence, bbox, detected_at, metadata
    """
    try:
        with psycopg.connect(DATABASE_URL) as connection:
            with connection.cursor() as cursor:
                cursor.execute(
                    query,
                    (
                        detection.source_name,
                        detection.frame_number,
                        detection.model_name,
                        detection.class_id,
                        detection.class_name,
                        detection.confidence,
                        Jsonb(detection.bbox),
                        Jsonb(detection.metadata),
                    ),
                )
                row = cursor.fetchone()
    except psycopg.Error as error:
        raise HTTPException(status_code=500, detail="No se pudo guardar la detección") from error
    return row_to_detection(row)


@app.get("/api/detections")
def list_detections(
    limit: int = Query(default=100, ge=1, le=500),
    offset: int = Query(default=0, ge=0),
) -> dict[str, Any]:
    query = """
        SELECT id, source_name, frame_number, model_name, class_id,
               class_name, confidence, bbox, detected_at, metadata
        FROM detections
        ORDER BY detected_at DESC, id DESC
        LIMIT %s OFFSET %s
    """
    with psycopg.connect(DATABASE_URL) as connection:
        with connection.cursor() as cursor:
            cursor.execute(query, (limit, offset))
            rows = cursor.fetchall()
    return {"items": [row_to_detection(row) for row in rows], "limit": limit, "offset": offset}