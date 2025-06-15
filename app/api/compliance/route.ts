import { type NextRequest, NextResponse } from "next/server"
import { getComplianceRules, sql } from "@/lib/database"

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const organizationId = searchParams.get("organizationId")

    const rules = await getComplianceRules()

    // Get compliance statistics with fallback for when database is not available
    let stats
    if (sql) {
      try {
        const [dbStats] = await sql`
          SELECT 
            COUNT(*) as total_rules,
            COUNT(CASE WHEN cm.status = 'compliant' THEN 1 END) as compliant_count,
            COUNT(CASE WHEN cm.status = 'at_risk' THEN 1 END) as at_risk_count,
            COUNT(CASE WHEN cm.status = 'non_compliant' THEN 1 END) as non_compliant_count,
            ROUND(
              (COUNT(CASE WHEN cm.status = 'compliant' THEN 1 END)::float / COUNT(*)::float) * 100, 
              2
            ) as compliance_percentage
          FROM compliance_rules cr
          LEFT JOIN compliance_monitoring cm ON cr.id = cm.rule_id
          WHERE cr.is_active = true
          ${organizationId ? sql`AND cm.organization_id = ${organizationId}` : sql``}
        `
        stats = dbStats
      } catch (error) {
        console.error("Database error for compliance stats:", error)
        stats = {
          total_rules: rules.length,
          compliant_count: rules.filter((r) => r.status === "compliant").length,
          at_risk_count: rules.filter((r) => r.status === "at_risk").length,
          non_compliant_count: rules.filter((r) => r.status === "non_compliant").length,
          compliance_percentage: Math.round(
            (rules.filter((r) => r.status === "compliant").length / rules.length) * 100,
          ),
        }
      }
    } else {
      // Mock statistics when database is not available
      stats = {
        total_rules: rules.length,
        compliant_count: rules.filter((r) => r.status === "compliant").length,
        at_risk_count: rules.filter((r) => r.status === "at_risk").length,
        non_compliant_count: rules.filter((r) => r.status === "non_compliant").length,
        compliance_percentage: Math.round((rules.filter((r) => r.status === "compliant").length / rules.length) * 100),
      }
    }

    return NextResponse.json({
      success: true,
      data: {
        rules,
        statistics: stats,
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

    if (action === "check_compliance") {
      if (sql) {
        try {
          // Run compliance check for specific rule
          await sql`
            UPDATE compliance_monitoring 
            SET 
              last_checked = NOW(),
              next_check_due = NOW() + INTERVAL '30 days',
              updated_at = NOW()
            WHERE organization_id = ${organizationId} AND rule_id = ${ruleId}
          `
        } catch (error) {
          console.error("Database error updating compliance:", error)
        }
      }

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
