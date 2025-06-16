-- ============================================================================
-- COMPLETE LEGAL AI DATABASE SETUP
-- This script creates ALL tables, views, indexes, and relationships
-- Run this ONCE in your Neon database to set up everything
-- ============================================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop existing views first (in case of updates)
DROP VIEW IF EXISTS active_compliance_alerts CASCADE;
DROP VIEW IF EXISTS recent_depositions CASCADE;
DROP VIEW IF EXISTS dashboard_summary CASCADE;
DROP VIEW IF EXISTS document_analytics CASCADE;
DROP VIEW IF EXISTS compliance_overview CASCADE;

-- ============================================================================
-- 1. CORE TABLES (Create if not exist, but ensure all columns are present)
-- ============================================================================

-- Organizations Table
CREATE TABLE IF NOT EXISTS organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) DEFAULT 'law_firm',
    address TEXT,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(50),
    registration_number VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'user',
    organization_id UUID REFERENCES organizations(id),
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Documents Table (Enhanced)
CREATE TABLE IF NOT EXISTS documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    content TEXT,
    file_path TEXT,
    file_type VARCHAR(50),
    file_size BIGINT,
    document_type VARCHAR(100),
    status VARCHAR(50) DEFAULT 'active',
    tags TEXT[],
    metadata JSONB DEFAULT '{}',
    organization_id UUID REFERENCES organizations(id),
    uploaded_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tasks Table
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL DEFAULT 'general',
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'failed', 'cancelled')),
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    assigned_to UUID REFERENCES users(id),
    organization_id UUID REFERENCES organizations(id),
    due_date TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Compliance Rules Table
CREATE TABLE IF NOT EXISTS compliance_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    regulation_source VARCHAR(100),
    jurisdiction VARCHAR(50),
    risk_level VARCHAR(20) DEFAULT 'medium' CHECK (risk_level IN ('low', 'medium', 'high', 'critical')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Compliance Monitoring Table
CREATE TABLE IF NOT EXISTS compliance_monitoring (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_id UUID NOT NULL REFERENCES compliance_rules(id),
    organization_id UUID REFERENCES organizations(id),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('compliant', 'non_compliant', 'at_risk', 'pending')),
    last_checked TIMESTAMP WITH TIME ZONE,
    next_check_due TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    evidence_documents UUID[],
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
    organization_id UUID REFERENCES organizations(id),
    created_by UUID REFERENCES users(id),
    assigned_to UUID REFERENCES users(id),
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
    organization_id UUID REFERENCES organizations(id),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Deposition Analyses Table
CREATE TABLE IF NOT EXISTS deposition_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    deposition_id UUID NOT NULL REFERENCES depositions(id) ON DELETE CASCADE,
    analysis_type VARCHAR(50) NOT NULL,
    key_points JSONB DEFAULT '[]',
    inconsistencies JSONB DEFAULT '[]',
    credibility_assessment JSONB DEFAULT '{}',
    follow_up_questions JSONB DEFAULT '[]',
    confidence_score DECIMAL(3,2),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Case Timelines Table
CREATE TABLE IF NOT EXISTS case_timelines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_name VARCHAR(255) NOT NULL,
    case_number VARCHAR(100),
    timeline_data JSONB NOT NULL DEFAULT '[]',
    document_ids UUID[],
    organization_id UUID REFERENCES organizations(id),
    created_by UUID REFERENCES users(id),
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
    document_reference UUID REFERENCES documents(id),
    importance_level INTEGER DEFAULT 1 CHECK (importance_level BETWEEN 1 AND 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Compliance Reports Table
CREATE TABLE IF NOT EXISTS compliance_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_name VARCHAR(255) NOT NULL,
    report_type VARCHAR(50) NOT NULL,
    report_data JSONB DEFAULT '{}',
    generated_date DATE DEFAULT CURRENT_DATE,
    file_path TEXT,
    status VARCHAR(20) DEFAULT 'generated' CHECK (status IN ('generating', 'generated', 'failed')),
    organization_id UUID REFERENCES organizations(id),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Regulatory Updates Table
CREATE TABLE IF NOT EXISTS regulatory_updates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    source VARCHAR(100),
    jurisdiction VARCHAR(50),
    category VARCHAR(100),
    effective_date DATE,
    impact_level VARCHAR(20) DEFAULT 'medium' CHECK (impact_level IN ('low', 'medium', 'high', 'critical')),
    url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Document Analyses Table
CREATE TABLE IF NOT EXISTS document_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    analysis_type VARCHAR(50) NOT NULL,
    analysis_result JSONB DEFAULT '{}',
    confidence_score DECIMAL(3,2),
    key_findings TEXT[],
    recommendations TEXT[],
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Document Comparisons Table
CREATE TABLE IF NOT EXISTS document_comparisons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document1_id UUID NOT NULL REFERENCES documents(id),
    document2_id UUID NOT NULL REFERENCES documents(id),
    comparison_type VARCHAR(50) NOT NULL,
    similarity_score DECIMAL(3,2),
    differences JSONB DEFAULT '[]',
    similarities JSONB DEFAULT '[]',
    analysis_summary TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Audit Logs Table
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id UUID,
    details JSONB DEFAULT '{}',
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- 2. CREATE COMPREHENSIVE INDEXES
-- ============================================================================

-- Organizations
CREATE INDEX IF NOT EXISTS idx_organizations_type ON organizations(type);

-- Users
CREATE INDEX IF NOT EXISTS idx_users_organization ON users(organization_id);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active);

-- Documents
CREATE INDEX IF NOT EXISTS idx_documents_type ON documents(document_type);
CREATE INDEX IF NOT EXISTS idx_documents_status ON documents(status);
CREATE INDEX IF NOT EXISTS idx_documents_organization ON documents(organization_id);
CREATE INDEX IF NOT EXISTS idx_documents_created ON documents(created_at);
CREATE INDEX IF NOT EXISTS idx_documents_tags ON documents USING GIN(tags);

-- Tasks
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX IF NOT EXISTS idx_tasks_organization ON tasks(organization_id);

-- Compliance Rules
CREATE INDEX IF NOT EXISTS idx_compliance_rules_category ON compliance_rules(category);
CREATE INDEX IF NOT EXISTS idx_compliance_rules_active ON compliance_rules(is_active);
CREATE INDEX IF NOT EXISTS idx_compliance_rules_risk ON compliance_rules(risk_level);

-- Compliance Monitoring
CREATE INDEX IF NOT EXISTS idx_compliance_monitoring_rule ON compliance_monitoring(rule_id);
CREATE INDEX IF NOT EXISTS idx_compliance_monitoring_status ON compliance_monitoring(status);
CREATE INDEX IF NOT EXISTS idx_compliance_monitoring_org ON compliance_monitoring(organization_id);
CREATE INDEX IF NOT EXISTS idx_compliance_monitoring_next_check ON compliance_monitoring(next_check_due);

-- Compliance Alerts
CREATE INDEX IF NOT EXISTS idx_compliance_alerts_status ON compliance_alerts(status);
CREATE INDEX IF NOT EXISTS idx_compliance_alerts_priority ON compliance_alerts(priority);
CREATE INDEX IF NOT EXISTS idx_compliance_alerts_due_date ON compliance_alerts(due_date);
CREATE INDEX IF NOT EXISTS idx_compliance_alerts_type ON compliance_alerts(type);
CREATE INDEX IF NOT EXISTS idx_compliance_alerts_org ON compliance_alerts(organization_id);

-- Depositions
CREATE INDEX IF NOT EXISTS idx_depositions_status ON depositions(status);
CREATE INDEX IF NOT EXISTS idx_depositions_date ON depositions(date_conducted);
CREATE INDEX IF NOT EXISTS idx_depositions_case_name ON depositions(case_name);
CREATE INDEX IF NOT EXISTS idx_depositions_org ON depositions(organization_id);

-- Other Indexes
CREATE INDEX IF NOT EXISTS idx_deposition_analyses_deposition ON deposition_analyses(deposition_id);
CREATE INDEX IF NOT EXISTS idx_timeline_events_timeline ON timeline_events(timeline_id);
CREATE INDEX IF NOT EXISTS idx_timeline_events_date ON timeline_events(event_date);
CREATE INDEX IF NOT EXISTS idx_compliance_reports_type ON compliance_reports(report_type);
CREATE INDEX IF NOT EXISTS idx_regulatory_updates_active ON regulatory_updates(is_active);
CREATE INDEX IF NOT EXISTS idx_regulatory_updates_date ON regulatory_updates(effective_date);
CREATE INDEX IF NOT EXISTS idx_document_analyses_document ON document_analyses(document_id);
CREATE INDEX IF NOT EXISTS idx_document_comparisons_docs ON document_comparisons(document1_id, document2_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON audit_logs(created_at);

-- ============================================================================
-- 3. INSERT COMPREHENSIVE SEED DATA
-- ============================================================================

-- Organizations
INSERT INTO organizations (id, name, type, address, contact_email) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'Legal AI Demo Firm', 'law_firm', '123 Legal Street, Cape Town, South Africa', 'info@legalaidemo.co.za'),
('550e8400-e29b-41d4-a716-446655440001', 'Corporate Legal Services', 'corporate', '456 Business Ave, Johannesburg, South Africa', 'contact@corplegalsvc.co.za')
ON CONFLICT (id) DO NOTHING;

-- Users
INSERT INTO users (id, email, name, role, organization_id) VALUES
('660e8400-e29b-41d4-a716-446655440000', 'admin@legalaidemo.co.za', 'Admin User', 'admin', '550e8400-e29b-41d4-a716-446655440000'),
('660e8400-e29b-41d4-a716-446655440001', 'lawyer@legalaidemo.co.za', 'Senior Lawyer', 'lawyer', '550e8400-e29b-41d4-a716-446655440000'),
('660e8400-e29b-41d4-a716-446655440002', 'paralegal@legalaidemo.co.za', 'Paralegal Assistant', 'paralegal', '550e8400-e29b-41d4-a716-446655440000')
ON CONFLICT (id) DO NOTHING;

-- Tasks Seed Data
INSERT INTO tasks (title, description, type, status, priority, due_date, organization_id, created_by) VALUES
('Review POPIA Compliance Documentation', 'Complete annual review of POPIA compliance documentation and update policies', 'compliance', 'pending', 'high', NOW() + INTERVAL '7 days', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000'),
('Contract Analysis - ABC Corp', 'Analyze new vendor contract for compliance and risk assessment', 'analysis', 'in_progress', 'medium', NOW() + INTERVAL '3 days', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('Deposition Preparation - Smith Case', 'Prepare questions and documentation for upcoming deposition', 'legal', 'pending', 'high', NOW() + INTERVAL '2 days', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('Regulatory Update Review', 'Review new B-BBEE regulations and assess impact on current operations', 'regulatory', 'completed', 'medium', NOW() - INTERVAL '1 day', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440002'),
('Document Classification', 'Classify and tag new legal documents in the system', 'document', 'pending', 'low', NOW() + INTERVAL '14 days', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440002'),
('Compliance Report Generation', 'Generate quarterly compliance report for board review', 'reporting', 'in_progress', 'high', NOW() + INTERVAL '5 days', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000'),
('Risk Assessment Update', 'Update enterprise risk assessment with new regulatory changes', 'risk', 'pending', 'medium', NOW() + INTERVAL '10 days', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('Training Material Update', 'Update compliance training materials with latest regulations', 'training', 'pending', 'low', NOW() + INTERVAL '21 days', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440002'),
('Audit Preparation', 'Prepare documentation for upcoming compliance audit', 'audit', 'pending', 'critical', NOW() + INTERVAL '1 day', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000'),
('Policy Review - Data Protection', 'Annual review of data protection policies and procedures', 'policy', 'completed', 'high', NOW() - INTERVAL '3 days', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001')
ON CONFLICT DO NOTHING;

-- Compliance Rules
INSERT INTO compliance_rules (title, description, category, regulation_source, jurisdiction, risk_level) VALUES
('Data Retention Policy', 'Personal data must be retained only for as long as necessary', 'Data Protection', 'POPIA', 'South Africa', 'high'),
('Employment Equity Reporting', 'Annual employment equity reports must be submitted', 'Employment', 'Employment Equity Act', 'South Africa', 'medium'),
('B-BBEE Compliance', 'Maintain valid B-BBEE certificate and compliance', 'Economic Empowerment', 'B-BBEE Act', 'South Africa', 'high'),
('Tax Compliance', 'Ensure all tax obligations are met and returns filed', 'Tax', 'Income Tax Act', 'South Africa', 'critical'),
('Environmental Compliance', 'Comply with environmental regulations and permits', 'Environment', 'NEMA', 'South Africa', 'medium'),
('Health and Safety Standards', 'Maintain workplace health and safety standards', 'Safety', 'Occupational Health and Safety Act', 'South Africa', 'high'),
('Financial Services Compliance', 'Comply with financial services regulations', 'Financial', 'Financial Services Laws', 'South Africa', 'critical'),
('Consumer Protection', 'Ensure compliance with consumer protection laws', 'Consumer', 'Consumer Protection Act', 'South Africa', 'medium')
ON CONFLICT DO NOTHING;

-- Compliance Monitoring
INSERT INTO compliance_monitoring (rule_id, organization_id, status, last_checked, next_check_due) 
SELECT 
    cr.id,
    '550e8400-e29b-41d4-a716-446655440000',
    CASE 
        WHEN random() < 0.7 THEN 'compliant'
        WHEN random() < 0.9 THEN 'at_risk'
        ELSE 'non_compliant'
    END,
    NOW() - INTERVAL '30 days' * random(),
    NOW() + INTERVAL '30 days' * (1 + random())
FROM compliance_rules cr
ON CONFLICT DO NOTHING;

-- Compliance Alerts
INSERT INTO compliance_alerts (title, description, priority, due_date, type, regulation_source, jurisdiction, organization_id, created_by) VALUES
('POPIA Data Retention Review Due', 'Annual review of data retention policies required under POPIA regulations. Review all data processing activities and update retention schedules.', 'High', CURRENT_DATE + INTERVAL '3 days', 'deadline', 'POPIA', 'South Africa', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000'),
('New B-BBEE Regulations', 'Updated B-BBEE codes effective January 2025 - review and update compliance procedures. Impact assessment required for current certification.', 'Medium', CURRENT_DATE + INTERVAL '6 months', 'regulatory', 'B-BBEE', 'South Africa', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('Contract Renewal Alert', 'Vendor agreement expires next month - review terms and conditions. Negotiate new rates and service levels.', 'Medium', CURRENT_DATE + INTERVAL '28 days', 'contract', 'Internal', 'South Africa', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440002'),
('GDPR Compliance Audit', 'Quarterly GDPR compliance audit required for EU data processing. Prepare documentation and evidence.', 'High', CURRENT_DATE + INTERVAL '14 days', 'audit', 'GDPR', 'European Union', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000'),
('Labour Relations Act Update', 'New amendments to Labour Relations Act require policy updates. Review employment contracts and procedures.', 'Critical', CURRENT_DATE + INTERVAL '7 days', 'regulatory', 'LRA', 'South Africa', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('Tax Compliance Review', 'Annual tax compliance review due. Prepare supporting documentation for SARS submission.', 'High', CURRENT_DATE + INTERVAL '21 days', 'tax', 'SARS', 'South Africa', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440002'),
('Environmental Impact Assessment', 'Environmental compliance assessment required for new facility. Submit EIA report to authorities.', 'Medium', CURRENT_DATE + INTERVAL '45 days', 'environmental', 'NEMA', 'South Africa', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000'),
('Intellectual Property Renewal', 'Trademark renewals due for key brand assets. File renewal applications with CIPC.', 'Low', CURRENT_DATE + INTERVAL '90 days', 'ip', 'CIPC', 'South Africa', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('Financial Services Compliance', 'FSCA regulatory return submission deadline approaching. Compile financial data and submit reports.', 'Critical', CURRENT_DATE + INTERVAL '5 days', 'financial', 'FSCA', 'South Africa', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440002'),
('Health and Safety Audit', 'Annual workplace health and safety audit required. Schedule inspection and prepare documentation.', 'High', CURRENT_DATE + INTERVAL '30 days', 'safety', 'DoL', 'South Africa', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000')
ON CONFLICT DO NOTHING;

-- Documents
INSERT INTO documents (title, content, document_type, status, organization_id, uploaded_by) VALUES
('Employment Contract Template', 'Standard employment contract template compliant with South African labour laws...', 'contract', 'active', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('POPIA Privacy Policy', 'Privacy policy document compliant with POPIA requirements...', 'policy', 'active', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000'),
('B-BBEE Certificate 2024', 'Current B-BBEE certificate and compliance documentation...', 'certificate', 'active', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440002'),
('Vendor Agreement - ABC Corp', 'Service agreement with ABC Corporation for IT services...', 'contract', 'active', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('Risk Assessment Report Q4', 'Quarterly risk assessment report covering operational and compliance risks...', 'report', 'active', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000'),
('Health and Safety Manual', 'Comprehensive workplace health and safety procedures manual...', 'manual', 'active', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440002'),
('Financial Audit Report 2024', 'Annual financial audit report and management letter...', 'report', 'active', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('Intellectual Property Portfolio', 'Complete listing of trademarks, patents, and IP assets...', 'inventory', 'active', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000'),
('Environmental Compliance Certificate', 'Environmental compliance certificate and permit documentation...', 'certificate', 'active', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440002'),
('Training Records Database', 'Employee training records and compliance certification tracking...', 'database', 'active', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001')
ON CONFLICT DO NOTHING;

-- Depositions
INSERT INTO depositions (case_name, case_number, deponent_name, deponent_role, date_conducted, location, status, duration_minutes, organization_id, created_by) VALUES
('Smith vs. ABC Corporation', 'HC-2024-001', 'John Smith', 'Plaintiff', '2024-01-15', 'Cape Town High Court', 'completed', 180, '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('Estate Planning Matter - Johnson', 'EST-2024-045', 'Mary Johnson', 'Beneficiary', '2024-01-20', 'Johannesburg Office', 'completed', 120, '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('Contract Dispute - Wilson vs. XYZ Ltd', 'COM-2024-023', 'Robert Wilson', 'Defendant', '2024-01-25', 'Durban Commercial Court', 'pending', NULL, '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('Personal Injury Claim', 'PI-2024-067', 'Sarah Davis', 'Witness', '2024-02-01', 'Pretoria Magistrate Court', 'completed', 90, '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('Employment Dispute', 'LAB-2024-012', 'Michael Brown', 'Former Employee', '2024-02-05', 'CCMA Offices', 'in_progress', NULL, '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('Property Development Case', 'PROP-2024-089', 'Jennifer Lee', 'Property Developer', '2024-02-10', 'Cape Town Office', 'pending', NULL, '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('Insurance Claim Dispute', 'INS-2024-156', 'David Thompson', 'Claimant', '2024-02-15', 'Insurance Ombudsman', 'completed', 150, '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('Merger and Acquisition Due Diligence', 'MA-2024-078', 'Lisa Chen', 'CFO', '2024-02-20', 'Corporate Offices', 'completed', 240, '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001')
ON CONFLICT DO NOTHING;

-- Case Timelines
INSERT INTO case_timelines (case_name, case_number, timeline_data, organization_id, created_by) VALUES
('Smith vs. ABC Corporation', 'HC-2024-001', '[
  {"date": "2023-06-15", "event": "Initial incident occurred", "type": "incident", "importance": 5},
  {"date": "2023-07-01", "event": "Legal notice served", "type": "legal", "importance": 4},
  {"date": "2023-08-15", "event": "Summons issued", "type": "court", "importance": 5},
  {"date": "2024-01-15", "event": "Deposition conducted", "type": "discovery", "importance": 4},
  {"date": "2024-03-01", "event": "Trial date scheduled", "type": "court", "importance": 5}
]'::jsonb, '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('Estate Planning Matter - Johnson', 'EST-2024-045', '[
  {"date": "2023-12-01", "event": "Will executed", "type": "document", "importance": 5},
  {"date": "2024-01-05", "event": "Probate application filed", "type": "court", "importance": 4},
  {"date": "2024-01-20", "event": "Beneficiary deposition", "type": "discovery", "importance": 3},
  {"date": "2024-02-15", "event": "Asset valuation completed", "type": "financial", "importance": 3}
]'::jsonb, '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('Contract Dispute - Wilson vs. XYZ Ltd', 'COM-2024-023', '[
  {"date": "2023-09-01", "event": "Contract signed", "type": "contract", "importance": 5},
  {"date": "2023-11-15", "event": "Breach of contract alleged", "type": "dispute", "importance": 4},
  {"date": "2024-01-10", "event": "Mediation attempted", "type": "alternative_dispute", "importance": 3},
  {"date": "2024-01-25", "event": "Deposition scheduled", "type": "discovery", "importance": 4}
]'::jsonb, '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001')
ON CONFLICT DO NOTHING;

-- Compliance Reports
INSERT INTO compliance_reports (report_name, report_type, status, report_data, organization_id, created_by) VALUES
('Q4 2024 POPIA Compliance Report', 'popia', 'generated', '{"compliance_score": 85, "issues_found": 3, "recommendations": 7, "data_subjects": 1250, "processing_activities": 15}'::jsonb, '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000'),
('Annual B-BBEE Status Report', 'bbbee', 'generated', '{"level": 4, "score": 75, "elements": {"ownership": 15, "management": 12, "skills_development": 18, "enterprise_development": 10}}'::jsonb, '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('GDPR Data Processing Audit', 'gdpr', 'generated', '{"data_subjects": 1250, "processing_activities": 15, "consent_rate": 92, "data_breaches": 0, "dpo_reports": 4}'::jsonb, '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440002'),
('Monthly Risk Assessment', 'risk', 'generated', '{"high_risk": 2, "medium_risk": 8, "low_risk": 15, "total_risks": 25, "mitigation_plans": 10}'::jsonb, '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000'),
('Contract Compliance Review', 'contract', 'generated', '{"total_contracts": 45, "expiring_soon": 8, "non_compliant": 2, "renewal_required": 12, "value_at_risk": 2500000}'::jsonb, '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001'),
('Financial Services Compliance Report', 'financial', 'generated', '{"regulatory_returns": 12, "compliance_score": 92, "outstanding_issues": 1, "fsca_submissions": 4}'::jsonb, '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440002'),
('Environmental Compliance Audit', 'environmental', 'generated', '{"permits_current": 8, "permits_expiring": 2, "environmental_incidents": 0, "compliance_score": 95}'::jsonb, '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440000'),
('Labour Relations Compliance', 'labour', 'generated', '{"employment_equity_score": 78, "skills_development_spend": 1.2, "workplace_incidents": 3, "ccma_cases": 1}'::jsonb, '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001')
ON CONFLICT DO NOTHING;

-- Regulatory Updates
INSERT INTO regulatory_updates (title, description, source, jurisdiction, category, effective_date, impact_level) VALUES
('POPIA Amendment Regulations 2024', 'New regulations under POPIA regarding cross-border data transfers and consent mechanisms', 'Department of Justice', 'South Africa', 'Data Protection', '2024-07-01', 'high'),
('B-BBEE Codes Update', 'Updated B-BBEE codes with revised scoring methodology and sector-specific requirements', 'Department of Trade and Industry', 'South Africa', 'Economic Empowerment', '2024-04-01', 'high'),
('Labour Relations Amendment Act', 'Amendments to the Labour Relations Act affecting collective bargaining and dispute resolution', 'Department of Employment and Labour', 'South Africa', 'Employment', '2024-06-01', 'medium'),
('Companies Act Regulations Update', 'New regulations under the Companies Act regarding beneficial ownership disclosure', 'CIPC', 'South Africa', 'Corporate', '2024-05-15', 'medium'),
('Tax Administration Laws Amendment', 'Changes to tax administration procedures and penalties', 'SARS', 'South Africa', 'Tax', '2024-03-01', 'high'),
('Environmental Impact Assessment Regulations', 'Updated EIA regulations with new assessment criteria and public participation requirements', 'Department of Environment', 'South Africa', 'Environment', '2024-08-01', 'medium'),
('Financial Services Conduct Authority Rules', 'New conduct standards for financial services providers', 'FSCA', 'South Africa', 'Financial Services', '2024-09-01', 'high'),
('Consumer Protection Act Amendments', 'Amendments to consumer protection regulations affecting e-commerce and digital services', 'National Consumer Commission', 'South Africa', 'Consumer Protection', '2024-10-01', 'medium')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 4. CREATE COMPREHENSIVE VIEWS
-- ============================================================================

-- Active Compliance Alerts View
CREATE OR REPLACE VIEW active_compliance_alerts AS
SELECT 
    ca.*,
    u.name as created_by_name,
    o.name as organization_name,
    CASE 
        WHEN due_date < CURRENT_DATE THEN 'overdue'
        WHEN due_date <= CURRENT_DATE + INTERVAL '7 days' THEN 'urgent'
        WHEN due_date <= CURRENT_DATE + INTERVAL '30 days' THEN 'upcoming'
        ELSE 'future'
    END as urgency_status,
    CASE 
        WHEN due_date < CURRENT_DATE THEN CURRENT_DATE - due_date
        ELSE NULL
    END as days_overdue
FROM compliance_alerts ca
LEFT JOIN users u ON ca.created_by = u.id
LEFT JOIN organizations o ON ca.organization_id = o.id
WHERE ca.status = 'active'
ORDER BY 
    CASE ca.priority 
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'Low' THEN 4
    END,
    ca.due_date ASC;

-- Recent Depositions View
CREATE OR REPLACE VIEW recent_depositions AS
SELECT 
    d.*,
    u.name as created_by_name,
    o.name as organization_name,
    COUNT(da.id) as analysis_count,
    CASE 
        WHEN d.status = 'completed' THEN 'Complete'
        WHEN d.status = 'in_progress' THEN 'In Progress'
        WHEN d.status = 'pending' THEN 'Pending'
        WHEN d.status = 'cancelled' THEN 'Cancelled'
        ELSE 'Unknown'
    END as status_display
FROM depositions d
LEFT JOIN deposition_analyses da ON d.id = da.deposition_id
LEFT JOIN users u ON d.created_by = u.id
LEFT JOIN organizations o ON d.organization_id = o.id
GROUP BY d.id, u.name, o.name
ORDER BY d.date_conducted DESC;

-- Dashboard Summary View
CREATE OR REPLACE VIEW dashboard_summary AS
SELECT 
    'documents' as metric_type,
    COUNT(*) as total_count,
    COUNT(CASE WHEN status = 'active' THEN 1 END) as active_count,
    COUNT(CASE WHEN created_at >= NOW() - INTERVAL '30 days' THEN 1 END) as recent_count
FROM documents
UNION ALL
SELECT 
    'tasks' as metric_type,
    COUNT(*) as total_count,
    COUNT(CASE WHEN status IN ('pending', 'in_progress') THEN 1 END) as active_count,
    COUNT(CASE WHEN created_at >= NOW() - INTERVAL '7 days' THEN 1 END) as recent_count
FROM tasks
UNION ALL
SELECT 
    'compliance_alerts' as metric_type,
    COUNT(*) as total_count,
    COUNT(CASE WHEN status = 'active' THEN 1 END) as active_count,
    COUNT(CASE WHEN due_date <= NOW() + INTERVAL '7 days' THEN 1 END) as recent_count
FROM compliance_alerts
UNION ALL
SELECT 
    'depositions' as metric_type,
    COUNT(*) as total_count,
    COUNT(CASE WHEN status IN ('pending', 'in_progress') THEN 1 END) as active_count,
    COUNT(CASE WHEN date_conducted >= NOW() - INTERVAL '30 days' THEN 1 END) as recent_count
FROM depositions;

-- Document Analytics View
CREATE OR REPLACE VIEW document_analytics AS
SELECT 
    d.document_type,
    COUNT(*) as document_count,
    COUNT(da.id) as analyzed_count,
    AVG(da.confidence_score) as avg_confidence_score,
    COUNT(CASE WHEN d.created_at >= NOW() - INTERVAL '30 days' THEN 1 END) as recent_documents
FROM documents d
LEFT JOIN document_analyses da ON d.id = da.document_id
WHERE d.status = 'active'
GROUP BY d.document_type
ORDER BY document_count DESC;

-- Compliance Overview View
CREATE OR REPLACE VIEW compliance_overview AS
SELECT 
    cr.category,
    COUNT(cr.id) as total_rules,
    COUNT(cm.id) as monitored_rules,
    COUNT(CASE WHEN cm.status = 'compliant' THEN 1 END) as compliant_count,
    COUNT(CASE WHEN cm.status = 'non_compliant' THEN 1 END) as non_compliant_count,
    COUNT(CASE WHEN cm.status = 'at_risk' THEN 1 END) as at_risk_count,
    ROUND(
        COALESCE(
            COUNT(CASE WHEN cm.status = 'compliant' THEN 1 END)::float / 
            NULLIF(COUNT(cm.id), 0)::float * 100, 
            0
        ), 2
    ) as compliance_percentage
FROM compliance_rules cr
LEFT JOIN compliance_monitoring cm ON cr.id = cm.rule_id
WHERE cr.is_active = true
GROUP BY cr.category
ORDER BY compliance_percentage DESC;

-- ============================================================================
-- 5. CREATE FUNCTIONS AND TRIGGERS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_organizations_updated_at BEFORE UPDATE ON organizations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_documents_updated_at BEFORE UPDATE ON documents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_compliance_rules_updated_at BEFORE UPDATE ON compliance_rules FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_compliance_monitoring_updated_at BEFORE UPDATE ON compliance_monitoring FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_compliance_alerts_updated_at BEFORE UPDATE ON compliance_alerts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_depositions_updated_at BEFORE UPDATE ON depositions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_case_timelines_updated_at BEFORE UPDATE ON case_timelines FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_regulatory_updates_updated_at BEFORE UPDATE ON regulatory_updates FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 6. VERIFICATION AND SUMMARY
-- ============================================================================

-- Show comprehensive table and view summary
DO $$
DECLARE
    rec RECORD;
    table_count INTEGER;
    view_count INTEGER;
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE 'COMPLETE DATABASE SETUP - SUMMARY REPORT';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Setup completed at: %', NOW();
    RAISE NOTICE '';
    
    -- Tables Summary
    RAISE NOTICE 'TABLES CREATED:';
    RAISE NOTICE '----------------------------------------';
    FOR rec IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
    LOOP
        EXECUTE format('SELECT COUNT(*) FROM %I', rec.table_name) INTO table_count;
        RAISE NOTICE '% - % rows', RPAD(rec.table_name, 30), table_count;
    END LOOP;
    
    RAISE NOTICE '';
    RAISE NOTICE 'VIEWS CREATED:';
    RAISE NOTICE '----------------------------------------';
    FOR rec IN 
        SELECT table_name 
        FROM information_schema.views 
        WHERE table_schema = 'public'
        ORDER BY table_name
    LOOP
        RAISE NOTICE '%', rec.table_name;
    END LOOP;
    
    -- Get total counts
    SELECT COUNT(*) INTO table_count FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
    SELECT COUNT(*) INTO view_count FROM information_schema.views WHERE table_schema = 'public';
    
    RAISE NOTICE '';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'SUMMARY: % tables, % views created', table_count, view_count;
    RAISE NOTICE 'Database is fully configured and ready!';
    RAISE NOTICE '============================================';
END $$;
