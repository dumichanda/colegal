"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { FileText, Eye, Download } from "lucide-react"
import { useState } from "react"

export function RecentDocuments() {
  const [documents, setDocuments] = useState([
    {
      id: 1,
      title: "Software License Agreement - TechCorp",
      type: "Contract",
      status: "Analyzed",
      riskLevel: "Medium",
      uploadedAt: "2 hours ago",
      clauses: 23,
    },
    {
      id: 2,
      title: "Employment Agreement - Senior Developer",
      type: "Contract",
      status: "Processing",
      riskLevel: "Low",
      uploadedAt: "4 hours ago",
      clauses: 18,
    },
    {
      id: 3,
      title: "GDPR Compliance Assessment Report",
      type: "Compliance",
      status: "Analyzed",
      riskLevel: "High",
      uploadedAt: "1 day ago",
      clauses: 45,
    },
  ])

  const handleView = (docId: number) => {
    // Navigate to document analysis page
    window.location.href = `/documents?selected=${docId}`
  }

  const handleDownload = (docId: number, title: string) => {
    // Simulate file download
    const element = document.createElement("a")
    const file = new Blob([`Document: ${title}\nContent would be here...`], { type: "text/plain" })
    element.href = URL.createObjectURL(file)
    element.download = `${title.replace(/[^a-z0-9]/gi, "_").toLowerCase()}.txt`
    document.body.appendChild(element)
    element.click()
    document.body.removeChild(element)
  }

  const handleViewAll = () => {
    window.location.href = "/documents"
  }

  return (
    <Card className="bg-slate-800 border-slate-700">
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-4">
        <CardTitle className="text-lg font-semibold text-white">Recent Documents</CardTitle>
        <Button
          variant="outline"
          size="sm"
          className="border-slate-600 text-slate-300 hover:bg-slate-700 flex-shrink-0"
          onClick={handleViewAll}
        >
          View All
        </Button>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {documents.map((doc) => (
            <div
              key={doc.id}
              className="flex items-center justify-between p-4 border border-slate-700 rounded-lg hover:bg-slate-700/50 transition-colors"
            >
              <div className="flex items-center space-x-4 min-w-0 flex-1">
                <div className="p-2 bg-blue-500/20 rounded-lg flex-shrink-0">
                  <FileText className="w-5 h-5 text-blue-400" />
                </div>
                <div className="flex-1 min-w-0">
                  <h4 className="text-sm font-medium text-white truncate">{doc.title}</h4>
                  <div className="flex items-center space-x-2 mt-1 flex-wrap">
                    <Badge variant="outline" className="text-xs border-slate-600 text-slate-300">
                      {doc.type}
                    </Badge>
                    <Badge variant="outline" className="text-xs border-slate-600 text-slate-300">
                      {doc.status}
                    </Badge>
                    <Badge
                      variant={doc.riskLevel === "High" ? "destructive" : "outline"}
                      className="text-xs border-slate-600 text-slate-300"
                    >
                      {doc.riskLevel} Risk
                    </Badge>
                  </div>
                  <p className="text-xs text-slate-400 mt-1 truncate">
                    {doc.clauses} clauses • {doc.uploadedAt}
                  </p>
                </div>
              </div>
              <div className="flex items-center space-x-2 flex-shrink-0">
                <Button
                  variant="ghost"
                  size="sm"
                  className="text-slate-400 hover:text-white"
                  onClick={() => handleView(doc.id)}
                  title="View Document"
                >
                  <Eye className="w-4 h-4" />
                </Button>
                <Button
                  variant="ghost"
                  size="sm"
                  className="text-slate-400 hover:text-white"
                  onClick={() => handleDownload(doc.id, doc.title)}
                  title="Download Document"
                >
                  <Download className="w-4 h-4" />
                </Button>
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  )
}
