import { type NextRequest, NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

export async function GET(request: NextRequest) {
  try {
    // Get compliance alerts from compliance_monitoring table
    // where status indicates issues or upcoming deadlines
    const alerts = await sql`
      SELECT 
        cm.id,
        cr.title,
        cr.description,
        CASE 
          WHEN cm.status = 'non_compliant' THEN 'Critical'
          WHEN cm.status = 'at_risk' THEN 'High'
          WHEN cm.next_check_due < NOW() + INTERVAL '7 days' THEN 'Medium'
          ELSE 'Low'
        END as priority,
        cm.next_check_due as due_date,
        'compliance' as type,
        cm.status,
        cr.regulation_source,
        cr.jurisdiction
      FROM compliance_monitoring cm
      JOIN compliance_rules cr ON cm.rule_id = cr.id
      WHERE cm.status IN ('non_compliant', 'at_risk') 
         OR cm.next_check_due < NOW() + INTERVAL '30 days'
      ORDER BY 
        CASE 
          WHEN cm.status = 'non_compliant' THEN 1
          WHEN cm.status = 'at_risk' THEN 2
          WHEN cm.next_check_due < NOW() + INTERVAL '7 days' THEN 3
          ELSE 4
        END,
        cm.next_check_due ASC
      LIMIT 10
    `

    return NextResponse.json(alerts)
  } catch (error) {
    console.error("Database error:", error)
    return NextResponse.json({ error: "Failed to fetch compliance alerts" }, { status: 500 })
  }
}
