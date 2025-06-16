import { NextResponse } from "next/server"
import { sql } from "@/lib/database"

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url)
    const organizationId = searchParams.get("organization_id")
    const status = searchParams.get("status")
    const limit = Number.parseInt(searchParams.get("limit") || "20")

    console.log("🔄 Fetching depositions...")

    if (!sql) {
      throw new Error("Database connection not available")
    }

    let query = `
      SELECT 
        id,
        case_name,
        deponent_name,
        deposition_date,
        location,
        status,
        transcript_path,
        duration_minutes,
        key_topics,
        summary,
        organization_id,
        created_at,
        updated_at
      FROM depositions
      WHERE 1=1
    `

    const params: any[] = []
    let paramIndex = 1

    if (organizationId) {
      query += ` AND organization_id = $${paramIndex}`
      params.push(organizationId)
      paramIndex++
    }

    if (status) {
      query += ` AND status = $${paramIndex}`
      params.push(status)
      paramIndex++
    }

    query += ` ORDER BY deposition_date DESC LIMIT $${paramIndex}`
    params.push(limit)

    const depositions = await sql(query, params)

    console.log(`✅ Found ${depositions.length} depositions`)

    return NextResponse.json({
      success: true,
      data: depositions,
      count: depositions.length,
    })
  } catch (error) {
    console.error("❌ Error fetching depositions:", error)

    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : "Failed to fetch depositions",
        data: [],
      },
      { status: 500 },
    )
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json()
    const { case_name, deponent_name, deposition_date, location, transcript_path, duration_minutes, organization_id } =
      body

    console.log("🔄 Creating new deposition...")

    if (!sql) {
      throw new Error("Database connection not available")
    }

    const [newDeposition] = await sql`
      INSERT INTO depositions (
        case_name, deponent_name, deposition_date, location,
        transcript_path, duration_minutes, organization_id, status
      ) VALUES (
        ${case_name}, ${deponent_name}, ${deposition_date}, ${location},
        ${transcript_path}, ${duration_minutes}, ${organization_id}, 'pending'
      )
      RETURNING *
    `

    console.log("✅ Deposition created:", newDeposition.id)

    return NextResponse.json({
      success: true,
      data: newDeposition,
      message: "Deposition created successfully",
    })
  } catch (error) {
    console.error("❌ Error creating deposition:", error)

    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : "Failed to create deposition",
      },
      { status: 500 },
    )
  }
}
