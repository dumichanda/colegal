import { type NextRequest, NextResponse } from "next/server"
import { sql } from "@/lib/database"

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const type = searchParams.get("type") || "compliance"
    const organizationId = searchParams.get("organizationId")
    const format = searchParams.get("format") || "json"

    if (!sql) {
      return NextResponse.json({ success: false, error: "Database connection not available" }, { status: 503 })
    }

    let reportData: any = {}

    switch (type) {
      case "compliance":
        const complianceData = await sql`
          SELECT 
            cr.title,
            cr.category,
            cr.risk_level,
            cm.status,
            cm.last_checked,
            cm.next_check_due,
            o.name as organization_name
          FROM compliance_rules cr
          LEFT JOIN compliance_monitoring cm ON cr.id = cm.rule_id
          LEFT JOIN organizations o ON cm.organization_id = o.id
          WHERE cr.is_active = true
          ${organizationId ? sql`AND cm.organization_id = ${organizationId}` : sql``}
          ORDER BY cr.risk_level DESC, cr.created_at DESC
        `

        reportData = {
          title: "Compliance Report",
          generatedAt: new Date().toISOString(),
          data: complianceData,
          summary: {
            totalRules: complianceData.length,
            compliant: complianceData.filter((r: any) => r.status === "compliant").length,
            atRisk: complianceData.filter((r: any) => r.status === "at_risk").length,
            nonCompliant: complianceData.filter((r: any) => r.status === "non_compliant").length,
          },
        }
        break

      case "documents":
        const documentsData = await sql`
          SELECT 
            d.title,
            d.type,
            d.status,
            d.created_at,
            o.name as organization_name,
            COUNT(cc.id) as clause_count,
            COUNT(CASE WHEN cc.risk_level = 'high' THEN 1 END) as high_risk_clauses
          FROM documents d
          LEFT JOIN contract_clauses cc ON d.id = cc.document_id
          LEFT JOIN organizations o ON d.organization_id = o.id
          ${organizationId ? sql`WHERE d.organization_id = ${organizationId}` : sql``}
          GROUP BY d.id, d.title, d.type, d.status, d.created_at, o.name
          ORDER BY d.created_at DESC
        `

        reportData = {
          title: "Document Analysis Report",
          generatedAt: new Date().toISOString(),
          data: documentsData,
          summary: {
            totalDocuments: documentsData.length,
            analyzed: documentsData.filter((d: any) => d.status === "completed").length,
            processing: documentsData.filter((d: any) => d.status === "processing").length,
            pending: documentsData.filter((d: any) => d.status === "pending").length,
          },
        }
        break

      default:
        return NextResponse.json({ success: false, error: "Invalid report type" }, { status: 400 })
    }

    if (format === "csv") {
      // Convert to CSV format
      const csv = convertToCSV(reportData.data)
      return new NextResponse(csv, {
        headers: {
          "Content-Type": "text/csv",
          "Content-Disposition": `attachment; filename="${type}-report-${Date.now()}.csv"`,
        },
      })
    }

    return NextResponse.json({
      success: true,
      data: reportData,
    })
  } catch (error) {
    console.error("Error generating report:", error)
    return NextResponse.json({ success: false, error: "Failed to generate report" }, { status: 500 })
  }
}

function convertToCSV(data: any[]): string {
  if (!data.length) return ""

  const headers = Object.keys(data[0])
  const csvContent = [
    headers.join(","),
    ...data.map((row) => headers.map((header) => JSON.stringify(row[header] || "")).join(",")),
  ].join("\n")

  return csvContent
}
