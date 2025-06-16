import { NextResponse } from "next/server"
import { sql } from "@/lib/database"

export async function POST(request: Request) {
  try {
    const { reportType, organizationId, dateRange, filters = {} } = await request.json()

    console.log("🔄 Generating report:", reportType)

    if (!sql) {
      throw new Error("Database connection not available")
    }

    let reportData: any = {}
    let reportTitle = ""
    let reportDescription = ""

    switch (reportType) {
      case "compliance_summary":
        reportTitle = "Compliance Summary Report"
        reportDescription = "Comprehensive overview of compliance status across all regulations"

        const complianceData = await sql`
          SELECT 
            cr.title,
            cr.category,
            cr.risk_level,
            cr.description,
            cm.status,
            cm.last_checked,
            cm.next_check_due,
            o.name as organization_name
          FROM compliance_rules cr
          LEFT JOIN compliance_monitoring cm ON cr.id = cm.rule_id
          LEFT JOIN organizations o ON cm.organization_id = o.id
          WHERE cr.is_active = true
          ${organizationId ? sql`AND cm.organization_id = ${organizationId}` : sql``}
          ${dateRange?.start ? sql`AND cm.last_checked >= ${dateRange.start}` : sql``}
          ${dateRange?.end ? sql`AND cm.last_checked <= ${dateRange.end}` : sql``}
          ORDER BY cr.risk_level DESC, cr.created_at DESC
        `

        reportData = {
          summary: {
            totalRules: complianceData.length,
            compliant: complianceData.filter((r: any) => r.status === "compliant").length,
            atRisk: complianceData.filter((r: any) => r.status === "at_risk").length,
            nonCompliant: complianceData.filter((r: any) => r.status === "non_compliant").length,
          },
          details: complianceData,
          recommendations: generateComplianceRecommendations(complianceData),
        }
        break

      case "document_analysis":
        reportTitle = "Document Analysis Report"
        reportDescription = "Analysis of document processing and risk assessment"

        const documentsData = await sql`
          SELECT 
            d.title,
            d.type,
            d.status,
            d.created_at,
            d.file_size,
            o.name as organization_name,
            COUNT(cc.id) as clause_count,
            COUNT(CASE WHEN cc.risk_level = 'high' THEN 1 END) as high_risk_clauses,
            COUNT(CASE WHEN cc.risk_level = 'medium' THEN 1 END) as medium_risk_clauses,
            COUNT(CASE WHEN cc.risk_level = 'low' THEN 1 END) as low_risk_clauses
          FROM documents d
          LEFT JOIN contract_clauses cc ON d.id = cc.document_id
          LEFT JOIN organizations o ON d.organization_id = o.id
          ${organizationId ? sql`WHERE d.organization_id = ${organizationId}` : sql``}
          ${dateRange?.start ? sql`AND d.created_at >= ${dateRange.start}` : sql``}
          ${dateRange?.end ? sql`AND d.created_at <= ${dateRange.end}` : sql``}
          GROUP BY d.id, d.title, d.type, d.status, d.created_at, d.file_size, o.name
          ORDER BY d.created_at DESC
        `

        reportData = {
          summary: {
            totalDocuments: documentsData.length,
            analyzed: documentsData.filter((d: any) => d.status === "completed").length,
            processing: documentsData.filter((d: any) => d.status === "processing").length,
            pending: documentsData.filter((d: any) => d.status === "pending").length,
            totalClauses: documentsData.reduce((sum: number, d: any) => sum + (d.clause_count || 0), 0),
            highRiskClauses: documentsData.reduce((sum: number, d: any) => sum + (d.high_risk_clauses || 0), 0),
          },
          details: documentsData,
          riskAnalysis: generateRiskAnalysis(documentsData),
        }
        break

      case "regulatory_updates":
        reportTitle = "Regulatory Updates Report"
        reportDescription = "Recent regulatory changes and their impact"

        const regulatoryData = await sql`
          SELECT * FROM regulatory_updates
          ${dateRange?.start ? sql`WHERE effective_date >= ${dateRange.start}` : sql``}
          ${dateRange?.end ? sql`AND effective_date <= ${dateRange.end}` : sql``}
          ORDER BY effective_date DESC, created_at DESC
          LIMIT 50
        `

        reportData = {
          summary: {
            totalUpdates: regulatoryData.length,
            byImpact: {
              high: regulatoryData.filter((r: any) => r.impact_level === "high").length,
              medium: regulatoryData.filter((r: any) => r.impact_level === "medium").length,
              low: regulatoryData.filter((r: any) => r.impact_level === "low").length,
            },
            byJurisdiction: groupBy(regulatoryData, "jurisdiction"),
          },
          details: regulatoryData,
          actionItems: generateRegulatoryActionItems(regulatoryData),
        }
        break

      default:
        return NextResponse.json({ success: false, error: "Invalid report type" }, { status: 400 })
    }

    // Save report to database
    const [savedReport] = await sql`
      INSERT INTO compliance_reports (
        title, description, type, data, 
        organization_id, generated_by, filters
      ) VALUES (
        ${reportTitle}, ${reportDescription}, ${reportType},
        ${JSON.stringify(reportData)}, ${organizationId}, 
        ${"system"}, ${JSON.stringify(filters)}
      )
      RETURNING *
    `

    console.log("✅ Report generated successfully:", savedReport.id)

    return NextResponse.json({
      success: true,
      data: {
        report: savedReport,
        content: reportData,
        metadata: {
          generatedAt: new Date().toISOString(),
          reportType,
          organizationId,
          filters,
        },
      },
      message: "Report generated successfully",
    })
  } catch (error) {
    console.error("❌ Error generating report:", error)

    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : "Failed to generate report",
      },
      { status: 500 },
    )
  }
}

// Helper functions
function generateComplianceRecommendations(data: any[]) {
  const recommendations = []
  const nonCompliant = data.filter((r) => r.status === "non_compliant")
  const atRisk = data.filter((r) => r.status === "at_risk")

  if (nonCompliant.length > 0) {
    recommendations.push({
      priority: "high",
      title: "Address Non-Compliant Items",
      description: `${nonCompliant.length} compliance rules require immediate attention`,
      action: "Review and remediate non-compliant items within 30 days",
    })
  }

  if (atRisk.length > 0) {
    recommendations.push({
      priority: "medium",
      title: "Monitor At-Risk Items",
      description: `${atRisk.length} compliance rules are at risk`,
      action: "Implement monitoring and preventive measures",
    })
  }

  return recommendations
}

function generateRiskAnalysis(data: any[]) {
  const totalHighRisk = data.reduce((sum, d) => sum + (d.high_risk_clauses || 0), 0)
  const totalMediumRisk = data.reduce((sum, d) => sum + (d.medium_risk_clauses || 0), 0)

  return {
    overallRiskScore: totalHighRisk > 10 ? "high" : totalHighRisk > 5 ? "medium" : "low",
    riskDistribution: {
      high: totalHighRisk,
      medium: totalMediumRisk,
      low: data.reduce((sum, d) => sum + (d.low_risk_clauses || 0), 0),
    },
    recommendations:
      totalHighRisk > 0
        ? ["Review high-risk clauses immediately", "Consider legal consultation"]
        : ["Continue monitoring"],
  }
}

function generateRegulatoryActionItems(data: any[]) {
  return data
    .filter((r: any) => r.impact_level === "high")
    .map((r: any) => ({
      title: `Implement ${r.title}`,
      description: r.summary,
      dueDate: r.effective_date,
      priority: "high",
    }))
}

function groupBy(array: any[], key: string) {
  return array.reduce((groups, item) => {
    const group = item[key] || "unknown"
    groups[group] = (groups[group] || 0) + 1
    return groups
  }, {})
}
