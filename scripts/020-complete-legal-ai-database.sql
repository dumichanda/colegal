-- =====================================================
-- COMPLETE LEGAL AI DATABASE SETUP
-- Full database reset and creation with PDF generation
-- Run this ONE script to set up everything
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. DROP ALL EXISTING TABLES AND VIEWS
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
-- 2. CREATE ALL TABLES WITH COMPLETE SCHEMA
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

-- Documents table (enhanced for PDF generation)
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
    pdf_generated BOOLEAN DEFAULT false,
    pdf_generation_date TIMESTAMP,
    pdf_file_path VARCHAR(500),
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

-- Document Templates table (for PDF generation)
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
-- 3. CREATE COMPREHENSIVE INDEXES
-- =====================================================

-- Organizations indexes
CREATE INDEX idx_organizations_name ON organizations(name);
CREATE INDEX idx_organizations_type ON organizations(type);

-- Users indexes
CREATE INDEX idx_users_organization_id ON users(organization_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(is_active);

-- Documents indexes
CREATE INDEX idx_documents_organization_id ON documents(organization_id);
CREATE INDEX idx_documents_type ON documents(type);
CREATE INDEX idx_documents_category ON documents(category);
CREATE INDEX idx_documents_status ON documents(status);
CREATE INDEX idx_documents_risk_level ON documents(risk_level);
CREATE INDEX idx_documents_template_type ON documents(template_type);
CREATE INDEX idx_documents_generation_status ON documents(generation_status);
CREATE INDEX idx_documents_file_path ON documents(file_path);
CREATE INDEX idx_documents_created_at ON documents(created_at);

-- Tasks indexes
CREATE INDEX idx_tasks_organization_id ON tasks(organization_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);

-- Compliance indexes
CREATE INDEX idx_compliance_rules_organization_id ON compliance_rules(organization_id);
CREATE INDEX idx_compliance_rules_category ON compliance_rules(category);
CREATE INDEX idx_compliance_rules_active ON compliance_rules(is_active);
CREATE INDEX idx_compliance_monitoring_organization_id ON compliance_monitoring(organization_id);
CREATE INDEX idx_compliance_monitoring_rule_id ON compliance_monitoring(rule_id);
CREATE INDEX idx_compliance_monitoring_status ON compliance_monitoring(status);
CREATE INDEX idx_compliance_monitoring_next_check ON compliance_monitoring(next_check_due);
CREATE INDEX idx_compliance_alerts_organization_id ON compliance_alerts(organization_id);
CREATE INDEX idx_compliance_alerts_status ON compliance_alerts(status);
CREATE INDEX idx_compliance_alerts_priority ON compliance_alerts(priority);
CREATE INDEX idx_compliance_alerts_due_date ON compliance_alerts(due_date);

-- Depositions indexes
CREATE INDEX idx_depositions_organization_id ON depositions(organization_id);
CREATE INDEX idx_depositions_status ON depositions(status);
CREATE INDEX idx_depositions_date ON depositions(date_conducted);
CREATE INDEX idx_depositions_case_name ON depositions(case_name);
CREATE INDEX idx_deposition_analyses_deposition_id ON deposition_analyses(deposition_id);

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
CREATE INDEX idx_document_comparisons_primary ON document_comparisons(primary_document_id);

-- Template indexes
CREATE INDEX idx_document_templates_type ON document_templates(template_type);
CREATE INDEX idx_document_templates_category ON document_templates(category);
CREATE INDEX idx_document_templates_active ON document_templates(is_active);

-- Generation log indexes
CREATE INDEX idx_generation_log_document_id ON document_generation_log(document_id);
CREATE INDEX idx_generation_log_status ON document_generation_log(generation_status);
CREATE INDEX idx_generation_log_created_at ON document_generation_log(created_at);

-- Regulatory updates indexes
CREATE INDEX idx_regulatory_updates_active ON regulatory_updates(is_active);
CREATE INDEX idx_regulatory_updates_date ON regulatory_updates(effective_date);
CREATE INDEX idx_regulatory_updates_category ON regulatory_updates(category);

-- Audit indexes
CREATE INDEX idx_audit_logs_organization_id ON audit_logs(organization_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- =====================================================
-- 4. INSERT COMPREHENSIVE SEED DATA
-- =====================================================

-- Insert Organizations
INSERT INTO organizations (id, name, type, industry, country, address, contact_email) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Johannesburg Legal Firm', 'Law Firm', 'Legal Services', 'South Africa', '123 Commissioner Street, Johannesburg, 2001', 'info@jhblegal.co.za'),
('550e8400-e29b-41d4-a716-446655440002', 'Cape Town Corporate Law', 'Law Firm', 'Corporate Law', 'South Africa', '456 Long Street, Cape Town, 8001', 'contact@ctclaw.co.za');

-- Insert Users
INSERT INTO users (id, organization_id, email, name, role, department) VALUES
('550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440001', 'sarah.johnson@jhblegal.co.za', 'Sarah Johnson', 'Senior Partner', 'Corporate Law'),
('550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440001', 'michael.smith@jhblegal.co.za', 'Michael Smith', 'Associate', 'Compliance'),
('550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440002', 'linda.williams@ctclaw.co.za', 'Linda Williams', 'Compliance Officer', 'Risk Management');

-- Insert Document Templates
INSERT INTO document_templates (template_name, template_type, display_name, description, category, default_content, required_fields, optional_fields, compliance_requirements, applicable_laws, risk_level) VALUES
('employment_contract', 'contract', 'Employment Contract', 'Standard employment contract template compliant with South African labor laws', 'employment', 
 'Employment Contract between [EMPLOYER_NAME] and [EMPLOYEE_NAME]. This contract is governed by South African labor legislation including the Labour Relations Act, Basic Conditions of Employment Act, and Employment Equity Act.',
 '{"employer_name": "string", "employee_name": "string", "position": "string", "salary": "number", "start_date": "date"}',
 '{"probation_period": "string", "benefits": "array", "working_hours": "string", "leave_entitlement": "string"}',
 ARRAY['Labour Relations Act compliance', 'Employment Equity Act compliance', 'Basic Conditions of Employment Act compliance'],
 ARRAY['Labour Relations Act (Act 66 of 1995)', 'Employment Equity Act (Act 55 of 1998)', 'Basic Conditions of Employment Act (Act 75 of 1997)'],
 'medium'),

('software_license', 'contract', 'Software License Agreement', 'Software licensing agreement template with intellectual property protection', 'licensing',
 'Software License Agreement for [SOFTWARE_NAME]. This agreement governs the use of software in accordance with South African Copyright Act and Electronic Communications and Transactions Act.',
 '{"software_name": "string", "licensor": "string", "licensee": "string", "license_type": "string", "term": "string"}',
 '{"usage_restrictions": "array", "support_terms": "string", "update_policy": "string", "termination_conditions": "array"}',
 ARRAY['Copyright Act compliance', 'Consumer Protection Act compliance', 'Electronic Communications Act compliance'],
 ARRAY['Copyright Act (Act 98 of 1978)', 'Consumer Protection Act (Act 68 of 2008)', 'Electronic Communications and Transactions Act (Act 25 of 2002)'],
 'medium'),

('nda', 'contract', 'Non-Disclosure Agreement', 'Confidentiality agreement template with POPIA compliance', 'confidentiality',
 'Non-Disclosure Agreement between [DISCLOSING_PARTY] and [RECEIVING_PARTY]. This agreement protects confidential information in accordance with POPIA and common law confidentiality principles.',
 '{"disclosing_party": "string", "receiving_party": "string", "purpose": "string", "duration": "string"}',
 '{"information_types": "array", "permitted_uses": "array", "return_obligations": "string", "remedies": "array"}',
 ARRAY['POPIA compliance', 'Confidentiality law compliance', 'Data protection requirements'],
 ARRAY['Protection of Personal Information Act (Act 4 of 2013)', 'Common Law Confidentiality Principles'],
 'high'),

('partnership_agreement', 'contract', 'Partnership Agreement', 'Business partnership agreement template compliant with Companies Act', 'partnership',
 'Partnership Agreement between [PARTNER_1] and [PARTNER_2]. This agreement establishes a business partnership in accordance with South African Companies Act and Partnership Act.',
 '{"partner_1": "string", "partner_2": "string", "business_name": "string", "partnership_type": "string", "capital_contributions": "object"}',
 '{"profit_sharing": "object", "management_structure": "string", "decision_making": "string", "dissolution_terms": "array"}',
 ARRAY['Companies Act compliance', 'Partnership Act compliance', 'Tax law compliance'],
 ARRAY['Companies Act (Act 71 of 2008)', 'Partnership Act (Act 34 of 1961)', 'Income Tax Act (Act 58 of 1962)'],
 'high'),

('service_agreement', 'contract', 'Service Level Agreement', 'Service delivery agreement template with consumer protection compliance', 'service',
 'Service Level Agreement between [SERVICE_PROVIDER] and [CLIENT]. This agreement defines service delivery standards in accordance with South African Consumer Protection Act.',
 '{"service_provider": "string", "client": "string", "services": "array", "service_levels": "object", "term": "string"}',
 '{"performance_metrics": "object", "penalties": "object", "support_procedures": "string", "termination_rights": "array"}',
 ARRAY['Consumer Protection Act compliance', 'Service delivery standards', 'Performance monitoring requirements'],
 ARRAY['Consumer Protection Act (Act 68 of 2008)', 'Electronic Communications and Transactions Act (Act 25 of 2002)'],
 'medium');

-- Insert Documents with PDF generation data
INSERT INTO documents (id, organization_id, title, type, category, content, template_type, file_path, file_size, status, risk_level, uploaded_by, generated_at) VALUES
('550e8400-e29b-41d4-a716-446655440021', '550e8400-e29b-41d4-a716-446655440001', 'Employment Contract - Senior Developer', 'contract', 'employment', 
 'This Employment Contract is entered into between Johannesburg Legal Firm and John Doe for the position of Senior Developer. This contract is governed by South African labor legislation including the Labour Relations Act, Basic Conditions of Employment Act, and Employment Equity Act. The employee will receive a monthly salary of R45,000 with standard benefits including medical aid, pension fund, and 21 days annual leave.',
 'employment_contract', '/generated-pdfs/employment_contract_senior_developer.pdf', 156789, 'active', 'low', '550e8400-e29b-41d4-a716-446655440011', CURRENT_TIMESTAMP),

('550e8400-e29b-41d4-a716-446655440022', '550e8400-e29b-41d4-a716-446655440001', 'Software License Agreement - TechCorp v2.0', 'contract', 'licensing',
 'Software License Agreement for TechCorp Enterprise Suite v2.0. This agreement governs the use of software in accordance with South African Copyright Act and Electronic Communications and Transactions Act. The license grants non-exclusive rights to use the software for internal business purposes with restrictions on redistribution and modification.',
 'software_license', '/generated-pdfs/software_license_techcorp_v2.pdf', 198765, 'active', 'medium', '550e8400-e29b-41d4-a716-446655440011', CURRENT_TIMESTAMP),

('550e8400-e29b-41d4-a716-446655440023', '550e8400-e29b-41d4-a716-446655440001', 'Non-Disclosure Agreement - Project Alpha', 'contract', 'confidentiality',
 'Non-Disclosure Agreement between Johannesburg Legal Firm and ABC Corporation regarding Project Alpha. This agreement protects confidential information in accordance with POPIA and common law confidentiality principles. The agreement covers technical specifications, business strategies, and financial information with a 5-year confidentiality period.',
 'nda', '/generated-pdfs/nda_project_alpha.pdf', 134567, 'active', 'high', '550e8400-e29b-41d4-a716-446655440012', CURRENT_TIMESTAMP),

('550e8400-e29b-41d4-a716-446655440024', '550e8400-e29b-41d4-a716-446655440001', 'Service Level Agreement - Cloud Services', 'contract', 'service',
 'Service Level Agreement between Johannesburg Legal Firm and CloudTech Solutions for cloud infrastructure services. This agreement defines service delivery standards in accordance with South African Consumer Protection Act. The SLA guarantees 99.9% uptime, 24/7 support, and data backup services with penalties for non-compliance.',
 'service_agreement', '/generated-pdfs/sla_cloud_services.pdf', 176543, 'active', 'medium', '550e8400-e29b-41d4-a716-446655440011', CURRENT_TIMESTAMP),

('550e8400-e29b-41d4-a716-446655440025', '550e8400-e29b-41d4-a716-446655440002', 'Partnership Agreement - Strategic Alliance', 'contract', 'partnership',
 'Partnership Agreement between Cape Town Corporate Law and Legal Innovation Partners. This agreement establishes a business partnership in accordance with South African Companies Act and Partnership Act. The partnership focuses on legal technology development with 60/40 profit sharing and joint decision-making on strategic matters.',
 'partnership_agreement', '/generated-pdfs/partnership_strategic_alliance.pdf', 223456, 'active', 'high', '550e8400-e29b-41d4-a716-446655440013', CURRENT_TIMESTAMP),

('550e8400-e29b-41d4-a716-446655440026', '550e8400-e29b-41d4-a716-446655440002', 'Lease Agreement - Office Space Cape Town', 'contract', 'real_estate',
 'Commercial lease agreement for office space at 456 Long Street, Cape Town. The lease term is 5 years with monthly rental of R35,000 including utilities and parking. The agreement includes renewal options and maintenance responsibilities in accordance with South African property law.',
 'lease_agreement', '/generated-pdfs/lease_office_cape_town.pdf', 145678, 'active', 'low', '550e8400-e29b-41d4-a716-446655440013', CURRENT_TIMESTAMP),

('550e8400-e29b-41d4-a716-446655440027', '550e8400-e29b-41d4-a716-446655440001', 'Compliance Policy - Data Protection', 'policy', 'compliance',
 'Comprehensive Data Protection Policy for Johannesburg Legal Firm. This policy establishes compliance framework in accordance with POPIA, King IV Corporate Governance principles, and international data protection standards. The policy covers data collection, processing, storage, and disposal with regular compliance monitoring and staff training requirements.',
 'compliance_policy', '/generated-pdfs/compliance_policy_data_protection.pdf', 267890, 'active', 'high', '550e8400-e29b-41d4-a716-446655440012', CURRENT_TIMESTAMP),

('550e8400-e29b-41d4-a716-446655440028', '550e8400-e29b-41d4-a716-446655440001', 'Risk Assessment Report - Q4 2024', 'report', 'risk_management',
 'Quarterly Risk Assessment Report for Q4 2024 evaluating organizational risks in accordance with King IV Corporate Governance principles. The report identifies operational, compliance, financial, and strategic risks with corresponding mitigation strategies. Key risks include cybersecurity threats, regulatory changes, and market volatility.',
 'risk_report', '/generated-pdfs/risk_assessment_q4_2024.pdf', 345678, 'active', 'medium', '550e8400-e29b-41d4-a716-446655440012', CURRENT_TIMESTAMP),

('550e8400-e29b-41d4-a716-446655440029', '550e8400-e29b-41d4-a716-446655440002', 'Merger Agreement - TechStart Acquisition', 'contract', 'merger',
 'Merger Agreement for the acquisition of TechStart Innovation by Cape Town Corporate Law clients. This agreement facilitates corporate combination in compliance with South African Companies Act and Competition Act. The transaction value is R50 million with regulatory approvals required from Competition Commission and CIPC.',
 'merger_agreement', '/generated-pdfs/merger_techstart_acquisition.pdf', 456789, 'active', 'high', '550e8400-e29b-41d4-a716-446655440013', CURRENT_TIMESTAMP),

('550e8400-e29b-41d4-a716-446655440030', '550e8400-e29b-41d4-a716-446655440001', 'Software License Agreement - TechCorp v1.0', 'contract', 'licensing',
 'Software License Agreement for TechCorp Enterprise Suite v1.0 (legacy version). This agreement governs the use of previous software version with maintenance support until migration to v2.0. The license includes upgrade rights and data migration assistance with extended support terms.',
 'software_license', '/generated-pdfs/software_license_techcorp_v1.pdf', 187654, 'active', 'medium', '550e8400-e29b-41d4-a716-446655440011', CURRENT_TIMESTAMP);

-- Insert Tasks
INSERT INTO tasks (id, organization_id, title, description, type, status, priority, assigned_to, created_by, due_date) VALUES
('550e8400-e29b-41d4-a716-446655440041', '550e8400-e29b-41d4-a716-446655440001', 'Review Employment Contract Terms', 'Review and update standard employment contract terms for compliance with new labor laws', 'document_review', 'in_progress', 'high', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2024-12-30'),
('550e8400-e29b-41d4-a716-446655440042', '550e8400-e29b-41d4-a716-446655440001', 'Compliance Audit - Q4 2024', 'Conduct quarterly compliance audit for all active contracts', 'compliance_check', 'pending', 'high', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2024-12-31'),
('550e8400-e29b-41d4-a716-446655440043', '550e8400-e29b-41d4-a716-446655440001', 'Update NDA Templates', 'Update non-disclosure agreement templates with latest legal requirements', 'template_update', 'completed', 'medium', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440011', '2024-12-15'),
('550e8400-e29b-41d4-a716-446655440044', '550e8400-e29b-41d4-a716-446655440002', 'Risk Assessment - New Partnership', 'Assess legal risks for the proposed strategic alliance partnership', 'risk_assessment', 'in_progress', 'high', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', '2024-12-28'),
('550e8400-e29b-41d4-a716-446655440045', '550e8400-e29b-41d4-a716-446655440001', 'Document Classification Review', 'Review and reclassify documents based on new risk assessment criteria', 'classification', 'pending', 'medium', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2025-01-15'),
('550e8400-e29b-41d4-a716-446655440046', '550e8400-e29b-41d4-a716-446655440002', 'Lease Renewal Negotiation', 'Negotiate terms for office lease renewal in Cape Town', 'negotiation', 'pending', 'medium', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', '2025-01-31'),
('550e8400-e29b-41d4-a716-446655440047', '550e8400-e29b-41d4-a716-446655440001', 'Regulatory Update Review', 'Review and implement changes from latest POPIA amendments', 'regulatory_review', 'in_progress', 'high', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2024-12-20'),
('550e8400-e29b-41d4-a716-446655440048', '550e8400-e29b-41d4-a716-446655440002', 'Contract Comparison Analysis', 'Compare merger agreement terms with industry standards', 'analysis', 'pending', 'medium', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', '2025-01-10'),
('550e8400-e29b-41d4-a716-446655440049', '550e8400-e29b-41d4-a716-446655440001', 'Client Onboarding Documentation', 'Prepare legal documentation for new corporate client onboarding', 'documentation', 'completed', 'low', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440011', '2024-12-10'),
('550e8400-e29b-41d4-a716-446655440050', '550e8400-e29b-41d4-a716-446655440001', 'Training Material Update', 'Update compliance training materials for staff', 'training', 'failed', 'low', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2025-02-01');

-- Insert Compliance Rules
INSERT INTO compliance_rules (id, organization_id, name, title, description, category, regulation_source, risk_level) VALUES
('550e8400-e29b-41d4-a716-446655440061', '550e8400-e29b-41d4-a716-446655440001', 'POPIA Data Protection Compliance', 'POPIA Data Protection Compliance', 'Ensure all contracts comply with Protection of Personal Information Act requirements', 'data_protection', 'POPIA (Act 4 of 2013)', 'high'),
('550e8400-e29b-41d4-a716-446655440062', '550e8400-e29b-41d4-a716-446655440001', 'Employment Equity Act Compliance', 'Employment Equity Act Compliance', 'Verify employment contracts meet Employment Equity Act standards', 'employment', 'Employment Equity Act (Act 55 of 1998)', 'high'),
('550e8400-e29b-41d4-a716-446655440063', '550e8400-e29b-41d4-a716-446655440001', 'Consumer Protection Act Compliance', 'Consumer Protection Act Compliance', 'Ensure service agreements comply with Consumer Protection Act', 'consumer_protection', 'Consumer Protection Act (Act 68 of 2008)', 'medium'),
('550e8400-e29b-41d4-a716-446655440064', '550e8400-e29b-41d4-a716-446655440002', 'Companies Act Compliance', 'Companies Act Compliance', 'Verify corporate documents comply with Companies Act requirements', 'corporate', 'Companies Act (Act 71 of 2008)', 'high'),
('550e8400-e29b-41d4-a716-446655440065', '550e8400-e29b-41d4-a716-446655440001', 'Labour Relations Act Compliance', 'Labour Relations Act Compliance', 'Ensure employment terms comply with Labour Relations Act', 'employment', 'Labour Relations Act (Act 66 of 1995)', 'medium'),
('550e8400-e29b-41d4-a716-446655440066', '550e8400-e29b-41d4-a716-446655440002', 'Competition Act Compliance', 'Competition Act Compliance', 'Review merger agreements for Competition Act compliance', 'competition', 'Competition Act (Act 89 of 1998)', 'high'),
('550e8400-e29b-41d4-a716-446655440067', '550e8400-e29b-41d4-a716-446655440001', 'Electronic Communications Act Compliance', 'Electronic Communications Act Compliance', 'Ensure digital contracts comply with Electronic Communications Act', 'electronic_communications', 'Electronic Communications Act (Act 36 of 2005)', 'medium'),
('550e8400-e29b-41d4-a716-446655440068', '550e8400-e29b-41d4-a716-446655440002', 'B-BBEE Compliance', 'B-BBEE Compliance', 'Verify contracts meet B-BBEE requirements', 'empowerment', 'B-BBEE Act (Act 53 of 2003)', 'medium');

-- Insert Compliance Monitoring
INSERT INTO compliance_monitoring (id, organization_id, rule_id, document_id, status, compliance_score, issues_found, next_check_due) VALUES
('550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440061', '550e8400-e29b-41d4-a716-446655440021', 'compliant', 95, 0, '2025-03-01'),
('550e8400-e29b-41d4-a716-446655440072', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440062', '550e8400-e29b-41d4-a716-446655440021', 'compliant', 88, 1, '2025-02-15'),
('550e8400-e29b-41d4-a716-446655440073', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440063', '550e8400-e29b-41d4-a716-446655440022', 'non_compliant', 65, 3, '2024-12-31'),
('550e8400-e29b-41d4-a716-446655440074', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440061', '550e8400-e29b-41d4-a716-446655440023', 'compliant', 92, 1, '2025-02-28'),
('550e8400-e29b-41d4-a716-446655440075', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440064', '550e8400-e29b-41d4-a716-446655440025', 'under_review', 78, 2, '2025-01-20'),
('550e8400-e29b-41d4-a716-446655440076', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440066', '550e8400-e29b-41d4-a716-446655440029', 'compliant', 85, 1, '2025-04-01'),
('550e8400-e29b-41d4-a716-446655440077', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440067', '550e8400-e29b-41d4-a716-446655440022', 'non_compliant', 58, 4, '2024-12-25'),
('550e8400-e29b-41d4-a716-446655440078', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440065', '550e8400-e29b-41d4-a716-446655440021', 'compliant', 90, 1, '2025-03-15');

-- Insert Compliance Alerts (mix of active and resolved)
INSERT INTO compliance_alerts (id, organization_id, rule_id, document_id, title, description, priority, type, status, due_date, regulation_source, jurisdiction) VALUES
('550e8400-e29b-41d4-a716-446655440081', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440063', '550e8400-e29b-41d4-a716-446655440022', 'Consumer Protection Act Violations Found', 'Software License Agreement contains clauses that may violate Consumer Protection Act requirements. Review and update required.', 'High', 'compliance', 'active', '2024-12-25', 'Consumer Protection Act (Act 68 of 2008)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440082', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440067', '550e8400-e29b-41d4-a716-446655440022', 'Electronic Communications Act Non-Compliance', 'Digital signature requirements not met in Software License Agreement. Update electronic execution clauses.', 'High', 'compliance', 'active', '2024-12-30', 'Electronic Communications Act (Act 36 of 2005)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440083', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440064', '550e8400-e29b-41d4-a716-446655440025', 'Companies Act Review Required', 'Partnership Agreement requires review for Companies Act compliance. Director liability clauses need attention.', 'Medium', 'compliance', 'resolved', '2025-01-15', 'Companies Act (Act 71 of 2008)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440084', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440062', '550e8400-e29b-41d4-a716-446655440021', 'Employment Equity Minor Issue', 'Employment Contract has minor Employment Equity Act compliance issue. Update diversity reporting clause.', 'Low', 'compliance', 'resolved', '2025-01-31', 'Employment Equity Act (Act 55 of 1998)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440085', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440061', '550e8400-e29b-41d4-a716-446655440023', 'POPIA Data Handling Update', 'NDA requires update to align with latest POPIA data handling requirements. Review data processing clauses.', 'Medium', 'compliance', 'active', '2025-01-10', 'POPIA (Act 4 of 2013)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440086', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440066', '550e8400-e29b-41d4-a716-446655440029', 'Competition Act Clearance Pending', 'Merger Agreement pending Competition Commission clearance. Monitor approval status and update terms if required.', 'Critical', 'regulatory', 'active', '2025-02-28', 'Competition Act (Act 89 of 1998)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440087', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440065', '550e8400-e29b-41d4-a716-446655440021', 'Labour Relations Act Update', 'Employment Contract needs minor update for Labour Relations Act compliance. Review dispute resolution clauses.', 'Low', 'compliance', 'resolved', '2025-02-15', 'Labour Relations Act (Act 66 of 1995)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440088', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440068', '550e8400-e29b-41d4-a716-446655440025', 'B-BBEE Compliance Check', 'Partnership Agreement requires B-BBEE compliance verification. Update procurement and supplier clauses.', 'Medium', 'compliance', 'active', '2025-01-20', 'B-BBEE Act (Act 53 of 2003)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440089', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440061', '550e8400-e29b-41d4-a716-446655440027', 'POPIA Policy Update Required', 'Data Protection Policy needs update to reflect latest POPIA amendments. Review consent mechanisms.', 'High', 'policy', 'active', '2024-12-31', 'POPIA (Act 4 of 2013)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440090', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440063', '550e8400-e29b-41d4-a716-446655440024', 'Consumer Protection Review', 'Service Level Agreement requires Consumer Protection Act compliance review. Update cancellation and refund terms.', 'Medium', 'compliance', 'active', '2025-01-05', 'Consumer Protection Act (Act 68 of 2008)', 'South Africa');

-- Insert Depositions
INSERT INTO depositions (id, organization_id, case_name, case_number, deponent_name, deponent_role, date_conducted, location, status, duration_minutes, created_by) VALUES
('550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440001', 'Smith vs. ABC Corporation', 'HC-2024-001', 'John Smith', 'Plaintiff', '2024-01-15', 'Cape Town High Court', 'completed', 180, '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440102', '550e8400-e29b-41d4-a716-446655440001', 'Estate Planning Matter - Johnson', 'EST-2024-045', 'Mary Johnson', 'Beneficiary', '2024-01-20', 'Johannesburg Office', 'completed', 120, '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440103', '550e8400-e29b-41d4-a716-446655440001', 'Contract Dispute - Wilson vs. XYZ Ltd', 'COM-2024-023', 'Robert Wilson', 'Defendant', '2024-12-25', 'Durban Commercial Court', 'scheduled', NULL, '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440104', '550e8400-e29b-41d4-a716-446655440001', 'Personal Injury Claim', 'PI-2024-067', 'Sarah Davis', 'Witness', '2024-02-01', 'Pretoria Magistrate Court', 'completed', 90, '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440105', '550e8400-e29b-41d4-a716-446655440001', 'Employment Dispute', 'LAB-2024-012', 'Michael Brown', 'Former Employee', '2024-12-20', 'CCMA Offices', 'scheduled', NULL, '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440106', '550e8400-e29b-41d4-a716-446655440002', 'Property Development Case', 'PROP-2024-089', 'Jennifer Lee', 'Property Developer', '2024-12-30', 'Cape Town Office', 'scheduled', NULL, '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440107', '550e8400-e29b-41d4-a716-446655440002', 'Insurance Claim Dispute', 'INS-2024-156', 'David Thompson', 'Claimant', '2024-02-15', 'Insurance Ombudsman', 'completed', 150, '550e8400-e29b-41d4-a716-446655440013'),
('550e8400-e29b-41d4-a716-446655440108', '550e8400-e29b-41d4-a716-446655440002', 'Merger Due Diligence', 'MA-2024-078', 'Lisa Chen', 'CFO', '2024-02-20', 'Corporate Offices', 'completed', 240, '550e8400-e29b-41d4-a716-446655440013');

-- Insert Document Analyses
INSERT INTO document_analyses (id, document_id, analysis_type, results, key_findings, risk_factors, compliance_issues, recommendations, confidence_score, status, pdf_generated, pdf_generation_date, pdf_file_path) VALUES
('550e8400-e29b-41d4-a716-446655440151', '550e8400-e29b-41d4-a716-446655440021', 'compliance_check',
 '{"overall_compliance": 88, "popia_score": 95, "employment_equity_score": 85, "labour_relations_score": 90}',
 ARRAY['Strong data protection clauses', 'Clear termination procedures', 'Comprehensive benefits package'],
 ARRAY['Minor employment equity reporting gap'],
 ARRAY['Employment equity reporting clause needs update'],
 ARRAY['Update diversity reporting requirements', 'Add remote work policy clauses'],
 0.92, 'completed', true, CURRENT_TIMESTAMP, '/generated-pdfs/analysis_employment_contract.pdf'),

('550e8400-e29b-41d4-a716-446655440152', '550e8400-e29b-41d4-a716-446655440022', 'compliance_check',
 '{"overall_compliance": 65, "consumer_protection_score": 58, "electronic_communications_score": 72}',
 ARRAY['Comprehensive licensing terms', 'Clear usage restrictions'],
 ARRAY['Consumer protection violations', 'Electronic signature requirements not met'],
 ARRAY['Unfair contract terms identified', 'Digital signature clauses missing'],
 ARRAY['Remove unfair cancellation terms', 'Add electronic signature provisions', 'Update consumer rights section'],
 0.85, 'completed', true, CURRENT_TIMESTAMP, '/generated-pdfs/analysis_software_license.pdf'),

('550e8400-e29b-41d4-a716-446655440153', '550e8400-e29b-41d4-a716-446655440023', 'compliance_check',
 '{"overall_compliance": 92, "popia_score": 95, "confidentiality_score": 90}',
 ARRAY['Strong confidentiality provisions', 'Clear data handling requirements', 'Appropriate duration terms'],
 ARRAY['Minor data processing clause ambiguity'],
 ARRAY['Data processing purposes could be more specific'],
 ARRAY['Clarify data processing purposes', 'Add data retention schedule'],
 0.90, 'completed', true, CURRENT_TIMESTAMP, '/generated-pdfs/analysis_nda.pdf'),

('550e8400-e29b-41d4-a716-446655440154', '550e8400-e29b-41d4-a716-446655440024', 'compliance_check',
 '{"overall_compliance": 75, "consumer_protection_score": 70, "service_delivery_score": 80}',
 ARRAY['Clear service level definitions', 'Appropriate penalty structures'],
 ARRAY['Consumer protection compliance gaps', 'Cancellation terms may be unfair'],
 ARRAY['Cancellation notice period too short', 'Refund terms unclear'],
 ARRAY['Extend cancellation notice period', 'Clarify refund procedures', 'Add consumer rights notice'],
 0.82, 'completed', true, CURRENT_TIMESTAMP, '/generated-pdfs/analysis_sla.pdf'),

('550e8400-e29b-41d4-a716-446655440155', '550e8400-e29b-41d4-a716-446655440025', 'compliance_check',
 '{"overall_compliance": 78, "companies_act_score": 75, "competition_act_score": 80, "bbbee_score": 75}',
 ARRAY['Comprehensive partnership structure', 'Clear governance arrangements'],
 ARRAY['Competition Commission approval pending', 'B-BBEE compliance verification needed'],
 ARRAY['Competition clearance required', 'B-BBEE verification certificates needed'],
 ARRAY['Obtain Competition Commission clearance', 'Update B-BBEE compliance documentation', 'Review director liability clauses'],
 0.85, 'completed', true, CURRENT_TIMESTAMP, '/generated-pdfs/analysis_partnership.pdf'),

('550e8400-e29b-41d4-a716-446655440156', '550e8400-e29b-41d4-a716-446655440027', 'policy_review',
 '{"policy_effectiveness": 90, "popia_alignment": 95, "implementation_score": 85}',
 ARRAY['Comprehensive data protection framework', 'Clear consent mechanisms', 'Strong breach response procedures'],
 ARRAY['Implementation monitoring could be enhanced'],
 ARRAY['Regular review schedule needs formalization'],
 ARRAY['Implement quarterly policy reviews', 'Enhance staff training programs', 'Add automated compliance monitoring'],
 0.88, 'completed', true, CURRENT_TIMESTAMP, '/generated-pdfs/analysis_compliance_policy.pdf'),

('550e8400-e29b-41d4-a716-446655440157', '550e8400-e29b-41d4-a716-446655440029', 'compliance_check',
 '{"overall_compliance": 82, "companies_act_score": 85, "competition_act_score": 80}',
 ARRAY['Well-structured merger terms', 'Clear valuation methodology', 'Appropriate due diligence provisions'],
 ARRAY['Competition Commission approval timeline uncertain'],
 ARRAY['Regulatory approval conditions pending'],
 ARRAY['Monitor Competition Commission approval process', 'Prepare for potential condition modifications', 'Update closing conditions'],
 0.87, 'completed', true, CURRENT_TIMESTAMP, '/generated-pdfs/analysis_merger.pdf'),

('550e8400-e29b-41d4-a716-446655440158', '550e8400-e29b-41d4-a716-446655440030', 'version_comparison',
 '{"similarity_score": 0.85, "key_differences": 12, "risk_changes": 3}',
 ARRAY['Version 1.0 to 2.0 comparison completed', 'Significant terms updates identified'],
 ARRAY['New liability limitations added', 'Payment terms modified', 'Termination clauses updated'],
 ARRAY['Review impact of new liability limitations', 'Assess payment term changes'],
 ARRAY['Analyze liability limitation impact', 'Review payment term modifications', 'Update internal procedures for v2.0'],
 0.90, 'completed', true, CURRENT_TIMESTAMP, '/generated-pdfs/analysis_version_comparison.pdf');

-- Insert Case Timelines
INSERT INTO case_timelines (id, organization_id, case_name, case_number, timeline_data, created_by) VALUES
('550e8400-e29b-41d4-a716-446655440131', '550e8400-e29b-41d4-a716-446655440001', 'Smith vs. ABC Corporation', 'HC-2024-001', 
 '[{"date": "2023-06-15", "event": "Initial incident occurred", "type": "incident", "importance": 5}, {"date": "2023-07-01", "event": "Legal notice served", "type": "legal", "importance": 4}, {"date": "2023-08-15", "event": "Summons issued", "type": "court", "importance": 5}, {"date": "2024-01-15", "event": "Deposition conducted", "type": "discovery", "importance": 4}, {"date": "2024-03-01", "event": "Trial date scheduled", "type": "court", "importance": 5}]'::jsonb, 
 '550e8400-e29b-41d4-a716-446655440011'),

('550e8400-e29b-41d4-a716-446655440132', '550e8400-e29b-41d4-a716-446655440001', 'Estate Planning Matter - Johnson', 'EST-2024-045',
 '[{"date": "2023-12-01", "event": "Will executed", "type": "document", "importance": 5}, {"date": "2024-01-05", "event": "Probate application filed", "type": "court", "importance": 4}, {"date": "2024-01-20", "event": "Beneficiary deposition", "type": "discovery", "importance": 3}, {"date": "2024-02-15", "event": "Asset valuation completed", "type": "financial", "importance": 3}]'::jsonb,
 '550e8400-e29b-41d4-a716-446655440011'),

('550e8400-e29b-41d4-a716-446655440133', '550e8400-e29b-41d4-a716-446655440002', 'Merger Due Diligence', 'MA-2024-078',
 '[{"date": "2023-09-01", "event": "Initial merger discussions", "type": "negotiation", "importance": 4}, {"date": "2023-11-15", "event": "Due diligence commenced", "type": "investigation", "importance": 5}, {"date": "2024-01-10", "event": "Financial audit completed", "type": "financial", "importance": 4}, {"date": "2024-02-20", "event": "Management deposition", "type": "discovery", "importance": 4}, {"date": "2024-04-01", "event": "Competition Commission filing", "type": "regulatory", "importance": 5}]'::jsonb,
 '550e8400-e29b-41d4-a716-446655440013');

-- Insert Compliance Reports
INSERT INTO compliance_reports (id, organization_id, title, report_type, period_start, period_end, overall_score, total_documents, compliant_documents, non_compliant_documents, recommendations, report_data, generated_by) VALUES
('550e8400-e29b-41d4-a716-446655440141', '550e8400-e29b-41d4-a716-446655440001', 'Q4 2024 POPIA Compliance Report', 'popia', '2024-10-01', '2024-12-31', 85, 10, 8, 2, 
 ARRAY['Update data processing agreements', 'Enhance consent mechanisms', 'Implement automated compliance monitoring'],
 '{"compliance_score": 85, "issues_found": 3, "recommendations": 7, "data_subjects": 1250, "processing_activities": 15}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440012'),

('550e8400-e29b-41d4-a716-446655440142', '550e8400-e29b-41d4-a716-446655440001', 'Annual Employment Law Compliance 2024', 'employment', '2024-01-01', '2024-12-31', 78, 15, 12, 3,
 ARRAY['Update employment equity reporting', 'Review dispute resolution procedures', 'Enhance training programs'],
 '{"compliance_score": 78, "employment_contracts": 15, "equity_reports": 4, "disputes": 2, "training_sessions": 8}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440012'),

('550e8400-e29b-41d4-a716-446655440143', '550e8400-e29b-41d4-a716-446655440002', 'Corporate Governance Review 2024', 'corporate', '2024-01-01', '2024-12-31', 82, 12, 10, 2,
 ARRAY['Strengthen board oversight', 'Update risk management framework', 'Enhance stakeholder communication'],
 '{"compliance_score": 82, "board_meetings": 12, "risk_assessments": 4, "stakeholder_reports": 6, "governance_policies": 8}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440013'),

('550e8400-e29b-41d4-a716-446655440144', '550e8400-e29b-41d4-a716-446655440001', 'Consumer Protection Compliance Q3 2024', 'consumer_protection', '2024-07-01', '2024-09-30', 72, 8, 6, 2,
 ARRAY['Review cancellation terms', 'Update refund procedures', 'Enhance consumer rights notices'],
 '{"compliance_score": 72, "service_agreements": 8, "complaints": 3, "refunds_processed": 12, "consumer_inquiries": 45}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440012'),

('550e8400-e29b-41d4-a716-446655440145', '550e8400-e29b-41d4-a716-446655440002', 'Competition Law Compliance 2024', 'competition', '2024-01-01', '2024-12-31', 88, 5, 5, 0,
 ARRAY['Monitor market concentration', 'Update competition compliance training', 'Enhance merger notification procedures'],
 '{"compliance_score": 88, "merger_notifications": 2, "market_analysis": 4, "competition_training": 6, "regulatory_interactions": 8}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440013'),

('550e8400-e29b-41d4-a716-446655440146', '550e8400-e29b-41d4-a716-446655440001', 'Electronic Communications Compliance Q4 2024', 'electronic_communications', '2024-10-01', '2024-12-31', 75, 6, 4, 2,
 ARRAY['Implement electronic signature standards', 'Update digital contract procedures', 'Enhance cybersecurity measures'],
 '{"compliance_score": 75, "digital_contracts": 6, "electronic_signatures": 15, "security_incidents": 1, "system_updates": 4}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440012'),

('550e8400-e29b-41d4-a716-446655440147', '550e8400-e29b-41d4-a716-446655440002', 'B-BBEE Compliance Assessment 2024', 'bbbee', '2024-01-01', '2024-12-31', 80, 8, 6, 2,
 ARRAY['Increase supplier diversity', 'Enhance skills development programs', 'Improve enterprise development initiatives'],
 '{"compliance_score": 80, "bbbee_level": 4, "procurement_spend": 75, "skills_development": 12, "enterprise_development": 8}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440013'),

('550e8400-e29b-41d4-a716-446655440148', '550e8400-e29b-41d4-a716-446655440001', 'Overall Legal Compliance Summary 2024', 'comprehensive', '2024-01-01', '2024-12-31', 81, 25, 20, 5,
 ARRAY['Prioritize high-risk compliance areas', 'Implement integrated compliance monitoring', 'Enhance cross-functional compliance training'],
 '{"overall_compliance": 81, "total_regulations": 8, "compliance_areas": 6, "training_hours": 120, "compliance_costs": 450000}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440012');

-- Insert Regulatory Updates
INSERT INTO regulatory_updates (title, description, regulation_source, category, jurisdiction, effective_date, impact_level, url) VALUES
('POPIA Amendment Regulations 2024', 'New regulations under POPIA addressing AI and automated decision-making in data processing', 'POPIA', 'data_protection', 'South Africa', '2024-07-01', 'high', 'https://www.gov.za/popia-amendments-2024'),
('Companies Act Amendment - Director Duties', 'Updated director duties and liability provisions under the Companies Act', 'Companies Act', 'corporate', 'South Africa', '2024-09-01', 'medium', 'https://www.gov.za/companies-act-amendments'),
('Employment Equity Amendment Act 2024', 'Revised employment equity targets and reporting requirements', 'Employment Equity Act', 'employment', 'South Africa', '2024-06-01', 'high', 'https://www.gov.za/employment-equity-amendments'),
('Consumer Protection Regulations Update', 'New consumer protection regulations for digital services and e-commerce', 'Consumer Protection Act', 'consumer_protection', 'South Africa', '2024-08-15', 'medium', 'https://www.gov.za/consumer-protection-digital'),
('Competition Commission Guidelines - Digital Markets', 'New guidelines for competition assessment in digital markets and platforms', 'Competition Act', 'competition', 'South Africa', '2024-10-01', 'high', 'https://www.compcom.co.za/digital-markets-guidelines'),
('Labour Relations Act - Remote Work Regulations', 'New regulations addressing remote work arrangements and digital workplace rights', 'Labour Relations Act', 'employment', 'South Africa', '2024-05-01', 'medium', 'https://www.gov.za/labour-remote-work'),
('Electronic Communications Amendment 2024', 'Updated electronic communications regulations for 5G and IoT technologies', 'Electronic Communications Act', 'electronic_communications', 'South Africa', '2024-11-01', 'medium', 'https://www.icasa.org.za/electronic-communications-2024'),
('B-BBEE Codes Amendment - Digital Economy', 'Revised B-BBEE codes addressing digital economy and technology sector requirements', 'B-BBEE Act', 'empowerment', 'South Africa', '2024-12-01', 'high', 'https://www.gov.za/bbbee-digital-economy');

-- Insert Document Comparisons
INSERT INTO document_comparisons (id, organization_id, primary_document_id, comparison_document_id, comparison_type, similarity_score, differences, similarities, analysis_summary, summary, risk_assessment, created_by) VALUES
('550e8400-e29b-41d4-a716-446655440161', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440022', '550e8400-e29b-41d4-a716-446655440030', 'version_comparison', 0.85,
 '{"liability_clauses": "New limitation of liability added in v2.0", "payment_terms": "Payment schedule changed from monthly to quarterly", "termination": "Notice period extended from 30 to 60 days", "support": "24/7 support added in v2.0"}'::jsonb,
 '{"licensing_model": "Both use perpetual licensing", "intellectual_property": "Same IP protection clauses", "confidentiality": "Identical confidentiality terms", "governing_law": "Both governed by SA law"}'::jsonb,
 'Comparison between TechCorp v1.0 and v2.0 software license agreements shows 85% similarity with key improvements in liability protection and support terms.',
 'Software license upgrade from v1.0 to v2.0 includes enhanced liability protection, improved payment terms, and expanded support coverage while maintaining core licensing structure.',
 '{"risk_level": "medium", "key_risks": ["New liability limitations may affect client protection", "Extended payment terms impact cash flow"], "recommendations": ["Review liability limitation impact", "Assess payment term changes"]}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440011'),

('550e8400-e29b-41d4-a716-446655440162', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440021', '550e8400-e29b-41d4-a716-446655440021', 'template_comparison', 0.95,
 '{"salary_structure": "Performance bonus structure differs", "benefits": "Medical aid options vary", "probation": "Probation period length differs"}'::jsonb,
 '{"basic_terms": "Standard employment terms identical", "termination": "Same termination procedures", "confidentiality": "Identical confidentiality clauses", "compliance": "Same regulatory compliance requirements"}'::jsonb,
 'Employment contract comparison shows high similarity with minor variations in compensation and benefits structure.',
 'Employment contracts are highly standardized with 95% similarity, differing mainly in individual compensation packages and specific benefit selections.',
 '{"risk_level": "low", "key_risks": ["Minor inconsistencies in benefit structures"], "recommendations": ["Standardize benefit option presentations"]}'::jsonb,
 '550e8400-e29b-41d4-a716-446655440012');

-- Insert File Storage Config
INSERT INTO file_storage_config (storage_type, base_path, max_file_size_mb, allowed_mime_types, retention_days) VALUES
('local', '/public/generated-pdfs/', 50, ARRAY['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'], 365),
('local', '/public/documents/', 100, ARRAY['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'text/plain'], 1095);

-- Insert Document Generation Log
INSERT INTO document_generation_log (document_id, template_used, generation_status, generation_time_ms, file_size_bytes, generated_by) VALUES
('550e8400-e29b-41d4-a716-446655440021', 'employment_contract', 'completed', 1250, 156789, '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440022', 'software_license', 'completed', 1450, 198765, '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440023', 'nda', 'completed', 980, 134567, '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440024', 'service_agreement', 'completed', 1320, 176543, '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440025', 'partnership_agreement', 'completed', 1680, 223456, '550e8400-e29b-41d4-a716-446655440013');

-- Insert Audit Logs
INSERT INTO audit_logs (organization_id, user_id, action, resource_type, resource_id, details) VALUES
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440011', 'document_created', 'document', '550e8400-e29b-41d4-a716-446655440021', '{"document_type": "employment_contract", "template_used": "employment_contract"}'::jsonb),
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440012', 'compliance_alert_created', 'compliance_alert', '550e8400-e29b-41d4-a716-446655440081', '{"alert_type": "compliance", "priority": "high"}'::jsonb),
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440011', 'document_analysis_completed', 'document_analysis', '550e8400-e29b-41d4-a716-446655440151', '{"analysis_type": "compliance_check", "confidence_score": 0.92}'::jsonb),
('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440013', 'compliance_report_generated', 'compliance_report', '550e8400-e29b-41d4-a716-446655440143', '{"report_type": "corporate", "period": "2024"}'::jsonb),
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440012', 'task_completed', 'task', '550e8400-e29b-41d4-a716-446655440043', '{"task_type": "template_update", "completion_time": "2024-12-15"}'::jsonb),
('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440013', 'deposition_scheduled', 'deposition', '550e8400-e29b-41d4-a716-446655440106', '{"case_name": "Property Development Case", "date": "2024-12-30"}'::jsonb),
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440011', 'document_comparison_completed', 'document_comparison', '550e8400-e29b-41d4-a716-446655440161', '{"comparison_type": "version_comparison", "similarity_score": 0.85}'::jsonb),
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440012', 'compliance_alert_resolved', 'compliance_alert', '550e8400-e29b-41d4-a716-446655440083', '{"resolution_type": "document_updated", "resolved_date": "2024-12-16"}'::jsonb);

-- =====================================================
-- 5. CREATE COMPREHENSIVE VIEWS
-- =====================================================

-- Active Compliance Alerts View
CREATE VIEW active_compliance_alerts AS
SELECT 
    ca.id,
    ca.title,
    ca.description,
    ca.priority,
    ca.type,
    ca.status,
    ca.due_date,
    ca.regulation_source,
    ca.jurisdiction,
    cr.name as rule_name,
    cr.category as rule_category,
    d.title as document_title,
    d.type as document_type,
    o.name as organization_name,
    CASE 
        WHEN ca.due_date < CURRENT_DATE THEN 'overdue'
        WHEN ca.due_date <= CURRENT_DATE + INTERVAL '7 days' THEN 'due_soon'
        ELSE 'normal'
    END as urgency_status,
    ca.created_at
FROM compliance_alerts ca
LEFT JOIN compliance_rules cr ON ca.rule_id = cr.id
LEFT JOIN documents d ON ca.document_id = d.id
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
CREATE VIEW recent_depositions AS
SELECT 
    d.id,
    d.case_name,
    d.case_number,
    d.deponent_name,
    d.deponent_role,
    d.date_conducted,
    d.location,
    d.status,
    d.duration_minutes,
    da.key_topics,
    da.confidence_score,
    o.name as organization_name,
    u.name as created_by_name,
    d.created_at
FROM depositions d
LEFT JOIN deposition_analyses da ON d.id = da.deposition_id
LEFT JOIN organizations o ON d.organization_id = o.id
LEFT JOIN users u ON d.created_by = u.id
ORDER BY d.date_conducted DESC, d.created_at DESC;

-- Dashboard Summary View
CREATE VIEW dashboard_summary AS
SELECT 
    o.id as organization_id,
    o.name as organization_name,
    
    -- Document Statistics
    COUNT(DISTINCT d.id) as total_documents,
    COUNT(DISTINCT CASE WHEN d.status = 'active' THEN d.id END) as active_documents,
    COUNT(DISTINCT CASE WHEN d.created_at >= CURRENT_DATE - INTERVAL '30 days' THEN d.id END) as recent_documents,
    
    -- Task Statistics
    COUNT(DISTINCT t.id) as total_tasks,
    COUNT(DISTINCT CASE WHEN t.status = 'pending' THEN t.id END) as pending_tasks,
    COUNT(DISTINCT CASE WHEN t.status = 'completed' THEN t.id END) as completed_tasks,
    COUNT(DISTINCT CASE WHEN t.status = 'failed' THEN t.id END) as failed_tasks,
    ROUND(
        CASE 
            WHEN COUNT(DISTINCT t.id) > 0 
            THEN (COUNT(DISTINCT CASE WHEN t.status = 'completed' THEN t.id END)::decimal / COUNT(DISTINCT t.id) * 100)
            ELSE 0 
        END, 0
    ) as task_completion_rate,
    
    -- Compliance Statistics
    COUNT(DISTINCT ca.id) as total_alerts,
    COUNT(DISTINCT CASE WHEN ca.status = 'active' THEN ca.id END) as active_alerts,
    COUNT(DISTINCT CASE WHEN ca.status = 'active' AND ca.priority = 'Critical' THEN ca.id END) as critical_alerts,
    COUNT(DISTINCT CASE WHEN ca.status = 'active' AND ca.due_date < CURRENT_DATE THEN ca.id END) as overdue_alerts,
    
    -- Compliance Rate Calculation
    ROUND(
        CASE 
            WHEN COUNT(DISTINCT cm.id) > 0 
            THEN (COUNT(DISTINCT CASE WHEN cm.status = 'compliant' THEN cm.id END)::decimal / COUNT(DISTINCT cm.id) * 100)
            ELSE 0 
        END, 0
    ) as compliance_rate
    
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
    d.template_type,
    d.generation_status,
    da.analysis_type,
    da.confidence_score,
    da.status as analysis_status,
    ARRAY_LENGTH(da.key_findings, 1) as findings_count,
    ARRAY_LENGTH(da.risk_factors, 1) as risk_factors_count,
    ARRAY_LENGTH(da.compliance_issues, 1) as compliance_issues_count,
    o.name as organization_name,
    d.created_at,
    da.analyzed_at
FROM documents d
LEFT JOIN document_analyses da ON d.id = da.document_id
LEFT JOIN organizations o ON d.organization_id = o.id
WHERE d.status = 'active'
ORDER BY d.created_at DESC;

-- Compliance Overview View
CREATE VIEW compliance_overview AS
SELECT 
    cr.category,
    COUNT(DISTINCT cr.id) as total_rules,
    COUNT(DISTINCT cm.id) as monitored_items,
    COUNT(DISTINCT CASE WHEN cm.status = 'compliant' THEN cm.id END) as compliant_items,
    COUNT(DISTINCT CASE WHEN cm.status = 'non_compliant' THEN cm.id END) as non_compliant_items,
    COUNT(DISTINCT CASE WHEN cm.status = 'under_review' THEN cm.id END) as under_review_items,
    COUNT(DISTINCT CASE WHEN ca.status = 'active' THEN ca.id END) as active_alerts,
    ROUND(
        CASE 
            WHEN COUNT(DISTINCT cm.id) > 0 
            THEN (COUNT(DISTINCT CASE WHEN cm.status = 'compliant' THEN cm.id END)::decimal / COUNT(DISTINCT cm.id) * 100)
            ELSE 0 
        END, 1
    ) as compliance_rate,
    CASE 
        WHEN ROUND(
            CASE 
                WHEN COUNT(DISTINCT cm.id) > 0 
                THEN (COUNT(DISTINCT CASE WHEN cm.status = 'compliant' THEN cm.id END)::decimal / COUNT(DISTINCT cm.id) * 100)
                ELSE 0 
            END, 1
        ) >= 90 THEN 'excellent'
        WHEN ROUND(
            CASE 
                WHEN COUNT(DISTINCT cm.id) > 0 
                THEN (COUNT(DISTINCT CASE WHEN cm.status = 'compliant' THEN cm.id END)::decimal / COUNT(DISTINCT cm.id) * 100)
                ELSE 0 
            END, 1
        ) >= 75 THEN 'good'
        WHEN ROUND(
            CASE 
                WHEN COUNT(DISTINCT cm.id) > 0 
                THEN (COUNT(DISTINCT CASE WHEN cm.status = 'compliant' THEN cm.id END)::decimal / COUNT(DISTINCT cm.id) * 100)
                ELSE 0 
            END, 1
        ) >= 60 THEN 'fair'
        ELSE 'poor'
    END as status
FROM compliance_rules cr
LEFT JOIN compliance_monitoring cm ON cr.id = cm.rule_id
LEFT JOIN compliance_alerts ca ON cr.id = ca.rule_id
WHERE cr.is_active = true
GROUP BY cr.category
ORDER BY compliance_rate DESC;

-- Document Generation Statistics View
CREATE VIEW document_generation_stats AS
SELECT 
    dt.template_name,
    dt.display_name,
    dt.category,
    COUNT(DISTINCT dgl.id) as total_generations,
    COUNT(DISTINCT CASE WHEN dgl.generation_status = 'completed' THEN dgl.id END) as successful_generations,
    COUNT(DISTINCT CASE WHEN dgl.generation_status = 'failed' THEN dgl.id END) as failed_generations,
    ROUND(AVG(dgl.generation_time_ms), 0) as avg_generation_time_ms,
    ROUND(AVG(dgl.file_size_bytes), 0) as avg_file_size_bytes,
    MAX(dgl.created_at) as last_generation_date,
    ROUND(
        CASE 
            WHEN COUNT(DISTINCT dgl.id) > 0 
            THEN (COUNT(DISTINCT CASE WHEN dgl.generation_status = 'completed' THEN dgl.id END)::decimal / COUNT(DISTINCT dgl.id) * 100)
            ELSE 0 
        END, 1
    ) as success_rate
FROM document_templates dt
LEFT JOIN document_generation_log dgl ON dt.template_name = dgl.template_used
WHERE dt.is_active = true
GROUP BY dt.template_name, dt.display_name, dt.category
ORDER BY total_generations DESC;

-- =====================================================
-- 6. CREATE UTILITY FUNCTIONS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Function to cleanup old generated files
CREATE OR REPLACE FUNCTION cleanup_old_generated_files()
RETURNS INTEGER AS $$
DECLARE
    cleanup_count INTEGER;
BEGIN
    -- Mark old generated documents for cleanup (older than retention period)
    UPDATE documents 
    SET status = 'archived'
    WHERE generation_status = 'completed' 
    AND generated_at < CURRENT_DATE - INTERVAL '365 days'
    AND status = 'active';
    
    GET DIAGNOSTICS cleanup_count = ROW_COUNT;
    
    -- Log cleanup activity
    INSERT INTO audit_logs (action, resource_type, details)
    VALUES ('file_cleanup', 'system', json_build_object('files_archived', cleanup_count));
    
    RETURN cleanup_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 7. CREATE TRIGGERS
-- =====================================================

-- Add updated_at triggers to relevant tables
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
CREATE TRIGGER update_document_templates_updated_at BEFORE UPDATE ON document_templates FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 8. VERIFICATION AND SUMMARY
-- =====================================================

-- Verify table creation
SELECT 
    'Tables Created' as verification_type,
    COUNT(*) as count
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE';

-- Verify view creation
SELECT 
    'Views Created' as verification_type,
    COUNT(*) as count
FROM information_schema.views 
WHERE table_schema = 'public';

-- Verify data insertion
SELECT 'organizations' as table_name, COUNT(*) as record_count FROM organizations
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
SELECT 'document_analyses', COUNT(*) FROM document_analyses
UNION ALL
SELECT 'case_timelines', COUNT(*) FROM case_timelines
UNION ALL
SELECT 'compliance_reports', COUNT(*) FROM compliance_reports
UNION ALL
SELECT 'regulatory_updates', COUNT(*) FROM regulatory_updates
UNION ALL
SELECT 'document_comparisons', COUNT(*) FROM document_comparisons
UNION ALL
SELECT 'document_templates', COUNT(*) FROM document_templates
UNION ALL
SELECT 'document_generation_log', COUNT(*) FROM document_generation_log
UNION ALL
SELECT 'file_storage_config', COUNT(*) FROM file_storage_config
UNION ALL
SELECT 'audit_logs', COUNT(*) FROM audit_logs
ORDER BY table_name;

-- Final success message
SELECT 
    '🎉 LEGAL AI DATABASE SETUP COMPLETE! 🎉' as status,
    'All tables, views, indexes, and data have been successfully created.' as message,
    'Your Legal AI application is now ready with comprehensive PDF generation capabilities.' as next_steps;
