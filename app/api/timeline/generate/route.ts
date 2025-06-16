import { NextResponse } from "next/server"
import { sql } from "@/lib/database"

export async function POST(request: Request) {
  try {
    const { caseId, documentIds, startDate, endDate, organizationId } = await request.json()

    console.log("🔄 Generating case timeline...")

    if (!sql) {
      throw new Error("Database connection not available")
    }

    // Get relevant documents
    let documents = []
    if (documentIds && documentIds.length > 0) {
      documents = await sql`
        SELECT id, title, type, created_at, file_path
        FROM documents 
        WHERE id = ANY(${documentIds})
        ORDER BY created_at ASC
      `
    } else {
      // Get all documents for the organization within date range
      documents = await sql`
        SELECT id, title, type, created_at, file_path
        FROM documents 
        WHERE organization_id = ${organizationId}
        ${startDate ? sql`AND created_at >= ${startDate}` : sql``}
        ${endDate ? sql`AND created_at <= ${endDate}` : sql``}
        ORDER BY created_at ASC
        LIMIT 50
      `
    }

    // Generate timeline events from documents and other sources
    const timelineEvents = []

    // Add document events
    documents.forEach((doc, index) => {
      timelineEvents.push({
        id: `doc-${doc.id}`,
        date: doc.created_at,
        title: `Document: ${doc.title}`,
        description: `${doc.type} document added to case`,
        type: "document",
        category: "evidence",
        importance: "medium",
        source: "document",
        metadata: {
          documentId: doc.id,
          documentType: doc.type,
        },
      })
    })

    // Add compliance events
    const complianceEvents = await sql`
      SELECT cm.*, cr.title as rule_title, cr.category
      FROM compliance_monitoring cm
      JOIN compliance_rules cr ON cm.rule_id = cr.id
      WHERE cm.organization_id = ${organizationId}
      ${startDate ? sql`AND cm.last_checked >= ${startDate}` : sql``}
      ${endDate ? sql`AND cm.last_checked <= ${endDate}` : sql``}
      ORDER BY cm.last_checked ASC
      LIMIT 20
    `

    complianceEvents.forEach((event) => {
      timelineEvents.push({
        id: `compliance-${event.id}`,
        date: event.last_checked,
        title: `Compliance Check: ${event.rule_title}`,
        description: `${event.category} compliance status: ${event.status}`,
        type: "compliance",
        category: "regulatory",
        importance: event.status === "non_compliant" ? "high" : "low",
        source: "compliance",
        metadata: {
          ruleId: event.rule_id,
          status: event.status,
          category: event.category,
        },
      })
    })

    // Sort all events by date
    timelineEvents.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime())

    // Create timeline record
    const [timeline] = await sql`
      INSERT INTO case_timelines (
        case_id, title, description, events, 
        start_date, end_date, organization_id
      ) VALUES (
        ${caseId}, 
        ${`Case Timeline - ${new Date().toLocaleDateString()}`},
        ${`Generated timeline with ${timelineEvents.length} events`},
        ${JSON.stringify(timelineEvents)},
        ${startDate || timelineEvents[0]?.date},
        ${endDate || timelineEvents[timelineEvents.length - 1]?.date},
        ${organizationId}
      )
      RETURNING *
    `

    console.log("✅ Timeline generated successfully")

    return NextResponse.json({
      success: true,
      data: {
        timeline,
        events: timelineEvents,
        summary: {
          totalEvents: timelineEvents.length,
          documentEvents: timelineEvents.filter((e) => e.type === "document").length,
          complianceEvents: timelineEvents.filter((e) => e.type === "compliance").length,
          dateRange: {
            start: timelineEvents[0]?.date,
            end: timelineEvents[timelineEvents.length - 1]?.date,
          },
        },
      },
      message: "Timeline generated successfully",
    })
  } catch (error) {
    console.error("❌ Error generating timeline:", error)

    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : "Failed to generate timeline",
      },
      { status: 500 },
    )
  }
}
