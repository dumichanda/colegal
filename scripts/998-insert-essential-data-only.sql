-- =====================================================
-- INSERT ESSENTIAL DATA ONLY
-- This script ONLY inserts data into existing tables
-- Run this after tables are already created
-- =====================================================

-- Insert Organizations (3 organizations)
INSERT INTO organizations (id, name, type, industry, country, address, contact_email) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Johannesburg Legal Firm', 'Law Firm', 'Legal Services', 'South Africa', '123 Commissioner Street, Johannesburg, 2001', 'info@jhblegal.co.za'),
('550e8400-e29b-41d4-a716-446655440002', 'Cape Town Corporate Law', 'Law Firm', 'Corporate Law', 'South Africa', '456 Long Street, Cape Town, 8001', 'contact@ctclaw.co.za'),
('550e8400-e29b-41d4-a716-446655440003', 'Pretoria Legal Associates', 'Law Firm', 'Commercial Law', 'South Africa', '789 Church Street, Pretoria, 0002', 'legal@ptaassoc.co.za');

-- Insert Users (5 users)
INSERT INTO users (id, organization_id, email, name, role, department) VALUES
('550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440001', 'sarah.johnson@jhblegal.co.za', 'Sarah Johnson', 'Senior Partner', 'Corporate Law'),
('550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440001', 'michael.smith@jhblegal.co.za', 'Michael Smith', 'Associate', 'Compliance'),
('550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440002', 'linda.williams@ctclaw.co.za', 'Linda Williams', 'Compliance Officer', 'Risk Management'),
('550e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440003', 'david.brown@ptaassoc.co.za', 'David Brown', 'Senior Associate', 'Commercial Law'),
('550e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440001', 'emma.davis@jhblegal.co.za', 'Emma Davis', 'Paralegal', 'Litigation');

-- Insert Documents (10 documents)
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
('550e8400-e29b-41d4-a716-446655440030', '550e8400-e29b-41d4-a716-446655440001', 'Software License Agreement - TechCorp v1.0', 'contract', 'licensing', 'Legacy software license agreement for previous version.', 'software_license', '/documents/software_license_010.pdf', 187654, 'active', 'medium', '550e8400-e29b-41d4-a716-446655440011', CURRENT_TIMESTAMP);

-- Insert Tasks (8 tasks)
INSERT INTO tasks (id, organization_id, title, description, type, status, priority, assigned_to, created_by, due_date) VALUES
('550e8400-e29b-41d4-a716-446655440051', '550e8400-e29b-41d4-a716-446655440001', 'Review Employment Contract Terms', 'Review and update standard employment contract terms for compliance with new labor laws', 'document_review', 'in_progress', 'high', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2024-12-30'),
('550e8400-e29b-41d4-a716-446655440052', '550e8400-e29b-41d4-a716-446655440001', 'Compliance Audit - Q4 2024', 'Conduct quarterly compliance audit for all active contracts', 'compliance_check', 'pending', 'high', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2024-12-31'),
('550e8400-e29b-41d4-a716-446655440053', '550e8400-e29b-41d4-a716-446655440001', 'Update NDA Templates', 'Update non-disclosure agreement templates with latest legal requirements', 'template_update', 'completed', 'medium', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440011', '2024-12-15'),
('550e8400-e29b-41d4-a716-446655440054', '550e8400-e29b-41d4-a716-446655440002', 'Risk Assessment - New Partnership', 'Assess legal risks for the proposed strategic alliance partnership', 'risk_assessment', 'in_progress', 'high', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', '2024-12-28'),
('550e8400-e29b-41d4-a716-446655440055', '550e8400-e29b-41d4-a716-446655440001', 'Document Classification Review', 'Review and reclassify documents based on new risk assessment criteria', 'classification', 'pending', 'medium', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2025-01-15'),
('550e8400-e29b-41d4-a716-446655440056', '550e8400-e29b-41d4-a716-446655440002', 'Lease Renewal Negotiation', 'Negotiate terms for office lease renewal in Cape Town', 'negotiation', 'pending', 'medium', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', '2025-01-31'),
('550e8400-e29b-41d4-a716-446655440057', '550e8400-e29b-41d4-a716-446655440001', 'Regulatory Update Review', 'Review and implement changes from latest POPIA amendments', 'regulatory_review', 'in_progress', 'high', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440011', '2024-12-20'),
('550e8400-e29b-41d4-a716-446655440058', '550e8400-e29b-41d4-a716-446655440002', 'Contract Comparison Analysis', 'Compare merger agreement terms with industry standards', 'analysis', 'pending', 'medium', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', '2025-01-10');

-- Insert Compliance Rules (6 rules)
INSERT INTO compliance_rules (id, organization_id, name, title, description, category, regulation_source, risk_level) VALUES
('550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440001', 'POPIA Data Protection Compliance', 'POPIA Data Protection Compliance', 'Ensure all contracts comply with Protection of Personal Information Act requirements', 'data_protection', 'POPIA (Act 4 of 2013)', 'high'),
('550e8400-e29b-41d4-a716-446655440072', '550e8400-e29b-41d4-a716-446655440001', 'Employment Equity Act Compliance', 'Employment Equity Act Compliance', 'Verify employment contracts meet Employment Equity Act standards', 'employment', 'Employment Equity Act (Act 55 of 1998)', 'high'),
('550e8400-e29b-41d4-a716-446655440073', '550e8400-e29b-41d4-a716-446655440001', 'Consumer Protection Act Compliance', 'Consumer Protection Act Compliance', 'Ensure service agreements comply with Consumer Protection Act', 'consumer_protection', 'Consumer Protection Act (Act 68 of 2008)', 'medium'),
('550e8400-e29b-41d4-a716-446655440074', '550e8400-e29b-41d4-a716-446655440002', 'Companies Act Compliance', 'Companies Act Compliance', 'Verify corporate documents comply with Companies Act requirements', 'corporate', 'Companies Act (Act 71 of 2008)', 'high'),
('550e8400-e29b-41d4-a716-446655440075', '550e8400-e29b-41d4-a716-446655440001', 'Labour Relations Act Compliance', 'Labour Relations Act Compliance', 'Ensure employment terms comply with Labour Relations Act', 'employment', 'Labour Relations Act (Act 66 of 1995)', 'medium'),
('550e8400-e29b-41d4-a716-446655440076', '550e8400-e29b-41d4-a716-446655440002', 'Competition Act Compliance', 'Competition Act Compliance', 'Review merger agreements for Competition Act compliance', 'competition', 'Competition Act (Act 89 of 1998)', 'high');

-- Insert Compliance Monitoring (12 monitoring records)
INSERT INTO compliance_monitoring (id, organization_id, rule_id, document_id, status, compliance_score, issues_found, next_check_due) VALUES
('550e8400-e29b-41d4-a716-446655440091', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440021', 'compliant', 95, 0, '2025-03-01'),
('550e8400-e29b-41d4-a716-446655440092', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440072', '550e8400-e29b-41d4-a716-446655440021', 'compliant', 88, 1, '2025-02-15'),
('550e8400-e29b-41d4-a716-446655440093', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440073', '550e8400-e29b-41d4-a716-446655440022', 'non_compliant', 65, 3, '2024-12-31'),
('550e8400-e29b-41d4-a716-446655440094', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440023', 'compliant', 92, 1, '2025-02-28'),
('550e8400-e29b-41d4-a716-446655440095', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440074', '550e8400-e29b-41d4-a716-446655440025', 'under_review', 78, 2, '2025-01-20'),
('550e8400-e29b-41d4-a716-446655440096', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440076', '550e8400-e29b-41d4-a716-446655440029', 'compliant', 85, 1, '2025-04-01'),
('550e8400-e29b-41d4-a716-446655440097', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440073', '550e8400-e29b-41d4-a716-446655440022', 'non_compliant', 58, 4, '2024-12-25'),
('550e8400-e29b-41d4-a716-446655440098', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440075', '550e8400-e29b-41d4-a716-446655440021', 'compliant', 90, 1, '2025-03-15'),
('550e8400-e29b-41d4-a716-446655440099', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440074', '550e8400-e29b-41d4-a716-446655440025', 'compliant', 82, 2, '2025-02-10'),
('550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440027', 'compliant', 96, 0, '2025-03-05'),
('550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440072', '550e8400-e29b-41d4-a716-446655440028', 'compliant', 84, 2, '2025-02-12'),
('550e8400-e29b-41d4-a716-446655440102', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440076', '550e8400-e29b-41d4-a716-446655440029', 'under_review', 75, 3, '2025-01-25');

-- Insert Compliance Alerts (8 alerts)
INSERT INTO compliance_alerts (id, organization_id, rule_id, document_id, title, description, priority, type, status, due_date, regulation_source, jurisdiction) VALUES
('550e8400-e29b-41d4-a716-446655440121', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440073', '550e8400-e29b-41d4-a716-446655440022', 'Consumer Protection Act Violations Found', 'Software License Agreement contains clauses that may violate Consumer Protection Act requirements. Review and update required.', 'High', 'compliance', 'active', '2024-12-25', 'Consumer Protection Act (Act 68 of 2008)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440122', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440023', 'POPIA Data Handling Update', 'NDA requires update to align with latest POPIA data handling requirements. Review data processing clauses.', 'Medium', 'compliance', 'active', '2025-01-10', 'POPIA (Act 4 of 2013)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440123', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440074', '550e8400-e29b-41d4-a716-446655440025', 'Companies Act Review Required', 'Partnership Agreement requires review for Companies Act compliance. Director liability clauses need attention.', 'Medium', 'compliance', 'active', '2025-01-15', 'Companies Act (Act 71 of 2008)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440124', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440072', '550e8400-e29b-41d4-a716-446655440021', 'Employment Equity Minor Issue', 'Employment Contract has minor Employment Equity Act compliance issue. Update diversity reporting clause.', 'Low', 'compliance', 'resolved', '2025-01-31', 'Employment Equity Act (Act 55 of 1998)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440125', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440076', '550e8400-e29b-41d4-a716-446655440029', 'Competition Act Clearance Pending', 'Merger Agreement pending Competition Commission clearance. Monitor approval status and update terms if required.', 'Critical', 'regulatory', 'active', '2025-02-28', 'Competition Act (Act 89 of 1998)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440126', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440075', '550e8400-e29b-41d4-a716-446655440021', 'Labour Relations Act Update', 'Employment Contract needs minor update for Labour Relations Act compliance. Review dispute resolution clauses.', 'Low', 'compliance', 'resolved', '2025-02-15', 'Labour Relations Act (Act 66 of 1995)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440127', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440071', '550e8400-e29b-41d4-a716-446655440027', 'POPIA Policy Update Required', 'Data Protection Policy needs update to reflect latest POPIA amendments. Review consent mechanisms.', 'High', 'policy', 'active', '2024-12-31', 'POPIA (Act 4 of 2013)', 'South Africa'),
('550e8400-e29b-41d4-a716-446655440128', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440073', '550e8400-e29b-41d4-a716-446655440024', 'Consumer Protection Review', 'Service Level Agreement requires Consumer Protection Act compliance review. Update cancellation and refund terms.', 'Medium', 'compliance', 'active', '2025-01-05', 'Consumer Protection Act (Act 68 of 2008)', 'South Africa');

-- Insert Depositions (6 depositions)
INSERT INTO depositions (id, organization_id, case_name, case_number, deponent_name, deponent_role, date_conducted, location, status, duration_minutes, created_by) VALUES
('550e8400-e29b-41d4-a716-446655440141', '550e8400-e29b-41d4-a716-446655440001', 'Smith vs. ABC Corporation', 'HC-2024-001', 'John Smith', 'Plaintiff', '2024-01-15', 'Cape Town High Court', 'completed', 180, '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440142', '550e8400-e29b-41d4-a716-446655440001', 'Estate Planning Matter - Johnson', 'EST-2024-045', 'Mary Johnson', 'Beneficiary', '2024-01-20', 'Johannesburg Office', 'completed', 120, '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440143', '550e8400-e29b-41d4-a716-446655440001', 'Contract Dispute - Wilson vs. XYZ Ltd', 'COM-2024-023', 'Robert Wilson', 'Defendant', '2024-12-25', 'Durban Commercial Court', 'scheduled', NULL, '550e8400-e29b-41d4-a716-446655440011'),
('550e8400-e29b-41d4-a716-446655440144', '550e8400-e29b-41d4-a716-446655440001', 'Personal Injury Claim', 'PI-2024-067', 'Sarah Davis', 'Witness', '2024-02-01', 'Pretoria Magistrate Court', 'completed', 90, '550e8400-e29b-41d4-a716-446655440015'),
('550e8400-e29b-41d4-a716-446655440145', '550e8400-e29b-41d4-a716-446655440001', 'Employment Dispute', 'LAB-2024-012', 'Michael Brown', 'Former Employee', '2024-12-20', 'CCMA Offices', 'scheduled', NULL, '550e8400-e29b-41d4-a716-446655440012'),
('550e8400-e29b-41d4-a716-446655440146', '550e8400-e29b-41d4-a716-446655440002', 'Property Development Case', 'PROP-2024-089', 'Jennifer Lee', 'Property Developer', '2024-12-30', 'Cape Town Office', 'scheduled', NULL, '550e8400-e29b-41d4-a716-446655440013');

-- Insert Regulatory Updates (5 updates)
INSERT INTO regulatory_updates (title, description, regulation_source, category, jurisdiction, effective_date, impact_level, url) VALUES
('POPIA Amendment Regulations 2024', 'New regulations under POPIA addressing AI and automated decision-making in data processing', 'POPIA', 'data_protection', 'South Africa', '2024-07-01', 'high', 'https://www.gov.za/popia-amendments-2024'),
('Companies Act Amendment - Director Duties', 'Updated director duties and liability provisions under the Companies Act', 'Companies Act', 'corporate', 'South Africa', '2024-09-01', 'medium', 'https://www.gov.za/companies-act-amendments'),
('Employment Equity Amendment Act 2024', 'Revised employment equity targets and reporting requirements', 'Employment Equity Act', 'employment', 'South Africa', '2024-06-01', 'high', 'https://www.gov.za/employment-equity-amendments'),
('Consumer Protection Regulations Update', 'New consumer protection regulations for digital services and e-commerce', 'Consumer Protection Act', 'consumer_protection', 'South Africa', '2024-08-15', 'medium', 'https://www.gov.za/consumer-protection-digital'),
('Competition Commission Guidelines - Digital Markets', 'New guidelines for competition assessment in digital markets and platforms', 'Competition Act', 'competition', 'South Africa', '2024-10-01', 'high', 'https://www.compcom.co.za/digital-markets-guidelines');

-- Insert Document Templates (4 templates)
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
 'high');

-- Insert File Storage Config
INSERT INTO file_storage_config (storage_type, base_path, max_file_size_mb, allowed_mime_types, retention_days) VALUES
('local', '/public/documents/', 100, ARRAY['application/pdf', 'application/msword', 'text/plain'], 1095);
