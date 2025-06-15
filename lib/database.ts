import { neon } from "@neondatabase/serverless"

// Validate environment variables
if (!process.env.DATABASE_URL) {
  console.warn("DATABASE_URL environment variable is not set. Database operations will be mocked.")
}

const sql = process.env.DATABASE_URL ? neon(process.env.DATABASE_URL) : null

export { sql }

// Mock data for when database is not available
const mockDocuments = [
  {
    id: "1",
    title: "Employment Contract Template",
    type: "contract",
    file_path: "/documents/employment-contract.pdf",
    file_size: 245760,
    mime_type: "application/pdf",
    uploaded_by: "admin",
    organization_id: "org-1",
    created_at: new Date().toISOString(),
    analysis_type: "contract_analysis",
    confidence_score: 0.95,
  },
  {
    id: "2",
    title: "POPIA Compliance Checklist",
    type: "compliance",
    file_path: "/documents/popia-checklist.pdf",
    file_size: 156432,
    mime_type: "application/pdf",
    uploaded_by: "admin",
    organization_id: "org-1",
    created_at: new Date().toISOString(),
    analysis_type: "compliance_check",
    confidence_score: 0.88,
  },
]

const mockComplianceRules = [
  {
    id: "1",
    title: "POPIA Data Processing",
    description: "Ensure all data processing complies with POPIA requirements",
    risk_level: "high",
    is_active: true,
    created_at: new Date().toISOString(),
    status: "compliant",
    last_checked: new Date().toISOString(),
    next_check_due: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
  },
  {
    id: "2",
    title: "B-BBEE Compliance",
    description: "Monitor B-BBEE scorecard requirements",
    risk_level: "medium",
    is_active: true,
    created_at: new Date().toISOString(),
    status: "at_risk",
    last_checked: new Date().toISOString(),
    next_check_due: new Date(Date.now() + 15 * 24 * 60 * 60 * 1000).toISOString(),
  },
]

const mockRegulatoryUpdates = [
  {
    id: "1",
    title: "POPIA Amendment Act 2024",
    description: "New amendments to data protection requirements",
    source: "Department of Justice",
    effective_date: new Date().toISOString(),
    created_at: new Date().toISOString(),
    impact_level: "high",
  },
]

// Database helper functions with fallback to mock data
export async function getDocuments(organizationId?: string) {
  if (!sql) {
    console.log("Using mock data for documents")
    return mockDocuments.filter((doc) => !organizationId || doc.organization_id === organizationId)
  }

  try {
    if (organizationId) {
      return await sql`
        SELECT d.*, da.analysis_type, da.confidence_score 
        FROM documents d
        LEFT JOIN document_analyses da ON d.id = da.document_id
        WHERE d.organization_id = ${organizationId}
        ORDER BY d.created_at DESC
      `
    }

    return await sql`
      SELECT d.*, da.analysis_type, da.confidence_score 
      FROM documents d
      LEFT JOIN document_analyses da ON d.id = da.document_id
      ORDER BY d.created_at DESC
      LIMIT 50
    `
  } catch (error) {
    console.error("Database error, falling back to mock data:", error)
    return mockDocuments
  }
}

export async function createDocument(data: {
  title: string
  type: string
  file_path: string
  file_size: number
  mime_type: string
  uploaded_by?: string
  organization_id?: string
}) {
  if (!sql) {
    console.log("Using mock data for document creation")
    const mockDoc = {
      id: Date.now().toString(),
      ...data,
      created_at: new Date().toISOString(),
    }
    return mockDoc
  }

  try {
    const [document] = await sql`
      INSERT INTO documents (title, type, file_path, file_size, mime_type, uploaded_by, organization_id)
      VALUES (${data.title}, ${data.type}, ${data.file_path}, ${data.file_size}, ${data.mime_type}, ${data.uploaded_by}, ${data.organization_id})
      RETURNING *
    `
    return document
  } catch (error) {
    console.error("Database error, using mock response:", error)
    return {
      id: Date.now().toString(),
      ...data,
      created_at: new Date().toISOString(),
    }
  }
}

export async function getComplianceRules() {
  if (!sql) {
    console.log("Using mock data for compliance rules")
    return mockComplianceRules
  }

  try {
    return await sql`
      SELECT cr.*, cm.status, cm.last_checked, cm.next_check_due
      FROM compliance_rules cr
      LEFT JOIN compliance_monitoring cm ON cr.id = cm.rule_id
      WHERE cr.is_active = true
      ORDER BY cr.risk_level DESC, cr.created_at DESC
    `
  } catch (error) {
    console.error("Database error, falling back to mock data:", error)
    return mockComplianceRules
  }
}

export async function getRegulatoryUpdates(limit = 10) {
  if (!sql) {
    console.log("Using mock data for regulatory updates")
    return mockRegulatoryUpdates.slice(0, limit)
  }

  try {
    return await sql`
      SELECT * FROM regulatory_updates
      ORDER BY effective_date DESC, created_at DESC
      LIMIT ${limit}
    `
  } catch (error) {
    console.error("Database error, falling back to mock data:", error)
    return mockRegulatoryUpdates.slice(0, limit)
  }
}
