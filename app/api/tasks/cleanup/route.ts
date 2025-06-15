import { type NextRequest, NextResponse } from "next/server"
import { taskTracker } from "@/lib/task-tracker"
import { withTaskTracking } from "@/lib/middleware/task-tracking-middleware"

async function handler(req: NextRequest) {
  const { searchParams } = new URL(req.url)
  const days = Number.parseInt(searchParams.get("days") || "30")

  const removedCount = await taskTracker.clearOldEvents(days)

  return NextResponse.json({
    success: true,
    message: `Cleaned up ${removedCount} old events`,
    removedCount,
  })
}

export const POST = withTaskTracking(handler)
