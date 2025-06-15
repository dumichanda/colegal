-- Seed data for Legal & Compliance AI Assistant

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

-- Insert sample compliance rules
INSERT INTO compliance_rules (title, description, regulation_source, jurisdiction, category, risk_level) VALUES
    ('GDPR Data Processing Requirements', 'Organizations must implement appropriate technical and organizational measures for data protection', 'GDPR Article 32', 'EU', 'Data Privacy', 'high'),
    ('SOX Financial Reporting Controls', 'Public companies must maintain adequate internal controls over financial reporting', 'Sarbanes-Oxley Act Section 404', 'US Federal', 'Financial Compliance', 'critical'),
    ('HIPAA Patient Data Security', 'Healthcare entities must implement safeguards to protect patient health information', 'HIPAA Security Rule', 'US Federal', 'Healthcare', 'high'),
    ('CCPA Consumer Rights', 'Businesses must provide consumers with rights regarding their personal information', 'California Consumer Privacy Act', 'California', 'Data Privacy', 'medium');

-- Insert sample regulatory updates
INSERT INTO regulatory_updates (title, description, source, jurisdiction, category, effective_date, impact_level, url) VALUES
    ('New SEC Cybersecurity Disclosure Rules', 'Public companies must disclose material cybersecurity incidents within four business days', 'SEC', 'US Federal', 'Cybersecurity', '2024-12-15', 'high', 'https://www.sec.gov/rules/final/2023/33-11216.pdf'),
    ('EU AI Act Implementation Guidelines', 'New guidelines for implementing the EU Artificial Intelligence Act requirements', 'European Commission', 'EU', 'Technology', '2024-08-01', 'medium', 'https://digital-strategy.ec.europa.eu/en/policies/european-approach-artificial-intelligence'),
    ('Updated OSHA Workplace Safety Standards', 'Revised workplace safety standards for manufacturing environments', 'OSHA', 'US Federal', 'Workplace Safety', '2024-06-01', 'medium', 'https://www.osha.gov/laws-regs/regulations/standardnumber/1910');

-- Insert sample compliance monitoring records
INSERT INTO compliance_monitoring (organization_id, rule_id, status, next_check_due, notes) 
SELECT 
    o.id,
    r.id,
    CASE 
        WHEN RANDOM() < 0.7 THEN 'compliant'
        WHEN RANDOM() < 0.9 THEN 'at_risk'
        ELSE 'non_compliant'
    END,
    NOW() + INTERVAL '30 days',
    'Automated compliance check scheduled'
FROM organizations o
CROSS JOIN compliance_rules r
WHERE o.type IN ('corporate', 'law_firm');
