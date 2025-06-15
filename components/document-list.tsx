"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { FileText, Clock, CheckCircle, AlertTriangle } from "lucide-react"

interface DocumentListProps {
  selectedDocument: string | null
  onSelectDocument: (id: string) => void
}

export function DocumentList({ selectedDocument, onSelectDocument }: DocumentListProps) {
  const documents = [
    {
      id: "doc-1",
      title: "Software License Agreement - TechCorp",
      type: "Contract",
      status: "Analyzed",
      riskLevel: "Medium",
      uploadedAt: "2 hours ago",
      clauses: 23,
      pages: 15,
    },
    {
      id: "doc-2",
      title: "Employment Agreement - Senior Developer",
      type: "Contract",
      status: "Processing",
      riskLevel: "Low",
      uploadedAt: "4 hours ago",
      clauses: 18,
      pages: 8,
    },
    {
      id: "doc-3",
      title: "GDPR Compliance Assessment Report",
      type: "Compliance",
      status: "Analyzed",
      riskLevel: "High",
      uploadedAt: "1 day ago",
      clauses: 45,
      pages: 32,
    },
    {
      id: "doc-4",
      title: "Vendor Service Agreement - CloudProvider",
      type: "Contract",
      status: "Analyzed",
      riskLevel: "Medium",
      uploadedAt: "2 days ago",
      clauses: 31,
      pages: 22,
    },
    {
      id: "doc-5",
      title: "Data Processing Agreement - Analytics Co",
      type: "Agreement",
      status: "Analyzed",
      riskLevel: "High",
      uploadedAt: "3 days ago",
      clauses: 28,
      pages: 18,
    },
  ]

  const getRiskBadgeColor = (risk: string) => {
    switch (risk) {
      case "High":
        return "destructive"
      case "Medium":
        return "outline"
      case "Low":
        return "secondary"
      default:
        return "outline"
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "Analyzed":
        return CheckCircle
      case "Processing":
        return Clock
      case "Error":
        return AlertTriangle
      default:
        return Clock
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case "Analyzed":
        return "text-green-400"
      case "Processing":
        return "text-yellow-400"
      case "Error":
        return "text-red-400"
      default:
        return "text-slate-400"
    }
  }

  return (
    <Card className="h-fit bg-slate-800 border-slate-700">
      <CardHeader>
        <CardTitle className="text-lg font-semibold text-white">Documents</CardTitle>
      </CardHeader>
      <CardContent className="p-0">
        <div className="space-y-1">
          {documents.map((doc) => {
            const StatusIcon = getStatusIcon(doc.status)
            const isSelected = selectedDocument === doc.id

            return (
              <div
                key={doc.id}
                className={`p-4 cursor-pointer transition-colors border-l-4 ${
                  isSelected ? "bg-blue-500/10 border-l-blue-500" : "hover:bg-slate-700/50 border-l-transparent"
                }`}
                onClick={() => onSelectDocument(doc.id)}
              >
                <div className="flex items-start space-x-3">
                  <div className="p-2 bg-slate-700 rounded-lg">
                    <FileText className="w-4 h-4 text-slate-400" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <h4 className="text-sm font-medium text-white truncate mb-1">{doc.title}</h4>
                    <div className="flex items-center space-x-2 mb-2">
                      <Badge variant="outline" className="text-xs border-slate-600 text-slate-300">
                        {doc.type}
                      </Badge>
                      <Badge variant={getRiskBadgeColor(doc.riskLevel)} className="text-xs border-slate-600">
                        {doc.riskLevel}
                      </Badge>
                    </div>
                    <div className="flex items-center justify-between text-xs text-slate-400">
                      <div className="flex items-center space-x-1">
                        <StatusIcon className={`w-3 h-3 ${getStatusColor(doc.status)}`} />
                        <span>{doc.status}</span>
                      </div>
                      <span>{doc.uploadedAt}</span>
                    </div>
                    <div className="text-xs text-slate-500 mt-1">
                      {doc.clauses} clauses • {doc.pages} pages
                    </div>
                  </div>
                </div>
              </div>
            )
          })}
        </div>
      </CardContent>
    </Card>
  )
}
