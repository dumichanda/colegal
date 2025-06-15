import { type NextRequest, NextResponse } from "next/server"
import { sql } from "@/lib/database"

export async function GET(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const documentId = params.id

    const [document] = await sql`
      SELECT d.*, 
             json_agg(
               json_build_object(
                 'id', da.id,
                 'analysis_type', da.analysis_type,
                 'results', da.results,
                 'confidence_score', da.confidence_score,
                 'created_at', da.created_at
               )
             ) as analyses,
             json_agg(
               json_build_object(
                 'id', cc.id,
                 'clause_type', cc.clause_type,
                 'content', cc.content,
                 'risk_level', cc.risk_level,
                 'page_number', cc.page_number
               )
             ) as clauses
      FROM documents d
      LEFT JOIN document_analyses da ON d.id = da.document_id
      LEFT JOIN contract_clauses cc ON d.id = cc.document_id
      WHERE d.id = ${documentId}
      GROUP BY d.id
    `

    if (!document) {
      return NextResponse.json({ success: false, error: "Document not found" }, { status: 404 })
    }

    return NextResponse.json({
      success: true,
      data: document,
    })
  } catch (error) {
    console.error("Error fetching document:", error)
    return NextResponse.json({ success: false, error: "Failed to fetch document" }, { status: 500 })
  }
}
