"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { FileText, Eye, Download } from "lucide-react"

interface Document {
  id: string
  title: string
  type: string
  status: string
  risk_level: string
  clauses_count: number
  created_at: string
}

export function RecentDocuments() {
  const [documents, setDocuments] = useState<Document[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function fetchRecentDocuments() {
      try {
        const response = await fetch("/api/documents?limit=5&sort=recent")
        if (!response.ok) throw new Error("Failed to fetch documents")
        const data = await response.json()
        setDocuments(data)
      } catch (error) {
        console.error("Error fetching recent documents:", error)
        setDocuments([])
      } finally {
        setLoading(false)
      }
    }

    fetchRecentDocuments()
  }, [])

  const handleView = (docId: string) => {
    window.location.href = `/documents?selected=${docId}`
  }

  const handleDownload = async (docId: string, title: string) => {
    try {
      const response = await fetch(`/api/documents/${docId}/download`)
      if (!response.ok) throw new Error("Download failed")

      const blob = await response.blob()
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement("a")
      a.href = url
      a.download = `${title.replace(/[^a-z0-9]/gi, "_").toLowerCase()}.pdf`
      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
      document.body.removeChild(a)
    } catch (error) {
      console.error("Download error:", error)
    }
  }

  const handleViewAll = () => {
    window.location.href = "/documents"
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
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-4">
          <CardTitle className="text-lg font-semibold text-white">Recent Documents</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {[1, 2, 3].map((i) => (
              <div key={i} className="animate-pulse p-4 border border-slate-700 rounded-lg">
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
          {documents.length === 0 ? (
            <div className="text-center py-8 text-slate-400">
              <FileText className="w-12 h-12 mx-auto mb-2 opacity-50" />
              <p>No documents found</p>
            </div>
          ) : (
            documents.map((doc) => (
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
                        variant={doc.risk_level === "high" ? "destructive" : "outline"}
                        className="text-xs border-slate-600 text-slate-300"
                      >
                        {doc.risk_level} Risk
                      </Badge>
                    </div>
                    <p className="text-xs text-slate-400 mt-1 truncate">
                      {doc.clauses_count} clauses • {formatTimeAgo(doc.created_at)}
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
            ))
          )}
        </div>
      </CardContent>
    </Card>
  )
}
