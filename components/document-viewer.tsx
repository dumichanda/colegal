"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { FileText, Download, Eye, AlertTriangle } from "lucide-react"

interface Document {
  id: string
  title: string
  type: string
  file_path?: string
  file_size?: number
  risk_level: string
  created_at: string
  content?: string
}

interface DocumentViewerProps {
  document: Document
}

export function DocumentViewer({ document }: DocumentViewerProps) {
  const [isLoading, setIsLoading] = useState(false)

  const handleDownload = async () => {
    if (!document.file_path) return

    setIsLoading(true)
    try {
      // In a real app, this would download from your file storage
      const response = await fetch(document.file_path)
      const blob = await response.blob()

      const url = window.URL.createObjectURL(blob)
      const a = document.createElement("a")
      a.href = url
      a.download = `${document.title}.pdf`
      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
      document.body.removeChild(a)
    } catch (error) {
      console.error("Download failed:", error)
    } finally {
      setIsLoading(false)
    }
  }

  const handleView = () => {
    if (!document.file_path) return
    window.open(document.file_path, "_blank")
  }

  const formatFileSize = (bytes?: number) => {
    if (!bytes) return "Unknown size"
    const kb = bytes / 1024
    const mb = kb / 1024

    if (mb >= 1) return `${mb.toFixed(1)} MB`
    return `${kb.toFixed(1)} KB`
  }

  const getRiskColor = (risk: string) => {
    switch (risk.toLowerCase()) {
      case "high":
        return "destructive"
      case "medium":
        return "default"
      case "low":
        return "secondary"
      default:
        return "outline"
    }
  }

  return (
    <Card className="w-full">
      <CardHeader>
        <div className="flex items-start justify-between">
          <div className="flex items-center gap-3">
            <FileText className="h-8 w-8 text-blue-600" />
            <div>
              <CardTitle className="text-lg">{document.title}</CardTitle>
              <div className="flex items-center gap-2 mt-1">
                <Badge variant="outline">{document.type}</Badge>
                <Badge variant={getRiskColor(document.risk_level)}>{document.risk_level} risk</Badge>
              </div>
            </div>
          </div>
          <div className="flex gap-2">
            {document.file_path && (
              <>
                <Button variant="outline" size="sm" onClick={handleView} className="flex items-center gap-2">
                  <Eye className="h-4 w-4" />
                  View
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={handleDownload}
                  disabled={isLoading}
                  className="flex items-center gap-2"
                >
                  <Download className="h-4 w-4" />
                  {isLoading ? "Downloading..." : "Download"}
                </Button>
              </>
            )}
          </div>
        </div>
      </CardHeader>

      <CardContent className="space-y-4">
        {/* Document Info */}
        <div className="grid grid-cols-2 gap-4 text-sm">
          <div>
            <span className="font-medium text-gray-600">File Size:</span>
            <span className="ml-2">{formatFileSize(document.file_size)}</span>
          </div>
          <div>
            <span className="font-medium text-gray-600">Created:</span>
            <span className="ml-2">{new Date(document.created_at).toLocaleDateString()}</span>
          </div>
        </div>

        {/* Document Content Preview */}
        {document.content && (
          <div className="border rounded-lg p-4 bg-gray-50">
            <h4 className="font-medium text-gray-800 mb-2">Document Summary</h4>
            <p className="text-sm text-gray-600 leading-relaxed">{document.content}</p>
          </div>
        )}

        {/* PDF Embed (if available) */}
        {document.file_path && (
          <div className="border rounded-lg overflow-hidden">
            <div className="bg-gray-100 px-4 py-2 border-b">
              <span className="text-sm font-medium text-gray-700">Document Preview</span>
            </div>
            <div className="h-96">
              <iframe
                src={`${document.file_path}#toolbar=0`}
                className="w-full h-full"
                title={`Preview of ${document.title}`}
              />
            </div>
          </div>
        )}

        {/* Warning for high-risk documents */}
        {document.risk_level === "high" && (
          <div className="flex items-center gap-2 p-3 bg-red-50 border border-red-200 rounded-lg">
            <AlertTriangle className="h-5 w-5 text-red-600" />
            <div>
              <p className="text-sm font-medium text-red-800">High Risk Document</p>
              <p className="text-xs text-red-600">
                This document requires careful review and may have compliance issues.
              </p>
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  )
}
