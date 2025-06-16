-- Add document comparisons table
CREATE TABLE IF NOT EXISTS document_comparisons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document1_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    document2_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    comparison_results JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(document1_id, document2_id)
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_document_comparisons_document1 ON document_comparisons(document1_id);
CREATE INDEX IF NOT EXISTS idx_document_comparisons_document2 ON document_comparisons(document2_id);
CREATE INDEX IF NOT EXISTS idx_document_comparisons_created_at ON document_comparisons(created_at);

-- Add trigger to update updated_at
CREATE OR REPLACE FUNCTION update_document_comparisons_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_document_comparisons_updated_at
    BEFORE UPDATE ON document_comparisons
    FOR EACH ROW
    EXECUTE FUNCTION update_document_comparisons_updated_at();
