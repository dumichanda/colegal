import { NextResponse } from "next/server"
import { sql } from "@/lib/database"

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url)
    const organizationId = searchParams.get("organization_id")

    console.log("🔄 Fetching compliance overview from database...")

    if (!sql) {
      throw new Error("Database connection not available")
    }

    // Get compliance statistics
    const complianceStats = await sql`
      SELECT 
        COUNT(*) as total_items,
        COUNT(CASE WHEN status = 'compliant' THEN 1 END) as compliant_count,
        COUNT(CASE WHEN status = 'non_compliant' THEN 1 END) as non_compliant_count,
        COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_count,
        COUNT(CASE WHEN priority = 'Critical' THEN 1 END) as critical_count,
        COUNT(CASE WHEN priority = 'High' THEN 1 END) as high_count
      FROM compliance_alerts
      WHERE (${organizationId}::text IS NULL OR organization_id = ${organizationId})
    `

    // Get compliance by category
    const complianceByCategory = await sql`
      SELECT 
        type as category,
        COUNT(*) as total,
        COUNT(CASE WHEN status = 'active' THEN 1 END) as active,
        COUNT(CASE WHEN priority = 'Critical' THEN 1 END) as critical
      FROM compliance_alerts
      WHERE (${organizationId}::text IS NULL OR organization_id = ${organizationId})
      GROUP BY type
      ORDER BY total DESC
    `

    // Get recent compliance activities
    const recentActivities = await sql`
      SELECT 
        id,
        title,
        type,
        priority,
        status,
        created_at,
        due_date
      FROM compliance_alerts
      WHERE (${organizationId}::text IS NULL OR organization_id = ${organizationId})
      ORDER BY created_at DESC
      LIMIT 10
    `

    const stats = complianceStats[0]
    const complianceRate = stats.total_items > 0 ? Math.round((stats.compliant_count / stats.total_items) * 100) : 0

    console.log(`✅ Compliance overview: ${stats.total_items} items, ${complianceRate}% compliant`)

    return NextResponse.json({
      success: true,
      data: {
        overview: {
          totalItems: Number(stats.total_items),
          compliantCount: Number(stats.compliant_count),
          nonCompliantCount: Number(stats.non_compliant_count),
          pendingCount: Number(stats.pending_count),
          criticalCount: Number(stats.critical_count),
          highCount: Number(stats.high_count),
          complianceRate,
        },
        categories: complianceByCategory.map((cat) => ({
          category: cat.category,
          total: Number(cat.total),
          active: Number(cat.active),
          critical: Number(cat.critical),
        })),
        recentActivities: recentActivities.map((activity) => ({
          id: activity.id,
          title: activity.title,
          type: activity.type,
          priority: activity.priority,
          status: activity.status,
          createdAt: activity.created_at,
          dueDate: activity.due_date,
        })),
      },
      timestamp: new Date().toISOString(),
    })
  } catch (error) {
    console.error("❌ Error fetching compliance overview:", error)

    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : "Failed to fetch compliance overview",
        data: null,
      },
      { status: 500 },
    )
  }
}
