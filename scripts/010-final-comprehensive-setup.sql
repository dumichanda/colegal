-- ============================================================================
-- FINAL COMPREHENSIVE DATABASE SETUP
-- This script creates ALL missing tables and data for the Legal AI application
-- Run this ONCE in your Neon database
-- ============================================================================

-- First, let's check what tables already exist
DO $$
BEGIN
    RAISE NOTICE 'Starting comprehensive database setup...';
    RAISE NOTICE 'Current timestamp: %', NOW();
END $$;

-- ============================================================================
-- 1. CREATE MISSING TABLES (only if they don't exist)
-- ============================================================================

-- Tasks Table (this is what's causing the current error)
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL DEFAULT 'general',
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'failed', 'cancelled')),
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    assigned_to UUID,
    organization_id UUID,
    due_date TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Compliance Alerts Table
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
    organization_id UUID,
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Depositions Table
CREATE TABLE IF NOT EXISTS depositions (
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
    organization_id UUID,
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Deposition Analyses Table
CREATE TABLE IF NOT EXISTS deposition_analyses (
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

-- Case Timelines Table
CREATE TABLE IF NOT EXISTS case_timelines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_name VARCHAR(255) NOT NULL,
    case_number VARCHAR(100),
    timeline_data JSONB NOT NULL,
    document_ids UUID[],
    organization_id UUID,
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Timeline Events Table
CREATE TABLE IF NOT EXISTS timeline_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    timeline_id UUID NOT NULL REFERENCES case_timelines(id) ON DELETE CASCADE,
    event_date DATE NOT NULL,
    event_title VARCHAR(255) NOT NULL,
    event_description TEXT,
    event_type VARCHAR(50),
    document_reference UUID,
    importance_level INTEGER DEFAULT 1 CHECK (importance_level BETWEEN 1 AND 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Compliance Reports Table
CREATE TABLE IF NOT EXISTS compliance_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_name VARCHAR(255) NOT NULL,
    report_type VARCHAR(50) NOT NULL,
    report_data JSONB,
    generated_date DATE DEFAULT CURRENT_DATE,
    file_path TEXT,
    status VARCHAR(20) DEFAULT 'generated' CHECK (status IN ('generating', 'generated', 'failed')),
    organization_id UUID,
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- 2. CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

-- Tasks Indexes
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_tasks_assigned_to ON tasks(assigned_to);

-- Compliance Alerts Indexes
CREATE INDEX IF NOT EXISTS idx_compliance_alerts_status ON compliance_alerts(status);
CREATE INDEX IF NOT EXISTS idx_compliance_alerts_priority ON compliance_alerts(priority);
CREATE INDEX IF NOT EXISTS idx_compliance_alerts_due_date ON compliance_alerts(due_date);
CREATE INDEX IF NOT EXISTS idx_compliance_alerts_type ON compliance_alerts(type);

-- Depositions Indexes
CREATE INDEX IF NOT EXISTS idx_depositions_status ON depositions(status);
CREATE INDEX IF NOT EXISTS idx_depositions_date ON depositions(date_conducted);
CREATE INDEX IF NOT EXISTS idx_depositions_case_name ON depositions(case_name);

-- Other Indexes
CREATE INDEX IF NOT EXISTS idx_deposition_analyses_deposition ON deposition_analyses(deposition_id);
CREATE INDEX IF NOT EXISTS idx_timeline_events_timeline ON timeline_events(timeline_id);
CREATE INDEX IF NOT EXISTS idx_timeline_events_date ON timeline_events(event_date);
CREATE INDEX IF NOT EXISTS idx_compliance_reports_type ON compliance_reports(report_type);

-- ============================================================================
-- 3. INSERT COMPREHENSIVE SEED DATA
-- ============================================================================

-- Tasks Seed Data (this fixes the immediate error)
INSERT INTO tasks (title, description, type, status, priority, due_date) VALUES
('Review POPIA Compliance Documentation', 'Complete annual review of POPIA compliance documentation and update policies', 'compliance', 'pending', 'high', NOW() + INTERVAL '7 days'),
('Contract Analysis - ABC Corp', 'Analyze new vendor contract for compliance and risk assessment', 'analysis', 'in_progress', 'medium', NOW() + INTERVAL '3 days'),
('Deposition Preparation - Smith Case', 'Prepare questions and documentation for upcoming deposition', 'legal', 'pending', 'high', NOW() + INTERVAL '2 days'),
('Regulatory Update Review', 'Review new B-BBEE regulations and assess impact on current operations', 'regulatory', 'completed', 'medium', NOW() - INTERVAL '1 day'),
('Document Classification', 'Classify and tag new legal documents in the system', 'document', 'pending', 'low', NOW() + INTERVAL '14 days'),
('Compliance Report Generation', 'Generate quarterly compliance report for board review', 'reporting', 'in_progress', 'high', NOW() + INTERVAL '5 days'),
('Risk Assessment Update', 'Update enterprise risk assessment with new regulatory changes', 'risk', 'pending', 'medium', NOW() + INTERVAL '10 days'),
('Training Material Update', 'Update compliance training materials with latest regulations', 'training', 'pending', 'low', NOW() + INTERVAL '21 days'),
('Audit Preparation', 'Prepare documentation for upcoming compliance audit', 'audit', 'pending', 'critical', NOW() + INTERVAL '1 day'),
('Policy Review - Data Protection', 'Annual review of data protection policies and procedures', 'policy', 'completed', 'high', NOW() - INTERVAL '3 days')
ON CONFLICT DO NOTHING;

-- Compliance Alerts Seed Data
INSERT INTO compliance_alerts (title, description, priority, due_date, type, regulation_source, jurisdiction) VALUES
('POPIA Data Retention Review Due', 'Annual review of data retention policies required under POPIA regulations. Review all data processing activities and update retention schedules.', 'High', CURRENT_DATE + INTERVAL '3 days', 'deadline', 'POPIA', 'South Africa'),
('New B-BBEE Regulations', 'Updated B-BBEE codes effective January 2025 - review and update compliance procedures. Impact assessment required for current certification.', 'Medium', CURRENT_DATE + INTERVAL '6 months', 'regulatory', 'B-BBEE', 'South Africa'),
('Contract Renewal Alert', 'Vendor agreement expires next month - review terms and conditions. Negotiate new rates and service levels.', 'Medium', CURRENT_DATE + INTERVAL '28 days', 'contract', 'Internal', 'South Africa'),
('GDPR Compliance Audit', 'Quarterly GDPR compliance audit required for EU data processing. Prepare documentation and evidence.', 'High', CURRENT_DATE + INTERVAL '14 days', 'audit', 'GDPR', 'European Union'),
('Labour Relations Act Update', 'New amendments to Labour Relations Act require policy updates. Review employment contracts and procedures.', 'Critical', CURRENT_DATE + INTERVAL '7 days', 'regulatory', 'LRA', 'South Africa'),
('Tax Compliance Review', 'Annual tax compliance review due. Prepare supporting documentation for SARS submission.', 'High', CURRENT_DATE + INTERVAL '21 days', 'tax', 'SARS', 'South Africa'),
('Environmental Impact Assessment', 'Environmental compliance assessment required for new facility. Submit EIA report to authorities.', 'Medium', CURRENT_DATE + INTERVAL '45 days', 'environmental', 'NEMA', 'South Africa'),
('Intellectual Property Renewal', 'Trademark renewals due for key brand assets. File renewal applications with CIPC.', 'Low', CURRENT_DATE + INTERVAL '90 days', 'ip', 'CIPC', 'South Africa'),
('Financial Services Compliance', 'FSCA regulatory return submission deadline approaching. Compile financial data and submit reports.', 'Critical', CURRENT_DATE + INTERVAL '5 days', 'financial', 'FSCA', 'South Africa'),
('Health and Safety Audit', 'Annual workplace health and safety audit required. Schedule inspection and prepare documentation.', 'High', CURRENT_DATE + INTERVAL '30 days', 'safety', 'DoL', 'South Africa')
ON CONFLICT DO NOTHING;

-- Depositions Seed Data
INSERT INTO depositions (case_name, case_number, deponent_name, deponent_role, date_conducted, location, status, duration_minutes) VALUES
('Smith vs. ABC Corporation', 'HC-2024-001', 'John Smith', 'Plaintiff', '2024-01-15', 'Cape Town High Court', 'completed', 180),
('Estate Planning Matter - Johnson', 'EST-2024-045', 'Mary Johnson', 'Beneficiary', '2024-01-20', 'Johannesburg Office', 'completed', 120),
('Contract Dispute - Wilson vs. XYZ Ltd', 'COM-2024-023', 'Robert Wilson', 'Defendant', '2024-01-25', 'Durban Commercial Court', 'pending', NULL),
('Personal Injury Claim', 'PI-2024-067', 'Sarah Davis', 'Witness', '2024-02-01', 'Pretoria Magistrate Court', 'completed', 90),
('Employment Dispute', 'LAB-2024-012', 'Michael Brown', 'Former Employee', '2024-02-05', 'CCMA Offices', 'in_progress', NULL),
('Property Development Case', 'PROP-2024-089', 'Jennifer Lee', 'Property Developer', '2024-02-10', 'Cape Town Office', 'pending', NULL),
('Insurance Claim Dispute', 'INS-2024-156', 'David Thompson', 'Claimant', '2024-02-15', 'Insurance Ombudsman', 'completed', 150),
('Merger and Acquisition Due Diligence', 'MA-2024-078', 'Lisa Chen', 'CFO', '2024-02-20', 'Corporate Offices', 'completed', 240)
ON CONFLICT DO NOTHING;

-- Case Timelines Seed Data
INSERT INTO case_timelines (case_name, case_number, timeline_data) VALUES
('Smith vs. ABC Corporation', 'HC-2024-001', '[
  {"date": "2023-06-15", "event": "Initial incident occurred", "type": "incident", "importance": 5},
  {"date": "2023-07-01", "event": "Legal notice served", "type": "legal", "importance": 4},
  {"date": "2023-08-15", "event": "Summons issued", "type": "court", "importance": 5},
  {"date": "2024-01-15", "event": "Deposition conducted", "type": "discovery", "importance": 4},
  {"date": "2024-03-01", "event": "Trial date scheduled", "type": "court", "importance": 5}
]'::jsonb),
('Estate Planning Matter - Johnson', 'EST-2024-045', '[
  {"date": "2023-12-01", "event": "Will executed", "type": "document", "importance": 5},
  {"date": "2024-01-05", "event": "Probate application filed", "type": "court", "importance": 4},
  {"date": "2024-01-20", "event": "Beneficiary deposition", "type": "discovery", "importance": 3},
  {"date": "2024-02-15", "event": "Asset valuation completed", "type": "financial", "importance": 3}
]'::jsonb),
('Contract Dispute - Wilson vs. XYZ Ltd', 'COM-2024-023', '[
  {"date": "2023-09-01", "event": "Contract signed", "type": "contract", "importance": 5},
  {"date": "2023-11-15", "event": "Breach of contract alleged", "type": "dispute", "importance": 4},
  {"date": "2024-01-10", "event": "Mediation attempted", "type": "alternative_dispute", "importance": 3},
  {"date": "2024-01-25", "event": "Deposition scheduled", "type": "discovery", "importance": 4}
]'::jsonb)
ON CONFLICT DO NOTHING;

-- Compliance Reports Seed Data
INSERT INTO compliance_reports (report_name, report_type, status, report_data) VALUES
('Q4 2024 POPIA Compliance Report', 'popia', 'generated', '{"compliance_score": 85, "issues_found": 3, "recommendations": 7, "data_subjects": 1250, "processing_activities": 15}'::jsonb),
('Annual B-BBEE Status Report', 'bbbee', 'generated', '{"level": 4, "score": 75, "elements": {"ownership": 15, "management": 12, "skills_development": 18, "enterprise_development": 10}}'::jsonb),
('GDPR Data Processing Audit', 'gdpr', 'generated', '{"data_subjects": 1250, "processing_activities": 15, "consent_rate": 92, "data_breaches": 0, "dpo_reports": 4}'::jsonb),
('Monthly Risk Assessment', 'risk', 'generated', '{"high_risk": 2, "medium_risk": 8, "low_risk": 15, "total_risks": 25, "mitigation_plans": 10}'::jsonb),
('Contract Compliance Review', 'contract', 'generated', '{"total_contracts": 45, "expiring_soon": 8, "non_compliant": 2, "renewal_required": 12, "value_at_risk": 2500000}'::jsonb),
('Financial Services Compliance Report', 'financial', 'generated', '{"regulatory_returns": 12, "compliance_score": 92, "outstanding_issues": 1, "fsca_submissions": 4}'::jsonb),
('Environmental Compliance Audit', 'environmental', 'generated', '{"permits_current": 8, "permits_expiring": 2, "environmental_incidents": 0, "compliance_score": 95}'::jsonb),
('Labour Relations Compliance', 'labour', 'generated', '{"employment_equity_score": 78, "skills_development_spend": 1.2, "workplace_incidents": 3, "ccma_cases": 1}'::jsonb)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 4. VERIFICATION AND SUMMARY
-- ============================================================================

-- Show table counts
DO $$
DECLARE
    rec RECORD;
    table_count INTEGER;
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE 'DATABASE SETUP COMPLETE - TABLE SUMMARY:';
    RAISE NOTICE '============================================';
    
    FOR rec IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name IN ('tasks', 'compliance_alerts', 'depositions', 'deposition_analyses', 'case_timelines', 'timeline_events', 'compliance_reports')
        ORDER BY table_name
    LOOP
        EXECUTE format('SELECT COUNT(*) FROM %I', rec.table_name) INTO table_count;
        RAISE NOTICE '% - % rows', RPAD(rec.table_name, 25), table_count;
    END LOOP;
    
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Setup completed at: %', NOW();
    RAISE NOTICE 'All tables created and populated successfully!';
    RAISE NOTICE '============================================';
END $$;
