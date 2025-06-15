-- Cleanup script to remove all seed data
-- Run this to clean the database before re-inserting fresh seed data

-- Delete in reverse order of dependencies to avoid foreign key constraint errors

-- 1. Delete compliance monitoring records (references organizations and compliance_rules)
DELETE FROM compliance_monitoring 
WHERE organization_id IN (
    '550e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440002', 
    '550e8400-e29b-41d4-a716-446655440003'
);

-- 2. Delete contract clauses (references documents)
DELETE FROM contract_clauses 
WHERE document_id IN (
    'doc-001', 'doc-002', 'doc-003', 'doc-004', 'doc-005',
    'doc-006', 'doc-007', 'doc-008', 'doc-009', 'doc-010'
);

-- 3. Delete document analyses (references documents)
DELETE FROM document_analyses 
WHERE document_id IN (
    'doc-001', 'doc-002', 'doc-003', 'doc-004', 'doc-005',
    'doc-006', 'doc-007', 'doc-008', 'doc-009', 'doc-010'
);

-- 4. Delete documents (references users and organizations)
DELETE FROM documents 
WHERE id IN (
    'doc-001', 'doc-002', 'doc-003', 'doc-004', 'doc-005',
    'doc-006', 'doc-007', 'doc-008', 'doc-009', 'doc-010'
);

-- 5. Delete users (references organizations)
DELETE FROM users 
WHERE id IN (
    '550e8400-e29b-41d4-a716-446655440011',
    '550e8400-e29b-41d4-a716-446655440012',
    '550e8400-e29b-41d4-a716-446655440013'
);

-- 6. Delete organizations (no dependencies)
DELETE FROM organizations 
WHERE id IN (
    '550e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440003'
);

-- 7. Delete compliance rules (no dependencies from our seed data)
DELETE FROM compliance_rules 
WHERE title IN (
    'GDPR Data Processing Requirements',
    'SOX Financial Reporting Controls',
    'HIPAA Patient Data Security',
    'CCPA Consumer Rights',
    'PCI DSS Payment Security',
    'OSHA Workplace Safety'
);

-- 8. Delete regulatory updates (no dependencies)
DELETE FROM regulatory_updates 
WHERE title IN (
    'New SEC Cybersecurity Disclosure Rules',
    'EU AI Act Implementation Guidelines',
    'Updated OSHA Workplace Safety Standards',
    'California Privacy Rights Act Updates',
    'FTC Safeguards Rule Amendments'
);

-- Verify cleanup - these should all return 0 rows
SELECT 'organizations' as table_name, COUNT(*) as remaining_rows FROM organizations
UNION ALL
SELECT 'users', COUNT(*) FROM users
UNION ALL  
SELECT 'documents', COUNT(*) FROM documents
UNION ALL
SELECT 'document_analyses', COUNT(*) FROM document_analyses
UNION ALL
SELECT 'contract_clauses', COUNT(*) FROM contract_clauses
UNION ALL
SELECT 'compliance_rules', COUNT(*) FROM compliance_rules
UNION ALL
SELECT 'regulatory_updates', COUNT(*) FROM regulatory_updates
UNION ALL
SELECT 'compliance_monitoring', COUNT(*) FROM compliance_monitoring;
