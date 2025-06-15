-- Alternative: Complete table cleanup (removes ALL data, not just seed data)
-- WARNING: This will delete ALL data in your database, not just seed data
-- Only use this if you want to completely reset the database

-- Disable foreign key checks temporarily (if supported by your database)
-- SET foreign_key_checks = 0; -- MySQL
-- SET session_replication_role = replica; -- PostgreSQL

-- Truncate all tables in dependency order
TRUNCATE TABLE compliance_monitoring CASCADE;
TRUNCATE TABLE contract_clauses CASCADE;
TRUNCATE TABLE document_analyses CASCADE;
TRUNCATE TABLE documents CASCADE;
TRUNCATE TABLE users CASCADE;
TRUNCATE TABLE organizations CASCADE;
TRUNCATE TABLE compliance_rules CASCADE;
TRUNCATE TABLE regulatory_updates CASCADE;

-- Re-enable foreign key checks
-- SET foreign_key_checks = 1; -- MySQL
-- SET session_replication_role = DEFAULT; -- PostgreSQL

-- Verify all tables are empty
SELECT 'organizations' as table_name, COUNT(*) as rows FROM organizations
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
