CREATE TABLE IF NOT EXISTS detections (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_name TEXT,
    frame_number INTEGER,
    model_name TEXT NOT NULL DEFAULT 'yolo26n',
    class_id INTEGER NOT NULL CHECK (class_id >= 0),
    label TEXT NOT NULL,
    confidence REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
    x1 REAL NOT NULL CHECK (x1 >= 0),
    y1 REAL NOT NULL CHECK (y1 >= 0),
    x2 REAL NOT NULL CHECK (x2 >= x1),
    y2 REAL NOT NULL CHECK (y2 >= y1),
    detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_detections_detected_at
    ON detections (detected_at DESC);

CREATE INDEX IF NOT EXISTS idx_detections_label
    ON detections (label);