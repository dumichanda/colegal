import { type NextRequest, NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

export async function GET(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const documentId = params.id

    // Get document details
    const [document] = await sql`
      SELECT 
        d.id,
        d.title,
        d.type,
        d.status,
        d.risk_level,
        d.created_at,
        d.updated_at,
        da.results,
        da.confidence_score as overall_score
      FROM documents d
      LEFT JOIN document_analyses da ON d.id = da.document_id
      WHERE d.id = ${documentId}
    `

    if (!document) {
      return NextResponse.json({ error: "Document not found" }, { status: 404 })
    }

    // Get contract clauses
    const clauses = await sql`
      SELECT 
        id,
        clause_type as type,
        content,
        risk_level,
        page_number,
        'Review this clause for potential issues' as recommendation
      FROM contract_clauses
      WHERE document_id = ${documentId}
      ORDER BY position
    `

    // Get compliance checks from analysis results
    let complianceChecks = []
    let keyTerms = []

    if (document.results) {
      try {
        const analysisResults = JSON.parse(document.results)
        complianceChecks = analysisResults.compliance || []
        keyTerms = analysisResults.keyTerms || []
      } catch (e) {
        console.error("Error parsing analysis results:", e)
      }
    }

    // If no compliance checks from analysis, get from compliance monitoring
    if (complianceChecks.length === 0) {
      const complianceData = await sql`
        SELECT 
          cr.title as rule,
          cm.status,
          cr.description as details
        FROM compliance_rules cr
        LEFT JOIN compliance_monitoring cm ON cr.id = cm.rule_id
        WHERE cr.is_active = true
        LIMIT 5
      `
      complianceChecks = complianceData.map((item) => ({
        rule: item.rule,
        status: item.status || "pending",
        details: item.details,
      }))
    }

    // Default key terms if none from analysis
    if (keyTerms.length === 0) {
      keyTerms = [
        { term: "Contract Value", value: "To be determined" },
        { term: "Term Length", value: "To be determined" },
        { term: "Payment Terms", value: "To be determined" },
        { term: "Governing Law", value: "To be determined" },
      ]
    }

    const analysisData = {
      id: document.id,
      title: document.title,
      type: document.type,
      status: document.status,
      risk_level: document.risk_level,
      overall_score: document.overall_score || 75,
      clauses: clauses,
      key_terms: keyTerms,
      compliance_checks: complianceChecks,
      created_at: document.created_at,
      updated_at: document.updated_at,
    }

    return NextResponse.json(analysisData)
  } catch (error) {
    console.error("Database error:", error)
    return NextResponse.json({ error: "Failed to fetch document analysis" }, { status: 500 })
  }
}
