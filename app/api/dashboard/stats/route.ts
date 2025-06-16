import { type NextRequest, NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

export async function GET(request: NextRequest) {
  try {
    // Get document statistics
    const [documentStats] = await sql`
      SELECT 
        COUNT(*) as total_documents,
        COUNT(CASE WHEN status = 'completed' THEN 1 END) as documents_analyzed,
        COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_documents
      FROM documents
    `

    // Get compliance score - simplified calculation with proper casting
    const complianceResult = await sql`
      SELECT 
        CASE 
          WHEN COUNT(*) = 0 THEN 85
          ELSE CAST(
            (COUNT(CASE WHEN status = 'compliant' THEN 1 END) * 100.0 / COUNT(*)) 
            AS INTEGER
          )
        END as compliance_score
      FROM compliance_monitoring
    `
    const complianceScore = complianceResult[0]?.compliance_score || 85

    // Get recent activity count (documents uploaded in last 7 days)
    const [activityStats] = await sql`
      SELECT COUNT(*) as recent_activity
      FROM documents 
      WHERE created_at >= NOW() - INTERVAL '7 days'
    `

    // Get pending reviews count
    const [reviewStats] = await sql`
      SELECT COUNT(*) as pending_reviews
      FROM documents 
      WHERE status IN ('pending', 'processing')
    `

    // Get high priority items count from compliance monitoring
    const [alertStats] = await sql`
      SELECT COUNT(*) as high_priority_alerts
      FROM compliance_monitoring 
      WHERE status IN ('non_compliant', 'at_risk')
    `

    const stats = {
      totalDocuments: Number.parseInt(documentStats?.total_documents || "0"),
      documentsAnalyzed: Number.parseInt(documentStats?.documents_analyzed || "0"),
      pendingDocuments: Number.parseInt(documentStats?.pending_documents || "0"),
      complianceScore: Number.parseInt(complianceScore?.toString() || "85"),
      recentActivity: Number.parseInt(activityStats?.recent_activity || "0"),
      pendingReviews: Number.parseInt(reviewStats?.pending_reviews || "0"),
      highPriorityAlerts: Number.parseInt(alertStats?.high_priority_alerts || "0"),
    }

    return NextResponse.json(stats)
  } catch (error) {
    console.error("Database error:", error)

    // Return fallback data in case of database error
    const fallbackStats = {
      totalDocuments: 0,
      documentsAnalyzed: 0,
      pendingDocuments: 0,
      complianceScore: 85,
      recentActivity: 0,
      pendingReviews: 0,
      highPriorityAlerts: 0,
    }

    return NextResponse.json(fallbackStats)
  }
}
