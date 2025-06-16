import { type NextRequest, NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

export async function GET(request: NextRequest) {
  try {
    const complianceOverview = await sql`
      SELECT 
        cr.category,
        ROUND(AVG(
          CASE 
            WHEN cm.status = 'compliant' THEN 100
            WHEN cm.status = 'at_risk' THEN 60
            WHEN cm.status = 'non_compliant' THEN 20
            ELSE 50
          END
        ), 0) as score,
        CASE 
          WHEN AVG(
            CASE 
              WHEN cm.status = 'compliant' THEN 100
              WHEN cm.status = 'at_risk' THEN 60
              WHEN cm.status = 'non_compliant' THEN 20
              ELSE 50
            END
          ) >= 80 THEN 'Compliant'
          WHEN AVG(
            CASE 
              WHEN cm.status = 'compliant' THEN 100
              WHEN cm.status = 'at_risk' THEN 60
              WHEN cm.status = 'non_compliant' THEN 20
              ELSE 50
            END
          ) >= 60 THEN 'At Risk'
          ELSE 'Non-Compliant'
        END as status,
        COUNT(cr.id) as rules_count,
        COUNT(CASE WHEN cm.status IN ('at_risk', 'non_compliant') THEN 1 END) as issues_count
      FROM compliance_rules cr
      LEFT JOIN compliance_monitoring cm ON cr.id = cm.rule_id
      WHERE cr.is_active = true
      GROUP BY cr.category
      ORDER BY score DESC
    `

    return NextResponse.json(complianceOverview)
  } catch (error) {
    console.error("Database error:", error)
    return NextResponse.json({ error: "Failed to fetch compliance overview" }, { status: 500 })
  }
}
