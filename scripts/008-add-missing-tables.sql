-- Create compliance_alerts table if it doesn't exist
CREATE TABLE IF NOT EXISTS compliance_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority VARCHAR(20) NOT NULL CHECK (priority IN ('Critical', 'High', 'Medium', 'Low')),
    due_date DATE,
    type VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'dismissed', 'resolved')),
    regulation_source VARCHAR(100),
    jurisdiction VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert sample compliance alerts
INSERT INTO compliance_alerts (title, description, priority, due_date, type, regulation_source, jurisdiction) VALUES
('POPIA Data Retention Review Due', 'Annual review of data retention policies required under POPIA regulations', 'High', CURRENT_DATE + INTERVAL '3 days', 'deadline', 'POPIA', 'South Africa'),
('New B-BBEE Regulations', 'Updated B-BBEE codes effective January 2025 - review and update compliance procedures', 'Medium', CURRENT_DATE + INTERVAL '6 months', 'regulatory', 'B-BBEE', 'South Africa'),
('Contract Renewal Alert', 'Vendor agreement expires next month - review terms and conditions', 'Medium', CURRENT_DATE + INTERVAL '28 days', 'contract', 'Internal', 'South Africa'),
('GDPR Compliance Audit', 'Quarterly GDPR compliance audit required for EU data processing', 'High', CURRENT_DATE + INTERVAL '14 days', 'audit', 'GDPR', 'European Union'),
('Labour Relations Act Update', 'New amendments to Labour Relations Act require policy updates', 'Critical', CURRENT_DATE + INTERVAL '7 days', 'regulatory', 'LRA', 'South Africa');

-- Create other missing tables for full functionality
CREATE TABLE IF NOT EXISTS depositions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_name VARCHAR(255) NOT NULL,
    deponent_name VARCHAR(255) NOT NULL,
    date_conducted DATE NOT NULL,
    transcript_path TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert sample depositions
INSERT INTO depositions (case_name, deponent_name, date_conducted, status) VALUES
('Smith vs. ABC Corp', 'John Smith', '2024-01-15', 'completed'),
('Estate Planning Matter', 'Mary Johnson', '2024-01-20', 'completed'),
('Contract Dispute Case', 'Robert Wilson', '2024-01-25', 'pending');

CREATE TABLE IF NOT EXISTS case_timelines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_name VARCHAR(255) NOT NULL,
    timeline_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS compliance_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_name VARCHAR(255) NOT NULL,
    report_type VARCHAR(50) NOT NULL,
    generated_date DATE DEFAULT CURRENT_DATE,
    file_path TEXT,
    status VARCHAR(20) DEFAULT 'generated',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert sample compliance reports
INSERT INTO compliance_reports (report_name, report_type, status) VALUES
('Q4 2024 POPIA Compliance Report', 'popia', 'generated'),
('Annual B-BBEE Status Report', 'bbbee', 'generated'),
('GDPR Data Processing Audit', 'gdpr', 'generated');

COMMENT ON TABLE compliance_alerts IS 'Stores compliance alerts and deadlines';
COMMENT ON TABLE depositions IS 'Stores deposition information and transcripts';
COMMENT ON TABLE case_timelines IS 'Stores generated case timelines';
COMMENT ON TABLE compliance_reports IS 'Stores generated compliance reports';
