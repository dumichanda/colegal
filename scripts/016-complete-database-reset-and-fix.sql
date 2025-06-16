-- =====================================================
-- COMPLETE DATABASE RESET & FIX ALL ISSUES
-- This script drops all existing tables and recreates everything with correct schema
-- =====================================================

-- Drop all existing tables (in correct order to handle foreign keys)
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS document_comparisons CASCADE;
DROP TABLE IF EXISTS document_analyses CASCADE;
DROP TABLE IF EXISTS regulatory_updates CASCADE;
DROP TABLE IF EXISTS compliance_reports CASCADE;
DROP TABLE IF EXISTS timeline_events CASCADE;
DROP TABLE IF EXISTS case_timelines CASCADE;
DROP TABLE IF EXISTS deposition_analyses CASCADE;
DROP TABLE IF EXISTS depositions CASCADE;
DROP TABLE IF EXISTS compliance_alerts CASCADE;
DROP TABLE IF EXISTS compliance_monitoring CASCADE;
DROP TABLE IF EXISTS compliance_rules CASCADE;
DROP TABLE IF EXISTS tasks CASCADE;
DROP TABLE IF EXISTS documents CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS organizations CASCADE;

-- Drop all views
DROP VIEW IF EXISTS active_compliance_alerts CASCADE;
DROP VIEW IF EXISTS recent_depositions CASCADE;
DROP VIEW IF EXISTS dashboard_summary CASCADE;
DROP VIEW IF EXISTS document_analytics CASCADE;
DROP VIEW IF EXISTS compliance_overview CASCADE;

-- =====================================================
-- CREATE ALL TABLES WITH CORRECT SCHEMA
-- =====================================================

-- Organizations table
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    type VARCHAR(100) NOT NULL,
    industry VARCHAR(100),
    country VARCHAR(100) DEFAULT 'South Africa',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(100) NOT NULL,
    department VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Documents table
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id),
    title VARCHAR(500) NOT NULL,
    type VARCHAR(100) NOT NULL,
    category VARCHAR(100),
    content TEXT,
    file_path VARCHAR(500),
    file_size INTEGER,
    mime_type VARCHAR(100),
    status VARCHAR(50) DEFAULT 'active',
    risk_level VARCHAR(20) DEFAULT 'medium',
    uploaded_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tasks table (with priority column)
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id),
    title VARCHAR(500) NOT NULL,
    description TEXT,
    type VARCHAR(100) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    priority VARCHAR(20) DEFAULT 'medium',
    assigned_to UUID REFERENCES users(id),
    created_by UUID REFERENCES users(id),
    due_date TIMESTAMP,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Compliance Rules table (with title column)
CREATE TABLE compliance_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id),
    title VARCHAR(500) NOT NULL,
    name VARCHAR(500) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    regulation_source VARCHAR(200),
    risk_level VARCHAR(20) DEFAULT 'medium',
    severity VARCHAR(20) DEFAULT 'medium',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Compliance Monitoring table (with next_check_due column)
CREATE TABLE compliance_monitoring (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id),
    rule_id UUID REFERENCES compliance_rules(id),
    document_id UUID REFERENCES documents(id),
    status VARCHAR(50) NOT NULL,
    compliance_score INTEGER CHECK (compliance_score >= 0 AND compliance_score <= 100),
    issues_found INTEGER DEFAULT 0,
    next_check_due TIMESTAMP,
    last_checked TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Compliance Alerts table (with all required columns)
CREATE TABLE compliance_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id),
    rule_id UUID REFERENCES compliance_rules(id),
    document_id UUID REFERENCES documents(id),
    title VARCHAR(500) NOT NULL,
    description TEXT,
    type VARCHAR(100) DEFAULT 'compliance_violation',
    priority VARCHAR(20) DEFAULT 'medium',
    severity VARCHAR(20) DEFAULT 'medium',
    status VARCHAR(50) DEFAULT 'active',
    regulation_source VARCHAR(200),
    jurisdiction VARCHAR(100) DEFAULT 'South Africa',
    due_date TIMESTAMP,
    resolved_at TIMESTAMP,
    resolved_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Depositions table (enhanced)
CREATE TABLE depositions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id),
    case_name VARCHAR(500) NOT NULL,
    case_number VARCHAR(100),
    deponent_name VARCHAR(255) NOT NULL,
    deponent_role VARCHAR(100),
    deposition_date DATE NOT NULL,
    location VARCHAR(255),
    transcript_path VARCHAR(500),
    status VARCHAR(50) DEFAULT 'scheduled',
    duration_minutes INTEGER,
    court_reporter VARCHAR(255),
    attorneys_present TEXT[],
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Deposition Analyses table
CREATE TABLE deposition_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    deposition_id UUID REFERENCES depositions(id),
    analysis_type VARCHAR(100) DEFAULT 'comprehensive',
    key_topics TEXT[],
    sentiment_analysis JSONB,
    credibility_assessment JSONB,
    inconsistencies TEXT[],
    recommendations TEXT[],
    confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
    status VARCHAR(50) DEFAULT 'completed',
    analyzed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Case Timelines table
CREATE TABLE case_timelines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id),
    case_name VARCHAR(500) NOT NULL,
    case_number VARCHAR(100),
    description TEXT,
    status VARCHAR(50) DEFAULT 'active',
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Timeline Events table
CREATE TABLE timeline_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    timeline_id UUID REFERENCES case_timelines(id),
    document_id UUID REFERENCES documents(id),
    event_date DATE NOT NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    event_type VARCHAR(100),
    importance VARCHAR(20) DEFAULT 'medium',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Compliance Reports table
CREATE TABLE compliance_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id),
    title VARCHAR(500) NOT NULL,
    report_type VARCHAR(100) NOT NULL,
    period_start DATE,
    period_end DATE,
    overall_score INTEGER CHECK (overall_score >= 0 AND overall_score <= 100),
    total_documents INTEGER DEFAULT 0,
    compliant_documents INTEGER DEFAULT 0,
    non_compliant_documents INTEGER DEFAULT 0,
    recommendations TEXT[],
    generated_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Regulatory Updates table
CREATE TABLE regulatory_updates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(500) NOT NULL,
    description TEXT,
    regulation_source VARCHAR(200),
    category VARCHAR(100),
    effective_date DATE,
    impact_level VARCHAR(20) DEFAULT 'medium',
    status VARCHAR(50) DEFAULT 'active',
    url VARCHAR(500),
    jurisdiction VARCHAR(100) DEFAULT 'South Africa',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Document Analyses table (with status column)
CREATE TABLE document_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID REFERENCES documents(id),
    analysis_type VARCHAR(100) NOT NULL,
    status VARCHAR(50) DEFAULT 'completed',
    results JSONB,
    key_findings TEXT[],
    risk_factors TEXT[],
    compliance_issues TEXT[],
    recommendations TEXT[],
    confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
    analyzed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Document Comparisons table
CREATE TABLE document_comparisons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id),
    primary_document_id UUID REFERENCES documents(id),
    comparison_document_id UUID REFERENCES documents(id),
    comparison_type VARCHAR(100) DEFAULT 'contract',
    similarity_score DECIMAL(3,2) CHECK (similarity_score >= 0 AND similarity_score <= 1),
    differences JSONB,
    summary TEXT,
    risk_assessment JSONB,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Audit Logs table
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(100),
    resource_id UUID,
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- CREATE INDEXES FOR PERFORMANCE
-- =====================================================

-- Organizations indexes
CREATE INDEX idx_organizations_name ON organizations(name);
CREATE INDEX idx_organizations_type ON organizations(type);

-- Users indexes
CREATE INDEX idx_users_organization_id ON users(organization_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- Documents indexes
CREATE INDEX idx_documents_organization_id ON documents(organization_id);
CREATE INDEX idx_documents_type ON documents(type);
CREATE INDEX idx_documents_category ON documents(category);
CREATE INDEX idx_documents_status ON documents(status);
CREATE INDEX idx_documents_risk_level ON documents(risk_level);
CREATE INDEX idx_documents_created_at ON documents(created_at);
CREATE INDEX idx_documents_title ON documents USING gin(to_tsvector('english', title));

-- Tasks indexes
CREATE INDEX idx_tasks_organization_id ON tasks(organization_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);

-- Compliance indexes
CREATE INDEX idx_compliance_rules_organization_id ON compliance_rules(organization_id);
CREATE INDEX idx_compliance_rules_category ON compliance_rules(category);
CREATE INDEX idx_compliance_rules_title ON compliance_rules USING gin(to_tsvector('english', title));
CREATE INDEX idx_compliance_monitoring_organization_id ON compliance_monitoring(organization_id);
CREATE INDEX idx_compliance_alerts_organization_id ON compliance_alerts(organization_id);
CREATE INDEX idx_compliance_alerts_status ON compliance_alerts(status);
CREATE INDEX idx_compliance_alerts_priority ON compliance_alerts(priority);
CREATE INDEX idx_compliance_alerts_severity ON compliance_alerts(severity);

-- Depositions indexes
CREATE INDEX idx_depositions_organization_id ON depositions(organization_id);
CREATE INDEX idx_depositions_status ON depositions(status);
CREATE INDEX idx_depositions_date ON depositions(deposition_date);
CREATE INDEX idx_depositions_case_name ON depositions USING gin(to_tsvector('english', case_name));

-- Timeline indexes
CREATE INDEX idx_case_timelines_organization_id ON case_timelines(organization_id);
CREATE INDEX idx_timeline_events_timeline_id ON timeline_events(timeline_id);
CREATE INDEX idx_timeline_events_date ON timeline_events(event_date);

-- Reports indexes
CREATE INDEX idx_compliance_reports_organization_id ON compliance_reports(organization_id);
CREATE INDEX idx_compliance_reports_type ON compliance_reports(report_type);

-- Analysis indexes
CREATE INDEX idx_document_analyses_document_id ON document_analyses(document_id);
CREATE INDEX idx_document_analyses_status ON document_analyses(status);
CREATE INDEX idx_document_comparisons_organization_id ON document_comparisons(organization_id);

-- Audit indexes
CREATE INDEX idx_audit_logs_organization_id ON audit_logs(organization_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- =====================================================
-- INSERT COMPREHENSIVE SEED DATA
-- =====================================================

-- Insert Organizations
INSERT INTO organizations (id, name, type, industry, country) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Johannesburg Legal Firm', 'Law Firm', 'Legal Services', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440002', 'Cape Town Corporate Law', 'Law Firm', 'Corporate Law', 'South Africa');

-- Insert Users
INSERT INTO users (id, organization_id, email, name, role, department) VALUES
('550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440001', 'sarah.johnson@jhblegal.co.za', 'Sarah Johnson', 'Senior Partner', 'Corporate Law'),
('550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440001', 'michael.smith@jhblegal.co.za', 'Michael Smith', 'Associate', 'Compliance'),
('550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440002', 'linda.williams@ctclaw.co.za', 'Linda Williams', 'Compliance Officer', 'Risk Management');

-- Insert Documents
INSERT INTO documents (id, organization_id, title, type, category, status, risk_level, uploaded_by) VALUES
('550e8400-e29b-41d4-a716-446655440021', '550e8400-e29b-41d4-a716-446655440001', 'Employment Contract - Senior Developer', 'contract', 'employment', 'active', 'low', '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440022', '550e8400-e29b-41d4-a716-446655440001', 'Software License Agreement - TechCorp v2.0', 'contract', 'licensing', 'active', 'medium', '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440023', '550e8400-e29b-41d4-a716-446655440001', 'Non-Disclosure Agreement - Project Alpha', 'contract', 'confidentiality', 'active', 'high', '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440024', '550e8400-e29b-41d4-a716-446655440001', 'Service Level Agreement - Cloud Services', 'contract', 'service', 'active', 'medium', '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440025', '550e8400-e29b-41d4-a716-446655440002', 'Partnership Agreement - Strategic Alliance', 'contract', 'partnership', 'active', 'high', '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440026', '550e8400-e29b-41d4-a716-446655440002', 'Lease Agreement - Office Space Cape Town', 'contract', 'real_estate', 'active', 'low', '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440027', '550e8400-e29b-41d4-a716-446655440001', 'Compliance Policy - Data Protection', 'policy', 'compliance', 'active', 'high', '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440028', '550e8400-e29b-41d4-a716-446655440001', 'Risk Assessment Report - Q4 2024', 'report', 'risk_management', 'active', 'medium', '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440029', '550e8400-e29b-41d4-a716-446655440002', 'Merger Agreement - TechStart Acquisition', 'contract', 'merger', 'active', 'high', '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440030', '550e8400-e29b-41d4-a716-446655440001', 'Software License Agreement - TechCorp v1.0', 'contract', 'licensing', 'active', 'medium', '550e8400-e29b-41d4-a716-446655440011');

-- Insert Tasks with priority
INSERT INTO tasks (id, organization_id, title, description, type, status, priority, assigned_to, created_by, due_date) VALUES
('550e8400-e29b-41d4-a716-446655440041', '550e8400-e29b-41d4-a716-446655440001', 'Review Employment Contract Terms', 'Review and update standard employment contract terms for compliance with new labor laws', 'document_review', 'in_progress', 'high', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2024-12-30'),
('550e8400-e29b-41d4-a716-446655440042', '550e8400-e29b-41d4-a716-446655440001', 'Compliance Audit - Q4 2024', 'Conduct quarterly compliance audit for all active contracts', 'compliance_check', 'pending', 'critical', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2024-12-31'),
('550e8400-e29b-41d4-a716-446655440043', '550e8400-e29b-41d4-a716-446655440001', 'Update NDA Templates', 'Update non-disclosure agreement templates with latest legal requirements', 'template_update', 'completed', 'medium', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440011', '2024-12-15'),
('550e8400-e29b-41d4-a716-446655440044', '550e8400-e29b-41d4-a716-446655440002', 'Risk Assessment - New Partnership', 'Assess legal risks for the proposed strategic alliance partnership', 'risk_assessment', 'in_progress', 'high', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', '2024-12-28'),
('550e8400-e29b-41d4-a716-446655440045', '550e8400-e29b-41d4-a716-446655440001', 'Document Classification Review', 'Review and reclassify documents based on new risk assessment criteria', 'classification', 'pending', 'medium', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2025-01-15'),
('550e8400-e29b-41d4-a716-446655440046', '550e8400-e29b-41d4-a716-446655440002', 'Lease Renewal Negotiation', 'Negotiate terms for office lease renewal in Cape Town', 'negotiation', 'pending', 'low', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', '2025-01-31'),
('550e8400-e29b-41d4-a716-446655440047', '550e8400-e29b-41d4-a716-446655440001', 'Regulatory Update Review', 'Review and implement changes from latest POPIA amendments', 'regulatory_review', 'in_progress', 'high', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2024-12-20'),
('550e8400-e29b-41d4-a716-446655440048', '550e8400-e29b-41d4-a716-446655440002', 'Contract Comparison Analysis', 'Compare merger agreement terms with industry standards', 'analysis', 'pending', 'medium', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', '2025-01-10'),
('550e8400-e29b-41d4-a716-446655440049', '550e8400-e29b-41d4-a716-446655440001', 'Client Onboarding Documentation', 'Prepare legal documentation for new corporate client onboarding', 'documentation', 'completed', 'low', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440011', '2024-12-10'),
('550e8400-e29b-41d4-a716-446655440050', '550e8400-e29b-41d4-a716-446655440001', 'Training Material Update', 'Update compliance training materials for staff', 'training', 'failed', 'low', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2025-02-01');

-- Insert Compliance Rules with title
INSERT INTO compliance_rules (id, organization_id, title, name, description, category, regulation_source, risk_level, severity) VALUES
('550e8400-e29b-41d4-a716-446655440061', '550e8400-e29b-41d4-a716-446655440001', 'POPIA Data Protection Requirements', 'POPIA Data Protection Compliance', 'Ensure all contracts comply with Protection of Personal Information Act requirements', 'data_protection', 'POPIA (Act 4 of 2013)', 'high', 'high'),
('550e8400-e29b-41d4-a716-446655440062', '550e8400-e29b-41d4-a716-446655440001', 'Employment Equity Standards', 'Employment Equity Act Compliance', 'Verify employment contracts meet Employment Equity Act standards', 'employment', 'Employment Equity Act (Act 55 of 1998)', 'high', 'high'),
('550e8400-e29b-41d4-a716-446655440063', '550e8400-e29b-41d4-a716-446655440001', 'Consumer Protection Standards', 'Consumer Protection Act Compliance', 'Ensure service agreements comply with Consumer Protection Act', 'consumer_protection', 'Consumer Protection Act (Act 68 of 2008)', 'medium', 'medium'),
('550e8400-e29b-41d4-a716-446655440064', '550e8400-e29b-41d4-a716-446655440002', 'Corporate Governance Requirements', 'Companies Act Compliance', 'Verify corporate documents comply with Companies Act requirements', 'corporate', 'Companies Act (Act 71 of 2008)', 'high', 'high'),
('550e8400-e29b-41d4-a716-446655440065', '550e8400-e29b-41d4-a716-446655440001', 'Labour Relations Standards', 'Labour Relations Act Compliance', 'Ensure employment terms comply with Labour Relations Act', 'employment', 'Labour Relations Act (Act 66 of 1995)', 'medium', 'medium'),
('550e8400-e29b-41d4-a716-446655440066', '550e8400-e29b-41d4-a716-446655440002', 'Competition Law Requirements', 'Competition Act Compliance', 'Review merger agreements for Competition Act compliance', 'competition', 'Competition Act (Act 89 of 1998)', 'high', 'high'),
('550e8400-e29b-41d4-a716-446655440067', '550e8400-e29b-41d4-a716-446655440001', 'Electronic Communications Standards', 'Electronic Communications Act Compliance', 'Ensure digital contracts comply with Electronic Communications Act', 'electronic_communications', 'Electronic Communications Act (Act 36 of 2005)', 'medium', 'medium'),
('550e8400-e29b-41d4-a716-446655440068', '550e8400-e29b-41d4-a716-446655440002', 'B-BBEE Requirements', 'Broad-Based Black Economic Empowerment Compliance', 'Verify contracts meet B-BBEE requirements', 'empowerment', 'B-BBEE Act (Act 53 of 2003)', 'medium', 'medium');

-- Insert Compliance Monitoring with next_check_due
INSERT INTO compliance_monitoring (id, organization_id, rule_id, document_id, status, compliance_score, issues_found, next_check_due) VALUES
('550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440061', '550e8400-e29b-41d4-a716-446655440021', 'compliant', 95, 0, '2025-03-01'),
('550e8400-e29b-41d4-a716-446655440072', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440062', '550e8400-e29b-41d4-a716-446655440021', 'compliant', 88, 1, '2025-02-15'),
('550e8400-e29b-41d4-a716-446655440073', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440063', '550e8400-e29b-41d4-a716-446655440022', 'non_compliant', 65, 3, '2024-12-31'),
('550e8400-e29b-41d4-a716-446655440074', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440061', '550e8400-e29b-41d4-a716-446655440023', 'compliant', 92, 1, '2025-02-28'),
('550e8400-e29b-41d4-a716-446655440075', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440064', '550e8400-e29b-41d4-a716-446655440025', 'under_review', 78, 2, '2025-01-15'),
('550e8400-e29b-41d4-a716-446655440076', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440066', '550e8400-e29b-41d4-a716-446655440029', 'compliant', 85, 1, '2025-04-01'),
('550e8400-e29b-41d4-a716-446655440077', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440067', '550e8400-e29b-41d4-a716-446655440022', 'non_compliant', 58, 4, '2024-12-25'),
('550e8400-e29b-41d4-a716-446655440078', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440065', '550e8400-e29b-41d4-a716-446655440021', 'compliant', 90, 1, '2025-03-15');

-- Insert Compliance Alerts with all required columns
INSERT INTO compliance_alerts (id, organization_id, rule_id, document_id, title, description, type, priority, severity, status, regulation_source, jurisdiction, due_date) VALUES
('550e8400-e29b-41d4-a716-446655440081', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440063', '550e8400-e29b-41d4-a716-446655440022', 'Consumer Protection Act Violations Found', 'Software License Agreement contains clauses that may violate Consumer Protection Act requirements. Review and update required.', 'compliance_violation', 'high', 'high', 'active', 'Consumer Protection Act (Act 68 of 2008)', 'South Africa', '2024-12-25'),
('550e8400-e29b-41d4-a716-446655440082', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440067', '550e8400-e29b-41d4-a716-446655440022', 'Electronic Communications Act Non-Compliance', 'Digital signature requirements not met in Software License Agreement. Update electronic execution clauses.', 'compliance_violation', 'critical', 'high', 'active', 'Electronic Communications Act (Act 36 of 2005)', 'South Africa', '2024-12-30'),
('550e8400-e29b-41d4-a716-446655440083', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440064', '550e8400-e29b-41d4-a716-446655440025', 'Companies Act Review Required', 'Partnership Agreement requires review for Companies Act compliance. Director liability clauses need attention.', 'review_required', 'medium', 'medium', 'active', 'Companies Act (Act 71 of 2008)', 'South Africa', '2025-01-15'),
('550e8400-e29b-41d4-a716-446655440084', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440062', '550e8400-e29b-41d4-a716-446655440021', 'Employment Equity Minor Issue', 'Employment Contract has minor Employment Equity Act compliance issue. Update diversity reporting clause.', 'minor_issue', 'low', 'low', 'resolved', 'Employment Equity Act (Act 55 of 1998)', 'South Africa', '2025-01-31'),
('550e8400-e29b-41d4-a716-446655440085', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440061', '550e8400-e29b-41d4-a716-446655440023', 'POPIA Data Handling Update', 'NDA requires update to align with latest POPIA data handling requirements. Review data processing clauses.', 'update_required', 'medium', 'medium', 'active', 'POPIA (Act 4 of 2013)', 'South Africa', '2025-01-10'),
('550e8400-e29b-41d4-a716-446655440086', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440066', '550e8400-e29b-41d4-a716-446655440029', 'Competition Act Clearance Pending', 'Merger Agreement pending Competition Commission clearance. Monitor approval status and update terms if required.', 'pending_approval', 'medium', 'medium', 'active', 'Competition Act (Act 89 of 1998)', 'South Africa', '2025-02-28'),
('550e8400-e29b-41d4-a716-446655440087', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440065', '550e8400-e29b-41d4-a716-446655440021', 'Labour Relations Act Update', 'Employment Contract needs minor update for Labour Relations Act compliance. Review dispute resolution clauses.', 'update_required', 'low', 'low', 'resolved', 'Labour Relations Act (Act 66 of 1995)', 'South Africa', '2025-02-15'),
('550e8400-e29b-41d4-a716-446655440088', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440068', '550e8400-e29b-41d4-a716-446655440025', 'B-BBEE Compliance Check', 'Partnership Agreement requires B-BBEE compliance verification. Update procurement and supplier clauses.', 'compliance_check', 'medium', 'medium', 'active', 'B-BBEE Act (Act 53 of 2003)', 'South Africa', '2025-01-20'),
('550e8400-e29b-41d4-a716-446655440089', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440061', '550e8400-e29b-41d4-a716-446655440027', 'POPIA Policy Update Required', 'Data Protection Policy needs update to reflect latest POPIA amendments. Review consent mechanisms.', 'policy_update', 'high', 'high', 'active', 'POPIA (Act 4 of 2013)', 'South Africa', '2024-12-31'),
('550e8400-e29b-41d4-a716-446655440090', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440063', '550e8400-e29b-41d4-a716-446655440024', 'Consumer Protection Review', 'Service Level Agreement requires Consumer Protection Act compliance review. Update cancellation and refund terms.', 'review_required', 'medium', 'medium', 'resolved', 'Consumer Protection Act (Act 68 of 2008)', 'South Africa', '2025-01-05');

-- Insert Depositions with enhanced fields
INSERT INTO depositions (id, organization_id, case_name, case_number, deponent_name, deponent_role, deposition_date, location, status, duration_minutes, court_reporter, attorneys_present, created_by) VALUES
('550e8400-e29b-41d4-a716-446655440091', '550e8400-e29b-41d4-a716-446655440001', 'TechCorp vs DataSystems Ltd', 'HC-2024-001', 'John Mitchell', 'Chief Technology Officer', '2024-11-15', 'Johannesburg High Court', 'completed', 180, 'Mary Stevens', ARRAY['Sarah Johnson', 'Michael Smith'], '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440092', '550e8400-e29b-41d4-a716-446655440001', 'Employment Dispute - Smith vs ABC Corp', 'CCMA-2024-045', 'Robert Smith', 'Former Employee', '2024-11-20', 'CCMA Johannesburg', 'completed', 120, 'James Wilson', ARRAY['Michael Smith'], '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440093', '550e8400-e29b-41d4-a716-446655440002', 'Merger Investigation - Competition Commission', 'CC-2024-012', 'Dr. Sarah Williams', 'Economic Expert', '2024-12-01', 'Competition Tribunal Cape Town', 'completed', 240, 'Patricia Brown', ARRAY['Linda Williams'], '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440094', '550e8400-e29b-41d4-a716-446655440001', 'Contract Breach - Alpha vs Beta Solutions', 'HC-2024-078', 'Michael Johnson', 'Project Manager', '2024-12-10', 'Johannesburg Commercial Court', 'completed', 150, 'David Lee', ARRAY['Sarah Johnson'], '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440095', '550e8400-e29b-41d4-a716-446655440002', 'Property Dispute - Landlord vs Tenant', 'MC-2024-156', 'Lisa Anderson', 'Property Manager', '2024-12-15', 'Cape Town Magistrate Court', 'scheduled', NULL, 'TBD', ARRAY['Linda Williams'], '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440096', '550e8400-e29b-41d4-a716-446655440001', 'IP Infringement - Creative vs Copy Co', 'HC-2025-003', 'David Brown', 'Creative Director', '2025-01-08', 'Johannesburg High Court', 'scheduled', NULL, 'TBD', ARRAY['Sarah Johnson', 'Michael Smith'], '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440097', '550e8400-e29b-41d4-a716-446655440002', 'Partnership Dissolution - Partners vs Partners', 'HC-2025-007', 'Jennifer Davis', 'Managing Partner', '2025-01-15', 'Cape Town High Court', 'scheduled', NULL, 'TBD', ARRAY['Linda Williams'], '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440098', '550e8400-e29b-41d4-a716-446655440001', 'Regulatory Compliance - FSCA Investigation', 'FSCA-2025-001', 'Mark Thompson', 'Compliance Officer', '2025-01-22', 'FSCA Offices Johannesburg', 'scheduled', NULL, 'TBD', ARRAY['Michael Smith'], '550e8400-e29b-41d4-a716-446655440012');

-- Insert Deposition Analyses with status
INSERT INTO deposition_analyses (id, deposition_id, analysis_type, key_topics, sentiment_analysis, credibility_assessment, inconsistencies, recommendations, confidence_score, status) VALUES
('550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440091', 'comprehensive',
 ARRAY['contract terms', 'breach of agreement', 'damages calculation', 'timeline of events'], 
 '{"overall_sentiment": "negative", "confidence": 0.85, "emotional_indicators": ["frustration", "defensiveness"]}',
 '{"credibility_score": 0.78, "consistency_rating": "high", "body_language": "defensive", "verbal_cues": "hesitant"}',
 ARRAY['Date discrepancy in contract signing', 'Conflicting statements about meeting attendance'],
 ARRAY['Request additional documentation for timeline verification', 'Follow up on contract signing witnesses'],
 0.82, 'completed'),
('550e8400-e29b-41d4-a716-446655440102', '550e8400-e29b-41d4-a716-446655440092', 'comprehensive',
 ARRAY['workplace harassment', 'employment termination', 'procedural fairness', 'witness testimony'],
 '{"overall_sentiment": "distressed", "confidence": 0.92, "emotional_indicators": ["anxiety", "anger", "sadness"]}',
 '{"credibility_score": 0.88, "consistency_rating": "very_high", "body_language": "consistent", "verbal_cues": "clear"}',
 ARRAY['Minor inconsistency in timeline of reporting incidents'],
 ARRAY['Strong case for unfair dismissal', 'Recommend settlement negotiation', 'Gather additional witness statements'],
 0.89, 'completed'),
('550e8400-e29b-41d4-a716-446655440103', '550e8400-e29b-41d4-a716-446655440093', 'comprehensive',
 ARRAY['market concentration', 'competition effects', 'consumer impact', 'efficiency gains'],
 '{"overall_sentiment": "professional", "confidence": 0.95, "emotional_indicators": ["confidence", "expertise"]}',
 '{"credibility_score": 0.95, "consistency_rating": "very_high", "body_language": "professional", "verbal_cues": "expert"}',
 ARRAY[],
 ARRAY['Expert testimony supports merger approval', 'Economic analysis is comprehensive', 'Address minor consumer concern points'],
 0.94, 'completed'),
('550e8400-e29b-41d4-a716-446655440104', '550e8400-e29b-41d4-a716-446655440094', 'comprehensive',
 ARRAY['contract performance', 'delivery delays', 'quality issues', 'penalty clauses'],
 '{"overall_sentiment": "frustrated", "confidence": 0.80, "emotional_indicators": ["frustration", "blame-shifting"]}',
 '{"credibility_score": 0.65, "consistency_rating": "medium", "body_language": "evasive", "verbal_cues": "defensive"}',
 ARRAY['Conflicting statements about delivery dates', 'Inconsistent quality control procedures'],
 ARRAY['Investigate delivery documentation', 'Review quality control records', 'Consider mediation'],
 0.72, 'completed');

-- Insert Case Timelines
INSERT INTO case_timelines (id, organization_id, case_name, case_number, description, status, created_by) VALUES
('550e8400-e29b-41d4-a716-446655440111', '550e8400-e29b-41d4-a716-446655440001', 'TechCorp Contract Dispute', 'HC-2024-001', 'Timeline of events leading to contract breach and subsequent legal action', 'active', '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440112', '550e8400-e29b-41d4-a716-446655440002', 'Strategic Partnership Formation', 'PART-2024-001', 'Timeline of partnership negotiations and agreement finalization', 'active', '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440113', '550e8400-e29b-41d4-a716-446655440001', 'Employment Law Compliance Review', 'COMP-2024-001', 'Timeline of compliance review process and policy updates', 'completed', '550e8400-e29b-41d4-a716-446655440012');

-- Insert Timeline Events
INSERT INTO timeline_events (id, timeline_id, document_id, event_date, title, description, event_type, importance) VALUES
('550e8400-e29b-41d4-a716-446655440121', '550e8400-e29b-41d4-a716-446655440111', '550e8400-e29b-41d4-a716-446655440022', '2024-01-15', 'Initial Contract Signing', 'Software License Agreement v2.0 signed between parties', 'contract_execution', 'high'),
('550e8400-e29b-41d4-a716-446655440122', '550e8400-e29b-41d4-a716-446655440111', NULL, '2024-03-20', 'First Performance Review', 'Initial performance review meeting held, minor issues identified', 'meeting', 'medium'),
('550e8400-e29b-41d4-a716-446655440123', '550e8400-e29b-41d4-a716-446655440111', NULL, '2024-06-10', 'Breach Notice Issued', 'Formal breach notice issued due to non-compliance with service levels', 'legal_notice', 'high'),
('550e8400-e29b-41d4-a716-446655440124', '550e8400-e29b-41d4-a716-446655440111', NULL, '2024-08-05', 'Mediation Attempt', 'Mediation session conducted to resolve dispute amicably', 'mediation', 'high'),
('550e8400-e29b-41d4-a716-446655440125', '550e8400-e29b-41d4-a716-446655440111', NULL, '2024-11-15', 'Deposition Conducted', 'Key witness deposition conducted as part of litigation process', 'deposition', 'high'),
('550e8400-e29b-41d4-a716-446655440126', '550e8400-e29b-41d4-a716-446655440112', '550e8400-e29b-41d4-a716-446655440025', '2024-02-01', 'Partnership Proposal', 'Initial partnership proposal submitted and reviewed', 'proposal', 'high'),
('550e8400-e29b-41d4-a716-446655440127', '550e8400-e29b-41d4-a716-446655440112', NULL, '2024-04-15', 'Due Diligence Phase', 'Comprehensive due diligence process initiated', 'due_diligence', 'high'),
('550e8400-e29b-41d4-a716-446655440128', '550e8400-e29b-41d4-a716-446655440112', '550e8400-e29b-41d4-a716-446655440025', '2024-07-30', 'Agreement Finalization', 'Partnership Agreement finalized and executed', 'contract_execution', 'high'),
('550e8400-e29b-41d4-a716-446655440129', '550e8400-e29b-41d4-a716-446655440113', '550e8400-e29b-41d4-a716-446655440021', '2024-01-10', 'Compliance Review Initiated', 'Employment contract compliance review process started', 'review_start', 'medium'),
('550e8400-e29b-41d4-a716-446655440130', '550e8400-e29b-41d4-a716-446655440113', '550e8400-e29b-41d4-a716-446655440027', '2024-09-15', 'Policy Update Completed', 'Updated compliance policy implemented across organization', 'policy_update', 'high');

-- Insert Compliance Reports
INSERT INTO compliance_reports (id, organization_id, title, report_type, period_start, period_end, overall_score, total_documents, compliant_documents, non_compliant_documents, recommendations, generated_by) VALUES
('550e8400-e29b-41d4-a716-446655440131', '550e8400-e29b-41d4-a716-446655440001', 'Q4 2024 Compliance Assessment', 'quarterly', '2024-10-01', '2024-12-31', 78, 8, 6, 2, 
 ARRAY['Update Software License Agreement for Consumer Protection Act compliance', 'Review electronic signature requirements', 'Implement automated compliance monitoring'],
 '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440132', '550e8400-e29b-41d4-a716-446655440002', 'Annual Corporate Compliance Review 2024', 'annual', '2024-01-01', '2024-12-31', 85, 4, 3, 1,
 ARRAY['Complete Competition Commission clearance process', 'Update B-BBEE compliance documentation', 'Enhance corporate governance procedures'],
 '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440133', '550e8400-e29b-41d4-a716-446655440001', 'POPIA Compliance Audit', 'regulatory', '2024-01-01', '2024-12-31', 88, 5, 4, 1,
 ARRAY['Update data processing agreements', 'Enhance consent mechanisms', 'Implement data breach response procedures'],
 '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440134', '550e8400-e29b-41d4-a716-446655440001', 'Employment Law Compliance Review', 'regulatory', '2024-01-01', '2024-12-31', 92, 3, 3, 0,
 ARRAY['Maintain current high compliance standards', 'Regular policy updates recommended', 'Continue staff training programs'],
 '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440135', '550e8400-e29b-41d4-a716-446655440002', 'Contract Risk Assessment Report', 'risk_assessment', '2024-07-01', '2024-12-31', 75, 4, 2, 2,
 ARRAY['Review high-risk merger agreement terms', 'Implement enhanced due diligence procedures', 'Update contract templates'],
 '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440136', '550e8400-e29b-41d4-a716-446655440001', 'Document Classification Audit', 'operational', '2024-11-01', '2024-12-31', 82, 8, 6, 2,
 ARRAY['Reclassify medium-risk documents', 'Implement automated risk scoring', 'Update document retention policies'],
 '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440137', '550e8400-e29b-41d4-a716-446655440002', 'Regulatory Update Impact Assessment', 'regulatory', '2024-01-01', '2024-12-31', 80, 4, 3, 1,
 ARRAY['Monitor upcoming regulatory changes', 'Update compliance monitoring systems', 'Enhance legal research capabilities'],
 '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440138', '550e8400-e29b-41d4-a716-446655440001', 'Client Onboarding Compliance Review', 'operational', '2024-01-01', '2024-12-31', 95, 2, 2, 0,
 ARRAY['Excellent compliance standards maintained', 'Continue current procedures', 'Consider process automation opportunities'],
 '550e8400-e29b-41d4-a716-446655440011');

-- Insert Regulatory Updates with jurisdiction
INSERT INTO regulatory_updates (id, title, description, regulation_source, category, effective_date, impact_level, status, jurisdiction) VALUES
('550e8400-e29b-41d4-a716-446655440141', 'POPIA Amendment Regulations 2024', 'New regulations under POPIA regarding cross-border data transfers and consent mechanisms', 'POPIA (Act 4 of 2013)', 'data_protection', '2024-07-01', 'high', 'active', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440142', 'Companies Act Amendment - Director Liability', 'Updated director liability provisions and corporate governance requirements', 'Companies Act (Act 71 of 2008)', 'corporate', '2024-09-01', 'high', 'active', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440143', 'Consumer Protection Act Regulations Update', 'New regulations on electronic transactions and consumer rights in digital services', 'Consumer Protection Act (Act 68 of 2008)', 'consumer_protection', '2024-06-15', 'medium', 'active', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440144', 'Competition Commission Merger Guidelines', 'Updated guidelines for merger notifications and competition assessment criteria', 'Competition Act (Act 89 of 1998)', 'competition', '2024-08-01', 'medium', 'active', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440145', 'Employment Equity Amendment Regulations', 'New reporting requirements and transformation targets for designated employers', 'Employment Equity Act (Act 55 of 1998)', 'employment', '2024-10-01', 'medium', 'active', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440146', 'B-BBEE Codes Amendment 2024', 'Updated B-BBEE codes with new scoring criteria and verification requirements', 'B-BBEE Act (Act 53 of 2003)', 'empowerment', '2024-05-01', 'medium', 'active', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440147', 'Electronic Communications Act Regulations', 'New cybersecurity and data localization requirements for electronic communications', 'Electronic Communications Act (Act 36 of 2005)', 'electronic_communications', '2024-11-01', 'high', 'active', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440148', 'Labour Relations Act Amendment - Remote Work', 'New provisions for remote work arrangements and digital workplace policies', 'Labour Relations Act (Act 66 of 1995)', 'employment', '2025-01-01', 'medium', 'pending', 'South Africa');

-- Insert Document Analyses with status
INSERT INTO document_analyses (id, document_id, analysis_type, status, results, key_findings, risk_factors, compliance_issues, recommendations, confidence_score) VALUES
('550e8400-e29b-41d4-a716-446655440151', '550e8400-e29b-41d4-a716-446655440021', 'compliance_check', 'completed',
 '{"overall_compliance": 88, "popia_score": 95, "employment_equity_score": 85, "labour_relations_score": 90}',
 ARRAY['Strong data protection clauses', 'Clear termination procedures', 'Comprehensive benefits package'],
 ARRAY['Minor employment equity reporting gap'],
 ARRAY['Employment equity reporting clause needs update'],
 ARRAY['Update diversity reporting requirements', 'Add remote work policy clauses'],
 0.92),
('550e8400-e29b-41d4-a716-446655440152', '550e8400-e29b-41d4-a716-446655440022', 'compliance_check', 'completed',
 '{"overall_compliance": 65, "consumer_protection_score": 58, "electronic_communications_score": 72}',
 ARRAY['Comprehensive licensing terms', 'Clear usage restrictions'],
 ARRAY['Consumer protection violations', 'Electronic signature requirements not met'],
 ARRAY['Unfair contract terms identified', 'Digital signature clauses missing'],
 ARRAY['Remove unfair cancellation terms', 'Add electronic signature provisions', 'Update consumer rights section'],
 0.85),
('550e8400-e29b-41d4-a716-446655440153', '550e8400-e29b-41d4-a716-446655440023', 'compliance_check', 'completed',
 '{"overall_compliance": 92, "popia_score": 95, "confidentiality_score": 90}',
 ARRAY['Strong confidentiality provisions', 'Clear data handling requirements', 'Appropriate duration terms'],
 ARRAY['Minor data processing clause ambiguity'],
 ARRAY['Data processing purposes could be more specific'],
 ARRAY['Clarify data processing purposes', 'Add data retention schedule'],
 0.90),
('550e8400-e29b-41d4-a716-446655440154', '550e8400-e29b-41d4-a716-446655440024', 'compliance_check', 'completed',
 '{"overall_compliance": 75, "consumer_protection_score": 70, "service_delivery_score": 80}',
 ARRAY['Clear service level definitions', 'Appropriate penalty structures'],
 ARRAY['Consumer protection compliance gaps', 'Cancellation terms may be unfair'],
 ARRAY['Cancellation notice period too short', 'Refund terms unclear'],
 ARRAY['Extend cancellation notice period', 'Clarify refund procedures', 'Add consumer rights notice'],
 0.82),
('550e8400-e29b-41d4-a716-446655440155', '550e8400-e29b-41d4-a716-446655440025', 'compliance_check', 'completed',
 '{"overall_compliance": 78, "companies_act_score": 75, "competition_act_score": 80, "bbbee_score": 75}',
 ARRAY['Comprehensive partnership structure', 'Clear governance arrangements'],
 ARRAY['Competition Commission approval pending', 'B-BBEE compliance verification needed'],
 ARRAY['Competition clearance required', 'B-BBEE verification certificates needed'],
 ARRAY['Obtain Competition Commission clearance', 'Update B-BBEE compliance documentation', 'Review director liability clauses'],
 0.85),
('550e8400-e29b-41d4-a716-446655440156', '550e8400-e29b-41d4-a716-446655440027', 'policy_review', 'completed',
 '{"policy_effectiveness": 90, "popia_alignment": 95, "implementation_score": 85}',
 ARRAY['Comprehensive data protection framework', 'Clear consent mechanisms', 'Strong breach response procedures'],
 ARRAY['Implementation monitoring could be enhanced'],
 ARRAY['Regular review schedule needs formalization'],
 ARRAY['Implement quarterly policy reviews', 'Enhance staff training programs', 'Add automated compliance monitoring'],
 0.88),
('550e8400-e29b-41d4-a716-446655440157', '550e8400-e29b-41d4-a716-446655440029', 'compliance_check', 'completed',
 '{"overall_compliance": 82, "companies_act_score": 85, "competition_act_score": 80}',
 ARRAY['Well-structured merger terms', 'Clear valuation methodology', 'Appropriate due diligence provisions'],
 ARRAY['Competition Commission approval timeline uncertain'],
 ARRAY['Regulatory approval conditions pending'],
 ARRAY['Monitor Competition Commission approval process', 'Prepare for potential condition modifications', 'Update closing conditions'],
 0.87),
('550e8400-e29b-41d4-a716-446655440158', '550e8400-e29b-41d4-a716-446655440030', 'version_comparison', 'completed',
 '{"similarity_score": 0.85, "key_differences": 12, "risk_changes": 3}',
 ARRAY['Version 1.0 to 2.0 comparison completed', 'Significant terms updates identified'],
 ARRAY['New liability limitations added', 'Payment terms modified', 'Termination clauses updated'],
 ARRAY['Review impact of new liability limitations', 'Assess payment term changes'],
 ARRAY['Analyze liability limitation impact', 'Review payment term modifications', 'Update internal procedures for v2.0'],
 0.90),
('550e8400-e29b-41d4-a716-446655440159', '550e8400-e29b-41d4-a716-446655440026', 'compliance_check', 'completed',
 '{"overall_compliance": 95, "property_law_score": 95, "consumer_protection_score": 95}',
 ARRAY['Standard lease terms compliant', 'Fair rental escalation clauses', 'Appropriate maintenance responsibilities'],
 ARRAY['No significant risks identified'],
 ARRAY['Excellent compliance standards maintained'],
 ARRAY['Continue current lease management practices', 'Monitor rental market conditions'],
 0.95),
('550e8400-e29b-41d4-a716-446655440160', '550e8400-e29b-41d4-a716-446655440028', 'risk_assessment', 'completed',
 '{"overall_risk_score": 72, "operational_risk": 70, "compliance_risk": 75, "financial_risk": 70}',
 ARRAY['Comprehensive risk framework', 'Regular monitoring procedures', 'Clear escalation protocols'],
 ARRAY['Some operational risks require enhanced monitoring', 'Compliance risk management could be automated'],
 ARRAY['Manual compliance monitoring processes', 'Limited predictive risk analytics'],
 ARRAY['Implement automated compliance monitoring', 'Develop predictive risk models', 'Enhance operational risk controls'],
 0.85);

-- Insert Document Comparisons
INSERT INTO document_comparisons (id, organization_id, primary_document_id, comparison_document_id, comparison_type, similarity_score, differences, summary, risk_assessment, created_by) VALUES
('550e8400-e29b-41d4-a716-446655440161', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440022', '550e8400-e29b-41d4-a716-446655440030', 'contract', 0.85,
 '{"term_changes": 12, "liability_modifications": 3, "payment_updates": 2, "new_clauses": 4, "removed_clauses": 1}',
 'Software License Agreement comparison between v2.0 and v1.0 shows significant updates in liability terms, payment structures, and termination clauses. Overall similarity is high with targeted improvements.',
 '{"risk_level": "medium", "key_risks": ["increased liability exposure", "modified payment terms"], "recommendations": ["review liability impact", "assess payment changes"]}',
 '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440162', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440025', '550e8400-e29b-41d4-a716-446655440029', 'contract', 0.45,
 '{"structural_differences": 25, "scope_variations": 8, "governance_changes": 12, "financial_terms": 15}',
 'Partnership Agreement vs Merger Agreement comparison reveals fundamental structural differences. Partnership focuses on collaboration while merger involves acquisition. Different risk profiles and governance structures.',
 '{"risk_level": "high", "key_risks": ["different legal structures", "varying liability exposure", "distinct governance requirements"], "recommendations": ["separate legal analysis required", "different compliance frameworks"]}',
 '550e8400-e29b-41d4-a716-446655440013');

-- Insert Audit Logs
INSERT INTO audit_logs (id, organization_id, user_id, action, resource_type, resource_id, details) VALUES
('550e8400-e29b-41d4-a716-446655440171', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440011', 'document_upload', 'document', '550e8400-e29b-41d4-a716-446655440021', '{"filename": "employment_contract_senior_dev.pdf", "size": 245760, "type": "contract"}'),
('550e8400-e29b-41d4-a716-446655440172', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440012', 'compliance_check', 'document', '550e8400-e29b-41d4-a716-446655440022', '{"analysis_type": "compliance_check", "score": 65, "issues_found": 3}'),
('550e8400-e29b-41d4-a716-446655440173', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440012', 'alert_created', 'compliance_alert', '550e8400-e29b-41d4-a716-446655440081', '{"alert_type": "compliance_violation", "priority": "high", "regulation": "Consumer Protection Act"}'),
('550e8400-e29b-41d4-a716-446655440174', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440013', 'deposition_scheduled', 'deposition', '550e8400-e29b-41d4-a716-446655440095', '{"case_name": "Property Dispute", "deponent": "Lisa Anderson", "date": "2024-12-15"}'),
('550e8400-e29b-41d4-a716-446655440175', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440011', 'report_generated', 'compliance_report', '550e8400-e29b-41d4-a716-446655440131', '{"report_type": "quarterly", "period": "Q4 2024", "overall_score": 78}'),
('550e8400-e29b-41d4-a716-446655440176', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440012', 'task_completed', 'task', '550e8400-e29b-41d4-a716-446655440043', '{"task_type": "template_update", "completion_time": "2024-12-15T10:30:00Z"}'),
('550e8400-e29b-41d4-a716-446655440177', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440013', 'document_comparison', 'document_comparison', '550e8400-e29b-41d4-a716-446655440161', '{"primary_doc": "Software License v2.0", "comparison_doc": "Software License v1.0", "similarity": 0.85}'),
('550e8400-e29b-41d4-a716-446655440178', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440011', 'timeline_created', 'case_timeline', '550e8400-e29b-41d4-a716-446655440111', '{"case_name": "TechCorp Contract Dispute", "events_count": 5}');

-- =====================================================
-- CREATE OPTIMIZED VIEWS
-- =====================================================

-- Active Compliance Alerts View
CREATE VIEW active_compliance_alerts AS
SELECT 
    ca.id,
    ca.title,
    ca.description,
    ca.priority,
    ca.severity,
    ca.status,
    ca.regulation_source,
    ca.jurisdiction,
    ca.due_date,
    ca.created_at,
    cr.name as rule_name,
    cr.category as rule_category,
    d.title as document_title,
    d.type as document_type,
    o.name as organization_name
FROM compliance_alerts ca
LEFT JOIN compliance_rules cr ON ca.rule_id = cr.id
LEFT JOIN documents d ON ca.document_id = d.id
LEFT JOIN organizations o ON ca.organization_id = o.id
WHERE ca.status = 'active'
ORDER BY 
    CASE ca.priority 
        WHEN 'critical' THEN 1 
        WHEN 'high' THEN 2 
        WHEN 'medium' THEN 3 
        WHEN 'low' THEN 4 
    END,
    ca.due_date ASC NULLS LAST;

-- Recent Depositions View
CREATE VIEW recent_depositions AS
SELECT 
    d.id,
    d.case_name,
    d.case_number,
    d.deponent_name,
    d.deponent_role,
    d.deposition_date,
    d.location,
    d.status,
    d.duration_minutes,
    d.created_at,
    da.key_topics,
    da.confidence_score,
    da.status as analysis_status,
    o.name as organization_name,
    u.name as created_by_name
FROM depositions d
LEFT JOIN deposition_analyses da ON d.id = da.deposition_id
LEFT JOIN organizations o ON d.organization_id = o.id
LEFT JOIN users u ON d.created_by = u.id
ORDER BY d.deposition_date DESC, d.created_at DESC;

-- Dashboard Summary View
CREATE VIEW dashboard_summary AS
SELECT 
    o.id as organization_id,
    o.name as organization_name,
    COUNT(DISTINCT d.id) as total_documents,
    COUNT(DISTINCT CASE WHEN d.status = 'active' THEN d.id END) as active_documents,
    COUNT(DISTINCT t.id) as total_tasks,
    COUNT(DISTINCT CASE WHEN t.status = 'pending' THEN t.id END) as pending_tasks,
    COUNT(DISTINCT CASE WHEN t.status = 'completed' THEN t.id END) as completed_tasks,
    COUNT(DISTINCT ca.id) as total_alerts,
    COUNT(DISTINCT CASE WHEN ca.status = 'active' THEN ca.id END) as active_alerts,
    COUNT(DISTINCT CASE WHEN ca.priority = 'critical' THEN ca.id END) as critical_alerts,
    ROUND(
        CASE 
            WHEN COUNT(DISTINCT cm.id) > 0 
            THEN AVG(cm.compliance_score)::numeric 
            ELSE 0 
        END, 2
    ) as avg_compliance_score
FROM organizations o
LEFT JOIN documents d ON o.id = d.organization_id
LEFT JOIN tasks t ON o.id = t.organization_id
LEFT JOIN compliance_alerts ca ON o.id = ca.organization_id
LEFT JOIN compliance_monitoring cm ON o.id = cm.organization_id
GROUP BY o.id, o.name;

-- Document Analytics View
CREATE VIEW document_analytics AS
SELECT 
    d.id,
    d.title,
    d.type,
    d.category,
    d.risk_level,
    d.status,
    d.created_at,
    da.analysis_type,
    da.status as analysis_status,
    da.confidence_score,
    COALESCE(array_length(da.key_findings, 1), 0) as findings_count,
    COALESCE(array_length(da.risk_factors, 1), 0) as risk_factors_count,
    COALESCE(array_length(da.compliance_issues, 1), 0) as compliance_issues_count,
    o.name as organization_name,
    u.name as uploaded_by_name
FROM documents d
LEFT JOIN document_analyses da ON d.id = da.document_id
LEFT JOIN organizations o ON d.organization_id = o.id
LEFT JOIN users u ON d.uploaded_by = u.id
ORDER BY d.created_at DESC;

-- Compliance Overview View
CREATE VIEW compliance_overview AS
SELECT 
    cr.category,
    COUNT(DISTINCT cr.id) as total_rules,
    COUNT(DISTINCT cm.id) as monitored_items,
    COUNT(DISTINCT CASE WHEN cm.status = 'compliant' THEN cm.id END) as compliant_items,
    COUNT(DISTINCT CASE WHEN cm.status = 'non_compliant' THEN cm.id END) as non_compliant_items,
    COUNT(DISTINCT CASE WHEN ca.status = 'active' THEN ca.id END) as active_alerts,
    ROUND(
        CASE 
            WHEN COUNT(DISTINCT cm.id) > 0 
            THEN (COUNT(DISTINCT CASE WHEN cm.status = 'compliant' THEN cm.id END)::numeric / COUNT(DISTINCT cm.id)::numeric) * 100 
            ELSE 0 
        END, 2
    ) as compliance_rate,
    cr.category as name,
    CASE 
        WHEN COUNT(DISTINCT CASE WHEN ca.priority = 'critical' THEN ca.id END) > 0 THEN 'critical'
        WHEN COUNT(DISTINCT CASE WHEN ca.priority = 'high' THEN ca.id END) > 0 THEN 'high'
        WHEN COUNT(DISTINCT CASE WHEN ca.priority = 'medium' THEN ca.id END) > 0 THEN 'medium'
        ELSE 'low'
    END as status
FROM compliance_rules cr
LEFT JOIN compliance_monitoring cm ON cr.id = cm.rule_id
LEFT JOIN compliance_alerts ca ON cr.id = ca.rule_id AND ca.status = 'active'
GROUP BY cr.category
ORDER BY compliance_rate DESC;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Verify table creation
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables 
WHERE schemaname = 'public' 
    AND tablename IN (
        'organizations', 'users', 'documents', 'tasks', 'compliance_rules',
        'compliance_monitoring', 'compliance_alerts', 'depositions', 'deposition_analyses',
        'case_timelines', 'timeline_events', 'compliance_reports', 'regulatory_updates',
        'document_analyses', 'document_comparisons', 'audit_logs'
    )
ORDER BY tablename;

-- Verify view creation
SELECT 
    schemaname,
    viewname,
    viewowner
FROM pg_views 
WHERE schemaname = 'public'
    AND viewname IN (
        'active_compliance_alerts', 'recent_depositions', 'dashboard_summary',
        'document_analytics', 'compliance_overview'
    )
ORDER BY viewname;

-- Verify data insertion
SELECT 
    'organizations' as table_name, COUNT(*) as record_count FROM organizations
UNION ALL
SELECT 'users', COUNT(*) FROM users
UNION ALL
SELECT 'documents', COUNT(*) FROM documents
UNION ALL
SELECT 'tasks', COUNT(*) FROM tasks
UNION ALL
SELECT 'compliance_rules', COUNT(*) FROM compliance_rules
UNION ALL
SELECT 'compliance_monitoring', COUNT(*) FROM compliance_monitoring
UNION ALL
SELECT 'compliance_alerts', COUNT(*) FROM compliance_alerts
UNION ALL
SELECT 'depositions', COUNT(*) FROM depositions
UNION ALL
SELECT 'deposition_analyses', COUNT(*) FROM deposition_analyses
UNION ALL
SELECT 'case_timelines', COUNT(*) FROM case_timelines
UNION ALL
SELECT 'timeline_events', COUNT(*) FROM timeline_events
UNION ALL
SELECT 'compliance_reports', COUNT(*) FROM compliance_reports
UNION ALL
SELECT 'regulatory_updates', COUNT(*) FROM regulatory_updates
UNION ALL
SELECT 'document_analyses', COUNT(*) FROM document_analyses
UNION ALL
SELECT 'document_comparisons', COUNT(*) FROM document_comparisons
UNION ALL
SELECT 'audit_logs', COUNT(*) FROM audit_logs
ORDER BY table_name;

-- Success message
SELECT 'DATABASE SETUP COMPLETED SUCCESSFULLY!' as status,
       'All 16 tables created with proper schema' as tables_status,
       'All 5 views created successfully' as views_status,
       'Comprehensive seed data inserted' as data_status,
       'Performance indexes created' as performance_status,
       'Ready for Legal AI application!' as ready_status;
