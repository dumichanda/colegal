"use client"

import { useState } from "react"
import { DashboardHeader } from "@/components/dashboard-header"
import { DocumentUpload } from "@/components/document-upload"
import { DocumentList } from "@/components/document-list"
import { DocumentAnalysis } from "@/components/document-analysis"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Search, Filter, Upload } from "lucide-react"

import { CopilotChat } from "@/components/copilot-chat"
import { DocumentCopilot } from "@/components/document-copilot"
import { MastraWorkflowPanel } from "@/components/mastra-workflow-panel"

export default function DocumentsPage() {
  const [selectedDocument, setSelectedDocument] = useState<string | null>(null)
  const [showUpload, setShowUpload] = useState(false)

  return (
    <div className="min-h-screen bg-slate-950">
      <DashboardHeader />

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-3xl font-bold text-white">Document Analysis</h1>
            <p className="mt-2 text-slate-400">AI-powered contract analysis and legal document review</p>
          </div>
          <Button
            onClick={() => setShowUpload(true)}
            className="flex items-center space-x-2 bg-blue-600 hover:bg-blue-700"
          >
            <Upload className="w-4 h-4" />
            <span>Upload Document</span>
          </Button>
        </div>

        {/* Search and Filters */}
        <div className="bg-slate-800 border border-slate-700 rounded-lg p-6 mb-8">
          <div className="flex flex-col md:flex-row gap-4">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400 w-4 h-4" />
              <Input
                type="search"
                placeholder="Search documents by title, content, or clauses..."
                className="pl-10 bg-slate-900 border-slate-600 text-white placeholder:text-slate-400"
              />
            </div>
            <Select>
              <SelectTrigger className="w-48 bg-slate-900 border-slate-600 text-white">
                <SelectValue placeholder="Document Type" />
              </SelectTrigger>
              <SelectContent className="bg-slate-800 border-slate-700">
                <SelectItem value="all">All Types</SelectItem>
                <SelectItem value="contract">Contracts</SelectItem>
                <SelectItem value="agreement">Agreements</SelectItem>
                <SelectItem value="policy">Policies</SelectItem>
                <SelectItem value="compliance">Compliance</SelectItem>
              </SelectContent>
            </Select>
            <Select>
              <SelectTrigger className="w-48 bg-slate-900 border-slate-600 text-white">
                <SelectValue placeholder="Risk Level" />
              </SelectTrigger>
              <SelectContent className="bg-slate-800 border-slate-700">
                <SelectItem value="all">All Levels</SelectItem>
                <SelectItem value="high">High Risk</SelectItem>
                <SelectItem value="medium">Medium Risk</SelectItem>
                <SelectItem value="low">Low Risk</SelectItem>
              </SelectContent>
            </Select>
            <Button variant="outline" className="border-slate-600 text-slate-300 hover:bg-slate-700">
              <Filter className="w-4 h-4 mr-2" />
              More Filters
            </Button>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Document List */}
          <div className="lg:col-span-1">
            <DocumentList selectedDocument={selectedDocument} onSelectDocument={setSelectedDocument} />
          </div>

          {/* Document Analysis */}
          <div className="lg:col-span-2">
            {selectedDocument ? (
              <div className="space-y-6">
                <DocumentAnalysis documentId={selectedDocument} />

                {/* Add AI Assistant Components */}
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                  <DocumentCopilot
                    documentId={selectedDocument}
                    documentTitle="Selected Document Title"
                    documentContent="Document content here..."
                  />
                  <MastraWorkflowPanel documentId={selectedDocument} organizationId="org-123" />
                </div>
              </div>
            ) : (
              <div className="bg-slate-800 border border-slate-700 rounded-lg p-8 text-center">
                <div className="text-slate-400 mb-4">
                  <Upload className="w-16 h-16 mx-auto" />
                </div>
                <h3 className="text-lg font-medium text-white mb-2">Select a document to analyze</h3>
                <p className="text-slate-400 mb-4">
                  Choose a document from the list to view AI-powered analysis, clause extraction, and risk assessment.
                </p>
                <Button onClick={() => setShowUpload(true)} className="bg-blue-600 hover:bg-blue-700">
                  Upload New Document
                </Button>
              </div>
            )}
          </div>
        </div>

        {/* Add AI Assistant Components */}
        <CopilotChat documentId={selectedDocument} context="Document analysis page" />

        {/* Upload Modal */}
        {showUpload && <DocumentUpload onClose={() => setShowUpload(false)} />}
      </main>
    </div>
  )
}
