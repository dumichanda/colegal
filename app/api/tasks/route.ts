import { type NextRequest, NextResponse } from "next/server"
import { taskTracker } from "@/lib/task-tracker"
import { withTaskTracking } from "@/lib/middleware/task-tracking-middleware"

async function handler(req: NextRequest) {
  if (req.method === "GET") {
    const { searchParams } = new URL(req.url)
    const type = searchParams.get("type")
    const action = searchParams.get("action")
    const userId = searchParams.get("userId")
    const since = searchParams.get("since")
    const limit = Number.parseInt(searchParams.get("limit") || "100")

    const events = await taskTracker.getEvents({
      type: type || undefined,
      action: action || undefined,
      userId: userId || undefined,
      since: since || undefined,
      limit,
    })

    return NextResponse.json({
      success: true,
      data: events,
      total: events.length,
    })
  }

  if (req.method === "POST") {
    const { type, action, details, userId, sessionId, metadata } = await req.json()

    await taskTracker.track({
      type,
      action,
      details,
      userId,
      sessionId,
      metadata,
    })

    return NextResponse.json({
      success: true,
      message: "Event tracked successfully",
    })
  }

  return NextResponse.json({ success: false, error: "Method not allowed" }, { status: 405 })
}

export const GET = withTaskTracking(handler)
export const POST = withTaskTracking(handler)
