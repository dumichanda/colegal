"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { FileText, Download, Share } from "lucide-react"

interface ComplianceReport {
  id: string
  title: string
  type: string
  generated_at: string
  status: string
  file_path?: string
}

export function ComplianceReports() {
  const [reports, setReports] = useState<ComplianceReport[]>([])
  const [loading, setLoading] = useState(true)
  const [generating, setGenerating] = useState(false)

  useEffect(() => {
    fetchReports()
  }, [])

  const fetchReports = async () => {
    try {
      console.log("🔄 Fetching compliance reports...")
      setLoading(true)
      const response = await fetch("/api/reports?type=compliance")
      if (!response.ok) throw new Error("Failed to fetch reports")
      const data = await response.json()
      console.log("✅ Compliance reports received:", data)
      setReports(data.success ? data.data.reports || [] : [])
    } catch (error) {
      console.error("❌ Error fetching reports:", error)
      setReports([])
    } finally {
      setLoading(false)
    }
  }

  const handleGenerateReport = async () => {
    try {
      console.log("🔄 Generating new compliance report...")
      setGenerating(true)
      const response = await fetch("/api/reports/generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ type: "compliance" }),
      })

      if (!response.ok) throw new Error("Failed to generate report")
      const data = await response.json()
      console.log("✅ Report generated:", data)

      // Refresh the reports list
      await fetchReports()
    } catch (error) {
      console.error("❌ Error generating report:", error)
    } finally {
      setGenerating(false)
    }
  }

  const handleDownload = async (reportId: string, title: string) => {
    try {
      console.log("🔄 Downloading report:", reportId)
      const response = await fetch(`/api/reports/${reportId}/download`)
      if (!response.ok) throw new Error("Failed to download report")

      const blob = await response.blob()
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement("a")
      a.href = url
      a.download = `${title}.pdf`
      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
      document.body.removeChild(a)
      console.log("✅ Report downloaded successfully")
    } catch (error) {
      console.error("❌ Error downloading report:", error)
    }
  }

  if (loading) {
    return (
      <Card className="bg-slate-800 border-slate-700">
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle className="text-lg font-semibold text-white">Recent Reports</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {[1, 2, 3].map((i) => (
              <div key={i} className="animate-pulse p-3 border border-slate-700 rounded-lg">
                <div className="h-4 bg-slate-700 rounded w-3/4 mb-2"></div>
                <div className="h-3 bg-slate-700 rounded w-1/2"></div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className="bg-slate-800 border-slate-700">
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle className="text-lg font-semibold text-white">Recent Reports</CardTitle>
        <Button
          variant="outline"
          size="sm"
          onClick={handleGenerateReport}
          disabled={generating}
          className="border-slate-600 text-slate-300 hover:bg-slate-700"
        >
          {generating ? "Generating..." : "Generate Report"}
        </Button>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {reports.length === 0 ? (
            <div className="text-center py-8 text-slate-400">
              <FileText className="w-12 h-12 mx-auto mb-2 opacity-50" />
              <p>No reports available</p>
              <p className="text-sm">Generate your first compliance report</p>
            </div>
          ) : (
            reports.map((report) => (
              <div
                key={report.id}
                className="p-3 border border-slate-700 rounded-lg hover:bg-slate-700/50 transition-colors"
              >
                <div className="flex items-start space-x-3">
                  <div className="p-2 bg-blue-500/20 rounded-lg">
                    <FileText className="w-4 h-4 text-blue-400" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <h4 className="font-medium text-white text-sm mb-1">{report.title}</h4>
                    <p className="text-xs text-slate-400 mb-2">
                      {report.type} • {new Date(report.generated_at).toLocaleDateString()}
                    </p>
                    <div className="flex space-x-2">
                      <Button
                        variant="ghost"
                        size="sm"
                        className="text-xs p-1 h-6 text-slate-300 hover:text-white"
                        onClick={() => handleDownload(report.id, report.title)}
                      >
                        <Download className="w-3 h-3 mr-1" />
                        Download
                      </Button>
                      <Button variant="ghost" size="sm" className="text-xs p-1 h-6 text-slate-300 hover:text-white">
                        <Share className="w-3 h-3 mr-1" />
                        Share
                      </Button>
                    </div>
                  </div>
                </div>
              </div>
            ))
          )}
        </div>
      </CardContent>
    </Card>
  )
}
