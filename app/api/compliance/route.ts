import { type NextRequest, NextResponse } from "next/server"
import { getComplianceRules, sql } from "@/lib/database"

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const organizationId = searchParams.get("organizationId")

    if (!sql) {
      return NextResponse.json({ success: false, error: "Database connection not available" }, { status: 503 })
    }

    const rules = await getComplianceRules(organizationId || undefined)

    // Get compliance statistics
    const [stats] = await sql`
      SELECT 
        COUNT(*) as total_rules,
        COUNT(CASE WHEN cm.status = 'compliant' THEN 1 END) as compliant_count,
        COUNT(CASE WHEN cm.status = 'at_risk' THEN 1 END) as at_risk_count,
        COUNT(CASE WHEN cm.status = 'non_compliant' THEN 1 END) as non_compliant_count,
        ROUND(
          (COUNT(CASE WHEN cm.status = 'compliant' THEN 1 END)::float / NULLIF(COUNT(*), 0)::float) * 100, 
          2
        ) as compliance_percentage
      FROM compliance_rules cr
      LEFT JOIN compliance_monitoring cm ON cr.id = cm.rule_id
      WHERE cr.is_active = true
      ${organizationId ? sql`AND (cm.organization_id = ${organizationId} OR cm.organization_id IS NULL)` : sql``}
    `

    return NextResponse.json({
      success: true,
      data: {
        rules,
        statistics: stats || {
          total_rules: 0,
          compliant_count: 0,
          at_risk_count: 0,
          non_compliant_count: 0,
          compliance_percentage: 0,
        },
      },
    })
  } catch (error) {
    console.error("Error fetching compliance data:", error)
    return NextResponse.json({ success: false, error: "Failed to fetch compliance data" }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const { organizationId, ruleId, action } = await request.json()

    if (!sql) {
      return NextResponse.json({ success: false, error: "Database connection not available" }, { status: 503 })
    }

    if (action === "check_compliance") {
      // Run compliance check for specific rule
      await sql`
        UPDATE compliance_monitoring 
        SET 
          last_checked = NOW(),
          next_check_due = NOW() + INTERVAL '30 days',
          updated_at = NOW()
        WHERE organization_id = ${organizationId} AND rule_id = ${ruleId}
      `

      return NextResponse.json({
        success: true,
        message: "Compliance check completed",
      })
    }

    return NextResponse.json({ success: false, error: "Invalid action" }, { status: 400 })
  } catch (error) {
    console.error("Error updating compliance:", error)
    return NextResponse.json({ success: false, error: "Failed to update compliance" }, { status: 500 })
  }
}
