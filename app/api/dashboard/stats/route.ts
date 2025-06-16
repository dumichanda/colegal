import { NextResponse } from "next/server"
import { sql } from "@/lib/database"

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url)
    const organizationId = searchParams.get("organization_id")

    console.log("🔄 Fetching dashboard statistics from database...")

    if (!sql) {
      throw new Error("Database connection not available")
    }

    // Get document statistics
    const documentStats = await sql`
      SELECT 
        COUNT(*) as total_documents,
        COUNT(CASE WHEN status = 'active' THEN 1 END) as active_documents,
        COUNT(CASE WHEN created_at >= NOW() - INTERVAL '30 days' THEN 1 END) as recent_documents
      FROM documents
      WHERE (${organizationId}::text IS NULL OR organization_id = ${organizationId})
    `

    // Get compliance statistics
    const complianceStats = await sql`
      SELECT 
        COUNT(*) as total_alerts,
        COUNT(CASE WHEN status = 'active' THEN 1 END) as active_alerts,
        COUNT(CASE WHEN priority = 'Critical' THEN 1 END) as critical_alerts,
        COUNT(CASE WHEN due_date < NOW() THEN 1 END) as overdue_alerts
      FROM compliance_alerts
      WHERE (${organizationId}::text IS NULL OR organization_id = ${organizationId})
    `

    // Get task statistics
    const taskStats = await sql`
      SELECT 
        COUNT(*) as total_tasks,
        COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_tasks,
        COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_tasks,
        COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed_tasks
      FROM tasks
      WHERE (${organizationId}::text IS NULL OR organization_id = ${organizationId})
    `

    // Get recent activity
    const recentActivity = await sql`
      SELECT 
        'document' as type,
        title as name,
        created_at,
        status
      FROM documents
      WHERE (${organizationId}::text IS NULL OR organization_id = ${organizationId})
      UNION ALL
      SELECT 
        'alert' as type,
        title as name,
        created_at,
        status
      FROM compliance_alerts
      WHERE (${organizationId}::text IS NULL OR organization_id = ${organizationId})
      ORDER BY created_at DESC
      LIMIT 10
    `

    const docStats = documentStats[0]
    const compStats = complianceStats[0]
    const tskStats = taskStats[0]

    // Calculate derived metrics
    const complianceRate =
      compStats.total_alerts > 0
        ? Math.round(((compStats.total_alerts - compStats.active_alerts) / compStats.total_alerts) * 100)
        : 100

    const taskCompletionRate =
      tskStats.total_tasks > 0 ? Math.round((tskStats.completed_tasks / tskStats.total_tasks) * 100) : 0

    console.log(`✅ Dashboard stats: ${docStats.total_documents} docs, ${compStats.total_alerts} alerts`)

    return NextResponse.json({
      success: true,
      data: {
        documents: {
          total: Number(docStats.total_documents),
          active: Number(docStats.active_documents),
          recent: Number(docStats.recent_documents),
        },
        compliance: {
          totalAlerts: Number(compStats.total_alerts),
          activeAlerts: Number(compStats.active_alerts),
          criticalAlerts: Number(compStats.critical_alerts),
          overdueAlerts: Number(compStats.overdue_alerts),
          complianceRate,
        },
        tasks: {
          total: Number(tskStats.total_tasks),
          pending: Number(tskStats.pending_tasks),
          completed: Number(tskStats.completed_tasks),
          failed: Number(tskStats.failed_tasks),
          completionRate: taskCompletionRate,
        },
        recentActivity: recentActivity.map((activity) => ({
          type: activity.type,
          name: activity.name,
          createdAt: activity.created_at,
          status: activity.status,
        })),
      },
      timestamp: new Date().toISOString(),
    })
  } catch (error) {
    console.error("❌ Error fetching dashboard statistics:", error)

    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : "Failed to fetch dashboard statistics",
        data: null,
      },
      { status: 500 },
    )
  }
}
