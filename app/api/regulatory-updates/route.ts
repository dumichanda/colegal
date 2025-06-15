import { type NextRequest, NextResponse } from "next/server"
import { getRegulatoryUpdates } from "@/lib/database"

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const limit = Number.parseInt(searchParams.get("limit") || "10")
    const jurisdiction = searchParams.get("jurisdiction")

    let updates = await getRegulatoryUpdates(limit)

    if (jurisdiction) {
      updates = updates.filter((update: any) => update.jurisdiction.toLowerCase().includes(jurisdiction.toLowerCase()))
    }

    return NextResponse.json({
      success: true,
      data: updates,
    })
  } catch (error) {
    console.error("Error fetching regulatory updates:", error)
    return NextResponse.json({ success: false, error: "Failed to fetch regulatory updates" }, { status: 500 })
  }
}
