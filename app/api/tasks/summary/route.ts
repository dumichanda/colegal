import { type NextRequest, NextResponse } from "next/server"
import { taskTracker } from "@/lib/task-tracker"
import { withTaskTracking } from "@/lib/middleware/task-tracking-middleware"

async function handler(req: NextRequest) {
  const summary = await taskTracker.getSummary()

  return NextResponse.json({
    success: true,
    data: summary,
  })
}

export const GET = withTaskTracking(handler)
