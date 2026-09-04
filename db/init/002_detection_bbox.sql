DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'detections' AND column_name = 'label'
    ) THEN
        ALTER TABLE detections RENAME COLUMN label TO class_name;
    END IF;
END $$;

ALTER TABLE detections ADD COLUMN IF NOT EXISTS bbox JSONB;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'detections' AND column_name = 'x1'
    ) THEN
        UPDATE detections
        SET bbox = jsonb_build_object('x1', x1, 'y1', y1, 'x2', x2, 'y2', y2)
        WHERE bbox IS NULL;
    END IF;
END $$;

UPDATE detections SET bbox = '{}'::jsonb WHERE bbox IS NULL;

ALTER TABLE detections
    ALTER COLUMN bbox SET DEFAULT '{}'::jsonb,
    ALTER COLUMN bbox SET NOT NULL;

ALTER TABLE detections
    DROP CONSTRAINT IF EXISTS detections_check,
    DROP CONSTRAINT IF EXISTS detections_check1,
    DROP CONSTRAINT IF EXISTS detections_x1_check,
    DROP CONSTRAINT IF EXISTS detections_y1_check;

ALTER TABLE detections
    DROP COLUMN IF EXISTS x1,
    DROP COLUMN IF EXISTS y1,
    DROP COLUMN IF EXISTS x2,
    DROP COLUMN IF EXISTS y2;

ALTER TABLE detections
    DROP CONSTRAINT IF EXISTS detections_bbox_object_check;

ALTER TABLE detections
    ADD CONSTRAINT detections_bbox_object_check
    CHECK (jsonb_typeof(bbox) = 'object');

ALTER INDEX IF EXISTS idx_detections_label RENAME TO idx_detections_class_name;