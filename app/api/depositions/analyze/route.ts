import { NextResponse } from "next/server"
import { sql } from "@/lib/database"

export async function POST(request: Request) {
  try {
    const { depositionId, analysisType = "full" } = await request.json()

    console.log("🔄 Analyzing deposition:", depositionId)

    if (!sql) {
      throw new Error("Database connection not available")
    }

    // Get deposition details
    const [deposition] = await sql`
      SELECT * FROM depositions WHERE id = ${depositionId}
    `

    if (!deposition) {
      return NextResponse.json({ success: false, error: "Deposition not found" }, { status: 404 })
    }

    // Update status to analyzing
    await sql`
      UPDATE depositions 
      SET status = 'analyzing', updated_at = NOW()
      WHERE id = ${depositionId}
    `

    // Simulate AI analysis (in real app, this would call OpenAI/Claude)
    const analysisResults = {
      keyTopics: [
        "Contract breach allegations",
        "Timeline of events",
        "Financial damages",
        "Witness credibility",
        "Document authenticity",
      ],
      summary: `Analysis of ${deposition.deponent_name}'s deposition reveals key testimony regarding ${deposition.case_name}. The deponent provided detailed accounts of events leading to the dispute, with particular emphasis on contractual obligations and timeline discrepancies.`,
      credibilityScore: Math.floor(Math.random() * 30) + 70, // 70-100
      inconsistencies: [
        {
          topic: "Timeline discrepancy",
          description: "Conflicting dates mentioned for contract signing",
          severity: "medium",
        },
        {
          topic: "Financial figures",
          description: "Inconsistent revenue numbers cited",
          severity: "low",
        },
      ],
      recommendations: [
        "Follow up on timeline discrepancies with additional documentation",
        "Cross-reference financial figures with accounting records",
        "Consider deposing additional witnesses mentioned",
      ],
    }

    // Update deposition with analysis results
    const [updatedDeposition] = await sql`
      UPDATE depositions 
      SET 
        status = 'completed',
        key_topics = ${JSON.stringify(analysisResults.keyTopics)},
        summary = ${analysisResults.summary},
        analysis_results = ${JSON.stringify(analysisResults)},
        updated_at = NOW()
      WHERE id = ${depositionId}
      RETURNING *
    `

    console.log("✅ Deposition analysis completed")

    return NextResponse.json({
      success: true,
      data: {
        deposition: updatedDeposition,
        analysis: analysisResults,
      },
      message: "Deposition analysis completed successfully",
    })
  } catch (error) {
    console.error("❌ Error analyzing deposition:", error)

    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : "Failed to analyze deposition",
      },
      { status: 500 },
    )
  }
}
