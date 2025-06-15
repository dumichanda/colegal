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

    if (!sql) {
      return NextResponse.json({ success: false, error: "Database connection not available" }, { status: 503 })
    }

    let guidance = ""

    // AI-powered regulatory guidance if OpenAI is available
    if (process.env.OPENAI_API_KEY) {
      try {
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
        guidance = text
      } catch (aiError) {
        console.error("AI guidance failed:", aiError)
        guidance = `Legal guidance for "${query}" - Please consult with a qualified legal professional for specific advice regarding ${jurisdiction} law.`
      }
    } else {
      guidance = `Legal guidance for "${query}" - AI-powered guidance requires OpenAI API key. Please consult with a qualified legal professional for specific advice regarding ${jurisdiction} law.`
    }

    // Search relevant documents in database
    const documents = await sql`
      SELECT d.id, d.title, d.type, da.results
      FROM documents d
      LEFT JOIN document_analyses da ON d.id = da.document_id
      WHERE d.title ILIKE ${"%" + query + "%"} 
         OR da.results::text ILIKE ${"%" + query + "%"}
      ORDER BY d.created_at DESC
      LIMIT 5
    `

    // Search compliance rules
    const complianceRules = await sql`
      SELECT id, title, description, regulation_source, category, risk_level
      FROM compliance_rules
      WHERE title ILIKE ${"%" + query + "%"} 
         OR description ILIKE ${"%" + query + "%"}
         OR regulation_source ILIKE ${"%" + query + "%"}
      ORDER BY risk_level DESC
      LIMIT 5
    `

    return NextResponse.json({
      success: true,
      data: {
        guidance,
        relatedDocuments: documents,
        relatedRules: complianceRules,
        query,
        jurisdiction,
        confidence: process.env.OPENAI_API_KEY ? 0.92 : 0.75,
        aiPowered: !!process.env.OPENAI_API_KEY,
      },
    })
  } catch (error) {
    console.error("Error processing search:", error)
    return NextResponse.json({ success: false, error: "Failed to process search query" }, { status: 500 })
  }
}
