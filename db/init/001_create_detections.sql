CREATE TABLE IF NOT EXISTS detections (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    class_name TEXT NOT NULL,
    confidence REAL NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
    bbox JSONB NOT NULL CHECK (jsonb_typeof(bbox) = 'object'),
    detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_detections_detected_at
    ON detections (detected_at DESC);

CREATE INDEX IF NOT EXISTS idx_detections_class_name
    ON detections (class_name);