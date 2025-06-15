import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { FileText, Download, Share } from "lucide-react"

export function ComplianceReports() {
  const reports = [
    {
      id: 1,
      title: "Q4 2024 Compliance Summary",
      type: "Quarterly Report",
      generatedAt: "Dec 1, 2024",
      status: "Ready",
    },
    {
      id: 2,
      title: "GDPR Compliance Assessment",
      type: "Risk Assessment",
      generatedAt: "Nov 28, 2024",
      status: "Ready",
    },
    {
      id: 3,
      title: "SOX Controls Testing",
      type: "Audit Report",
      generatedAt: "Nov 25, 2024",
      status: "Ready",
    },
  ]

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle className="text-lg font-semibold">Recent Reports</CardTitle>
        <Button variant="outline" size="sm">
          Generate Report
        </Button>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {reports.map((report) => (
            <div key={report.id} className="p-3 border rounded-lg">
              <div className="flex items-start space-x-3">
                <div className="p-2 bg-blue-100 rounded-lg">
                  <FileText className="w-4 h-4 text-blue-600" />
                </div>
                <div className="flex-1 min-w-0">
                  <h4 className="font-medium text-gray-900 text-sm mb-1">{report.title}</h4>
                  <p className="text-xs text-gray-600 mb-2">
                    {report.type} • {report.generatedAt}
                  </p>
                  <div className="flex space-x-2">
                    <Button variant="ghost" size="sm" className="text-xs p-1 h-6">
                      <Download className="w-3 h-3 mr-1" />
                      Download
                    </Button>
                    <Button variant="ghost" size="sm" className="text-xs p-1 h-6">
                      <Share className="w-3 h-3 mr-1" />
                      Share
                    </Button>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  )
}
