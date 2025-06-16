import { NextResponse } from "next/server"
import { sql } from "@/lib/database"

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url)
    const organizationId = searchParams.get("organization_id")
    const status = searchParams.get("status") || "active"
    const priority = searchParams.get("priority")
    const limit = Number.parseInt(searchParams.get("limit") || "10")

    console.log("🔄 Fetching compliance alerts from database...")
    console.log("Parameters:", { organizationId, status, priority, limit })

    if (!sql) {
      throw new Error("Database connection not available")
    }

    let alerts

    if (organizationId && priority) {
      alerts = await sql`
        SELECT 
          id,
          title,
          description,
          priority,
          due_date,
          type,
          status,
          regulation_source,
          jurisdiction,
          created_at,
          updated_at
        FROM compliance_alerts 
        WHERE status = ${status}
          AND organization_id = ${organizationId}
          AND priority = ${priority}
        ORDER BY 
          CASE priority 
            WHEN 'Critical' THEN 1
            WHEN 'High' THEN 2
            WHEN 'Medium' THEN 3
            WHEN 'Low' THEN 4
          END,
          due_date ASC
        LIMIT ${limit}
      `
    } else if (organizationId) {
      alerts = await sql`
        SELECT 
          id,
          title,
          description,
          priority,
          due_date,
          type,
          status,
          regulation_source,
          jurisdiction,
          created_at,
          updated_at
        FROM compliance_alerts 
        WHERE status = ${status}
          AND organization_id = ${organizationId}
        ORDER BY 
          CASE priority 
            WHEN 'Critical' THEN 1
            WHEN 'High' THEN 2
            WHEN 'Medium' THEN 3
            WHEN 'Low' THEN 4
          END,
          due_date ASC
        LIMIT ${limit}
      `
    } else if (priority) {
      alerts = await sql`
        SELECT 
          id,
          title,
          description,
          priority,
          due_date,
          type,
          status,
          regulation_source,
          jurisdiction,
          created_at,
          updated_at
        FROM compliance_alerts 
        WHERE status = ${status}
          AND priority = ${priority}
        ORDER BY 
          CASE priority 
            WHEN 'Critical' THEN 1
            WHEN 'High' THEN 2
            WHEN 'Medium' THEN 3
            WHEN 'Low' THEN 4
          END,
          due_date ASC
        LIMIT ${limit}
      `
    } else {
      alerts = await sql`
        SELECT 
          id,
          title,
          description,
          priority,
          due_date,
          type,
          status,
          regulation_source,
          jurisdiction,
          created_at,
          updated_at
        FROM compliance_alerts 
        WHERE status = ${status}
        ORDER BY 
          CASE priority 
            WHEN 'Critical' THEN 1
            WHEN 'High' THEN 2
            WHEN 'Medium' THEN 3
            WHEN 'Low' THEN 4
          END,
          due_date ASC
        LIMIT ${limit}
      `
    }

    console.log(`✅ Found ${alerts.length} compliance alerts`)

    return NextResponse.json({
      success: true,
      data: alerts,
      count: alerts.length,
      filters: { status, priority, organizationId, limit },
    })
  } catch (error) {
    console.error("❌ Error fetching compliance alerts:", error)

    // Return proper error response
    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : "Failed to fetch compliance alerts",
        data: [],
        count: 0,
      },
      { status: 500 },
    )
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json()
    const { title, description, priority, due_date, type, regulation_source, jurisdiction, organization_id } = body

    console.log("🔄 Creating new compliance alert...")

    if (!sql) {
      throw new Error("Database connection not available")
    }

    const newAlert = await sql`
      INSERT INTO compliance_alerts (
        title, description, priority, due_date, type, 
        regulation_source, jurisdiction, organization_id
      ) VALUES (
        ${title}, ${description}, ${priority}, ${due_date}, ${type},
        ${regulation_source}, ${jurisdiction}, ${organization_id}
      )
      RETURNING *
    `

    console.log("✅ Compliance alert created:", newAlert[0]?.id)

    return NextResponse.json({
      success: true,
      data: newAlert[0],
      message: "Compliance alert created successfully",
    })
  } catch (error) {
    console.error("❌ Error creating compliance alert:", error)

    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : "Failed to create compliance alert",
      },
      { status: 500 },
    )
  }
}
