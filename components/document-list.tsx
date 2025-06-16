"use client"

import { useState, useEffect } from "react"
import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { FileText, Clock, AlertTriangle, CheckCircle } from "lucide-react"

interface Document {
  id: string
  title: string
  type: string
  risk_level: string
  status: string
  clauses_count: number
  pages_count: number
  created_at: string
  updated_at: string
}

interface DocumentListProps {
  selectedDocument: string | null
  onSelectDocument: (id: string) => void
  searchTerm?: string
  documentType?: string
}

export function DocumentList({ selectedDocument, onSelectDocument, searchTerm, documentType }: DocumentListProps) {
  const [documents, setDocuments] = useState<Document[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    async function fetchDocuments() {
      try {
        setLoading(true)
        const params = new URLSearchParams()
        if (searchTerm) params.append("search", searchTerm)
        if (documentType && documentType !== "all") params.append("type", documentType)

        const response = await fetch(`/api/documents?${params.toString()}`)
        if (!response.ok) {
          throw new Error("Failed to fetch documents")
        }
        const data = await response.json()
        setDocuments(data)
      } catch (err) {
        setError(err instanceof Error ? err.message : "An error occurred")
      } finally {
        setLoading(false)
      }
    }

    fetchDocuments()
  }, [searchTerm, documentType])

  const getRiskColor = (risk: string) => {
    switch (risk.toLowerCase()) {
      case "high":
        return "bg-red-500/20 text-red-400 border-red-500/30"
      case "medium":
        return "bg-yellow-500/20 text-yellow-400 border-yellow-500/30"
      case "low":
        return "bg-green-500/20 text-green-400 border-green-500/30"
      default:
        return "bg-slate-500/20 text-slate-400 border-slate-500/30"
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status.toLowerCase()) {
      case "analyzed":
        return <CheckCircle className="w-4 h-4 text-green-400" />
      case "processing":
        return <Clock className="w-4 h-4 text-yellow-400" />
      case "pending":
        return <AlertTriangle className="w-4 h-4 text-orange-400" />
      default:
        return <FileText className="w-4 h-4 text-slate-400" />
    }
  }

  const formatTimeAgo = (dateString: string) => {
    const date = new Date(dateString)
    const now = new Date()
    const diffInHours = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60))

    if (diffInHours < 1) return "Less than an hour ago"
    if (diffInHours < 24) return `${diffInHours} hours ago`
    const diffInDays = Math.floor(diffInHours / 24)
    return `${diffInDays} days ago`
  }

  if (loading) {
    return (
      <Card className="bg-slate-800 border-slate-700">
        <CardContent className="p-6">
          <h2 className="text-lg font-semibold text-white mb-4">Documents</h2>
          <div className="space-y-4">
            {[1, 2, 3].map((i) => (
              <div key={i} className="animate-pulse">
                <div className="h-4 bg-slate-700 rounded w-3/4 mb-2"></div>
                <div className="h-3 bg-slate-700 rounded w-1/2"></div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    )
  }

  if (error) {
    return (
      <Card className="bg-slate-800 border-slate-700">
        <CardContent className="p-6">
          <h2 className="text-lg font-semibold text-white mb-4">Documents</h2>
          <div className="text-red-400 text-sm">Error loading documents: {error}</div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className="bg-slate-800 border-slate-700">
      <CardContent className="p-6">
        <h2 className="text-lg font-semibold text-white mb-4">Documents</h2>
        <div className="space-y-4">
          {documents.map((doc) => (
            <div
              key={doc.id}
              onClick={() => onSelectDocument(doc.id)}
              className={`p-4 rounded-lg border cursor-pointer transition-all hover:bg-slate-700/50 ${
                selectedDocument === doc.id
                  ? "bg-slate-700 border-blue-500"
                  : "bg-slate-900 border-slate-600 hover:border-slate-500"
              }`}
            >
              <div className="flex items-start justify-between mb-2">
                <h3 className="font-medium text-white text-sm leading-tight">{doc.title}</h3>
                {getStatusIcon(doc.status)}
              </div>

              <div className="flex items-center gap-2 mb-3">
                <Badge variant="outline" className="text-xs border-slate-600 text-slate-300">
                  {doc.type}
                </Badge>
                <Badge variant="outline" className={`text-xs border ${getRiskColor(doc.risk_level)}`}>
                  {doc.risk_level}
                </Badge>
              </div>

              <div className="flex items-center justify-between text-xs text-slate-400">
                <span className="flex items-center gap-1">
                  {getStatusIcon(doc.status)}
                  {doc.status}
                </span>
                <span>{formatTimeAgo(doc.updated_at)}</span>
              </div>

              <div className="flex items-center justify-between text-xs text-slate-500 mt-2">
                <span>{doc.clauses_count || 0} clauses</span>
                <span>{doc.pages_count || 0} pages</span>
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  )
}
