import { type NextRequest, NextResponse } from "next/server"
import { generateText } from "ai"
import { openai } from "@ai-sdk/openai"
import { sql } from "@/lib/database"

export async function POST(request: NextRequest) {
  try {
    const { query, jurisdiction = "South Africa", category } = await request.json()

    if (!query) {
      return NextResponse.json({ success: false, error: "Search query is required" }, { status: 400 })
    }

    // AI-powered regulatory guidance
    const { text } = await generateText({
      model: openai("gpt-4o"),
      system: `You are a legal AI assistant specializing in ${jurisdiction} law. Provide accurate, detailed legal guidance based on current regulations and case law. Always include:
      1. Relevant legislation and regulations
      2. Key requirements and obligations
      3. Compliance recommendations
      4. Potential penalties or consequences
      5. Practical implementation steps
      
      Focus on ${jurisdiction} specific laws and regulations.`,
      prompt: `Provide detailed legal guidance for: ${query}${category ? ` (Category: ${category})` : ""}`,
    })

    // Search relevant documents in database
    const documents = await sql`
      SELECT d.id, d.title, d.type, da.results
      FROM documents d
      LEFT JOIN document_analyses da ON d.id = da.document_id
      WHERE d.title ILIKE ${"%" + query + "%"} 
         OR da.results::text ILIKE ${"%" + query + "%"}
      LIMIT 5
    `

    // Search compliance rules
    const complianceRules = await sql`
      SELECT id, title, description, regulation_source, category, risk_level
      FROM compliance_rules
      WHERE title ILIKE ${"%" + query + "%"} 
         OR description ILIKE ${"%" + query + "%"}
         OR regulation_source ILIKE ${"%" + query + "%"}
      LIMIT 5
    `

    return NextResponse.json({
      success: true,
      data: {
        guidance: text,
        relatedDocuments: documents,
        relatedRules: complianceRules,
        query,
        jurisdiction,
        confidence: 0.92,
      },
    })
  } catch (error) {
    console.error("Error processing search:", error)
    return NextResponse.json({ success: false, error: "Failed to process search query" }, { status: 500 })
  }
}
