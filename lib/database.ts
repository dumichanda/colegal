import { neon } from "@neondatabase/serverless"

// Validate environment variables
if (!process.env.DATABASE_URL) {
  console.warn("DATABASE_URL environment variable is not set. Database operations will be mocked.")
}

const sql = process.env.DATABASE_URL ? neon(process.env.DATABASE_URL) : null

export { sql }

// Database helper functions - now using real database
export async function getDocuments(organizationId?: string) {
  if (!sql) {
    throw new Error("Database connection not available")
  }

  try {
    if (organizationId) {
      return await sql`
        SELECT d.*, da.analysis_type, da.confidence_score, da.results
        FROM documents d
        LEFT JOIN document_analyses da ON d.id = da.document_id
        WHERE d.organization_id = ${organizationId}
        ORDER BY d.created_at DESC
      `
    }

    return await sql`
      SELECT d.*, da.analysis_type, da.confidence_score, da.results
      FROM documents d
      LEFT JOIN document_analyses da ON d.id = da.document_id
      ORDER BY d.created_at DESC
      LIMIT 50
    `
  } catch (error) {
    console.error("Database error:", error)
    throw error
  }
}

export async function getDocumentById(id: string) {
  if (!sql) {
    throw new Error("Database connection not available")
  }

  try {
    const [document] = await sql`
      SELECT d.*, da.analysis_type, da.confidence_score, da.results
      FROM documents d
      LEFT JOIN document_analyses da ON d.id = da.document_id
      WHERE d.id = ${id}
    `
    return document
  } catch (error) {
    console.error("Database error:", error)
    throw error
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
    throw new Error("Database connection not available")
  }

  try {
    const [document] = await sql`
      INSERT INTO documents (title, type, file_path, file_size, mime_type, uploaded_by, organization_id, status)
      VALUES (${data.title}, ${data.type}, ${data.file_path}, ${data.file_size}, ${data.mime_type}, ${data.uploaded_by}, ${data.organization_id}, 'pending')
      RETURNING *
    `
    return document
  } catch (error) {
    console.error("Database error:", error)
    throw error
  }
}

export async function getComplianceRules(organizationId?: string) {
  if (!sql) {
    throw new Error("Database connection not available")
  }

  try {
    return await sql`
      SELECT cr.*, cm.status, cm.last_checked, cm.next_check_due
      FROM compliance_rules cr
      LEFT JOIN compliance_monitoring cm ON cr.id = cm.rule_id
      WHERE cr.is_active = true
      ${organizationId ? sql`AND (cm.organization_id = ${organizationId} OR cm.organization_id IS NULL)` : sql``}
      ORDER BY cr.risk_level DESC, cr.created_at DESC
    `
  } catch (error) {
    console.error("Database error:", error)
    throw error
  }
}

export async function getRegulatoryUpdates(limit = 10) {
  if (!sql) {
    throw new Error("Database connection not available")
  }

  try {
    return await sql`
      SELECT * FROM regulatory_updates
      ORDER BY effective_date DESC, created_at DESC
      LIMIT ${limit}
    `
  } catch (error) {
    console.error("Database error:", error)
    throw error
  }
}

export async function getContractClauses(documentId: string) {
  if (!sql) {
    throw new Error("Database connection not available")
  }

  try {
    return await sql`
      SELECT * FROM contract_clauses
      WHERE document_id = ${documentId}
      ORDER BY page_number ASC, position ASC
    `
  } catch (error) {
    console.error("Database error:", error)
    throw error
  }
}

export async function getOrganizations() {
  if (!sql) {
    throw new Error("Database connection not available")
  }

  try {
    return await sql`
      SELECT * FROM organizations
      ORDER BY name ASC
    `
  } catch (error) {
    console.error("Database error:", error)
    throw error
  }
}

export async function getUsers(organizationId?: string) {
  if (!sql) {
    throw new Error("Database connection not available")
  }

  try {
    return await sql`
      SELECT u.*, o.name as organization_name
      FROM users u
      LEFT JOIN organizations o ON u.organization_id = o.id
      ${organizationId ? sql`WHERE u.organization_id = ${organizationId}` : sql``}
      ORDER BY u.created_at DESC
    `
  } catch (error) {
    console.error("Database error:", error)
    throw error
  }
}
