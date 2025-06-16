-- Add compliance alerts table
CREATE TABLE IF NOT EXISTS compliance_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority VARCHAR(20) DEFAULT 'Medium' CHECK (priority IN ('Critical', 'High', 'Medium', 'Low')),
    due_date TIMESTAMP,
    type VARCHAR(50),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewing', 'reviewed', 'dismissed')),
    organization_id UUID,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Add regulatory updates table
CREATE TABLE IF NOT EXISTS regulatory_updates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    source VARCHAR(255),
    jurisdiction VARCHAR(100),
    category VARCHAR(100),
    impact VARCHAR(20) DEFAULT 'Medium' CHECK (impact IN ('Critical', 'High', 'Medium', 'Low')),
    effective_date DATE,
    summary TEXT,
    url TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Insert sample compliance alerts
INSERT INTO compliance_alerts (title, description, priority, due_date, type) VALUES
('POPIA Data Retention Review Due', 'Annual review of data retention policies required', 'High', NOW() + INTERVAL '3 days', 'deadline'),
('New B-BBEE Regulations', 'Updated B-BBEE codes effective January 2025', 'Medium', NOW() + INTERVAL '6 months', 'regulatory'),
('Contract Renewal Alert', 'Vendor agreement expires next month', 'Medium', NOW() + INTERVAL '28 days', 'contract');

-- Insert sample regulatory updates
INSERT INTO regulatory_updates (title, source, jurisdiction, category, impact, effective_date, summary) VALUES
('POPIA Amendment Bill Introduced', 'Information Regulator South Africa', 'South Africa', 'Data Privacy', 'High', '2025-03-15', 'Proposed amendments to POPIA include enhanced penalties and expanded data subject rights for cross-border data transfers.'),
('Updated B-BBEE Codes of Good Practice', 'Department of Trade, Industry and Competition', 'South Africa', 'B-BBEE', 'Medium', '2025-01-01', 'Revised B-BBEE codes introduce new measurement criteria for digital transformation and youth employment.');
