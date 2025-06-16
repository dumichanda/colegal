import { type NextRequest, NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

export async function PATCH(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const { status } = await request.json()
    const alertId = params.id

    await sql`
      UPDATE compliance_alerts 
      SET status = ${status}, updated_at = NOW()
      WHERE id = ${alertId}
    `

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error("Database error:", error)
    return NextResponse.json({ error: "Failed to update alert" }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const alertId = params.id

    await sql`
      UPDATE compliance_alerts 
      SET status = 'dismissed', updated_at = NOW()
      WHERE id = ${alertId}
    `

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error("Database error:", error)
    return NextResponse.json({ error: "Failed to dismiss alert" }, { status: 500 })
  }
}
