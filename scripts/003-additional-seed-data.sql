-- Additional seed data for enhanced functionality

-- Insert more sample documents for better testing
INSERT INTO documents (id, title, type, content, file_path, file_size, uploaded_by, organization_id) VALUES
    ('doc-006', 'Non-Disclosure Agreement', 'contract', 'This Non-Disclosure Agreement protects confidential information...', '/documents/nda.pdf', 145280, '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440001'),
    ('doc-007', 'Privacy Policy Template', 'policy', 'This Privacy Policy describes how we collect, use, and protect personal information...', '/documents/privacy-policy.pdf', 167936, '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440002'),
    ('doc-008', 'Service Level Agreement', 'contract', 'This SLA defines the level of service expected from the service provider...', '/documents/sla.pdf', 203776, '550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440003'),
    ('doc-009', 'Vendor Agreement', 'contract', 'This Vendor Agreement governs the relationship between company and vendor...', '/documents/vendor-agreement.pdf', 234496, '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440001'),
    ('doc-010', 'Employee Handbook', 'policy', 'This handbook outlines company policies, procedures, and expectations...', '/documents/employee-handbook.pdf', 456704, '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440002');

-- Insert additional document analyses
INSERT INTO document_analyses (id, document_id, analysis_type, results, confidence_score, analyzed_by) VALUES
    ('analysis-006', 'doc-006', 'contract_review', '{"key_terms": ["confidentiality_scope", "duration", "exceptions"], "risk_level": "low", "recommendations": ["Add return of materials clause"]}', 0.94, '550e8400-e29b-41d4-a716-446655440011'),
    ('analysis-007', 'doc-007', 'compliance_check', '{"compliance_status": "compliant", "gaps": [], "score": 98, "areas_reviewed": ["data_collection", "cookies", "third_party_sharing"]}', 0.97, '550e8400-e29b-41d4-a716-446655440012'),
    ('analysis-008', 'doc-008', 'contract_review', '{"key_terms": ["uptime_guarantee", "penalties", "escalation"], "risk_level": "medium", "recommendations": ["Clarify force majeure provisions"]}', 0.89, '550e8400-e29b-41d4-a716-446655440013'),
    ('analysis-009', 'doc-009', 'contract_review', '{"key_terms": ["payment_terms", "deliverables", "warranties"], "risk_level": "medium", "recommendations": ["Add performance benchmarks"]}', 0.87, '550e8400-e29b-41d4-a716-446655440011'),
    ('analysis-010', 'doc-010', 'policy_review', '{"completeness": "comprehensive", "compliance": "good", "recommendations": ["Update remote work policies", "Add diversity and inclusion section"]}', 0.91, '550e8400-e29b-41d4-a716-446655440012');

-- Insert additional contract clauses
INSERT INTO contract_clauses (id, document_id, clause_type, content, risk_level, position_start, position_end) VALUES
    ('clause-008', 'doc-006', 'confidentiality', 'Recipient shall not disclose confidential information to any third party without prior written consent.', 'medium', 500, 620),
    ('clause-009', 'doc-006', 'duration', 'This agreement shall remain in effect for a period of five (5) years.', 'low', 1200, 1300),
    ('clause-010', 'doc-008', 'sla_guarantee', 'Service provider guarantees 99.9% uptime with penalties for non-compliance.', 'high', 800, 920),
    ('clause-011', 'doc-008', 'escalation', 'Critical issues shall be escalated within 15 minutes of detection.', 'medium', 1500, 1620),
    ('clause-012', 'doc-009', 'payment_terms', 'Payment shall be made within thirty (30) days of invoice receipt.', 'low', 1000, 1120),
    ('clause-013', 'doc-009', 'warranty', 'Vendor warrants that all deliverables will be free from defects.', 'medium', 1800, 1920);

-- Update some existing records with more realistic data
UPDATE compliance_monitoring 
SET last_check_date = NOW() - INTERVAL '15 days',
    notes = 'Recent audit completed - minor recommendations implemented'
WHERE status = 'compliant';

UPDATE compliance_monitoring 
SET last_check_date = NOW() - INTERVAL '45 days',
    notes = 'Action plan in progress - next review scheduled'
WHERE status = 'at_risk';

UPDATE compliance_monitoring 
SET last_check_date = NOW() - INTERVAL '60 days',
    notes = 'Critical issues identified - immediate attention required'
WHERE status = 'non_compliant';
