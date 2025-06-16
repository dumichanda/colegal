-- =====================================================
-- COMPLETE LEGAL AI DATABASE REBUILD WITH FULL DATA
-- This script drops everything and rebuilds with comprehensive data
-- Run this ONCE in your Neon database to fix everything
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. DROP EVERYTHING (CLEAN SLATE)
-- =====================================================

-- Drop all views first
DROP VIEW IF EXISTS document_generation_stats CASCADE;
DROP VIEW IF EXISTS active_compliance_alerts CASCADE;
DROP VIEW IF EXISTS recent_depositions CASCADE;
DROP VIEW IF EXISTS dashboard_summary CASCADE;
DROP VIEW IF EXISTS document_analytics CASCADE;
DROP VIEW IF EXISTS compliance_overview CASCADE;

-- Drop all tables in correct order (foreign keys first)
DROP TABLE IF EXISTS document_generation_log CASCADE;
DROP TABLE IF EXISTS file_storage_config CASCADE;
DROP TABLE IF EXISTS document_templates CASCADE;
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

-- Drop functions
DROP FUNCTION IF EXISTS cleanup_old_generated_files();
DROP FUNCTION IF EXISTS update_updated_at_column();

-- =====================================================
-- 2. CREATE ALL TABLES
-- =====================================================

-- Organizations table
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    type VARCHAR(100) NOT NULL,
    industry VARCHAR(100),
    country VARCHAR(100) DEFAULT 'South Africa',
    address TEXT,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(50),
    registration_number VARCHAR(100),
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
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
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
    mime_type VARCHAR(100) DEFAULT 'application/pdf',
    status VARCHAR(50) DEFAULT 'active',
    risk_level VARCHAR(20) DEFAULT 'medium',
    template_type VARCHAR(100),
    generation_status VARCHAR(50) DEFAULT 'completed',
    generated_at TIMESTAMP,
    file_hash VARCHAR(64),
    uploaded_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tasks table
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

-- Compliance Rules table
CREATE TABLE compliance_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id),
    name VARCHAR(500) NOT NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    regulation_source VARCHAR(200),
    risk_level VARCHAR(20) DEFAULT 'medium',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Compliance Monitoring table
CREATE TABLE compliance_monitoring (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id),
    rule_id UUID REFERENCES compliance_rules(id),
    document_id UUID REFERENCES documents(id),
    status VARCHAR(50) NOT NULL,
    compliance_score INTEGER CHECK (compliance_score >= 0 AND compliance_score <= 100),
    issues_found INTEGER DEFAULT 0,
    last_checked TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    next_check_due TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Compliance Alerts table
CREATE TABLE compliance_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id),
    rule_id UUID REFERENCES compliance_rules(id),
    document_id UUID REFERENCES documents(id),
    title VARCHAR(500) NOT NULL,
    description TEXT,
    priority VARCHAR(20) DEFAULT 'Medium',
    type VARCHAR(100) DEFAULT 'compliance',
    status VARCHAR(50) DEFAULT 'active',
    due_date TIMESTAMP,
    regulation_source VARCHAR(200),
    jurisdiction VARCHAR(100) DEFAULT 'South Africa',
    resolved_at TIMESTAMP,
    resolved_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Depositions table
CREATE TABLE depositions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id),
    case_name VARCHAR(500) NOT NULL,
    case_number VARCHAR(100),
    deponent_name VARCHAR(255) NOT NULL,
    deponent_role VARCHAR(100),
    date_conducted DATE NOT NULL,
    location VARCHAR(255),
    transcript_path VARCHAR(500),
    transcript_content TEXT,
    duration_minutes INTEGER,
    status VARCHAR(50) DEFAULT 'scheduled',
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Deposition Analyses table
CREATE TABLE deposition_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    deposition_id UUID REFERENCES depositions(id),
    analysis_type VARCHAR(100) NOT NULL,
    key_topics TEXT[],
    sentiment_analysis JSONB,
    credibility_assessment JSONB,
    inconsistencies TEXT[],
    recommendations TEXT[],
    confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
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
    timeline_data JSONB DEFAULT '[]',
    document_ids UUID[],
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
    report_data JSONB DEFAULT '{}',
    status VARCHAR(50) DEFAULT 'generated',
    file_path TEXT,
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
    jurisdiction VARCHAR(100) DEFAULT 'South Africa',
    effective_date DATE,
    impact_level VARCHAR(20) DEFAULT 'medium',
    status VARCHAR(50) DEFAULT 'active',
    url VARCHAR(500),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Document Analyses table
CREATE TABLE document_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID REFERENCES documents(id),
    analysis_type VARCHAR(100) NOT NULL,
    results JSONB,
    key_findings TEXT[],
    risk_factors TEXT[],
    compliance_issues TEXT[],
    recommendations TEXT[],
    confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
    status VARCHAR(50) DEFAULT 'completed',
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
    similarities JSONB,
    analysis_summary TEXT,
    summary TEXT,
    risk_assessment JSONB,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Document Templates table
CREATE TABLE document_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_name VARCHAR(100) UNIQUE NOT NULL,
    template_type VARCHAR(100) NOT NULL,
    display_name VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    default_content TEXT,
    required_fields JSONB,
    optional_fields JSONB,
    compliance_requirements TEXT[],
    applicable_laws TEXT[],
    risk_level VARCHAR(20) DEFAULT 'medium',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Document Generation Log table
CREATE TABLE document_generation_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID REFERENCES documents(id),
    template_used VARCHAR(100),
    generation_status VARCHAR(50) NOT NULL,
    generation_time_ms INTEGER,
    file_size_bytes INTEGER,
    error_message TEXT,
    generated_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- File Storage Config table
CREATE TABLE file_storage_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    storage_type VARCHAR(50) NOT NULL,
    base_path VARCHAR(500) NOT NULL,
    max_file_size_mb INTEGER DEFAULT 50,
    allowed_mime_types TEXT[],
    retention_days INTEGER DEFAULT 365,
    is_active BOOLEAN DEFAULT true,
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
-- 3. CREATE INDEXES
-- =====================================================

CREATE INDEX idx_organizations_name ON organizations(name);
CREATE INDEX idx_users_organization_id ON users(organization_id);
CREATE INDEX idx_documents_organization_id ON documents(organization_id);
CREATE INDEX idx_documents_type ON documents(type);
CREATE INDEX idx_documents_status ON documents(status);
CREATE INDEX idx_tasks_organization_id ON tasks(organization_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_compliance_rules_organization_id ON compliance_rules(organization_id);
CREATE INDEX idx_compliance_rules_category ON compliance_rules(category);
CREATE INDEX idx_compliance_monitoring_organization_id ON compliance_monitoring(organization_id);
CREATE INDEX idx_compliance_alerts_organization_id ON compliance_alerts(organization_id);
CREATE INDEX idx_compliance_alerts_status ON compliance_alerts(status);
CREATE INDEX idx_compliance_alerts_priority ON compliance_alerts(priority);
CREATE INDEX idx_depositions_organization_id ON depositions(organization_id);
CREATE INDEX idx_depositions_status ON depositions(status);
CREATE INDEX idx_depositions_date ON depositions(date_conducted);
CREATE INDEX idx_deposition_analyses_deposition_id ON deposition_analyses(deposition_id);
CREATE INDEX idx_case_timelines_organization_id ON case_timelines(organization_id);
CREATE INDEX idx_timeline_events_timeline_id ON timeline_events(timeline_id);
CREATE INDEX idx_compliance_reports_organization_id ON compliance_reports(organization_id);
CREATE INDEX idx_document_analyses_document_id ON document_analyses(document_id);
CREATE INDEX idx_document_comparisons_organization_id ON document_comparisons(organization_id);
CREATE INDEX idx_audit_logs_organization_id ON audit_logs(organization_id);

-- =====================================================
-- 4. INSERT COMPREHENSIVE DATA
-- =====================================================

-- Insert Organizations
INSERT INTO organizations (id, name, type, industry, country, address, contact_email) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Johannesburg Legal Firm', 'Law Firm', 'Legal Services', 'South Africa', '123 Commissioner Street, Johannesburg, 2001', 'info@jhblegal.co.za'),
('550e8400-e29b-41d4-a716-446655440002', 'Cape Town Corporate Law', 'Law Firm', 'Corporate Law', 'South Africa', '456 Long Street, Cape Town, 8001', 'contact@ctclaw.co.za'),
('550e8400-e29b-41d4-a716-446655440003', 'Pretoria Legal Associates', 'Law Firm', 'Commercial Law', 'South Africa', '789 Church Street, Pretoria, 0002', 'legal@ptaassoc.co.za');

-- Insert Users
INSERT INTO users (id, organization_id, email, name, role, department) VALUES
('550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440001', 'sarah.johnson@jhblegal.co.za', 'Sarah Johnson', 'Senior Partner', 'Corporate Law'),
('550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440001', 'michael.smith@jhblegal.co.za', 'Michael Smith', 'Associate', 'Compliance'),
('550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440002', 'linda.williams@ctclaw.co.za', 'Linda Williams', 'Compliance Officer', 'Risk Management'),
('550e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440003', 'david.brown@ptaassoc.co.za', 'David Brown', 'Senior Associate', 'Commercial Law'),
('550e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440001', 'emma.davis@jhblegal.co.za', 'Emma Davis', 'Paralegal', 'Litigation');

-- Insert Documents (20 documents)
INSERT INTO documents (id, organization_id, title, type, category, content, template_type, file_path, file_size, status, risk_level, uploaded_by, generated_at) VALUES
('550e8400-e29b-41d4-a716-446655440021', '550e8400-e29b-41d4-a716-446655440001', 'Employment Contract - Senior Developer', 'contract', 'employment', 'Employment contract for senior software developer position with comprehensive terms and conditions.', 'employment_contract', '/documents/employment_contract_001.pdf', 156789, 'active', 'low', '550e8400-e29b-41d4-a716-446655440011', CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440022', '550e8400-e29b-41d4-a716-446655440001', 'Software License Agreement - TechCorp v2.0', 'contract', 'licensing', 'Comprehensive software licensing agreement with TechCorp for enterprise software suite.', 'software_license', '/documents/software_license_002.pdf', 198765, 'active', 'medium', '550e8400-e29b-41d4-a716-446655440011', CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440023', '550e8400-e29b-41d4-a716-446655440001', 'Non-Disclosure Agreement - Project Alpha', 'contract', 'confidentiality', 'Confidentiality agreement for sensitive project information and trade secrets.', 'nda', '/documents/nda_003.pdf', 134567, 'active', 'high', '550e8400-e29b-41d4-a716-446655440012', CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440024', '550e8400-e29b-41d4-a716-446655440001', 'Service Level Agreement - Cloud Services', 'contract', 'service', 'SLA defining service delivery standards for cloud infrastructure services.', 'service_agreement', '/documents/sla_004.pdf', 176543, 'active', 'medium', '550e8400-e29b-41d4-a716-446655440011', CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440025', '550e8400-e29b-41d4-a716-446655440002', 'Partnership Agreement - Strategic Alliance', 'contract', 'partnership', 'Strategic business partnership agreement for joint venture operations.', 'partnership_agreement', '/documents/partnership_005.pdf', 223456, 'active', 'high', '550e8400-e29b-41d4-a716-446655440013', CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440026', '550e8400-e29b-41d4-a716-446655440002', 'Lease Agreement - Office Space Cape Town', 'contract', 'real_estate', 'Commercial lease agreement for prime office space in Cape Town CBD.', 'lease_agreement', '/documents/lease_006.pdf', 145678, 'active', 'low', '550e8400-e29b-41d4-a716-446655440013', CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440027', '550e8400-e29b-41d4-a716-446655440001', 'Compliance Policy - Data Protection', 'policy', 'compliance', 'Comprehensive data protection policy ensuring POPIA compliance.', 'compliance_policy', '/documents/policy_007.pdf', 267890, 'active', 'high', '550e8400-e29b-41d4-a716-446655440012', CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440028', '550e8400-e29b-41d4-a716-446655440001', 'Risk Assessment Report - Q4 2024', 'report', 'risk_management', 'Quarterly risk assessment covering operational and compliance risks.', 'risk_report', '/documents/risk_008.pdf', 345678, 'active', 'medium', '550e8400-e29b-41d4-a716-446655440012', CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440029', '550e8400-e29b-41d4-a716-446655440002', 'Merger Agreement - TechStart Acquisition', 'contract', 'merger', 'Corporate merger agreement for acquisition of technology startup.', 'merger_agreement', '/documents/merger_009.pdf', 456789, 'active', 'high', '550e8400-e29b-41d4-a716-446655440013', CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440030', '550e8400-e29b-41d4-a716-446655440001', 'Software License Agreement - TechCorp v1.0', 'contract', 'licensing', 'Legacy software license agreement for previous version.', 'software_license', '/documents/software_license_010.pdf', 187654, 'active', 'medium', '550e8400-e29b-41d4-a716-446655440011', CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440031', '550e8400-e29b-41d4-a716-446655440003', 'Vendor Agreement - IT Services', 'contract', 'service', 'Comprehensive IT services agreement with managed service provider.', 'service_agreement', '/documents/vendor_011.pdf', 198432, 'active', 'medium', '550e8400-e29b-41d4-a716-446655440014', CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440032', '550e8400-e29b-41d4-a716-446655440003', 'Employment Contract - Legal Associate', 'contract', 'employment', 'Employment agreement for junior legal associate position.', 'employment_contract', '/documents/employment_012.pdf', 142356, 'active', 'low', '550e8400-e29b-41d4-a716-446655440014', CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440033', '550e8400-e29b-41d4-a716-446655440002', 'Intellectual Property Agreement', 'contract', 'ip', 'IP licensing and protection agreement for proprietary technology.', 'ip_agreement', '/documents/ip_013.pdf', 234567, 'active', 'high', '550e8400-e29b-41d4-a716-446655440013', CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440034', '550e8400-e29b-41d4-a716-446655440001', 'Client Retainer Agreement', 'contract', 'service', 'Legal services retainer agreement for corporate client.', 'retainer_agreement', '/documents/retainer_014.pdf', 167890, 'active', 'low', '550e8400-e29b-41d4-a716-446655440011', CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440035', '550e8400-e29b-41d4-a716-446655440003', 'Compliance Manual - Corporate Governance', 'manual', 'compliance', 'Corporate governance compliance manual and procedures.', 'compliance_manual', '/documents/manual_015.pdf', 456123, 'active', 'medium', '550e8400-e29b-41d4-a716-446655440014', CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440036', '550e8400-e29b-41d4-a716-446655440001', 'Settlement Agreement - Dispute Resolution', 'agreement', 'litigation', 'Settlement agreement for commercial dispute resolution.', 'settlement_agreement', '/documents/settlement_016.pdf', 189456, 'active', 'medium', '550e8400-e29b-41d4-a716-446655440015', CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440037', '550e8400-e29b-41d4-a716-446655440002', 'Due Diligence Report - M&A Transaction', 'report', 'due_diligence', 'Comprehensive due diligence report for merger transaction.', 'dd_report', '/documents/due_diligence_017.pdf', 567890, 'active', 'high', '550e8400-e29b-41d4-a716-446655440013', CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440038', '550e8400-e29b-41d4-a716-446655440003', 'Regulatory Compliance Audit', 'report', 'audit', 'Annual regulatory compliance audit report and findings.', 'audit_report', '/documents/audit_018.pdf', 345123, 'active', 'high', '550e8400-e29b-41d4-a716-446655440014', CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440039', '550e8400-e29b-41d4-a716-446655440001', 'Privacy Policy - Website Terms', 'policy', 'privacy', 'Website privacy policy and terms of service documentation.', 'privacy_policy', '/documents/privacy_019.pdf', 123789, 'active', 'medium', '550e8400-e29b-41d4-a716-446655440012', CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440040', '550e8400-e29b-41d4-a716-446655440002', 'Board Resolution - Corporate Actions', 'resolution', 'corporate', 'Board resolution authorizing major corporate actions and decisions.', 'board_resolution', '/documents/resolution_020.pdf', 98765, 'active', 'low', '550e8400-e29b-41d4-a716-446655440013', CURRENT_TIMESTAMP);

-- Insert Tasks (15 tasks)
INSERT INTO tasks (id, organization_id, title, description, type, status, priority, assigned_to, created_by, due_date) VALUES
('550e8400-e29b-41d4-a716-446655440051', '550e8400-e29b-41d4-a716-446655440001', 'Review Employment Contract Terms', 'Review and update standard employment contract terms for compliance with new labor laws', 'document_review', 'in_progress', 'high', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2024-12-30'),
('550e8400-e29b-41d4-a716-446655440052', '550e8400-e29b-41d4-a716-446655440001', 'Compliance Audit - Q4 2024', 'Conduct quarterly compliance audit for all active contracts', 'compliance_check', 'pending', 'high', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2024-12-31'),
('550e8400-e29b-41d4-a716-446655440053', '550e8400-e29b-41d4-a716-446655440001', 'Update NDA Templates', 'Update non-disclosure agreement templates with latest legal requirements', 'template_update', 'completed', 'medium', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440011', '2024-12-15'),
('550e8400-e29b-41d4-a716-446655440054', '550e8400-e29b-41d4-a716-446655440002', 'Risk Assessment - New Partnership', 'Assess legal risks for the proposed strategic alliance partnership', 'risk_assessment', 'in_progress', 'high', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', '2024-12-28'),
('550e8400-e29b-41d4-a716-446655440055', '550e8400-e29b-41d4-a716-446655440001', 'Document Classification Review', 'Review and reclassify documents based on new risk assessment criteria', 'classification', 'pending', 'medium', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2025-01-15'),
('550e8400-e29b-41d4-a716-446655440056', '550e8400-e29b-41d4-a716-446655440002', 'Lease Renewal Negotiation', 'Negotiate terms for office lease renewal in Cape Town', 'negotiation', 'pending', 'medium', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', '2025-01-31'),
('550e8400-e29b-41d4-a716-446655440057', '550e8400-e29b-41d4-a716-446655440001', 'Regulatory Update Review', 'Review and implement changes from latest POPIA amendments', 'regulatory_review', 'in_progress', 'high', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2024-12-20'),
('550e8400-e29b-41d4-a716-446655440058', '550e8400-e29b-41d4-a716-446655440002', 'Contract Comparison Analysis', 'Compare merger agreement terms with industry standards', 'analysis', 'pending', 'medium', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', '2025-01-10'),
('550e8400-e29b-41d4-a716-446655440059', '550e8400-e29b-41d4-a716-446655440001', 'Client Onboarding Documentation', 'Prepare legal documentation for new corporate client onboarding', 'documentation', 'completed', 'low', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440011', '2024-12-10'),
('550e8400-e29b-41d4-a716-446655440060', '550e8400-e29b-41d4-a716-446655440003', 'Training Material Update', 'Update compliance training materials for staff', 'training', 'pending', 'low', '550e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440014', '2025-02-01'),
('550e8400-e29b-41d4-a716-446655440061', '550e8400-e29b-41d4-a716-446655440003', 'IP Portfolio Review', 'Comprehensive review of intellectual property portfolio', 'review', 'in_progress', 'medium', '550e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440014', '2025-01-20'),
('550e8400-e29b-41d4-a716-446655440062', '550e8400-e29b-41d4-a716-446655440002', 'Due Diligence Preparation', 'Prepare due diligence materials for upcoming M&A transaction', 'preparation', 'pending', 'high', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', '2025-01-05'),
('550e8400-e29b-41d4-a716-446655440063', '550e8400-e29b-41d4-a716-446655440001', 'Settlement Negotiation', 'Negotiate settlement terms for ongoing commercial dispute', 'negotiation', 'in_progress', 'high', '550e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440011', '2024-12-25'),
('550e8400-e29b-41d4-a716-446655440064', '550e8400-e29b-41d4-a716-446655440003', 'Regulatory Filing Preparation', 'Prepare annual regulatory filings and compliance reports', 'filing', 'pending', 'medium', '550e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440014', '2025-02-15'),
('550e8400-e29b-41d4-a716-446655440065', '550e8400-e29b-41d4-a716-446655440002', 'Board Meeting Preparation', 'Prepare materials and resolutions for quarterly board meeting', 'preparation', 'completed', 'low', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', '2024-12-12');

-- Insert Compliance Rules (12 rules)
INSERT INTO compliance_rules (id, organization_id, name, title, description, category, regulation_source, risk_level) VALUES
('550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440001', 'POPIA Data Protection Compliance', 'POPIA Data Protection Compliance', 'Ensure all contracts comply with Protection of Personal Information Act requirements', 'data_protection', 'POPIA (Act 4 of 2013)', 'high'),
('550e8400-e29b-41d4-a716-446655440072', '550e8400-e29b-41d4-a716-446655440001', 'Employment Equity Act Compliance', 'Employment Equity Act Compliance', 'Verify employment contracts meet Employment Equity Act standards', 'employment', 'Employment Equity Act (Act 55 of 1998)', 'high'),
('550e8400-e29b-41d4-a716-446655440073', '550e8400-e29b-41d4-a716-446655440001', 'Consumer Protection Act Compliance', 'Consumer Protection Act Compliance', 'Ensure service agreements comply with Consumer Protection Act', 'consumer_protection', 'Consumer Protection Act (Act 68 of 2008)', 'medium'),
('550e8400-e29b-41d4-a716-446655440074', '550e8400-e29b-41d4-a716-446655440002', 'Companies Act Compliance', 'Companies Act Compliance', 'Verify corporate documents comply with Companies Act requirements', 'corporate', 'Companies Act (Act 71 of 2008)', 'high'),
('550e8400-e29b-41d4-a716-446655440075', '550e8400-e29b-41d4-a716-446655440001', 'Labour Relations Act Compliance', 'Labour Relations Act Compliance', 'Ensure employment terms comply with Labour Relations Act', 'employment', 'Labour Relations Act (Act 66 of 1995)', 'medium'),
('550e8400-e29b-41d4-a716-446655440076', '550e8400-e29b-41d4-a716-446655440002', 'Competition Act Compliance', 'Competition Act Compliance', 'Review merger agreements for Competition Act compliance', 'competition', 'Competition Act (Act 89 of 1998)', 'high'),
('550e8400-e29b-41d4-a716-446655440077', '550e8400-e29b-41d4-a716-446655440001', 'Electronic Communications Act Compliance', 'Electronic Communications Act Compliance', 'Ensure digital contracts comply with Electronic Communications Act', 'electronic_communications', 'Electronic Communications Act (Act 36 of 2005)', 'medium'),
('550e8400-e29b-41d4-a716-446655440078', '550e8400-e29b-41d4-a716-446655440002', 'B-BBEE Compliance', 'B-BBEE Compliance', 'Verify contracts meet B-BBEE requirements', 'empowerment', 'B-BBEE Act (Act 53 of 2003)', 'medium'),
('550e8400-e29b-41d4-a716-446655440079', '550e8400-e29b-41d4-a716-446655440003', 'Intellectual Property Act Compliance', 'Intellectual Property Act Compliance', 'Ensure IP agreements comply with intellectual property laws', 'intellectual_property', 'Copyright Act (Act 98 of 1978)', 'high'),
('550e8400-e29b-41d4-a716-446655440080', '550e8400-e29b-41d4-a716-446655440003', 'Tax Administration Act Compliance', 'Tax Administration Act Compliance', 'Verify tax compliance in all commercial agreements', 'tax', 'Tax Administration Act (Act 28 of 2011)', 'medium'),
('550e8400-e29b-41d4-a716-446655440081', '550e8400-e29b-41d4-a716-446655440001', 'Financial Intelligence Centre Act Compliance', 'FICA Compliance', 'Ensure compliance with anti-money laundering requirements', 'financial', 'Financial Intelligence Centre Act (Act 38 of 2001)', 'high'),
('550e8400-e29b-41d4-a716-446655440082', '550e8400-e29b-41d4-a716-446655440002', 'King IV Corporate Governance', 'King IV Governance Principles', 'Apply King IV corporate governance principles in all corporate documents', 'governance', 'King IV Report on Corporate Governance', 'medium');

-- Insert Compliance Monitoring (24 monitoring records)
INSERT INTO compliance_monitoring (id, organization_id, rule_id, document_id, status, compliance_score, issues_found, next_check_due) VALUES
('550e8400-e29b-41d4-a716-446655440091', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440021', 'compliant', 95, 0, '2025-03-01'),
('550e8400-e29b-41d4-a716-446655440092', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440072', '550e8400-e29b-41d4-a716-446655440021', 'compliant', 88, 1, '2025-02-15'),
('550e8400-e29b-41d4-a716-446655440093', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440073', '550e8400-e29b-41d4-a716-446655440022', 'non_compliant', 65, 3, '2024-12-31'),
('550e8400-e29b-41d4-a716-446655440094', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440023', 'compliant', 92, 1, '2025-02-28'),
('550e8400-e29b-41d4-a716-446655440095', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440074', '550e8400-e29b-41d4-a716-446655440025', 'under_review', 78, 2, '2025-01-20'),
('550e8400-e29b-41d4-a716-446655440096', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440076', '550e8400-e29b-41d4-a716-446655440029', 'compliant', 85, 1, '2025-04-01'),
('550e8400-e29b-41d4-a716-446655440097', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440077', '550e8400-e29b-41d4-a716-446655440022', 'non_compliant', 58, 4, '2024-12-25'),
('550e8400-e29b-41d4-a716-446655440098', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440075', '550e8400-e29b-41d4-a716-446655440021', 'compliant', 90, 1, '2025-03-15'),
('550e8400-e29b-41d4-a716-446655440099', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440078', '550e8400-e29b-41d4-a716-446655440025', 'compliant', 82, 2, '2025-02-10'),
('550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440079', '550e8400-e29b-41d4-a716-446655440033', 'compliant', 94, 0, '2025-03-20'),
('550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440080', '550e8400-e29b-41d4-a716-446655440031', 'compliant', 87, 1, '2025-02-25'),
('550e8400-e29b-41d4-a716-446655440102', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440081', '550e8400-e29b-41d4-a716-446655440034', 'compliant', 91, 0, '2025-03-10'),
('550e8400-e29b-41d4-a716-446655440103', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440082', '550e8400-e29b-41d4-a716-446655440040', 'compliant', 89, 1, '2025-02-20'),
('550e8400-e29b-41d4-a716-446655440104', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440073', '550e8400-e29b-41d4-a716-446655440024', 'at_risk', 72, 2, '2025-01-15'),
('550e8400-e29b-41d4-a716-446655440105', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440074', '550e8400-e29b-41d4-a716-446655440037', 'compliant', 86, 1, '2025-02-28'),
('550e8400-e29b-41d4-a716-446655440106', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440079', '550e8400-e29b-41d4-a716-446655440035', 'compliant', 93, 0, '2025-03-25'),
('550e8400-e29b-41d4-a716-446655440107', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440027', 'compliant', 96, 0, '2025-03-05'),
('550e8400-e29b-41d4-a716-446655440108', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440072', '550e8400-e29b-41d4-a716-446655440032', 'compliant', 84, 2, '2025-02-12'),
('550e8400-e29b-41d4-a716-446655440109', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440076', '550e8400-e29b-41d4-a716-446655440037', 'under_review', 75, 3, '2025-01-25'),
('550e8400-e29b-41d4-a716-446655440110', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440080', '550e8400-e29b-41d4-a716-446655440038', 'compliant', 88, 1, '2025-02-18'),
('550e8400-e29b-41d4-a716-446655440111', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440077', '550e8400-e29b-41d4-a716-446655440030', 'non_compliant', 62, 3, '2024-12-28'),
('550e8400-e29b-41d4-a716-446655440112', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440078', '550e8400-e29b-41d4-a716-446655440026', 'compliant', 81, 2, '2025-02-08'),
('550e8400-e29b-41d4-a716-446655440113', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440075', '550e8400-e29b-41d4-a716-446655440036', 'compliant', 87, 1, '2025-02-22'),
('550e8400-e29b-41d4-a716-446655440114', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440079', '550e8400-e29b-41d4-a716-446655440038', 'compliant', 92, 0, '2025-03-12');

-- Insert Compliance Alerts (15 alerts - mix of active and resolved)
INSERT INTO compliance_alerts (id, organization_id, rule_id, document_id, title, description, priority, type, status, due_date, regulation_source, jurisdiction) VALUES
('550e8400-e29b-41d4-a716-446655440121', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440073', '550e8400-e29b-41d4-a716-446655440022', 'Consumer Protection Act Violations Found', 'Software License Agreement contains clauses that may violate Consumer Protection Act requirements. Review and update required.', 'High', 'compliance', 'active', '2024-12-25', 'Consumer Protection Act (Act 68 of 2008)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440122', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440077', '550e8400-e29b-41d4-a716-446655440022', 'Electronic Communications Act Non-Compliance', 'Digital signature requirements not met in Software License Agreement. Update electronic execution clauses.', 'High', 'compliance', 'active', '2024-12-30', 'Electronic Communications Act (Act 36 of 2005)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440123', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440074', '550e8400-e29b-41d4-a716-446655440025', 'Companies Act Review Required', 'Partnership Agreement requires review for Companies Act compliance. Director liability clauses need attention.', 'Medium', 'compliance', 'active', '2025-01-15', 'Companies Act (Act 71 of 2008)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440124', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440072', '550e8400-e29b-41d4-a716-446655440021', 'Employment Equity Minor Issue', 'Employment Contract has minor Employment Equity Act compliance issue. Update diversity reporting clause.', 'Low', 'compliance', 'resolved', '2025-01-31', 'Employment Equity Act (Act 55 of 1998)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440125', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440023', 'POPIA Data Handling Update', 'NDA requires update to align with latest POPIA data handling requirements. Review data processing clauses.', 'Medium', 'compliance', 'active', '2025-01-10', 'POPIA (Act 4 of 2013)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440126', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440076', '550e8400-e29b-41d4-a716-446655440029', 'Competition Act Clearance Pending', 'Merger Agreement pending Competition Commission clearance. Monitor approval status and update terms if required.', 'Critical', 'regulatory', 'active', '2025-02-28', 'Competition Act (Act 89 of 1998)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440127', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440075', '550e8400-e29b-41d4-a716-446655440021', 'Labour Relations Act Update', 'Employment Contract needs minor update for Labour Relations Act compliance. Review dispute resolution clauses.', 'Low', 'compliance', 'resolved', '2025-02-15', 'Labour Relations Act (Act 66 of 1995)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440128', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440078', '550e8400-e29b-41d4-a716-446655440025', 'B-BBEE Compliance Check', 'Partnership Agreement requires B-BBEE compliance verification. Update procurement and supplier clauses.', 'Medium', 'compliance', 'active', '2025-01-20', 'B-BBEE Act (Act 53 of 2003)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440129', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440027', 'POPIA Policy Update Required', 'Data Protection Policy needs update to reflect latest POPIA amendments. Review consent mechanisms.', 'High', 'policy', 'active', '2024-12-31', 'POPIA (Act 4 of 2013)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440130', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440073', '550e8400-e29b-41d4-a716-446655440024', 'Consumer Protection Review', 'Service Level Agreement requires Consumer Protection Act compliance review. Update cancellation and refund terms.', 'Medium', 'compliance', 'active', '2025-01-05', 'Consumer Protection Act (Act 68 of 2008)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440131', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440079', '550e8400-e29b-41d4-a716-446655440033', 'IP Agreement Review', 'Intellectual Property Agreement requires review for latest copyright law changes.', 'Medium', 'compliance', 'active', '2025-01-25', 'Copyright Act (Act 98 of 1978)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440132', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440080', '550e8400-e29b-41d4-a716-446655440031', 'Tax Compliance Verification', 'Vendor Agreement requires tax compliance verification and SARS clearance certificate.', 'High', 'tax', 'active', '2025-01-12', 'Tax Administration Act (Act 28 of 2011)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440133', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440081', '550e8400-e29b-41d4-a716-446655440034', 'FICA Compliance Check', 'Client Retainer Agreement requires FICA compliance verification for new client onboarding.', 'Medium', 'financial', 'resolved', '2025-01-08', 'Financial Intelligence Centre Act (Act 38 of 2001)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440134', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440082', '550e8400-e29b-41d4-a716-446655440040', 'King IV Governance Review', 'Board Resolution requires review against King IV governance principles.', 'Low', 'governance', 'resolved', '2025-02-01', 'King IV Report on Corporate Governance', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440135', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440077', '550e8400-e29b-41d4-a716-446655440030', 'Electronic Signature Update', 'Legacy Software License Agreement needs electronic signature compliance update.', 'Medium', 'compliance', 'active', '2025-01-18', 'Electronic Communications Act (Act 36 of 2005)', 'South Africa');

-- Insert Depositions (12 depositions)
INSERT INTO depositions (id, organization_id, case_name, case_number, deponent_name, deponent_role, date_conducted, location, status, duration_minutes, created_by) VALUES
('550e8400-e29b-41d4-a716-446655440141', '550e8400-e29b-41d4-a716-446655440001', 'Smith vs. ABC Corporation', 'HC-2024-001', 'John Smith', 'Plaintiff', '2024-01-15', 'Cape Town High Court', 'completed', 180, '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440142', '550e8400-e29b-41d4-a716-446655440001', 'Estate Planning Matter - Johnson', 'EST-2024-045', 'Mary Johnson', 'Beneficiary', '2024-01-20', 'Johannesburg Office', 'completed', 120, '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440143', '550e8400-e29b-41d4-a716-446655440001', 'Contract Dispute - Wilson vs. XYZ Ltd', 'COM-2024-023', 'Robert Wilson', 'Defendant', '2024-12-25', 'Durban Commercial Court', 'scheduled', NULL, '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440144', '550e8400-e29b-41d4-a716-446655440001', 'Personal Injury Claim', 'PI-2024-067', 'Sarah Davis', 'Witness', '2024-02-01', 'Pretoria Magistrate Court', 'completed', 90, '550e8400-e29b-41d4-a716-446655440015'),
('550e8400-e29b-41d4-a716-446655440145', '550e8400-e29b-41d4-a716-446655440001', 'Employment Dispute', 'LAB-2024-012', 'Michael Brown', 'Former Employee', '2024-12-20', 'CCMA Offices', 'scheduled', NULL, '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29  '2024-12-20', 'CCMA Offices', 'scheduled', NULL, '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440146', '550e8400-e29b-41d4-a716-446655440002', 'Property Development Case', 'PROP-2024-089', 'Jennifer Lee', 'Property Developer', '2024-12-30', 'Cape Town Office', 'scheduled', NULL, '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440147', '550e8400-e29b-41d4-a716-446655440002', 'Insurance Claim Dispute', 'INS-2024-156', 'David Thompson', 'Claimant', '2024-02-15', 'Insurance Ombudsman', 'completed', 150, '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440148', '550e8400-e29b-41d4-a716-446655440002', 'Merger Due Diligence', 'MA-2024-078', 'Lisa Chen', 'CFO', '2024-02-20', 'Corporate Offices', 'completed', 240, '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440149', '550e8400-e29b-41d4-a716-446655440003', 'IP Infringement Case', 'IP-2024-034', 'Mark Stevens', 'Technical Expert', '2024-11-25', 'Johannesburg High Court', 'completed', 200, '550e8400-e29b-41d4-a716-446655440014'),
('550e8400-e29b-41d4-a716-446655440150', '550e8400-e29b-41d4-a716-446655440003', 'Commercial Arbitration', 'ARB-2024-067', 'Susan Miller', 'Contract Manager', '2024-12-15', 'Arbitration Centre', 'completed', 160, '550e8400-e29b-41d4-a716-446655440014'),
('550e8400-e29b-41d4-a716-446655440151', '550e8400-e29b-41d4-a716-446655440001', 'Regulatory Investigation', 'REG-2024-089', 'Peter Adams', 'Compliance Manager', '2025-01-10', 'Regulatory Authority', 'scheduled', NULL, '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440152', '550e8400-e29b-41d4-a716-446655440002', 'Shareholder Dispute', 'SH-2024-123', 'Rachel Green', 'Minority Shareholder', '2025-01-15', 'Cape Town High Court', 'scheduled', NULL, '550e8400-e29b-41d4-a716-446655440013');

-- Insert Deposition Analyses (8 analyses for completed depositions)
INSERT INTO deposition_analyses (id, deposition_id, analysis_type, key_topics, sentiment_analysis, credibility_assessment, inconsistencies, recommendations, confidence_score) VALUES
('550e8400-e29b-41d4-a716-446655440161', '550e8400-e29b-41d4-a716-446655440141', 'comprehensive',
 ARRAY['contract breach', 'damages calculation', 'timeline of events', 'witness credibility'], 
 '{"overall_sentiment": "negative", "confidence": 0.85, "emotional_indicators": ["frustration", "defensiveness"]}'::jsonb,
 '{"credibility_score": 0.78, "consistency_rating": "high", "body_language": "defensive", "verbal_cues": "hesitant"}'::jsonb,
 ARRAY['Date discrepancy in contract signing', 'Conflicting statements about meeting attendance'],
 ARRAY['Request additional documentation for timeline verification', 'Follow up on contract signing witnesses'],
 0.82),
('550e8400-e29b-41d4-a716-446655440162', '550e8400-e29b-41d4-a716-446655440142', 'comprehensive',
 ARRAY['estate assets', 'beneficiary rights', 'will validity', 'family dynamics'],
 '{"overall_sentiment": "emotional", "confidence": 0.92, "emotional_indicators": ["grief", "concern", "determination"]}'::jsonb,
 '{"credibility_score": 0.88, "consistency_rating": "very_high", "body_language": "consistent", "verbal_cues": "clear"}'::jsonb,
 ARRAY['Minor inconsistency in asset valuation dates'],
 ARRAY['Strong testimony supporting will validity', 'Recommend family mediation', 'Gather additional asset documentation'],
 0.89),
('550e8400-e29b-41d4-a716-446655440163', '550e8400-e29b-41d4-a716-446655440144', 'comprehensive',
 ARRAY['accident details', 'injury extent', 'liability factors', 'medical evidence'],
 '{"overall_sentiment": "distressed", "confidence": 0.90, "emotional_indicators": ["pain", "frustration", "determination"]}'::jsonb,
 '{"credibility_score": 0.85, "consistency_rating": "high", "body_language": "consistent", "verbal_cues": "detailed"}'::jsonb,
 ARRAY['Minor timing discrepancy in medical treatment'],
 ARRAY['Strong case for liability', 'Medical evidence supports claims', 'Consider settlement negotiation'],
 0.87),
('550e8400-e29b-41d4-a716-446655440164', '550e8400-e29b-41d4-a716-446655440147', 'comprehensive',
 ARRAY['insurance policy terms', 'claim validity', 'coverage disputes', 'documentation'],
 '{"overall_sentiment": "frustrated", "confidence": 0.83, "emotional_indicators": ["anger", "confusion", "persistence"]}'::jsonb,
 '{"credibility_score": 0.80, "consistency_rating": "medium", "body_language": "agitated", "verbal_cues": "repetitive"}'::jsonb,
 ARRAY['Conflicting statements about policy understanding', 'Documentation timeline unclear'],
 ARRAY['Review policy documentation thoroughly', 'Clarify coverage terms', 'Consider mediation'],
 0.75),
('550e8400-e29b-41d4-a716-446655440165', '550e8400-e29b-41d4-a716-446655440148', 'comprehensive',
 ARRAY['financial records', 'due diligence process', 'merger valuation', 'corporate governance'],
 '{"overall_sentiment": "professional", "confidence": 0.95, "emotional_indicators": ["confidence", "expertise", "caution"]}'::jsonb,
 '{"credibility_score": 0.95, "consistency_rating": "very_high", "body_language": "professional", "verbal_cues": "expert"}'::jsonb,
 ARRAY[],
 ARRAY['Expert testimony supports merger valuation', 'Financial analysis is comprehensive', 'Due diligence process was thorough'],
 0.94),
('550e8400-e29b-41d4-a716-446655440166', '550e8400-e29b-41d4-a716-446655440149', 'comprehensive',
 ARRAY['patent infringement', 'technical analysis', 'prior art', 'damages assessment'],
 '{"overall_sentiment": "analytical", "confidence": 0.91, "emotional_indicators": ["expertise", "precision", "objectivity"]}'::jsonb,
 '{"credibility_score": 0.92, "consistency_rating": "very_high", "body_language": "professional", "verbal_cues": "technical"}'::jsonb,
 ARRAY['Minor technical specification clarification needed'],
 ARRAY['Strong technical evidence of infringement', 'Prior art analysis is thorough', 'Damages calculation well-supported'],
 0.91),
('550e8400-e29b-41d4-a716-446655440167', '550e8400-e29b-41d4-a716-446655440150', 'comprehensive',
 ARRAY['contract performance', 'breach allegations', 'commercial terms', 'dispute resolution'],
 '{"overall_sentiment": "defensive", "confidence": 0.84, "emotional_indicators": ["defensiveness", "justification", "concern"]}'::jsonb,
 '{"credibility_score": 0.77, "consistency_rating": "medium", "body_language": "guarded", "verbal_cues": "careful"}'::jsonb,
 ARRAY['Conflicting statements about contract interpretation', 'Timeline discrepancies in performance'],
 ARRAY['Review contract terms carefully', 'Investigate performance timeline', 'Consider commercial resolution'],
 0.79);

-- Insert Case Timelines (6 timelines)
INSERT INTO case_timelines (id, organization_id, case_name, case_number, timeline_data, created_by) VALUES
('550e8400-e29b-41d4-a716-446655440171', '550e8400-e29b-41d4-a716-446655440001', 'Smith vs. ABC Corporation', 'HC-2024-001', 
 '[{"date": "2023-06-15", "event": "Initial incident occurred", "type": "incident", "importance": 5}, {"date": "2023-07-01", "event": "Legal notice served", "type": "legal", "importance": 4}, {"date": "2023-08-15", "event": "Summons issued", "type": "court", "importance": 5}, {"date": "2024-01-15", "event": "Deposition conducted", "type": "discovery", "importance": 4}, {"date": "2024-03-01", "event": "Trial date scheduled", "type": "court", "importance": 5}]'::jsonb, 
 '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440172', '550e8400-e29b-41d4-a716-446655440001', 'Estate Planning Matter - Johnson', 'EST-2024-045',
 '[{"date": "2023-12-01", "event": "Will executed", "type": "document", "importance": 5}, {"date": "2024-01-05", "event": "Probate application filed", "type": "court", "importance": 4}, {"date": "2024-01-20", "event": "Beneficiary deposition", "type": "discovery", "importance": 3}, {"date": "2024-02-15", "event": "Asset valuation completed", "type": "financial", "importance": 3}]'::jsonb,
 '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440173', '550e8400-e29b-41d4-a716-446655440002', 'Merger Due Diligence', 'MA-2024-078',
 '[{"date": "2023-09-01", "event": "Initial merger discussions", "type": "negotiation", "importance": 4}, {"date": "2023-11-15", "event": "Due diligence commenced", "type": "investigation", "importance": 5}, {"date": "2024-01-10", "event": "Financial audit completed", "type": "financial", "importance": 4}, {"date": "2024-02-20", "event": "Management deposition", "type": "discovery", "importance": 4}, {"date": "2024-04-01", "event": "Competition Commission filing", "type": "regulatory", "importance": 5}]'::jsonb,
 '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440174', '550e8400-e29b-41d4-a716-446655440003', 'IP Infringement Case', 'IP-2024-034',
 '[{"date": "2023-08-01", "event": "Patent infringement discovered", "type": "discovery", "importance": 5}, {"date": "2023-09-15", "event": "Cease and desist letter sent", "type": "legal", "importance": 4}, {"date": "2023-11-01", "event": "Litigation commenced", "type": "court", "importance": 5}, {"date": "2024-11-25", "event": "Expert deposition", "type": "discovery", "importance": 4}]'::jsonb,
 '550e8400-e29b-41d4-a716-446655440014'),
('550e8400-e29b-41d4-a716-446655440175', '550e8400-e29b-41d4-a716-446655440003', 'Commercial Arbitration', 'ARB-2024-067',
 '[{"date": "2023-10-01", "event": "Contract dispute arose", "type": "dispute", "importance": 4}, {"date": "2023-11-15", "event": "Arbitration initiated", "type": "arbitration", "importance": 5}, {"date": "2024-06-01", "event": "Evidence exchange", "type": "discovery", "importance": 3}, {"date": "2024-12-15", "event": "Witness deposition", "type": "discovery", "importance": 4}]'::jsonb,
 '550e8400-e29b-41d4-a716-446655440014'),
('550e8400-e29b-41d4-a716-446655440176', '550e8400-e29b-41d4-a716-446655440001', 'Employment Dispute', 'LAB-2024-012',
 '[{"date": "2024-03-01", "event": "Employment terminated", "type": "employment", "importance": 5}, {"date": "2024-04-15", "event": "CCMA referral filed", "type": "legal", "importance": 4}, {"date": "2024-08-01", "event": "Conciliation attempted", "type": "mediation", "importance": 3}, {"date": "2024-12-20", "event": "Arbitration hearing scheduled", "type": "arbitration", "importance": 4}]'::jsonb,
 '550e8400-e29b-41d4-a716-446655440012');

-- Insert Timeline Events (30 events across timelines)
INSERT INTO timeline_events (id, timeline_id, document_id, event_date, title, description, event_type, importance) VALUES
('550e8400-e29b-41d4-a716-446655440181', '550e8400-e29b-41d4-a716-446655440171', '550e8400-e29b-41d4-a716-446655440022', '2023-06-15', 'Contract Signing', 'Software License Agreement executed between parties', 'contract_execution', 'high'),
('550e8400-e29b-41d4-a716-446655440182', '550e8400-e29b-41d4-a716-446655440171', NULL, '2023-07-01', 'Performance Issues Identified', 'Initial performance issues with software implementation noted', 'issue_identification', 'medium'),
('550e8400-e29b-41d4-a716-446655440183', '550e8400-e29b-41d4-a716-446655440171', NULL, '2023-08-15', 'Formal Complaint Filed', 'Formal complaint regarding contract breach filed with court', 'legal_action', 'high'),
('550e8400-e29b-41d4-a716-446655440184', '550e8400-e29b-41d4-a716-446655440171', NULL, '2024-01-15', 'Plaintiff Deposition', 'John Smith deposition conducted at Cape Town High Court', 'deposition', 'high'),
('550e8400-e29b-41d4-a716-446655440185', '550e8400-e29b-41d4-a716-446655440171', NULL, '2024-03-01', 'Trial Scheduled', 'Court trial date set for contract dispute resolution', 'court_scheduling', 'high'),
('550e8400-e29b-41d4-a716-446655440186', '550e8400-e29b-41d4-a716-446655440172', NULL, '2023-12-01', 'Will Execution', 'Last will and testament executed with proper witnesses', 'document_execution', 'high'),
('550e8400-e29b-41d4-a716-446655440187', '550e8400-e29b-41d4-a716-446655440172', NULL, '2024-01-05', 'Probate Filing', 'Probate application filed with Master of High Court', 'court_filing', 'high'),
('550e8400-e29b-41d4-a716-446655440188', '550e8400-e29b-41d4-a716-446655440172', NULL, '2024-01-20', 'Beneficiary Interview', 'Mary Johnson deposition regarding estate matters', 'deposition', 'medium'),
('550e8400-e29b-41d4-a716-446655440189', '550e8400-e29b-41d4-a716-446655440172', NULL, '2024-02-15', 'Asset Valuation', 'Professional valuation of estate assets completed', 'valuation', 'medium'),
('550e8400-e29b-41d4-a716-446655440190', '550e8400-e29b-41d4-a716-446655440173', '550e8400-e29b-41d4-a716-446655440029', '2023-09-01', 'Merger Proposal', 'Initial merger proposal submitted and reviewed', 'proposal', 'high'),
('550e8400-e29b-41d4-a716-446655440191', '550e8400-e29b-41d4-a716-446655440173', NULL, '2023-11-15', 'Due Diligence Start', 'Comprehensive due diligence process initiated', 'due_diligence', 'high'),
('550e8400-e29b-41d4-a716-446655440192', '550e8400-e29b-41d4-a716-446655440173', NULL, '2024-01-10', 'Financial Audit', 'Independent financial audit completed', 'audit', 'high'),
('550e8400-e29b-41d4-a716-446655440193', '550e8400-e29b-41d4-a716-446655440173', NULL, '2024-02-20', 'Management Deposition', 'CFO Lisa Chen deposition conducted', 'deposition', 'high'),
('550e8400-e29b-41d4-a716-446655440194', '550e8400-e29b-41d4-a716-446655440173', NULL, '2024-04-01', 'Regulatory Filing', 'Competition Commission notification filed', 'regulatory_filing', 'high'),
('550e8400-e29b-41d4-a716-446655440195', '550e8400-e29b-41d4-a716-446655440174', '550e8400-e29b-41d4-a716-446655440033', '2023-08-01', 'Infringement Discovery', 'Patent infringement identified through market analysis', 'discovery', 'high'),
('550e8400-e29b-41d4-a716-446655440196', '550e8400-e29b-41d4-a716-446655440174', NULL, '2023-09-15', 'Cease and Desist', 'Formal cease and desist letter sent to infringer', 'legal_notice', 'medium'),
('550e8400-e29b-41d4-a716-446655440197', '550e8400-e29b-41d4-a716-446655440174', NULL, '2023-11-01', 'Litigation Filed', 'Patent infringement lawsuit filed in High Court', 'litigation', 'high'),
('550e8400-e29b-41d4-a716-446655440198', '550e8400-e29b-41d4-a716-446655440174', NULL, '2024-11-25', 'Expert Testimony', 'Technical expert Mark Stevens deposition', 'deposition', 'high'),
('550e8400-e29b-41d4-a716-446655440199', '550e8400-e29b-41d4-a716-446655440175', '550e8400-e29b-41d4-a716-446655440031', '2023-10-01', 'Contract Dispute', 'Dispute arose over IT services contract performance', 'dispute', 'medium'),
('550e8400-e29b-41d4-a716-446655440200', '550e8400-e29b-41d4-a716-446655440175', NULL, '2023-11-15', 'Arbitration Notice', 'Arbitration proceedings initiated per contract terms', 'arbitration', 'high'),
('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440175', NULL, '2024-06-01', 'Evidence Exchange', 'Parties exchanged evidence and documentation', 'discovery', 'medium'),
('550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440175', NULL, '2024-12-15', 'Witness Deposition', 'Contract Manager Susan Miller deposition', 'deposition', 'medium'),
('550e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440176', '550e8400-e29b-41d4-a716-446655440021', '2024-03-01', 'Employment Termination', 'Employee Michael Brown terminated from position', 'termination', 'high'),
('550e8400-e29b-41d4-a716-446655440204', '550e8400-e29b-41d4-a716-446655440176', NULL, '2024-04-15', 'CCMA Referral', 'Unfair dismissal case referred to CCMA', 'legal_filing', 'high'),
('550e8400-e29b-41d4-a716-446655440205', '550e8400-e29b-41d4-a716-446655440176', NULL, '2024-08-01', 'Conciliation Meeting', 'CCMA conciliation meeting attempted', 'mediation', 'medium'),
('550e8400-e29b-41d4-a716-446655440206', '550e8400-e29b-41d4-a716-446655440176', NULL, '2024-12-20', 'Arbitration Hearing', 'CCMA arbitration hearing scheduled', 'arbitration', 'high');

-- Insert Compliance Reports (10 reports)
INSERT INTO compliance_reports (id, organization_id, title, report_type, period_start, period_end, overall_score, total_documents, compliant_documents, non_compliant_documents, recommendations, report_data, generated_by) VALUES
('550e8400-e29b-41d4-a716-446655440211', '550e8400-e29b-41d4-a716-446655440001', 'Q4 2024 POPIA Compliance Report', 'popia', '2024-10-01', '2024-12-31', 85, 15, 12, 3, 
 ARRAY['Update data processing agreements', 'Enhance consent mechanisms', 'Implement automated compliance monitoring'],
 '{"compliance_score": 85, "issues_found": 3, "recommendations": 7, "data_subjects": 1250, "processing_activities": 15}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440212', '550e8400-e29b-41d4-a716-446655440001', 'Annual Employment Law Compliance 2024', 'employment', '2024-01-01', '2024-12-31', 78, 18, 15, 3,
 ARRAY['Update employment equity reporting', 'Review dispute resolution procedures', 'Enhance training programs'],
 '{"compliance_score": 78, "employment_contracts": 18, "equity_reports": 4, "disputes": 2, "training_sessions": 8}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440213', '550e8400-e29b-41d4-a716-446655440002', 'Corporate Governance Review 2024', 'corporate', '2024-01-01', '2024-12-31', 82, 12, 10, 2,
 ARRAY['Strengthen board oversight', 'Update risk management framework', 'Enhance stakeholder communication'],
 '{"compliance_score": 82, "board_meetings": 12, "risk_assessments": 4, "stakeholder_reports": 6, "governance_policies": 8}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440214', '550e8400-e29b-41d4-a716-446655440001', 'Consumer Protection Compliance Q3 2024', 'consumer_protection', '2024-07-01', '2024-09-30', 72, 8, 6, 2,
 ARRAY['Review cancellation terms', 'Update refund procedures', 'Enhance consumer rights notices'],
 '{"compliance_score": 72, "service_agreements": 8, "complaints": 3, "refunds_processed": 12, "consumer_inquiries": 45}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440215', '550e8400-e29b-41d4-a716-446655440002', 'Competition Law Compliance 2024', 'competition', '2024-01-01', '2024-12-31', 88, 5, 5, 0,
 ARRAY['Monitor market concentration', 'Update competition compliance training', 'Enhance merger notification procedures'],
 '{"compliance_score": 88, "merger_notifications": 2, "market_analysis": 4, "competition_training": 6, "regulatory_interactions": 8}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440216', '550e8400-e29b-41d4-a716-446655440003', 'Intellectual Property Compliance 2024', 'intellectual_property', '2024-01-01', '2024-12-31', 91, 6, 6, 0,
 ARRAY['Maintain excellent IP protection standards', 'Continue regular portfolio reviews', 'Enhance IP training programs'],
 '{"compliance_score": 91, "ip_agreements": 6, "patent_applications": 3, "trademark_renewals": 4, "ip_disputes": 1}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440014'),
('550e8400-e29b-41d4-a716-446655440217', '550e8400-e29b-41d4-a716-446655440003', 'Tax Compliance Assessment 2024', 'tax', '2024-01-01', '2024-12-31', 86, 8, 7, 1,
 ARRAY['Update tax compliance procedures', 'Enhance SARS reporting systems', 'Implement automated tax calculations'],
 '{"compliance_score": 86, "tax_returns": 12, "sars_submissions": 8, "tax_disputes": 0, "compliance_certificates": 6}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440014'),
('550e8400-e29b-41d4-a716-446655440218', '550e8400-e29b-41d4-a716-446655440001', 'Financial Services Compliance Q4 2024', 'financial', '2024-10-01', '2024-12-31', 89, 4, 4, 0,
 ARRAY['Maintain excellent FICA compliance', 'Continue enhanced due diligence procedures', 'Update AML training programs'],
 '{"compliance_score": 89, "fica_verifications": 15, "aml_reports": 4, "suspicious_transactions": 0, "compliance_training": 8}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440219', '550e8400-e29b-41d4-a716-446655440002', 'King IV Governance Assessment 2024', 'governance', '2024-01-01', '2024-12-31', 84, 6, 5, 1,
 ARRAY['Enhance board diversity', 'Improve stakeholder engagement', 'Strengthen risk management oversight'],
 '{"compliance_score": 84, "governance_principles": 17, "board_effectiveness": 85, "stakeholder_reports": 4, "ethics_training": 12}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440220', '550e8400-e29b-41d4-a716-446655440001', 'Overall Legal Compliance Summary 2024', 'comprehensive', '2024-01-01', '2024-12-31', 81, 25, 20, 5,
 ARRAY['Prioritize high-risk compliance areas', 'Implement integrated compliance monitoring', 'Enhance cross-functional compliance training'],
 '{"overall_compliance": 81, "total_regulations": 12, "compliance_areas": 8, "training_hours": 120, "compliance_costs": 450000}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440012');

-- Insert Regulatory Updates (10 updates)
INSERT INTO regulatory_updates (title, description, regulation_source, category, jurisdiction, effective_date, impact_level, url) VALUES
('POPIA Amendment Regulations 2024', 'New regulations under POPIA addressing AI and automated decision-making in data processing', 'POPIA', 'data_protection', 'South Africa', '2024-07-01', 'high', 'https://www.gov.za/popia-amendments-2024'),
('Companies Act Amendment - Director Duties', 'Updated director duties and liability provisions under the Companies Act', 'Companies Act', 'corporate', 'South Africa', '2024-09-01', 'medium', 'https://www.gov.za/companies-act-amendments'),
('Employment Equity Amendment Act 2024', 'Revised employment equity targets and reporting requirements', 'Employment Equity Act', 'employment', 'South Africa', '2024-06-01', 'high', 'https://www.gov.za/employment-equity-amendments'),
('Consumer Protection Regulations Update', 'New consumer protection regulations for digital services and e-commerce', 'Consumer Protection Act', 'consumer_protection', 'South Africa', '2024-08-15', 'medium', 'https://www.gov.za/consumer-protection-digital'),
('Competition Commission Guidelines - Digital Markets', 'New guidelines for competition assessment in digital markets and platforms', 'Competition Act', 'competition', 'South Africa', '2024-10-01', 'high', 'https://www.compcom.co.za/digital-markets-guidelines'),
('Labour Relations Act - Remote Work Regulations', 'New regulations addressing remote work arrangements and digital workplace rights', 'Labour Relations Act', 'employment', 'South Africa', '2024-05-01', 'medium', 'https://www.gov.za/labour-remote-work'),
('Electronic Communications Amendment 2024', 'Updated electronic communications regulations for 5G and IoT technologies', 'Electronic Communications Act', 'electronic_communications', 'South Africa', '2024-11-01', 'medium', 'https://www.icasa.org.za/electronic-communications-2024'),
('B-BBEE Codes Amendment - Digital Economy', 'Revised B-BBEE codes addressing digital economy and technology sector requirements', 'B-BBEE Act', 'empowerment', 'South Africa', '2024-12-01', 'high', 'https://www.gov.za/bbbee-digital-economy'),
('Copyright Act Amendment - AI and Digital Content', 'New copyright provisions for AI-generated content and digital rights management', 'Copyright Act', 'intellectual_property', 'South Africa', '2024-09-15', 'high', 'https://www.gov.za/copyright-ai-amendments'),
('Tax Administration Act - Digital Transactions', 'New tax reporting requirements for digital transactions and cryptocurrency', 'Tax Administration Act', 'tax', 'South Africa', '2024-10-15', 'medium', 'https://www.sars.gov.za/digital-tax-regulations');

-- Insert Document Analyses (15 analyses)
INSERT INTO document_analyses (id, document_id, analysis_type, results, key_findings, risk_factors, compliance_issues, recommendations, confidence_score, status) VALUES
('550e8400-e29b-41d4-a716-446655440231', '550e8400-e29b-41d4-a716-446655440021', 'compliance_check',
 '{"overall_compliance": 88, "popia_score": 95, "employment_equity_score": 85, "labour_relations_score": 90}'::jsonb,
 ARRAY['Strong data protection clauses', 'Clear termination procedures', 'Comprehensive benefits package'],
 ARRAY['Minor employment equity reporting gap'],
 ARRAY['Employment equity reporting clause needs update'],
 ARRAY['Update diversity reporting requirements', 'Add remote work policy clauses'],
 0.92, 'completed'),
('550e8400-e29b-41d4-a716-446655440232', '550e8400-e29b-41d4-a716-446655440022', 'compliance_check',
 '{"overall_compliance": 65, "consumer_protection_score": 58, "electronic_communications_score": 72}'::jsonb,
 ARRAY['Comprehensive licensing terms', 'Clear usage restrictions'],
 ARRAY['Consumer protection violations', 'Electronic signature requirements not met'],
 ARRAY['Unfair contract terms identified', 'Digital signature clauses missing'],
 ARRAY['Remove unfair cancellation terms', 'Add electronic signature provisions', 'Update consumer rights section'],
 0.85, 'completed'),
('550e8400-e29b-41d4-a716-446655440233', '550e8400-e29b-41d4-a716-446655440023', 'compliance_check',
 '{"overall_compliance": 92, "popia_score": 95, "confidentiality_score": 90}'::jsonb,
 ARRAY['Strong confidentiality provisions', 'Clear data handling requirements', 'Appropriate duration terms'],
 ARRAY['Minor data processing clause ambiguity'],
 ARRAY['Data processing purposes could be more specific'],
 ARRAY['Clarify data processing purposes', 'Add data retention schedule'],
 0.90, 'completed'),
('550e8400-e29b-41d4-a716-446655440234', '550e8400-e29b-41d4-a716-446655440024', 'compliance_check',
 '{"overall_compliance": 75, "consumer_protection_score": 70, "service_delivery_score": 80}'::jsonb,
 ARRAY['Clear service level definitions', 'Appropriate penalty structures'],
 ARRAY['Consumer protection compliance gaps', 'Cancellation terms may be unfair'],
 ARRAY['Cancellation notice period too short', 'Refund terms unclear'],
 ARRAY['Extend cancellation notice period', 'Clarify refund procedures', 'Add consumer rights notice'],
 0.82, 'completed'),
('550e8400-e29b-41d4-a716-446655440235', '550e8400-e29b-41d4-a716-446655440025', 'compliance_check',
 '{"overall_compliance": 78, "companies_act_score": 75, "competition_act_score": 80, "bbbee_score": 75}'::jsonb,
 ARRAY['Comprehensive partnership structure', 'Clear governance arrangements'],
 ARRAY['Competition Commission approval pending', 'B-BBEE compliance verification needed'],
 ARRAY['Competition clearance required', 'B-BBEE verification certificates needed'],
 ARRAY['Obtain Competition Commission clearance', 'Update B-BBEE compliance documentation', 'Review director liability clauses'],
 0.85, 'completed'),
('550e8400-e29b-41d4-a716-446655440236', '550e8400-e29b-41d4-a716-446655440026', 'compliance_check',
 '{"overall_compliance": 95, "property_law_score": 95, "consumer_protection_score": 95}'::jsonb,
 ARRAY['Standard lease terms compliant', 'Fair rental escalation clauses', 'Appropriate maintenance responsibilities'],
 ARRAY['No significant risks identified'],
 ARRAY['Excellent compliance standards maintained'],
 ARRAY['Continue current lease management practices', 'Monitor rental market conditions'],
 0.95, 'completed'),
('550e8400-e29b-41d4-a716-446655440237', '550e8400-e29b-41d4-a716-446655440027', 'policy_review',
 '{"policy_effectiveness": 90, "popia_alignment": 95, "implementation_score": 85}'::jsonb,
 ARRAY['Comprehensive data protection framework', 'Clear consent mechanisms', 'Strong breach response procedures'],
 ARRAY['Implementation monitoring could be enhanced'],
 ARRAY['Regular review schedule needs formalization'],
 ARRAY['Implement quarterly policy reviews', 'Enhance staff training programs', 'Add automated compliance monitoring'],
 0.88, 'completed'),
('550e8400-e29b-41d4-a716-446655440238', '550e8400-e29b-41d4-a716-446655440028', 'risk_assessment',
 '{"overall_risk_score": 72, "operational_risk": 70, "compliance_risk": 75, "financial_risk": 70}'::jsonb,
 ARRAY['Comprehensive risk framework', 'Regular monitoring procedures', 'Clear escalation protocols'],
 ARRAY['Some operational risks require enhanced monitoring', 'Compliance risk management could be automated'],
 ARRAY['Manual compliance monitoring processes', 'Limited predictive risk analytics'],
 ARRAY['Implement automated compliance monitoring', 'Develop predictive risk models', 'Enhance operational risk controls'],
 0.85, 'completed'),
('550e8400-e29b-41d4-a716-446655440239', '550e8400-e29b-41d4-a716-446655440029', 'compliance_check',
 '{"overall_compliance": 82, "companies_act_score": 85, "competition_act_score": 80}'::jsonb,
 ARRAY['Well-structured merger terms', 'Clear valuation methodology', 'Appropriate due diligence provisions'],
 ARRAY['Competition Commission approval timeline uncertain'],
 ARRAY['Regulatory approval conditions pending'],
 ARRAY['Monitor Competition Commission approval process', 'Prepare for potential condition modifications', 'Update closing conditions'],
 0.87, 'completed'),
('550e8400-e29b-41d4-a716-446655440240', '550e8400-e29b-41d4-a716-446655440030', 'version_comparison',
 '{"similarity_score": 0.85, "key_differences": 12, "risk_changes": 3}'::jsonb,
 ARRAY['Version 1.0 to 2.0 comparison completed', 'Significant terms updates identified'],
 ARRAY['New liability limitations added', 'Payment terms modified', 'Termination clauses updated'],
 ARRAY['Review impact of new liability limitations', 'Assess payment term changes'],
 ARRAY['Analyze liability limitation impact', 'Review payment term modifications', 'Update internal procedures for v2.0'],
 0.90, 'completed'),
('550e8400-e29b-41d4-a716-446655440241', '550e8400-e29b-41d4-a716-446655440031', 'compliance_check',
 '{"overall_compliance": 83, "service_delivery_score": 85, "tax_compliance_score": 80}'::jsonb,
 ARRAY['Comprehensive IT service terms', 'Clear performance metrics', 'Appropriate liability allocation'],
 ARRAY['Tax compliance verification needed'],
 ARRAY['SARS clearance certificate required'],
 ARRAY['Obtain SARS tax clearance certificate', 'Update tax compliance clauses'],
 0.84, 'completed'),
('550e8400-e29b-41d4-a716-446655440242', '550e8400-e29b-41d4-a716-446655440032', 'compliance_check',
 '{"overall_compliance": 87, "employment_equity_score": 85, "labour_relations_score": 90}'::jsonb,
 ARRAY['Standard employment terms', 'Clear career progression path', 'Appropriate compensation structure'],
 ARRAY['Minor employment equity reporting requirements'],
 ARRAY['Employment equity plan needs update'],
 ARRAY['Update employment equity plan', 'Add skills development provisions'],
 0.88, 'completed'),
('550e8400-e29b-41d4-a716-446655440243', '550e8400-e29b-41d4-a716-446655440033', 'compliance_check',
 '{"overall_compliance": 94, "ip_protection_score": 95, "copyright_score": 93}'::jsonb,
 ARRAY['Strong IP protection clauses', 'Clear ownership provisions', 'Comprehensive licensing terms'],
 ARRAY['Minor copyright registration updates needed'],
 ARRAY['Some copyright registrations require renewal'],
 ARRAY['Renew copyright registrations', 'Update IP portfolio documentation'],
 0.93, 'completed'),
('550e8400-e29b-41d4-a716-446655440244', '550e8400-e29b-41d4-a716-446655440034', 'compliance_check',
 '{"overall_compliance": 91, "fica_score": 95, "service_delivery_score": 88}'::jsonb,
 ARRAY['Excellent FICA compliance', 'Clear service scope', 'Appropriate fee structure'],
 ARRAY['No significant risks identified'],
 ARRAY['Excellent compliance standards'],
 ARRAY['Maintain current high standards', 'Continue regular compliance reviews'],
 0.92, 'completed'),
('550e8400-e29b-41d4-a716-446655440245', '550e8400-e29b-41d4-a716-446655440035', 'policy_review',
 '{"policy_effectiveness": 86, "governance_alignment": 88, "implementation_score": 84}'::jsonb,
 ARRAY['Comprehensive governance framework', 'Clear compliance procedures', 'Regular monitoring protocols'],
 ARRAY['Some procedures need automation'],
 ARRAY['Manual compliance tracking processes'],
 ARRAY['Implement automated compliance tracking', 'Enhance reporting mechanisms'],
 0.86, 'completed');

-- Insert Document Comparisons (5 comparisons)
INSERT INTO document_comparisons (id, organization_id, primary_document_id, comparison_document_id, comparison_type, similarity_score, differences, similarities, analysis_summary, summary, risk_assessment, created_by) VALUES
('550e8400-e29b-41d4-a716-446655440251', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440022', '550e8400-e29b-41d4-a716-446655440030', 'version_comparison', 0.85,
 '{"liability_clauses": "New limitation of liability added in v2.0", "payment_terms": "Payment schedule changed from monthly to quarterly", "termination": "Notice period extended from 30 to 60 days", "support": "24/7 support added in v2.0"}'::jsonb,
 '{"licensing_model": "Both use perpetual licensing", "intellectual_property": "Same IP protection clauses", "confidentiality": "Identical confidentiality terms", "governing_law": "Both governed by SA law"}'::jsonb,
 'Comparison between TechCorp v1.0 and v2.0 software license agreements shows 85% similarity with key improvements in liability protection and support terms.',
 'Software license upgrade from v1.0 to v2.0 includes enhanced liability protection, improved payment terms, and expanded support coverage while maintaining core licensing structure.',
 '{"risk_level": "medium", "key_risks": ["New liability limitations may affect client protection", "Extended payment terms impact cash flow"], "recommendations": ["Review liability limitation impact", "Assess payment term changes"]}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440252', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440021', '550e8400-e29b-41d4-a716-446655440032', 'template_comparison', 0.92,
 '{"salary_structure": "Different salary bands", "benefits": "Medical aid options vary", "probation": "Probation period differs"}'::jsonb,
 '{"basic_terms": "Standard employment terms identical", "termination": "Same termination procedures", "confidentiality": "Identical confidentiality clauses", "compliance": "Same regulatory compliance requirements"}'::jsonb,
 'Employment contract comparison shows high similarity with minor variations in compensation structure.',
 'Employment contracts are highly standardized with 92% similarity, differing mainly in individual compensation packages.',
 '{"risk_level": "low", "key_risks": ["Minor inconsistencies in benefit structures"], "recommendations": ["Standardize benefit presentations"]}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440253', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440025', '550e8400-e29b-41d4-a716-446655440029', 'contract_comparison', 0.45,
 '{"structure": "Partnership vs acquisition structure", "governance": "Different decision-making processes", "liability": "Varying liability allocations", "termination": "Different exit mechanisms"}'::jsonb,
 '{"legal_framework": "Both use SA corporate law", "due_diligence": "Similar DD requirements", "regulatory": "Both require Competition Commission approval"}'::jsonb,
 'Partnership Agreement vs Merger Agreement comparison reveals fundamental structural differences.',
 'Partnership and merger agreements have different legal structures (45% similarity) requiring separate compliance frameworks.',
 '{"risk_level": "high", "key_risks": ["Different legal structures", "Varying liability exposure"], "recommendations": ["Separate legal analysis required"]}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440254', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440024', '550e8400-e29b-41d4-a716-446655440031', 'service_comparison', 0.78,
 '{"service_scope": "Cloud vs IT services", "performance_metrics": "Different SLA metrics", "pricing": "Different pricing models", "support": "Varying support levels"}'::jsonb,
 '{"contract_structure": "Similar service agreement format", "termination": "Same termination procedures", "liability": "Similar liability limitations", "governing_law": "Both SA law"}'::jsonb,
 'Service agreements comparison shows good similarity in structure with differences in service specifics.',
 'Cloud services and IT services agreements share common structure (78% similarity) with service-specific variations.',
 '{"risk_level": "medium", "key_risks": ["Different service delivery models"], "recommendations": ["Standardize common terms"]}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440255', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440033', '550e8400-e29b-41d4-a716-446655440035', 'policy_comparison', 0.67,
 '{"scope": "IP agreement vs governance manual", "detail_level": "Different levels of detail", "compliance_focus": "IP vs corporate governance", "update_frequency": "Different review cycles"}'::jsonb,
 '{"legal_framework": "Both reference SA law", "compliance_approach": "Similar compliance methodology", "risk_management": "Common risk assessment approach"}'::jsonb,
 'IP Agreement vs Governance Manual comparison shows moderate similarity in compliance approach.',
 'IP and governance documents share compliance methodology (67% similarity) but address different regulatory areas.',
 '{"risk_level": "low", "key_risks": ["Different regulatory focuses"], "recommendations": ["Align compliance approaches"]}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440014');

-- Insert Document Templates (8 templates)
INSERT INTO document_templates (template_name, template_type, display_name, description, category, default_content, required_fields, optional_fields, compliance_requirements, applicable_laws, risk_level) VALUES
('employment_contract', 'contract', 'Employment Contract', 'Standard employment contract template compliant with South African labor laws', 'employment', 
 'Employment Contract between [EMPLOYER_NAME] and [EMPLOYEE_NAME]. This contract is governed by South African labor legislation.',
 '{"employer_name": "string", "employee_name": "string", "position": "string", "salary": "number", "start_date": "date"}'::jsonb,
 '{"probation_period": "string", "benefits": "array", "working_hours": "string"}'::jsonb,
 ARRAY['Labour Relations Act compliance', 'Employment Equity Act compliance'],
 ARRAY['Labour Relations Act (Act 66 of 1995)', 'Employment Equity Act (Act 55 of 1998)'],
 'medium'),
('software_license', 'contract', 'Software License Agreement', 'Software licensing agreement template with IP protection', 'licensing',
 'Software License Agreement for [SOFTWARE_NAME]. This agreement governs software use in accordance with SA law.',
 '{"software_name": "string", "licensor": "string", "licensee": "string", "license_type": "string"}'::jsonb,
 '{"usage_restrictions": "array", "support_terms": "string", "update_policy": "string"}'::jsonb,
 ARRAY['Copyright Act compliance', 'Consumer Protection Act compliance'],
 ARRAY['Copyright Act (Act 98 of 1978)', 'Consumer Protection Act (Act 68 of 2008)'],
 'medium'),
('nda', 'contract', 'Non-Disclosure Agreement', 'Confidentiality agreement template with POPIA compliance', 'confidentiality',
 'Non-Disclosure Agreement between [DISCLOSING_PARTY] and [RECEIVING_PARTY]. POPIA compliant.',
 '{"disclosing_party": "string", "receiving_party": "string", "purpose": "string"}'::jsonb,
 '{"information_types": "array", "permitted_uses": "array", "return_obligations": "string"}'::jsonb,
 ARRAY['POPIA compliance', 'Confidentiality law compliance'],
 ARRAY['Protection of Personal Information Act (Act 4 of 2013)'],
 'high'),
('partnership_agreement', 'contract', 'Partnership Agreement', 'Business partnership agreement template', 'partnership',
 'Partnership Agreement between [PARTNER_1] and [PARTNER_2]. SA Companies Act compliant.',
 '{"partner_1": "string", "partner_2": "string", "business_name": "string"}'::jsonb,
 '{"profit_sharing": "object", "management_structure": "string", "decision_making": "string"}'::jsonb,
 ARRAY['Companies Act compliance', 'Partnership Act compliance'],
 ARRAY['Companies Act (Act 71 of 2008)', 'Partnership Act (Act 34 of 1961)'],
 'high'),
('service_agreement', 'contract', 'Service Level Agreement', 'Service delivery agreement template', 'service',
 'Service Level Agreement between [SERVICE_PROVIDER] and [CLIENT]. Consumer Protection Act compliant.',
 '{"service_provider": "string", "client": "string", "services": "array"}'::jsonb,
 '{"performance_metrics": "object", "penalties": "object", "support_procedures": "string"}'::jsonb,
 ARRAY['Consumer Protection Act compliance', 'Service delivery standards'],
 ARRAY['Consumer Protection Act (Act 68 of 2008)'],
 'medium'),
('lease_agreement', 'contract', 'Commercial Lease Agreement', 'Commercial property lease template', 'real_estate',
 'Commercial Lease Agreement for [PROPERTY_ADDRESS] between [LANDLORD] and [TENANT].',
 '{"property_address": "string", "landlord": "string", "tenant": "string", "rental_amount": "number"}'::jsonb,
 '{"lease_term": "string", "escalation": "object", "maintenance": "string"}'::jsonb,
 ARRAY['Property law compliance', 'Consumer Protection Act compliance'],
 ARRAY['Rental Housing Act (Act 50 of 1999)', 'Consumer Protection Act (Act 68 of 2008)'],
 'low'),
('ip_agreement', 'contract', 'Intellectual Property Agreement', 'IP licensing and protection agreement', 'intellectual_property',
 'Intellectual Property Agreement for [IP_DESCRIPTION] between [LICENSOR] and [LICENSEE].',
 '{"ip_description": "string", "licensor": "string", "licensee": "string", "ip_type": "string"}'::jsonb,
 '{"royalty_terms": "object", "territory": "string", "exclusivity": "boolean"}'::jsonb,
 ARRAY['Copyright Act compliance', 'Patent Act compliance'],
 ARRAY['Copyright Act (Act 98 of 1978)', 'Patents Act (Act 57 of 1978)'],
 'high'),
('compliance_policy', 'policy', 'Compliance Policy Template', 'Corporate compliance policy template', 'compliance',
 'Compliance Policy for [ORGANIZATION_NAME]. This policy ensures regulatory compliance across all operations.',
 '{"organization_name": "string", "policy_scope": "string", "effective_date": "date"}'::jsonb,
 '{"review_frequency": "string", "responsible_parties": "array", "training_requirements": "string"}'::jsonb,
 ARRAY['King IV governance principles', 'Regulatory compliance standards'],
 ARRAY['King IV Report on Corporate Governance', 'Various regulatory acts'],
 'medium');

-- Insert File Storage Config
INSERT INTO file_storage_config (storage_type, base_path, max_file_size_mb, allowed_mime_types, retention_days) VALUES
('local', '/public/documents/', 100, ARRAY['application/pdf', 'application/msword', 'text/plain'], 1095),
('local', '/public/generated-pdfs/', 50, ARRAY['application/pdf'], 365);

-- Insert Document Generation Log (10 entries)
INSERT INTO document_generation_log (document_id, template_used, generation_status, generation_time_ms, file_size_bytes, generated_by) VALUES
('550e8400-e29b-41d4-a716-446655440021', 'employment_contract', 'completed', 1250, 156789, '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440022', 'software_license', 'completed', 1450, 198765, '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440023', 'nda', 'completed', 980, 134567, '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440024', 'service_agreement', 'completed', 1320, 176543, '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440025', 'partnership_agreement', 'completed', 1680, 223456, '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440026', 'lease_agreement', 'completed', 1100, 145678, '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440027', 'compliance_policy', 'completed', 1800, 267890, '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440033', 'ip_agreement', 'completed', 1550, 234567, '550e8400-e29b-41d4-a716-446655440014'),
('550e8400-e29b-41d4-a716-446655440034', 'service_agreement', 'completed', 1200, 167890, '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440035', 'compliance_policy', 'completed', 1900, 456123, '550e8400-e29b-41d4-a716-446655440014');

-- Insert Audit Logs (15 entries)
INSERT INTO audit_logs (organization_id, user_id, action, resource_type, resource_id, details) VALUES
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440011', 'document_created', 'document', '550e8400-e29b-41d4-a716-446655440021', '{"document_type": "employment_contract", "template_used": "employment_contract"}'::jsonb),
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440012', 'compliance_alert_created', 'compliance_alert', '550e8400-e29b-41d4-a716-446655440121', '{"alert_type": "compliance", "priority": "high"}'::jsonb),
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440011', 'document_analysis_completed', 'document_analysis', '550e8400-e29b-41d4-a716-446655440231', '{"analysis_type": "compliance_check", "confidence_score": 0.92}'::jsonb),
('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440013', 'compliance_report_generated', 'compliance_report', '550e8400-e29b-41d4-a716-446655440213', '{"report_type": "corporate", "period": "2024"}'::jsonb),
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440012', 'task_completed', 'task', '550e8400-e29b-41d4-a716-446655440053', '{"task_type": "template_update", "completion_time": "2024-12-15"}'::jsonb),
('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440013', 'deposition_scheduled', 'deposition', '550e8400-e29b-41d4-a716-446655440146', '{"case_name": "Property Development Case", "date": "2024-12-30"}'::jsonb),
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440011', 'document_comparison_completed', 'document_comparison', '550e8400-e29b-41d4-a716-446655440251', '{"comparison_type": "version_comparison", "similarity_score": 0.85}'::jsonb),
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440012', 'compliance_alert_resolved', 'compliance_alert', '550e8400-e29b-41d4-a716-446655440124', '{"resolution_type": "document_updated", "resolved_date": "2024-12-16"}'::jsonb),
('550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440014', 'document_uploaded', 'document', '550e8400-e29b-41d4-a716-446655440033', '{"document_type": "ip_agreement", "file_size": 234567}'::jsonb),
('550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440014', 'deposition_completed', 'deposition', '550e8400-e29b-41d4-a716-446655440149', '{"case_name": "IP Infringement Case", "duration": 200}'::jsonb),
('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440013', 'timeline_created', 'case_timeline', '550e8400-e29b-41d4-a716-446655440173', '{"case_name": "Merger Due
