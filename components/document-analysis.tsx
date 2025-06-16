"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Progress } from "@/components/ui/progress"
import { AlertTriangle, Shield, Download, Share, MessageSquare, HighlighterIcon as Highlight } from "lucide-react"

interface DocumentAnalysisProps {
  documentId: string
}

interface DocumentAnalysis {
  id: string
  title: string
  type: string
  status: string
  risk_level: string
  overall_score: number
  clauses: Array<{
    id: string
    type: string
    content: string
    risk_level: string
    page_number: number
    recommendation: string
  }>
  key_terms: Array<{
    term: string
    value: string
  }>
  compliance_checks: Array<{
    rule: string
    status: string
    details: string
  }>
  created_at: string
  updated_at: string
}

export function DocumentAnalysis({ documentId }: DocumentAnalysisProps) {
  const [analysis, setAnalysis] = useState<DocumentAnalysis | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [activeTab, setActiveTab] = useState("overview")

  useEffect(() => {
    async function fetchAnalysis() {
      try {
        setLoading(true)
        const response = await fetch(`/api/documents/${documentId}/analysis`)
        if (!response.ok) {
          throw new Error("Failed to fetch document analysis")
        }
        const data = await response.json()
        setAnalysis(data)
      } catch (err) {
        setError(err instanceof Error ? err.message : "An error occurred")
      } finally {
        setLoading(false)
      }
    }

    if (documentId) {
      fetchAnalysis()
    }
  }, [documentId])

  const getRiskColor = (risk: string) => {
    switch (risk.toLowerCase()) {
      case "high":
        return "text-red-600 bg-red-50"
      case "medium":
        return "text-yellow-600 bg-yellow-50"
      case "low":
        return "text-green-600 bg-green-50"
      default:
        return "text-gray-600 bg-gray-50"
    }
  }

  const getComplianceColor = (status: string) => {
    switch (status.toLowerCase()) {
      case "compliant":
        return "text-green-600"
      case "at risk":
        return "text-yellow-600"
      case "non-compliant":
        return "text-red-600"
      default:
        return "text-gray-600"
    }
  }

  if (loading) {
    return (
      <div className="space-y-6">
        <Card className="bg-slate-800 border-slate-700">
          <CardContent className="p-6">
            <div className="animate-pulse space-y-4">
              <div className="h-6 bg-slate-700 rounded w-1/2"></div>
              <div className="h-4 bg-slate-700 rounded w-3/4"></div>
              <div className="grid grid-cols-3 gap-4">
                {[1, 2, 3].map((i) => (
                  <div key={i} className="h-16 bg-slate-700 rounded"></div>
                ))}
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    )
  }

  if (error) {
    return (
      <Card className="bg-slate-800 border-slate-700">
        <CardContent className="p-6">
          <div className="text-red-400 text-center">
            <AlertTriangle className="w-12 h-12 mx-auto mb-2" />
            <p>Error loading analysis: {error}</p>
          </div>
        </CardContent>
      </Card>
    )
  }

  if (!analysis) {
    return (
      <Card className="bg-slate-800 border-slate-700">
        <CardContent className="p-6">
          <div className="text-slate-400 text-center">
            <p>No analysis available for this document</p>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <div className="space-y-6">
      {/* Document Header */}
      <Card className="bg-slate-800 border-slate-700">
        <CardHeader>
          <div className="flex items-start justify-between">
            <div>
              <CardTitle className="text-xl text-white">{analysis.title}</CardTitle>
              <div className="flex items-center space-x-2 mt-2">
                <Badge variant="outline" className="border-slate-600 text-slate-300">
                  {analysis.type}
                </Badge>
                <Badge
                  variant={analysis.risk_level === "high" ? "destructive" : "outline"}
                  className="border-slate-600"
                >
                  {analysis.risk_level} Risk
                </Badge>
                <span className="text-sm text-slate-400">
                  • Analyzed {new Date(analysis.updated_at).toLocaleDateString()}
                </span>
              </div>
            </div>
            <div className="flex space-x-2">
              <Button variant="outline" size="sm" className="border-slate-600 text-slate-300 hover:bg-slate-700">
                <Download className="w-4 h-4 mr-2" />
                Export
              </Button>
              <Button variant="outline" size="sm" className="border-slate-600 text-slate-300 hover:bg-slate-700">
                <Share className="w-4 h-4 mr-2" />
                Share
              </Button>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="text-center">
              <div className="text-3xl font-bold text-white">{analysis.overall_score}</div>
              <div className="text-sm text-slate-400">Overall Score</div>
              <Progress value={analysis.overall_score} className="mt-2" />
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-white">{analysis.clauses.length}</div>
              <div className="text-sm text-slate-400">Clauses Analyzed</div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-red-400">
                {analysis.clauses.filter((c) => c.risk_level === "high").length}
              </div>
              <div className="text-sm text-slate-400">High Risk Issues</div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Analysis Tabs */}
      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList className="grid w-full grid-cols-4 bg-slate-800 border-slate-700">
          <TabsTrigger value="overview" className="data-[state=active]:bg-slate-700 text-slate-300">
            Overview
          </TabsTrigger>
          <TabsTrigger value="clauses" className="data-[state=active]:bg-slate-700 text-slate-300">
            Clauses
          </TabsTrigger>
          <TabsTrigger value="compliance" className="data-[state=active]:bg-slate-700 text-slate-300">
            Compliance
          </TabsTrigger>
          <TabsTrigger value="chat" className="data-[state=active]:bg-slate-700 text-slate-300">
            AI Chat
          </TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-6">
          {/* Key Terms */}
          <Card className="bg-slate-800 border-slate-700">
            <CardHeader>
              <CardTitle className="text-lg text-white">Key Terms</CardTitle>
            </CardHeader>
            <CardContent>
              {analysis.key_terms.length === 0 ? (
                <div className="text-center py-4 text-slate-400">No key terms extracted</div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {analysis.key_terms.map((term, index) => (
                    <div key={index} className="flex justify-between items-center p-3 bg-slate-700 rounded-lg">
                      <span className="font-medium text-white">{term.term}</span>
                      <span className="text-slate-300">{term.value}</span>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>

          {/* Risk Summary */}
          <Card className="bg-slate-800 border-slate-700">
            <CardHeader>
              <CardTitle className="text-lg text-white">Risk Summary</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {analysis.clauses.map((clause) => (
                  <div key={clause.id} className="flex items-start space-x-3 p-4 border border-slate-700 rounded-lg">
                    <AlertTriangle
                      className={`w-5 h-5 mt-0.5 ${
                        clause.risk_level === "high"
                          ? "text-red-400"
                          : clause.risk_level === "medium"
                            ? "text-yellow-400"
                            : "text-green-400"
                      }`}
                    />
                    <div className="flex-1">
                      <div className="flex items-center justify-between mb-2">
                        <h4 className="font-medium text-white">{clause.type}</h4>
                        <Badge
                          variant={clause.risk_level === "high" ? "destructive" : "outline"}
                          className="text-xs border-slate-600"
                        >
                          {clause.risk_level} Risk
                        </Badge>
                      </div>
                      <p className="text-sm text-slate-300 mb-2">{clause.recommendation}</p>
                      <span className="text-xs text-slate-500">Page {clause.page_number}</span>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="clauses" className="space-y-6">
          <Card className="bg-slate-800 border-slate-700">
            <CardHeader>
              <CardTitle className="text-lg text-white">Contract Clauses Analysis</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {analysis.clauses.map((clause) => (
                  <div key={clause.id} className="border border-slate-700 rounded-lg p-4">
                    <div className="flex items-center justify-between mb-3">
                      <div className="flex items-center space-x-2">
                        <h4 className="font-medium text-white">{clause.type}</h4>
                        <Badge variant="outline" className="text-xs border-slate-600 text-slate-300">
                          Page {clause.page_number}
                        </Badge>
                      </div>
                      <div className="flex items-center space-x-2">
                        <Badge
                          variant={clause.risk_level === "high" ? "destructive" : "outline"}
                          className="text-xs border-slate-600"
                        >
                          {clause.risk_level} Risk
                        </Badge>
                        <Button variant="ghost" size="sm" className="text-slate-400 hover:text-white">
                          <Highlight className="w-4 h-4" />
                        </Button>
                      </div>
                    </div>
                    <div className="p-3 rounded-lg mb-3 bg-slate-700 border border-slate-600">
                      <p className="text-sm text-slate-300">{clause.content}</p>
                    </div>
                    <div className="bg-blue-500/10 border border-blue-500/20 p-3 rounded-lg">
                      <p className="text-sm text-blue-300">
                        <strong>Recommendation:</strong> {clause.recommendation}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="compliance" className="space-y-6">
          <Card className="bg-slate-800 border-slate-700">
            <CardHeader>
              <CardTitle className="text-lg text-white">Compliance Assessment</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {analysis.compliance_checks.map((check, index) => (
                  <div key={index} className="flex items-start space-x-3 p-4 border border-slate-700 rounded-lg">
                    <Shield className={`w-5 h-5 mt-0.5 ${getComplianceColor(check.status)}`} />
                    <div className="flex-1">
                      <div className="flex items-center justify-between mb-2">
                        <h4 className="font-medium text-white">{check.rule}</h4>
                        <Badge
                          variant={check.status === "compliant" ? "outline" : "destructive"}
                          className="text-xs border-slate-600"
                        >
                          {check.status}
                        </Badge>
                      </div>
                      <p className="text-sm text-slate-300">{check.details}</p>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="chat" className="space-y-6">
          <Card className="bg-slate-800 border-slate-700">
            <CardHeader>
              <CardTitle className="text-lg flex items-center text-white">
                <MessageSquare className="w-5 h-5 mr-2" />
                AI Document Assistant
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="bg-slate-900 rounded-lg p-4 mb-4 h-64 overflow-y-auto">
                <div className="space-y-4">
                  <div className="flex items-start space-x-3">
                    <div className="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center">
                      <span className="text-white text-xs font-bold">AI</span>
                    </div>
                    <div className="bg-slate-800 p-3 rounded-lg shadow-sm">
                      <p className="text-sm text-slate-300">
                        I've analyzed your {analysis.type.toLowerCase()}. I found {analysis.clauses.length} clauses that
                        need attention, with {analysis.clauses.filter((c) => c.risk_level === "high").length} high-risk
                        issues. Would you like me to explain any specific section?
                      </p>
                    </div>
                  </div>
                </div>
              </div>
              <div className="flex space-x-2">
                <input
                  type="text"
                  placeholder="Ask about this document..."
                  className="flex-1 px-3 py-2 border border-slate-600 rounded-lg bg-slate-900 text-white placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
                <Button className="bg-blue-600 hover:bg-blue-700">Send</Button>
              </div>
              <div className="mt-3 flex flex-wrap gap-2">
                <Button variant="outline" size="sm" className="border-slate-600 text-slate-300 hover:bg-slate-700">
                  Explain high-risk clauses
                </Button>
                <Button variant="outline" size="sm" className="border-slate-600 text-slate-300 hover:bg-slate-700">
                  Compare to standard
                </Button>
                <Button variant="outline" size="sm" className="border-slate-600 text-slate-300 hover:bg-slate-700">
                  Suggest improvements
                </Button>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  )
}
