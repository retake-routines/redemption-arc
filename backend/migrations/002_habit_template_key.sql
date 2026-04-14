-- Optional stable id for habits created from app templates (sport, water, ...).
ALTER TABLE habits
    ADD COLUMN IF NOT EXISTS template_key VARCHAR(64) NULL DEFAULT NULL;

-- At most one non-archived habit per user per template.
CREATE UNIQUE INDEX IF NOT EXISTS idx_habits_user_template_active
    ON habits (user_id, template_key)
    WHERE template_key IS NOT NULL AND template_key <> '' AND is_archived = FALSE;
