-- =====================================================
-- CLEAR AND POPULATE DATABASE
-- This script clears existing data and inserts fresh data
-- =====================================================

-- Clear existing data in correct order (respecting foreign keys)
DELETE FROM compliance_monitoring;
DELETE FROM compliance_alerts;
DELETE FROM deposition_analyses;
DELETE FROM depositions;
DELETE FROM document_analyses;
DELETE FROM document_comparisons;
DELETE FROM document_generation_log;
DELETE FROM timeline_events;
DELETE FROM case_timelines;
DELETE FROM tasks;
DELETE FROM documents;
DELETE FROM document_templates;
DELETE FROM compliance_reports;
DELETE FROM regulatory_updates;
DELETE FROM compliance_rules;
DELETE FROM file_storage_config;
DELETE FROM audit_logs;
DELETE FROM users;
DELETE FROM organizations;

-- Reset sequences if they exist
-- (This ensures clean ID generation)

-- Insert Organizations (3 organizations)
INSERT INTO organizations (id, name, type, industry, country, address, contact_email, created_at, updated_at) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Johannesburg Legal Firm', 'Law Firm', 'Legal Services', 'South Africa', '123 Commissioner Street, Johannesburg, 2001', 'info@jhblegal.co.za', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440002', 'Cape Town Corporate Law', 'Law Firm', 'Corporate Law', 'South Africa', '456 Long Street, Cape Town, 8001', 'contact@ctclaw.co.za', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440003', 'Pretoria Legal Associates', 'Law Firm', 'Commercial Law', 'South Africa', '789 Church Street, Pretoria, 0002', 'legal@ptaassoc.co.za', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert Users (5 users)
INSERT INTO users (id, organization_id, email, name, role, department, created_at, updated_at) VALUES
('550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440001', 'sarah.johnson@jhblegal.co.za', 'Sarah Johnson', 'Senior Partner', 'Corporate Law', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440001', 'michael.smith@jhblegal.co.za', 'Michael Smith', 'Associate', 'Compliance', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440002', 'linda.williams@ctclaw.co.za', 'Linda Williams', 'Compliance Officer', 'Risk Management', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440003', 'david.brown@ptaassoc.co.za', 'David Brown', 'Senior Associate', 'Commercial Law', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440001', 'emma.davis@jhblegal.co.za', 'Emma Davis', 'Paralegal', 'Litigation', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert Documents (10 documents)
INSERT INTO documents (id, organization_id, title, type, category, content, template_type, file_path, file_size, status, risk_level, uploaded_by, generated_at, created_at, updated_at) VALUES
('550e8400-e29b-41d4-a716-446655440021', '550e8400-e29b-41d4-a716-446655440001', 'Employment Contract - Senior Developer', 'contract', 'employment', 'Employment contract for senior software developer position with comprehensive terms and conditions including salary, benefits, working hours, and termination clauses.', 'employment_contract', '/documents/employment_contract_001.pdf', 156789, 'active', 'low', '550e8400-e29b-41d4-a716-446655440011', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440022', '550e8400-e29b-41d4-a716-446655440001', 'Software License Agreement - TechCorp v2.0', 'contract', 'licensing', 'Comprehensive software licensing agreement with TechCorp for enterprise software suite including usage rights, restrictions, and support terms.', 'software_license', '/documents/software_license_002.pdf', 198765, 'active', 'medium', '550e8400-e29b-41d4-a716-446655440011', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440023', '550e8400-e29b-41d4-a716-446655440001', 'Non-Disclosure Agreement - Project Alpha', 'contract', 'confidentiality', 'Confidentiality agreement for sensitive project information and trade secrets with strict data protection requirements.', 'nda', '/documents/nda_003.pdf', 134567, 'active', 'high', '550e8400-e29b-41d4-a716-446655440012', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440024', '550e8400-e29b-41d4-a716-446655440001', 'Service Level Agreement - Cloud Services', 'contract', 'service', 'SLA defining service delivery standards for cloud infrastructure services including uptime guarantees and support response times.', 'service_agreement', '/documents/sla_004.pdf', 176543, 'active', 'medium', '550e8400-e29b-41d4-a716-446655440011', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440025', '550e8400-e29b-41d4-a716-446655440002', 'Partnership Agreement - Strategic Alliance', 'contract', 'partnership', 'Strategic business partnership agreement for joint venture operations including profit sharing and governance structure.', 'partnership_agreement', '/documents/partnership_005.pdf', 223456, 'active', 'high', '550e8400-e29b-41d4-a716-446655440013', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440026', '550e8400-e29b-41d4-a716-446655440002', 'Lease Agreement - Office Space Cape Town', 'contract', 'real_estate', 'Commercial lease agreement for prime office space in Cape Town CBD including rental terms and maintenance responsibilities.', 'lease_agreement', '/documents/lease_006.pdf', 145678, 'active', 'low', '550e8400-e29b-41d4-a716-446655440013', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440027', '550e8400-e29b-41d4-a716-446655440001', 'Compliance Policy - Data Protection', 'policy', 'compliance', 'Comprehensive data protection policy ensuring POPIA compliance with detailed procedures for data handling and privacy protection.', 'compliance_policy', '/documents/policy_007.pdf', 267890, 'active', 'high', '550e8400-e29b-41d4-a716-446655440012', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440028', '550e8400-e29b-41d4-a716-446655440001', 'Risk Assessment Report - Q4 2024', 'report', 'risk_management', 'Quarterly risk assessment covering operational and compliance risks with mitigation strategies and action plans.', 'risk_report', '/documents/risk_008.pdf', 345678, 'active', 'medium', '550e8400-e29b-41d4-a716-446655440012', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440029', '550e8400-e29b-41d4-a716-446655440002', 'Merger Agreement - TechStart Acquisition', 'contract', 'merger', 'Corporate merger agreement for acquisition of technology startup including valuation, terms, and integration plan.', 'merger_agreement', '/documents/merger_009.pdf', 456789, 'active', 'high', '550e8400-e29b-41d4-a716-446655440013', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440030', '550e8400-e29b-41d4-a716-446655440001', 'Software License Agreement - TechCorp v1.0', 'contract', 'licensing', 'Legacy software license agreement for previous version with maintenance and upgrade provisions.', 'software_license', '/documents/software_license_010.pdf', 187654, 'active', 'medium', '550e8400-e29b-41d4-a716-446655440011', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert Tasks (8 tasks)
INSERT INTO tasks (id, organization_id, title, description, type, status, priority, assigned_to, created_by, due_date, created_at, updated_at) VALUES
('550e8400-e29b-41d4-a716-446655440051', '550e8400-e29b-41d4-a716-446655440001', 'Review Employment Contract Terms', 'Review and update standard employment contract terms for compliance with new labor laws and recent regulatory changes', 'document_review', 'in_progress', 'high', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2024-12-30', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440052', '550e8400-e29b-41d4-a716-446655440001', 'Compliance Audit - Q4 2024', 'Conduct quarterly compliance audit for all active contracts and identify potential risk areas', 'compliance_check', 'pending', 'high', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2024-12-31', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440053', '550e8400-e29b-41d4-a716-446655440001', 'Update NDA Templates', 'Update non-disclosure agreement templates with latest legal requirements and POPIA compliance measures', 'template_update', 'completed', 'medium', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440011', '2024-12-15', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440054', '550e8400-e29b-41d4-a716-446655440002', 'Risk Assessment - New Partnership', 'Assess legal risks for the proposed strategic alliance partnership and prepare risk mitigation strategies', 'risk_assessment', 'in_progress', 'high', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', '2024-12-28', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440055', '550e8400-e29b-41d4-a716-446655440001', 'Document Classification Review', 'Review and reclassify documents based on new risk assessment criteria and compliance requirements', 'classification', 'pending', 'medium', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2025-01-15', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440056', '550e8400-e29b-41d4-a716-446655440002', 'Lease Renewal Negotiation', 'Negotiate terms for office lease renewal in Cape Town including rent adjustments and new clauses', 'negotiation', 'pending', 'medium', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', '2025-01-31', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440057', '550e8400-e29b-41d4-a716-446655440001', 'Regulatory Update Review', 'Review and implement changes from latest POPIA amendments and update all affected policies', 'regulatory_review', 'in_progress', 'high', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2024-12-20', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440058', '550e8400-e29b-41d4-a716-446655440002', 'Contract Comparison Analysis', 'Compare merger agreement terms with industry standards and identify areas for improvement', 'analysis', 'pending', 'medium', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', '2025-01-10', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert Compliance Rules (6 rules)
INSERT INTO compliance_rules (id, organization_id, name, title, description, category, regulation_source, risk_level, created_at, updated_at) VALUES
('550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440001', 'POPIA Data Protection Compliance', 'POPIA Data Protection Compliance', 'Ensure all contracts comply with Protection of Personal Information Act requirements including consent mechanisms and data processing limitations', 'data_protection', 'POPIA (Act 4 of 2013)', 'high', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440072', '550e8400-e29b-41d4-a716-446655440001', 'Employment Equity Act Compliance', 'Employment Equity Act Compliance', 'Verify employment contracts meet Employment Equity Act standards including diversity reporting and fair employment practices', 'employment', 'Employment Equity Act (Act 55 of 1998)', 'high', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440073', '550e8400-e29b-41d4-a716-446655440001', 'Consumer Protection Act Compliance', 'Consumer Protection Act Compliance', 'Ensure service agreements comply with Consumer Protection Act including fair trading and consumer rights protection', 'consumer_protection', 'Consumer Protection Act (Act 68 of 2008)', 'medium', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440074', '550e8400-e29b-41d4-a716-446655440002', 'Companies Act Compliance', 'Companies Act Compliance', 'Verify corporate documents comply with Companies Act requirements including director duties and corporate governance', 'corporate', 'Companies Act (Act 71 of 2008)', 'high', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440075', '550e8400-e29b-41d4-a716-446655440001', 'Labour Relations Act Compliance', 'Labour Relations Act Compliance', 'Ensure employment terms comply with Labour Relations Act including dispute resolution and collective bargaining rights', 'employment', 'Labour Relations Act (Act 66 of 1995)', 'medium', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440076', '550e8400-e29b-41d4-a716-446655440002', 'Competition Act Compliance', 'Competition Act Compliance', 'Review merger agreements for Competition Act compliance including market concentration and anti-competitive practices', 'competition', 'Competition Act (Act 89 of 1998)', 'high', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert Compliance Monitoring (12 monitoring records)
INSERT INTO compliance_monitoring (id, organization_id, rule_id, document_id, status, compliance_score, issues_found, next_check_due, created_at, updated_at) VALUES
('550e8400-e29b-41d4-a716-446655440091', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440021', 'compliant', 95, 0, '2025-03-01', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440092', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440072', '550e8400-e29b-41d4-a716-446655440021', 'compliant', 88, 1, '2025-02-15', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440093', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440073', '550e8400-e29b-41d4-a716-446655440022', 'non_compliant', 65, 3, '2024-12-31', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440094', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440023', 'compliant', 92, 1, '2025-02-28', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440095', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440074', '550e8400-e29b-41d4-a716-446655440025', 'under_review', 78, 2, '2025-01-20', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440096', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440076', '550e8400-e29b-41d4-a716-446655440029', 'compliant', 85, 1, '2025-04-01', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440097', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440073', '550e8400-e29b-41d4-a716-446655440022', 'non_compliant', 58, 4, '2024-12-25', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440098', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440075', '550e8400-e29b-41d4-a716-446655440021', 'compliant', 90, 1, '2025-03-15', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440099', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440074', '550e8400-e29b-41d4-a716-446655440025', 'compliant', 82, 2, '2025-02-10', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440027', 'compliant', 96, 0, '2025-03-05', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440072', '550e8400-e29b-41d4-a716-446655440028', 'compliant', 84, 2, '2025-02-12', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440102', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440076', '550e8400-e29b-41d4-a716-446655440029', 'under_review', 75, 3, '2025-01-25', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert Compliance Alerts (8 alerts)
INSERT INTO compliance_alerts (id, organization_id, rule_id, document_id, title, description, priority, type, status, due_date, regulation_source, jurisdiction, created_at, updated_at) VALUES
('550e8400-e29b-41d4-a716-446655440121', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440073', '550e8400-e29b-41d4-a716-446655440022', 'Consumer Protection Act Violations Found', 'Software License Agreement contains clauses that may violate Consumer Protection Act requirements. Review and update required for fair trading compliance.', 'High', 'compliance', 'active', '2024-12-25', 'Consumer Protection Act (Act 68 of 2008)', 'South Africa', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440122', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440023', 'POPIA Data Handling Update', 'NDA requires update to align with latest POPIA data handling requirements. Review data processing clauses and consent mechanisms.', 'Medium', 'compliance', 'active', '2025-01-10', 'POPIA (Act 4 of 2013)', 'South Africa', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440123', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440074', '550e8400-e29b-41d4-a716-446655440025', 'Companies Act Review Required', 'Partnership Agreement requires review for Companies Act compliance. Director liability clauses need attention and governance structure review.', 'Medium', 'compliance', 'active', '2025-01-15', 'Companies Act (Act 71 of 2008)', 'South Africa', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440124', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440072', '550e8400-e29b-41d4-a716-446655440021', 'Employment Equity Minor Issue', 'Employment Contract has minor Employment Equity Act compliance issue. Update diversity reporting clause and fair employment practices.', 'Low', 'compliance', 'resolved', '2025-01-31', 'Employment Equity Act (Act 55 of 1998)', 'South Africa', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440125', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440076', '550e8400-e29b-41d4-a716-446655440029', 'Competition Act Clearance Pending', 'Merger Agreement pending Competition Commission clearance. Monitor approval status and update terms if required for market concentration compliance.', 'Critical', 'regulatory', 'active', '2025-02-28', 'Competition Act (Act 89 of 1998)', 'South Africa', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440126', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440075', '550e8400-e29b-41d4-a716-446655440021', 'Labour Relations Act Update', 'Employment Contract needs minor update for Labour Relations Act compliance. Review dispute resolution clauses and collective bargaining rights.', 'Low', 'compliance', 'resolved', '2025-02-15', 'Labour Relations Act (Act 66 of 1995)', 'South Africa', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440127', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440027', 'POPIA Policy Update Required', 'Data Protection Policy needs update to reflect latest POPIA amendments. Review consent mechanisms and data processing procedures.', 'High', 'policy', 'active', '2024-12-31', 'POPIA (Act 4 of 2013)', 'South Africa', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440128', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440073', '550e8400-e29b-41d4-a716-446655440024', 'Consumer Protection Review', 'Service Level Agreement requires Consumer Protection Act compliance review. Update cancellation and refund terms for consumer rights protection.', 'Medium', 'compliance', 'active', '2025-01-05', 'Consumer Protection Act (Act 68 of 2008)', 'South Africa', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert Depositions (6 depositions)
INSERT INTO depositions (id, organization_id, case_name, case_number, deponent_name, deponent_role, date_conducted, location, status, duration_minutes, created_by, created_at, updated_at) VALUES
('550e8400-e29b-41d4-a716-446655440141', '550e8400-e29b-41d4-a716-446655440001', 'Smith vs. ABC Corporation', 'HC-2024-001', 'John Smith', 'Plaintiff', '2024-01-15', 'Cape Town High Court', 'completed', 180, '550e8400-e29b-41d4-a716-446655440011', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440142', '550e8400-e29b-41d4-a716-446655440001', 'Estate Planning Matter - Johnson', 'EST-2024-045', 'Mary Johnson', 'Beneficiary', '2024-01-20', 'Johannesburg Office', 'completed', 120, '550e8400-e29b-41d4-a716-446655440011', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440143', '550e8400-e29b-41d4-a716-446655440001', 'Contract Dispute - Wilson vs. XYZ Ltd', 'COM-2024-023', 'Robert Wilson', 'Defendant', '2024-12-25', 'Durban Commercial Court', 'scheduled', NULL, '550e8400-e29b-41d4-a716-446655440011', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440144', '550e8400-e29b-41d4-a716-446655440001', 'Personal Injury Claim', 'PI-2024-067', 'Sarah Davis', 'Witness', '2024-02-01', 'Pretoria Magistrate Court', 'completed', 90, '550e8400-e29b-41d4-a716-446655440015', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440145', '550e8400-e29b-41d4-a716-446655440001', 'Employment Dispute', 'LAB-2024-012', 'Michael Brown', 'Former Employee', '2024-12-20', 'CCMA Offices', 'scheduled', NULL, '550e8400-e29b-41d4-a716-446655440012', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('550e8400-e29b-41d4-a716-446655440146', '550e8400-e29b-41d4-a716-446655440002', 'Property Development Case', 'PROP-2024-089', 'Jennifer Lee', 'Property Developer', '2024-12-30', 'Cape Town Office', 'scheduled', NULL, '550e8400-e29b-41d4-a716-446655440013', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert Regulatory Updates (5 updates)
INSERT INTO regulatory_updates (title, description, regulation_source, category, jurisdiction, effective_date, impact_level, url, created_at, updated_at) VALUES
('POPIA Amendment Regulations 2024', 'New regulations under POPIA addressing AI and automated decision-making in data processing with enhanced consent requirements and data subject rights', 'POPIA', 'data_protection', 'South Africa', '2024-07-01', 'high', 'https://www.gov.za/popia-amendments-2024', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Companies Act Amendment - Director Duties', 'Updated director duties and liability provisions under the Companies Act including enhanced corporate governance requirements and fiduciary responsibilities', 'Companies Act', 'corporate', 'South Africa', '2024-09-01', 'medium', 'https://www.gov.za/companies-act-amendments', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Employment Equity Amendment Act 2024', 'Revised employment equity targets and reporting requirements with new sector-specific targets and enhanced monitoring mechanisms', 'Employment Equity Act', 'employment', 'South Africa', '2024-06-01', 'high', 'https://www.gov.za/employment-equity-amendments', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Consumer Protection Regulations Update', 'New consumer protection regulations for digital services and e-commerce including online transaction protection and digital rights', 'Consumer Protection Act', 'consumer_protection', 'South Africa', '2024-08-15', 'medium', 'https://www.gov.za/consumer-protection-digital', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('Competition Commission Guidelines - Digital Markets', 'New guidelines for competition assessment in digital markets and platforms including market dominance thresholds and merger review criteria', 'Competition Act', 'competition', 'South Africa', '2024-10-01', 'high', 'https://www.compcom.co.za/digital-markets-guidelines', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert Document Templates (4 templates)
INSERT INTO document_templates (template_name, template_type, display_name, description, category, default_content, required_fields, optional_fields, compliance_requirements, applicable_laws, risk_level, created_at, updated_at) VALUES
('employment_contract', 'contract', 'Employment Contract', 'Standard employment contract template compliant with South African labor laws including comprehensive terms and conditions', 'employment', 
 'Employment Contract between [EMPLOYER_NAME] and [EMPLOYEE_NAME]. This contract is governed by South African labor legislation and includes provisions for salary, benefits, working conditions, and termination procedures.',
 '{"employer_name": "string", "employee_name": "string", "position": "string", "salary": "number", "start_date": "date"}'::jsonb,
 '{"probation_period": "string", "benefits": "array", "working_hours": "string", "leave_entitlement": "string"}'::jsonb,
 ARRAY['Labour Relations Act compliance', 'Employment Equity Act compliance', 'Basic Conditions of Employment Act compliance'],
 ARRAY['Labour Relations Act (Act 66 of 1995)', 'Employment Equity Act (Act 55 of 1998)', 'Basic Conditions of Employment Act (Act 75 of 1997)'],
 'medium', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('software_license', 'contract', 'Software License Agreement', 'Software licensing agreement template with comprehensive IP protection and usage terms', 'licensing',
 'Software License Agreement for [SOFTWARE_NAME]. This agreement governs software use in accordance with South African intellectual property law and includes usage rights, restrictions, and support terms.',
 '{"software_name": "string", "licensor": "string", "licensee": "string", "license_type": "string", "license_fee": "number"}'::jsonb,
 '{"usage_restrictions": "array", "support_terms": "string", "update_policy": "string", "termination_conditions": "string"}'::jsonb,
 ARRAY['Copyright Act compliance', 'Consumer Protection Act compliance', 'Electronic Communications and Transactions Act compliance'],
 ARRAY['Copyright Act (Act 98 of 1978)', 'Consumer Protection Act (Act 68 of 2008)', 'Electronic Communications and Transactions Act (Act 25 of 2002)'],
 'medium', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('nda', 'contract', 'Non-Disclosure Agreement', 'Confidentiality agreement template with comprehensive POPIA compliance and data protection measures', 'confidentiality',
 'Non-Disclosure Agreement between [DISCLOSING_PARTY] and [RECEIVING_PARTY]. This agreement ensures confidentiality and is POPIA compliant with enhanced data protection provisions.',
 '{"disclosing_party": "string", "receiving_party": "string", "purpose": "string", "confidentiality_period": "string"}'::jsonb,
 '{"information_types": "array", "permitted_uses": "array", "return_obligations": "string", "data_processing_terms": "string"}'::jsonb,
 ARRAY['POPIA compliance', 'Confidentiality law compliance', 'Trade secrets protection'],
 ARRAY['Protection of Personal Information Act (Act 4 of 2013)', 'Common law confidentiality principles'],
 'high', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('partnership_agreement', 'contract', 'Partnership Agreement', 'Comprehensive business partnership agreement template with governance and profit-sharing provisions', 'partnership',
 'Partnership Agreement between [PARTNER_1] and [PARTNER_2]. This agreement establishes a business partnership in compliance with South African Companies Act and Partnership Act requirements.',
 '{"partner_1": "string", "partner_2": "string", "business_name": "string", "partnership_type": "string", "capital_contributions": "object"}'::jsonb,
 '{"profit_sharing": "object", "management_structure": "string", "decision_making": "string", "dispute_resolution": "string"}'::jsonb,
 ARRAY['Companies Act compliance', 'Partnership Act compliance', 'Tax compliance requirements'],
 ARRAY['Companies Act (Act 71 of 2008)', 'Partnership Act (Act 34 of 1961)', 'Income Tax Act (Act 58 of 1962)'],
 'high', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert File Storage Config
INSERT INTO file_storage_config (storage_type, base_path, max_file_size_mb, allowed_mime_types, retention_days, created_at, updated_at) VALUES
('local', '/public/documents/', 100, ARRAY['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'text/plain'], 1095, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Success message
SELECT 'Database successfully populated with essential data!' as result;
