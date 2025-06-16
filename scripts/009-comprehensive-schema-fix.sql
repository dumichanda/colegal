-- ============================================================================
-- COMPREHENSIVE SCHEMA FIX FOR LEGAL AI APPLICATION
-- This script creates all missing tables and ensures proper relationships
-- ============================================================================

-- Drop existing tables if they exist (for clean setup)
DROP TABLE IF EXISTS compliance_alerts CASCADE;
DROP TABLE IF EXISTS depositions CASCADE;
DROP TABLE IF EXISTS case_timelines CASCADE;
DROP TABLE IF EXISTS compliance_reports CASCADE;
DROP TABLE IF EXISTS deposition_analyses CASCADE;
DROP TABLE IF EXISTS timeline_events CASCADE;

-- ============================================================================
-- 1. COMPLIANCE ALERTS TABLE
-- ============================================================================
CREATE TABLE compliance_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority VARCHAR(20) NOT NULL CHECK (priority IN ('Critical', 'High', 'Medium', 'Low')),
    due_date DATE,
    type VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'dismissed', 'resolved')),
    regulation_source VARCHAR(100),
    jurisdiction VARCHAR(50),
    organization_id UUID REFERENCES organizations(id),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_compliance_alerts_status ON compliance_alerts(status);
CREATE INDEX idx_compliance_alerts_priority ON compliance_alerts(priority);
CREATE INDEX idx_compliance_alerts_due_date ON compliance_alerts(due_date);
CREATE INDEX idx_compliance_alerts_organization ON compliance_alerts(organization_id);

-- ============================================================================
-- 2. DEPOSITIONS TABLE
-- ============================================================================
CREATE TABLE depositions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_name VARCHAR(255) NOT NULL,
    case_number VARCHAR(100),
    deponent_name VARCHAR(255) NOT NULL,
    deponent_role VARCHAR(100),
    date_conducted DATE NOT NULL,
    location VARCHAR(255),
    transcript_path TEXT,
    transcript_content TEXT,
    duration_minutes INTEGER,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    organization_id UUID REFERENCES organizations(id),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_depositions_status ON depositions(status);
CREATE INDEX idx_depositions_date ON depositions(date_conducted);
CREATE INDEX idx_depositions_organization ON depositions(organization_id);

-- ============================================================================
-- 3. DEPOSITION ANALYSES TABLE
-- ============================================================================
CREATE TABLE deposition_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    deposition_id UUID NOT NULL REFERENCES depositions(id) ON DELETE CASCADE,
    analysis_type VARCHAR(50) NOT NULL,
    key_points JSONB,
    inconsistencies JSONB,
    credibility_assessment JSONB,
    follow_up_questions JSONB,
    confidence_score DECIMAL(3,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_deposition_analyses_deposition ON deposition_analyses(deposition_id);

-- ============================================================================
-- 4. CASE TIMELINES TABLE
-- ============================================================================
CREATE TABLE case_timelines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_name VARCHAR(255) NOT NULL,
    case_number VARCHAR(100),
    timeline_data JSONB NOT NULL,
    document_ids UUID[],
    organization_id UUID REFERENCES organizations(id),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_case_timelines_organization ON case_timelines(organization_id);
CREATE INDEX idx_case_timelines_case_name ON case_timelines(case_name);

-- ============================================================================
-- 5. TIMELINE EVENTS TABLE
-- ============================================================================
CREATE TABLE timeline_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    timeline_id UUID NOT NULL REFERENCES case_timelines(id) ON DELETE CASCADE,
    event_date DATE NOT NULL,
    event_title VARCHAR(255) NOT NULL,
    event_description TEXT,
    event_type VARCHAR(50),
    document_reference UUID REFERENCES documents(id),
    importance_level INTEGER DEFAULT 1 CHECK (importance_level BETWEEN 1 AND 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_timeline_events_timeline ON timeline_events(timeline_id);
CREATE INDEX idx_timeline_events_date ON timeline_events(event_date);

-- ============================================================================
-- 6. COMPLIANCE REPORTS TABLE
-- ============================================================================
CREATE TABLE compliance_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_name VARCHAR(255) NOT NULL,
    report_type VARCHAR(50) NOT NULL,
    report_data JSONB,
    generated_date DATE DEFAULT CURRENT_DATE,
    file_path TEXT,
    status VARCHAR(20) DEFAULT 'generated' CHECK (status IN ('generating', 'generated', 'failed')),
    organization_id UUID REFERENCES organizations(id),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_compliance_reports_type ON compliance_reports(report_type);
CREATE INDEX idx_compliance_reports_organization ON compliance_reports(organization_id);

-- ============================================================================
-- 7. SEED DATA FOR COMPLIANCE ALERTS
-- ============================================================================
INSERT INTO compliance_alerts (title, description, priority, due_date, type, regulation_source, jurisdiction) VALUES
('POPIA Data Retention Review Due', 'Annual review of data retention policies required under POPIA regulations. Review all data processing activities and update retention schedules.', 'High', CURRENT_DATE + INTERVAL '3 days', 'deadline', 'POPIA', 'South Africa'),
('New B-BBEE Regulations', 'Updated B-BBEE codes effective January 2025 - review and update compliance procedures. Impact assessment required for current certification.', 'Medium', CURRENT_DATE + INTERVAL '6 months', 'regulatory', 'B-BBEE', 'South Africa'),
('Contract Renewal Alert', 'Vendor agreement expires next month - review terms and conditions. Negotiate new rates and service levels.', 'Medium', CURRENT_DATE + INTERVAL '28 days', 'contract', 'Internal', 'South Africa'),
('GDPR Compliance Audit', 'Quarterly GDPR compliance audit required for EU data processing. Prepare documentation and evidence.', 'High', CURRENT_DATE + INTERVAL '14 days', 'audit', 'GDPR', 'European Union'),
('Labour Relations Act Update', 'New amendments to Labour Relations Act require policy updates. Review employment contracts and procedures.', 'Critical', CURRENT_DATE + INTERVAL '7 days', 'regulatory', 'LRA', 'South Africa'),
('Tax Compliance Review', 'Annual tax compliance review due. Prepare supporting documentation for SARS submission.', 'High', CURRENT_DATE + INTERVAL '21 days', 'tax', 'SARS', 'South Africa'),
('Environmental Impact Assessment', 'Environmental compliance assessment required for new facility. Submit EIA report to authorities.', 'Medium', CURRENT_DATE + INTERVAL '45 days', 'environmental', 'NEMA', 'South Africa'),
('Intellectual Property Renewal', 'Trademark renewals due for key brand assets. File renewal applications with CIPC.', 'Low', CURRENT_DATE + INTERVAL '90 days', 'ip', 'CIPC', 'South Africa');

-- ============================================================================
-- 8. SEED DATA FOR DEPOSITIONS
-- ============================================================================
INSERT INTO depositions (case_name, case_number, deponent_name, deponent_role, date_conducted, location, status, duration_minutes) VALUES
('Smith vs. ABC Corporation', 'HC-2024-001', 'John Smith', 'Plaintiff', '2024-01-15', 'Cape Town High Court', 'completed', 180),
('Estate Planning Matter - Johnson', 'EST-2024-045', 'Mary Johnson', 'Beneficiary', '2024-01-20', 'Johannesburg Office', 'completed', 120),
('Contract Dispute - Wilson vs. XYZ Ltd', 'COM-2024-023', 'Robert Wilson', 'Defendant', '2024-01-25', 'Durban Commercial Court', 'pending', NULL),
('Personal Injury Claim', 'PI-2024-067', 'Sarah Davis', 'Witness', '2024-02-01', 'Pretoria Magistrate Court', 'completed', 90),
('Employment Dispute', 'LAB-2024-012', 'Michael Brown', 'Former Employee', '2024-02-05', 'CCMA Offices', 'in_progress', NULL),
('Property Development Case', 'PROP-2024-089', 'Jennifer Lee', 'Property Developer', '2024-02-10', 'Cape Town Office', 'pending', NULL);

-- ============================================================================
-- 9. SEED DATA FOR CASE TIMELINES
-- ============================================================================
INSERT INTO case_timelines (case_name, case_number, timeline_data) VALUES
('Smith vs. ABC Corporation', 'HC-2024-001', '[
  {"date": "2023-06-15", "event": "Initial incident occurred", "type": "incident"},
  {"date": "2023-07-01", "event": "Legal notice served", "type": "legal"},
  {"date": "2023-08-15", "event": "Summons issued", "type": "court"},
  {"date": "2024-01-15", "event": "Deposition conducted", "type": "discovery"}
]'::jsonb),
('Estate Planning Matter - Johnson', 'EST-2024-045', '[
  {"date": "2023-12-01", "event": "Will executed", "type": "document"},
  {"date": "2024-01-05", "event": "Probate application filed", "type": "court"},
  {"date": "2024-01-20", "event": "Beneficiary deposition", "type": "discovery"}
]'::jsonb);

-- ============================================================================
-- 10. SEED DATA FOR COMPLIANCE REPORTS
-- ============================================================================
INSERT INTO compliance_reports (report_name, report_type, status, report_data) VALUES
('Q4 2024 POPIA Compliance Report', 'popia', 'generated', '{"compliance_score": 85, "issues_found": 3, "recommendations": 7}'::jsonb),
('Annual B-BBEE Status Report', 'bbbee', 'generated', '{"level": 4, "score": 75, "elements": {"ownership": 15, "management": 12}}'::jsonb),
('GDPR Data Processing Audit', 'gdpr', 'generated', '{"data_subjects": 1250, "processing_activities": 15, "consent_rate": 92}'::jsonb),
('Monthly Risk Assessment', 'risk', 'generated', '{"high_risk": 2, "medium_risk": 8, "low_risk": 15}'::jsonb),
('Contract Compliance Review', 'contract', 'generated', '{"total_contracts": 45, "expiring_soon": 8, "non_compliant": 2}'::jsonb);

-- ============================================================================
-- 11. ADD COMMENTS FOR DOCUMENTATION
-- ============================================================================
COMMENT ON TABLE compliance_alerts IS 'Stores compliance alerts, deadlines, and regulatory notifications';
COMMENT ON TABLE depositions IS 'Stores deposition information, transcripts, and metadata';
COMMENT ON TABLE deposition_analyses IS 'Stores AI-powered analysis results for depositions';
COMMENT ON TABLE case_timelines IS 'Stores generated case timelines and chronologies';
COMMENT ON TABLE timeline_events IS 'Individual events within case timelines';
COMMENT ON TABLE compliance_reports IS 'Generated compliance reports and audit results';

-- ============================================================================
-- 12. CREATE VIEWS FOR COMMON QUERIES
-- ============================================================================
CREATE OR REPLACE VIEW active_compliance_alerts AS
SELECT 
    ca.*,
    o.name as organization_name,
    u.name as created_by_name
FROM compliance_alerts ca
LEFT JOIN organizations o ON ca.organization_id = o.id
LEFT JOIN users u ON ca.created_by = u.id
WHERE ca.status = 'active'
ORDER BY 
    CASE ca.priority 
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'Low' THEN 4
    END,
    ca.due_date ASC;

CREATE OR REPLACE VIEW recent_depositions AS
SELECT 
    d.*,
    COUNT(da.id) as analysis_count
FROM depositions d
LEFT JOIN deposition_analyses da ON d.id = da.deposition_id
GROUP BY d.id
ORDER BY d.date_conducted DESC;

-- ============================================================================
-- 13. GRANT PERMISSIONS (if using specific database users)
-- ============================================================================
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- Verify tables exist
SELECT table_name, table_type 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('compliance_alerts', 'depositions', 'case_timelines', 'compliance_reports')
ORDER BY table_name;

-- Verify data exists
SELECT 'compliance_alerts' as table_name, COUNT(*) as row_count FROM compliance_alerts
UNION ALL
SELECT 'depositions', COUNT(*) FROM depositions
UNION ALL
SELECT 'case_timelines', COUNT(*) FROM case_timelines
UNION ALL
SELECT 'compliance_reports', COUNT(*) FROM compliance_reports;
