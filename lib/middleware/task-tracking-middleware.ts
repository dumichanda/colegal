import type { NextRequest, NextResponse } from "next/server"
import { taskTracker, trackSystemEvent } from "@/lib/task-tracker"

export function withTaskTracking(handler: (req: NextRequest) => Promise<NextResponse>) {
  return async (req: NextRequest) => {
    const startTime = Date.now()
    const requestId = `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`

    try {
      // Track request start
      await taskTracker.track({
        type: "system",
        action: "request_start",
        details: {
          method: req.method,
          url: req.url,
          userAgent: req.headers.get("user-agent"),
          requestId,
        },
        metadata: {
          startTime,
        },
      })

      // Execute the handler
      const response = await handler(req)
      const endTime = Date.now()
      const responseTime = endTime - startTime

      // Track successful request
      await taskTracker.track({
        type: "system",
        action: "request_complete",
        details: {
          method: req.method,
          url: req.url,
          status: response.status,
          requestId,
        },
        metadata: {
          responseTime,
          startTime,
          endTime,
        },
      })

      return response
    } catch (error) {
      const endTime = Date.now()
      const responseTime = endTime - startTime

      // Track failed request
      await trackSystemEvent({
        event: "request_error",
        level: "error",
        message: `Request failed: ${req.method} ${req.url}`,
        error,
        metadata: {
          responseTime,
          requestId,
          method: req.method,
          url: req.url,
        },
      })

      throw error
    }
  }
}
