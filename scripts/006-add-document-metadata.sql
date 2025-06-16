-- Add missing columns to documents table for better functionality
ALTER TABLE documents 
ADD COLUMN IF NOT EXISTS clauses_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS pages_count INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS risk_level VARCHAR(20) DEFAULT 'medium';

-- Update existing documents with default values
UPDATE documents 
SET 
  clauses_count = 0,
  pages_count = 1,
  risk_level = 'medium'
WHERE clauses_count IS NULL OR pages_count IS NULL OR risk_level IS NULL;

-- Add some sample risk levels based on document type
UPDATE documents 
SET risk_level = CASE 
  WHEN type = 'contract' THEN 'high'
  WHEN type = 'policy' THEN 'medium'
  WHEN type = 'memo' THEN 'low'
  ELSE 'medium'
END;

-- Add some sample clause counts based on document type
UPDATE documents 
SET clauses_count = CASE 
  WHEN type = 'contract' THEN FLOOR(RANDOM() * 20) + 5
  WHEN type = 'policy' THEN FLOOR(RANDOM() * 10) + 2
  WHEN type = 'memo' THEN FLOOR(RANDOM() * 3) + 1
  ELSE FLOOR(RANDOM() * 5) + 1
END;

-- Add some sample page counts
UPDATE documents 
SET pages_count = CASE 
  WHEN type = 'contract' THEN FLOOR(RANDOM() * 50) + 10
  WHEN type = 'policy' THEN FLOOR(RANDOM() * 20) + 5
  WHEN type = 'memo' THEN FLOOR(RANDOM() * 5) + 1
  ELSE FLOOR(RANDOM() * 10) + 1
END;
