-- Update documents table to reference actual PDF files
UPDATE documents SET 
    file_path = '/documents/employment-contract-template.pdf',
    file_size = 245760,
    mime_type = 'application/pdf',
    content = 'Employment contract template with standard terms and conditions for South African employment law compliance.'
WHERE title = 'Employment Contract - Senior Developer';

UPDATE documents SET 
    file_path = '/documents/software-license-agreement.pdf',
    file_size = 156432,
    mime_type = 'application/pdf',
    content = 'Software license agreement governing the use, distribution, and modification of software products.'
WHERE title LIKE 'Software License Agreement%';

UPDATE documents SET 
    file_path = '/documents/non-disclosure-agreement.pdf',
    file_size = 98765,
    mime_type = 'application/pdf',
    content = 'Non-disclosure agreement template for protecting confidential information in business relationships.'
WHERE title = 'Non-Disclosure Agreement - Project Alpha';

UPDATE documents SET 
    file_path = '/documents/partnership-agreement-template.pdf',
    file_size = 187654,
    mime_type = 'application/pdf',
    content = 'Partnership agreement template outlining terms for strategic business partnerships and joint ventures.'
WHERE title = 'Partnership Agreement - Strategic Alliance';

UPDATE documents SET 
    file_path = '/documents/service-level-agreement.pdf',
    file_size = 134567,
    mime_type = 'application/pdf',
    content = 'Service level agreement defining performance standards, metrics, and penalties for service delivery.'
WHERE title = 'Service Level Agreement - Cloud Services';

-- Add more realistic document metadata
UPDATE documents SET 
    content = 'Comprehensive compliance policy document outlining data protection procedures, POPIA compliance requirements, and privacy safeguards for organizational data handling.'
WHERE title = 'Compliance Policy - Data Protection';

UPDATE documents SET 
    content = 'Quarterly risk assessment report analyzing legal, operational, and compliance risks across the organization with recommendations for risk mitigation.'
WHERE title = 'Risk Assessment Report - Q4 2024';

UPDATE documents SET 
    content = 'Merger and acquisition agreement detailing the terms, conditions, and regulatory requirements for the acquisition of TechStart company.'
WHERE title = 'Merger Agreement - TechStart Acquisition';

UPDATE documents SET 
    content = 'Commercial lease agreement for office space in Cape Town, including rental terms, maintenance responsibilities, and renewal options.'
WHERE title = 'Lease Agreement - Office Space Cape Town';

-- Verify updates
SELECT id, title, file_path, file_size, mime_type, LEFT(content, 100) as content_preview
FROM documents 
WHERE file_path IS NOT NULL
ORDER BY title;
