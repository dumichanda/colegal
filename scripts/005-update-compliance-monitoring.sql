-- Update compliance_monitoring table to include next_check_due dates
UPDATE compliance_monitoring 
SET next_check_due = CASE 
  WHEN status = 'non_compliant' THEN NOW() + INTERVAL '1 day'
  WHEN status = 'at_risk' THEN NOW() + INTERVAL '7 days'
  WHEN status = 'compliant' THEN NOW() + INTERVAL '30 days'
  ELSE NOW() + INTERVAL '14 days'
END
WHERE next_check_due IS NULL;

-- Add some sample compliance monitoring records with different statuses
INSERT INTO compliance_monitoring (organization_id, rule_id, status, last_checked, next_check_due, notes)
SELECT 
  o.id as organization_id,
  cr.id as rule_id,
  CASE 
    WHEN RANDOM() < 0.1 THEN 'non_compliant'
    WHEN RANDOM() < 0.3 THEN 'at_risk'
    ELSE 'compliant'
  END as status,
  NOW() - INTERVAL '1 day' as last_checked,
  CASE 
    WHEN RANDOM() < 0.1 THEN NOW() + INTERVAL '1 day'
    WHEN RANDOM() < 0.3 THEN NOW() + INTERVAL '7 days'
    ELSE NOW() + INTERVAL '30 days'
  END as next_check_due,
  'Automated compliance check' as notes
FROM organizations o
CROSS JOIN compliance_rules cr
WHERE NOT EXISTS (
  SELECT 1 FROM compliance_monitoring cm 
  WHERE cm.organization_id = o.id AND cm.rule_id = cr.id
)
LIMIT 20;
