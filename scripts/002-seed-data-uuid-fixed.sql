-- Fixed seed data with proper UUIDs for Legal & Compliance AI Assistant

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

-- Insert sample documents with proper UUIDs
INSERT INTO documents (id, title, type, file_path, file_size, mime_type, uploaded_by, organization_id, status) VALUES
    ('550e8400-e29b-41d4-a716-446655440101', 'Employment Agreement Template', 'contract', '/documents/employment-agreement.pdf', 245760, 'application/pdf', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440001', 'completed'),
    ('550e8400-e29b-41d4-a716-446655440102', 'GDPR Compliance Policy', 'policy', '/documents/gdpr-policy.pdf', 189440, 'application/pdf', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440002', 'completed'),
    ('550e8400-e29b-41d4-a716-446655440103', 'Software License Agreement', 'contract', '/documents/software-license.pdf', 156672, 'application/pdf', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440003', 'completed'),
    ('550e8400-e29b-41d4-a716-446655440104', 'Data Processing Agreement', 'contract', '/documents/dpa.pdf', 198144, 'application/pdf', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440001', 'completed'),
    ('550e8400-e29b-41d4-a716-446655440105', 'Corporate Bylaws', 'legal', '/documents/bylaws.pdf', 312320, 'application/pdf', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440002', 'completed'),
    ('550e8400-e29b-41d4-a716-446655440106', 'Non-Disclosure Agreement', 'contract', '/documents/nda.pdf', 145280, 'application/pdf', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440001', 'completed'),
    ('550e8400-e29b-41d4-a716-446655440107', 'Privacy Policy Template', 'policy', '/documents/privacy-policy.pdf', 167936, 'application/pdf', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440002', 'completed'),
    ('550e8400-e29b-41d4-a716-446655440108', 'Service Level Agreement', 'contract', '/documents/sla.pdf', 203776, 'application/pdf', '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440003', 'completed'),
    ('550e8400-e29b-41d4-a716-446655440109', 'Vendor Agreement', 'contract', '/documents/vendor-agreement.pdf', 234496, 'application/pdf', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440001', 'processing'),
    ('550e8400-e29b-41d4-a716-446655440110', 'Employee Handbook', 'policy', '/documents/employee-handbook.pdf', 456704, 'application/pdf', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440002', 'pending');

-- Insert sample document analyses with proper UUIDs
INSERT INTO document_analyses (id, document_id, analysis_type, results, confidence_score) VALUES
    ('550e8400-e29b-41d4-a716-446655440201', '550e8400-e29b-41d4-a716-446655440101', 'contract_review', '{"key_terms": ["employment_duration", "compensation", "termination_clause"], "risk_level": "low", "recommendations": ["Add non-compete clause", "Clarify intellectual property rights"], "summary": "Standard employment agreement with typical terms"}', 0.92),
    ('550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440102', 'compliance_check', '{"compliance_status": "compliant", "gaps": [], "score": 95, "areas_reviewed": ["data_collection", "consent_management", "breach_notification"], "summary": "Comprehensive GDPR compliance policy"}', 0.95),
    ('550e8400-e29b-41d4-a716-446655440203', '550e8400-e29b-41d4-a716-446655440103', 'contract_review', '{"key_terms": ["license_scope", "payment_terms", "liability_limitations"], "risk_level": "medium", "recommendations": ["Review indemnification clause", "Add termination rights"], "summary": "Software license with moderate risk factors"}', 0.88),
    ('550e8400-e29b-41d4-a716-446655440204', '550e8400-e29b-41d4-a716-446655440104', 'compliance_check', '{"compliance_status": "needs_review", "gaps": ["data_retention_period"], "score": 82, "areas_reviewed": ["processing_purposes", "data_subject_rights"], "summary": "DPA requires minor updates for full compliance"}', 0.85),
    ('550e8400-e29b-41d4-a716-446655440205', '550e8400-e29b-41d4-a716-446655440105', 'legal_review', '{"structure_analysis": "standard", "completeness": "good", "recommendations": ["Update director responsibilities", "Add electronic meeting provisions"], "summary": "Corporate bylaws are well-structured"}', 0.90),
    ('550e8400-e29b-41d4-a716-446655440206', '550e8400-e29b-41d4-a716-446655440106', 'contract_review', '{"key_terms": ["confidentiality_scope", "duration", "exceptions"], "risk_level": "low", "recommendations": ["Add return of materials clause"], "summary": "Standard NDA with appropriate protections"}', 0.94),
    ('550e8400-e29b-41d4-a716-446655440207', '550e8400-e29b-41d4-a716-446655440107', 'compliance_check', '{"compliance_status": "compliant", "gaps": [], "score": 98, "areas_reviewed": ["data_collection", "cookies", "third_party_sharing"], "summary": "Excellent privacy policy coverage"}', 0.97),
    ('550e8400-e29b-41d4-a716-446655440208', '550e8400-e29b-41d4-a716-446655440108', 'contract_review', '{"key_terms": ["uptime_guarantee", "penalties", "escalation"], "risk_level": "medium", "recommendations": ["Clarify force majeure provisions"], "summary": "SLA with clear performance metrics"}', 0.89);

-- Insert sample contract clauses with proper UUIDs
INSERT INTO contract_clauses (id, document_id, clause_type, content, risk_level, page_number, position_start, position_end) VALUES
    ('550e8400-e29b-41d4-a716-446655440301', '550e8400-e29b-41d4-a716-446655440101', 'termination', 'Either party may terminate this agreement with thirty (30) days written notice.', 'low', 3, 1250, 1350),
    ('550e8400-e29b-41d4-a716-446655440302', '550e8400-e29b-41d4-a716-446655440101', 'compensation', 'Employee shall receive an annual salary of $[AMOUNT] payable in bi-weekly installments.', 'low', 2, 800, 920),
    ('550e8400-e29b-41d4-a716-446655440303', '550e8400-e29b-41d4-a716-446655440101', 'confidentiality', 'Employee agrees to maintain confidentiality of all proprietary information.', 'medium', 4, 1500, 1620),
    ('550e8400-e29b-41d4-a716-446655440304', '550e8400-e29b-41d4-a716-446655440103', 'liability', 'Licensor''s liability shall not exceed the total amount paid under this agreement.', 'high', 5, 2100, 2220),
    ('550e8400-e29b-41d4-a716-446655440305', '550e8400-e29b-41d4-a716-446655440103', 'indemnification', 'Licensee shall indemnify Licensor against all third-party claims.', 'high', 6, 2300, 2420),
    ('550e8400-e29b-41d4-a716-446655440306', '550e8400-e29b-41d4-a716-446655440104', 'data_retention', 'Personal data shall be retained for no longer than necessary for processing purposes.', 'medium', 3, 1800, 1920),
    ('550e8400-e29b-41d4-a716-446655440307', '550e8400-e29b-41d4-a716-446655440104', 'breach_notification', 'Data breaches shall be reported within 72 hours of discovery.', 'critical', 4, 2500, 2620),
    ('550e8400-e29b-41d4-a716-446655440308', '550e8400-e29b-41d4-a716-446655440106', 'confidentiality', 'Recipient shall not disclose confidential information to any third party without prior written consent.', 'medium', 2, 500, 620),
    ('550e8400-e29b-41d4-a716-446655440309', '550e8400-e29b-41d4-a716-446655440106', 'duration', 'This agreement shall remain in effect for a period of five (5) years.', 'low', 1, 1200, 1300),
    ('550e8400-e29b-41d4-a716-446655440310', '550e8400-e29b-41d4-a716-446655440108', 'sla_guarantee', 'Service provider guarantees 99.9% uptime with penalties for non-compliance.', 'high', 2, 800, 920),
    ('550e8400-e29b-41d4-a716-446655440311', '550e8400-e29b-41d4-a716-446655440108', 'escalation', 'Critical issues shall be escalated within 15 minutes of detection.', 'medium', 3, 1500, 1620),
    ('550e8400-e29b-41d4-a716-446655440312', '550e8400-e29b-41d4-a716-446655440109', 'payment_terms', 'Payment shall be made within thirty (30) days of invoice receipt.', 'low', 2, 1000, 1120),
    ('550e8400-e29b-41d4-a716-446655440313', '550e8400-e29b-41d4-a716-446655440109', 'warranty', 'Vendor warrants that all deliverables will be free from defects.', 'medium', 4, 1800, 1920);

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
