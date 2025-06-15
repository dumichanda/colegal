import { writeFile, readFile, mkdir } from "fs/promises"
import { existsSync } from "fs"
import { join } from "path"

export interface TaskEvent {
  id: string
  timestamp: string
  type: "chat" | "file" | "workflow" | "compliance" | "document" | "user" | "system"
  action: string
  details: Record<string, any>
  userId?: string
  sessionId?: string
  metadata?: Record<string, any>
}

export interface TaskSummary {
  totalEvents: number
  eventsByType: Record<string, number>
  recentActivity: TaskEvent[]
  activeUsers: string[]
  systemHealth: {
    status: "healthy" | "warning" | "error"
    lastUpdate: string
    performance: {
      averageResponseTime: number
      errorRate: number
    }
  }
}

class TaskTracker {
  private events: TaskEvent[] = []
  private readonly maxEvents = 10000
  private readonly tasklistPath = join(process.cwd(), "tasklist.json")
  private readonly logPath = join(process.cwd(), "logs")
  private saveTimeout: NodeJS.Timeout | null = null
  private performanceMetrics: {
    responseTimes: number[]
    errors: number
    totalRequests: number
  } = {
    responseTimes: [],
    errors: 0,
    totalRequests: 0,
  }

  constructor() {
    this.initializeTasklist()
    this.startPeriodicSave()
  }

  private async initializeTasklist() {
    try {
      // Ensure logs directory exists
      if (!existsSync(this.logPath)) {
        await mkdir(this.logPath, { recursive: true })
      }

      // Load existing tasklist if it exists
      if (existsSync(this.tasklistPath)) {
        const data = await readFile(this.tasklistPath, "utf-8")
        const parsed = JSON.parse(data)
        this.events = parsed.events || []

        // Log system startup
        await this.track({
          type: "system",
          action: "startup",
          details: {
            message: "Task tracking system initialized",
            existingEvents: this.events.length,
          },
        })
      } else {
        // Create initial tasklist
        await this.track({
          type: "system",
          action: "initialize",
          details: {
            message: "Task tracking system created",
            version: "1.0.0",
          },
        })
      }
    } catch (error) {
      console.error("Failed to initialize task tracker:", error)
    }
  }

  async track(event: Omit<TaskEvent, "id" | "timestamp">): Promise<void> {
    const taskEvent: TaskEvent = {
      id: `task_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      timestamp: new Date().toISOString(),
      ...event,
    }

    // Add to events array
    this.events.unshift(taskEvent)

    // Maintain max events limit
    if (this.events.length > this.maxEvents) {
      this.events = this.events.slice(0, this.maxEvents)
    }

    // Update performance metrics
    this.updatePerformanceMetrics(event)

    // Schedule save (debounced)
    this.scheduleSave()

    // Log to console in development
    if (process.env.NODE_ENV === "development") {
      console.log(`[TASK TRACKER] ${event.type.toUpperCase()}: ${event.action}`, event.details)
    }
  }

  private updatePerformanceMetrics(event: Omit<TaskEvent, "id" | "timestamp">) {
    this.performanceMetrics.totalRequests++

    if (event.metadata?.responseTime) {
      this.performanceMetrics.responseTimes.push(event.metadata.responseTime)
      // Keep only last 100 response times
      if (this.performanceMetrics.responseTimes.length > 100) {
        this.performanceMetrics.responseTimes = this.performanceMetrics.responseTimes.slice(-100)
      }
    }

    if (event.type === "system" && event.action === "error") {
      this.performanceMetrics.errors++
    }
  }

  private scheduleSave() {
    if (this.saveTimeout) {
      clearTimeout(this.saveTimeout)
    }

    this.saveTimeout = setTimeout(() => {
      this.saveTasklist()
    }, 1000) // Save after 1 second of inactivity
  }

  private async saveTasklist() {
    try {
      const summary = this.generateSummary()
      const tasklistData = {
        lastUpdated: new Date().toISOString(),
        summary,
        events: this.events.slice(0, 1000), // Save only recent 1000 events
        metadata: {
          version: "1.0.0",
          totalEventsTracked: this.events.length,
          systemInfo: {
            nodeVersion: process.version,
            platform: process.platform,
            uptime: process.uptime(),
          },
        },
      }

      await writeFile(this.tasklistPath, JSON.stringify(tasklistData, null, 2))

      // Also save daily log
      const today = new Date().toISOString().split("T")[0]
      const dailyLogPath = join(this.logPath, `tasks-${today}.json`)
      await writeFile(
        dailyLogPath,
        JSON.stringify(
          {
            date: today,
            events: this.events.filter((e) => e.timestamp.startsWith(today)),
          },
          null,
          2,
        ),
      )
    } catch (error) {
      console.error("Failed to save tasklist:", error)
    }
  }

  private generateSummary(): TaskSummary {
    const now = new Date()
    const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000)

    const recentEvents = this.events.filter((e) => new Date(e.timestamp) > oneHourAgo)
    const eventsByType = this.events.reduce(
      (acc, event) => {
        acc[event.type] = (acc[event.type] || 0) + 1
        return acc
      },
      {} as Record<string, number>,
    )

    const activeUsers = [...new Set(recentEvents.filter((e) => e.userId).map((e) => e.userId!))]

    const averageResponseTime =
      this.performanceMetrics.responseTimes.length > 0
        ? this.performanceMetrics.responseTimes.reduce((a, b) => a + b, 0) /
          this.performanceMetrics.responseTimes.length
        : 0

    const errorRate =
      this.performanceMetrics.totalRequests > 0
        ? (this.performanceMetrics.errors / this.performanceMetrics.totalRequests) * 100
        : 0

    return {
      totalEvents: this.events.length,
      eventsByType,
      recentActivity: recentEvents.slice(0, 50),
      activeUsers,
      systemHealth: {
        status: errorRate > 10 ? "error" : errorRate > 5 ? "warning" : "healthy",
        lastUpdate: now.toISOString(),
        performance: {
          averageResponseTime,
          errorRate,
        },
      },
    }
  }

  private startPeriodicSave() {
    // Save every 5 minutes
    setInterval(
      () => {
        this.saveTasklist()
      },
      5 * 60 * 1000,
    )
  }

  async getEvents(filter?: {
    type?: string
    action?: string
    userId?: string
    since?: string
    limit?: number
  }): Promise<TaskEvent[]> {
    let filteredEvents = this.events

    if (filter) {
      if (filter.type) {
        filteredEvents = filteredEvents.filter((e) => e.type === filter.type)
      }
      if (filter.action) {
        filteredEvents = filteredEvents.filter((e) => e.action === filter.action)
      }
      if (filter.userId) {
        filteredEvents = filteredEvents.filter((e) => e.userId === filter.userId)
      }
      if (filter.since) {
        const sinceDate = new Date(filter.since)
        filteredEvents = filteredEvents.filter((e) => new Date(e.timestamp) > sinceDate)
      }
    }

    return filteredEvents.slice(0, filter?.limit || 100)
  }

  async getSummary(): Promise<TaskSummary> {
    return this.generateSummary()
  }

  async clearOldEvents(olderThanDays = 30): Promise<number> {
    const cutoffDate = new Date()
    cutoffDate.setDate(cutoffDate.getDate() - olderThanDays)

    const initialCount = this.events.length
    this.events = this.events.filter((e) => new Date(e.timestamp) > cutoffDate)
    const removedCount = initialCount - this.events.length

    if (removedCount > 0) {
      await this.track({
        type: "system",
        action: "cleanup",
        details: {
          message: "Cleaned up old events",
          removedCount,
          cutoffDate: cutoffDate.toISOString(),
        },
      })
    }

    return removedCount
  }
}

// Singleton instance
export const taskTracker = new TaskTracker()

// Utility functions for common tracking scenarios
export const trackChatInteraction = async (details: {
  userId?: string
  sessionId?: string
  message: string
  response?: string
  model?: string
  responseTime?: number
}) => {
  await taskTracker.track({
    type: "chat",
    action: "interaction",
    details,
    userId: details.userId,
    sessionId: details.sessionId,
    metadata: {
      responseTime: details.responseTime,
    },
  })
}

export const trackFileOperation = async (details: {
  operation: "create" | "update" | "delete" | "read"
  fileName: string
  filePath: string
  fileSize?: number
  userId?: string
}) => {
  await taskTracker.track({
    type: "file",
    action: details.operation,
    details: {
      fileName: details.fileName,
      filePath: details.filePath,
      fileSize: details.fileSize,
    },
    userId: details.userId,
  })
}

export const trackWorkflowExecution = async (details: {
  workflowId: string
  workflowType: string
  status: "started" | "completed" | "failed"
  duration?: number
  userId?: string
  results?: any
}) => {
  await taskTracker.track({
    type: "workflow",
    action: details.status,
    details: {
      workflowId: details.workflowId,
      workflowType: details.workflowType,
      duration: details.duration,
      results: details.results,
    },
    userId: details.userId,
  })
}

export const trackDocumentAnalysis = async (details: {
  documentId: string
  documentTitle: string
  analysisType: string
  status: "started" | "completed" | "failed"
  results?: any
  userId?: string
}) => {
  await taskTracker.track({
    type: "document",
    action: `analysis_${details.status}`,
    details: {
      documentId: details.documentId,
      documentTitle: details.documentTitle,
      analysisType: details.analysisType,
      results: details.results,
    },
    userId: details.userId,
  })
}

export const trackComplianceCheck = async (details: {
  ruleId: string
  ruleName: string
  status: "compliant" | "at_risk" | "non_compliant"
  organizationId?: string
  userId?: string
}) => {
  await taskTracker.track({
    type: "compliance",
    action: "check",
    details: {
      ruleId: details.ruleId,
      ruleName: details.ruleName,
      status: details.status,
      organizationId: details.organizationId,
    },
    userId: details.userId,
  })
}

export const trackUserAction = async (details: {
  action: string
  page?: string
  feature?: string
  userId?: string
  sessionId?: string
  metadata?: Record<string, any>
}) => {
  await taskTracker.track({
    type: "user",
    action: details.action,
    details: {
      page: details.page,
      feature: details.feature,
      ...details.metadata,
    },
    userId: details.userId,
    sessionId: details.sessionId,
  })
}

export const trackSystemEvent = async (details: {
  event: string
  level: "info" | "warning" | "error"
  message: string
  error?: any
  metadata?: Record<string, any>
}) => {
  await taskTracker.track({
    type: "system",
    action: details.event,
    details: {
      level: details.level,
      message: details.message,
      error: details.error?.message || details.error,
      stack: details.error?.stack,
      ...details.metadata,
    },
  })
}
