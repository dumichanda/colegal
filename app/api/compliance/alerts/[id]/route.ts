import { NextResponse } from "next/server"
import { sql } from "@/lib/database"

export async function DELETE(request: Request, { params }: { params: { id: string } }) {
  try {
    const { id } = params

    console.log("🔄 Dismissing compliance alert:", id)

    if (!sql) {
      throw new Error("Database connection not available")
    }

    const [updatedAlert] = await sql`
      UPDATE compliance_alerts 
      SET status = 'dismissed', updated_at = NOW()
      WHERE id = ${id}
      RETURNING *
    `

    if (!updatedAlert) {
      return NextResponse.json({ success: false, error: "Alert not found" }, { status: 404 })
    }

    console.log("✅ Compliance alert dismissed successfully")

    return NextResponse.json({
      success: true,
      data: updatedAlert,
      message: "Alert dismissed successfully",
    })
  } catch (error) {
    console.error("❌ Error dismissing compliance alert:", error)

    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : "Failed to dismiss alert",
      },
      { status: 500 },
    )
  }
}

export async function PATCH(request: Request, { params }: { params: { id: string } }) {
  try {
    const { id } = params
    const body = await request.json()

    console.log("🔄 Updating compliance alert:", id)

    if (!sql) {
      throw new Error("Database connection not available")
    }

    const updateFields = []
    const values = []
    let paramIndex = 1

    // Build dynamic update query
    Object.entries(body).forEach(([key, value]) => {
      if (key !== "id") {
        updateFields.push(`${key} = $${paramIndex}`)
        values.push(value)
        paramIndex++
      }
    })

    if (updateFields.length === 0) {
      return NextResponse.json({ success: false, error: "No fields to update" }, { status: 400 })
    }

    updateFields.push(`updated_at = NOW()`)
    values.push(id)

    const query = `
      UPDATE compliance_alerts 
      SET ${updateFields.join(", ")}
      WHERE id = $${paramIndex}
      RETURNING *
    `

    const [updatedAlert] = await sql(query, values)

    if (!updatedAlert) {
      return NextResponse.json({ success: false, error: "Alert not found" }, { status: 404 })
    }

    console.log("✅ Compliance alert updated successfully")

    return NextResponse.json({
      success: true,
      data: updatedAlert,
      message: "Alert updated successfully",
    })
  } catch (error) {
    console.error("❌ Error updating compliance alert:", error)

    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : "Failed to update alert",
      },
      { status: 500 },
    )
  }
}
