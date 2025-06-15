-- Enhanced seed data for Legal & Compliance AI Assistant

-- Insert sample organizations
INSERT INTO organizations (id, name, type) VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'Acme Legal Partners', 'law_firm'),
    ('550e8400-e29b-41d4-a716-446655440002', 'TechCorp Legal Department', 'corporate'),
    ('550e8400-e29b-41d4-a716-446655440003', 'Smith & Associates', 'solo_practice');

-- Insert sample users
INSERT INTO users (id, email, name, role, organization_id) VALUES
    ('550e8400-e29b-41d4-a716-446655440011', 'sarah.johnson@acmelegal.com', 'Sarah Johnson', 'attorney', '550e8400-e29b-41d4-a716-446655440001'),
    ('550e8400-e29b-41d4-a716-446655440012', 'mike.chen@techcorp.com', 'Mike Chen', 'compliance_officer', '550e8400-e29b-41d4-a716-446655440002'),
    ('550e8400-e29b-41d4-a716-446655440013', 'lisa.davis@smithlaw.com', 'Lisa Davis', 'attorney', '550e8400-e29b-41d4-a716-446655440003');

-- Insert sample documents
INSERT INTO documents (id, title, type, content, file_path, file_size, uploaded_by, organization_id) VALUES
    ('doc-001', 'Employment Agreement Template', 'contract', 'This Employment Agreement is entered into between [Company Name] and [Employee Name]...', '/documents/employment-agreement.pdf', 245760, '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440001'),
    ('doc-002', 'GDPR Compliance Policy', 'policy', 'This document outlines our organization''s approach to GDPR compliance...', '/documents/gdpr-policy.pdf', 189440, '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440002'),
    ('doc-003', 'Software License Agreement', 'contract', 'This Software License Agreement governs the use of proprietary software...', '/documents/software-license.pdf', 156672, '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440003'),
    ('doc-004', 'Data Processing Agreement', 'contract', 'This Data Processing Agreement is entered into pursuant to GDPR requirements...', '/documents/dpa.pdf', 198144, '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440001'),
    ('doc-005', 'Corporate Bylaws', 'legal', 'These bylaws govern the internal management of the corporation...', '/documents/bylaws.pdf', 312320, '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440002');

-- Insert sample document analyses
INSERT INTO document_analyses (id, document_id, analysis_type, results, confidence_score, analyzed_by) VALUES
    ('analysis-001', 'doc-001', 'contract_review', '{"key_terms": ["employment_duration", "compensation", "termination_clause"], "risk_level": "low", "recommendations": ["Add non-compete clause", "Clarify intellectual property rights"]}', 0.92, '550e8400-e29b-41d4-a716-446655440011'),
    ('analysis-002', 'doc-002', 'compliance_check', '{"compliance_status": "compliant", "gaps": [], "score": 95, "areas_reviewed": ["data_collection", "consent_management", "breach_notification"]}', 0.95, '550e8400-e29b-41d4-a716-446655440012'),
    ('analysis-003', 'doc-003', 'contract_review', '{"key_terms": ["license_scope", "payment_terms", "liability_limitations"], "risk_level": "medium", "recommendations": ["Review indemnification clause", "Add termination rights"]}', 0.88, '550e8400-e29b-41d4-a716-446655440013'),
    ('analysis-004', 'doc-004', 'compliance_check', '{"compliance_status": "needs_review", "gaps": ["data_retention_period"], "score": 82, "areas_reviewed": ["processing_purposes", "data_subject_rights"]}', 0.85, '550e8400-e29b-41d4-a716-446655440011'),
    ('analysis-005', 'doc-005', 'legal_review', '{"structure_analysis": "standard", "completeness": "good", "recommendations": ["Update director responsibilities", "Add electronic meeting provisions"]}', 0.90, '550e8400-e29b-41d4-a716-446655440012');

-- Insert sample contract clauses
INSERT INTO contract_clauses (id, document_id, clause_type, content, risk_level, position_start, position_end) VALUES
    ('clause-001', 'doc-001', 'termination', 'Either party may terminate this agreement with thirty (30) days written notice.', 'low', 1250, 1350),
    ('clause-002', 'doc-001', 'compensation', 'Employee shall receive an annual salary of $[AMOUNT] payable in bi-weekly installments.', 'low', 800, 920),
    ('clause-003', 'doc-001', 'confidentiality', 'Employee agrees to maintain confidentiality of all proprietary information.', 'medium', 1500, 1620),
    ('clause-004', 'doc-003', 'liability', 'Licensor''s liability shall not exceed the total amount paid under this agreement.', 'high', 2100, 2220),
    ('clause-005', 'doc-003', 'indemnification', 'Licensee shall indemnify Licensor against all third-party claims.', 'high', 2300, 2420),
    ('clause-006', 'doc-004', 'data_retention', 'Personal data shall be retained for no longer than necessary for processing purposes.', 'medium', 1800, 1920),
    ('clause-007', 'doc-004', 'breach_notification', 'Data breaches shall be reported within 72 hours of discovery.', 'critical', 2500, 2620);

-- Insert sample compliance rules
INSERT INTO compliance_rules (title, description, regulation_source, jurisdiction, category, risk_level) VALUES
    ('GDPR Data Processing Requirements', 'Organizations must implement appropriate technical and organizational measures for data protection', 'GDPR Article 32', 'EU', 'Data Privacy', 'high'),
    ('SOX Financial Reporting Controls', 'Public companies must maintain adequate internal controls over financial reporting', 'Sarbanes-Oxley Act Section 404', 'US Federal', 'Financial Compliance', 'critical'),
    ('HIPAA Patient Data Security', 'Healthcare entities must implement safeguards to protect patient health information', 'HIPAA Security Rule', 'US Federal', 'Healthcare', 'high'),
    ('CCPA Consumer Rights', 'Businesses must provide consumers with rights regarding their personal information', 'California Consumer Privacy Act', 'California', 'Data Privacy', 'medium'),
    ('PCI DSS Payment Security', 'Organizations handling credit card data must comply with Payment Card Industry standards', 'PCI DSS v4.0', 'Global', 'Financial Security', 'high'),
    ('OSHA Workplace Safety', 'Employers must provide a safe working environment free from recognized hazards', 'OSHA General Duty Clause', 'US Federal', 'Workplace Safety', 'medium');

-- Insert sample regulatory updates
INSERT INTO regulatory_updates (title, description, source, jurisdiction, category, effective_date, impact_level, url) VALUES
    ('New SEC Cybersecurity Disclosure Rules', 'Public companies must disclose material cybersecurity incidents within four business days', 'SEC', 'US Federal', 'Cybersecurity', '2024-12-15', 'high', 'https://www.sec.gov/rules/final/2023/33-11216.pdf'),
    ('EU AI Act Implementation Guidelines', 'New guidelines for implementing the EU Artificial Intelligence Act requirements', 'European Commission', 'EU', 'Technology', '2024-08-01', 'medium', 'https://digital-strategy.ec.europa.eu/en/policies/european-approach-artificial-intelligence'),
    ('Updated OSHA Workplace Safety Standards', 'Revised workplace safety standards for manufacturing environments', 'OSHA', 'US Federal', 'Workplace Safety', '2024-06-01', 'medium', 'https://www.osha.gov/laws-regs/regulations/standardnumber/1910'),
    ('California Privacy Rights Act Updates', 'New amendments to CCPA expanding consumer privacy rights', 'California Attorney General', 'California', 'Data Privacy', '2024-01-01', 'high', 'https://oag.ca.gov/privacy/ccpa'),
    ('FTC Safeguards Rule Amendments', 'Enhanced cybersecurity requirements for financial institutions', 'FTC', 'US Federal', 'Financial Security', '2024-06-09', 'high', 'https://www.ftc.gov/enforcement/rules/rulemaking-regulatory-reform-proceedings/safeguards-rule');

-- Insert sample compliance monitoring records
INSERT INTO compliance_monitoring (organization_id, rule_id, status, next_check_due, notes) 
SELECT 
    o.id,
    r.id,
    CASE 
        WHEN RANDOM() < 0.6 THEN 'compliant'
        WHEN RANDOM() < 0.85 THEN 'at_risk'
        ELSE 'non_compliant'
    END,
    NOW() + INTERVAL '30 days',
    CASE 
        WHEN RANDOM() < 0.5 THEN 'Automated compliance check scheduled'
        WHEN RANDOM() < 0.8 THEN 'Manual review required'
        ELSE 'Remediation in progress'
    END
FROM organizations o
CROSS JOIN compliance_rules r
WHERE o.type IN ('corporate', 'law_firm');
