ALTER TABLE detections
    DROP COLUMN IF EXISTS source_name,
    DROP COLUMN IF EXISTS frame_number,
    DROP COLUMN IF EXISTS model_name,
    DROP COLUMN IF EXISTS class_id,
    DROP COLUMN IF EXISTS metadata;

ALTER INDEX IF EXISTS idx_detections_label RENAME TO idx_detections_class_name;