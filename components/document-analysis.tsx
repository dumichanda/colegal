"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Progress } from "@/components/ui/progress"
import { AlertTriangle, Shield, Download, Share, MessageSquare, HighlighterIcon as Highlight } from "lucide-react"

interface DocumentAnalysisProps {
  documentId: string
}

export function DocumentAnalysis({ documentId }: DocumentAnalysisProps) {
  const [activeTab, setActiveTab] = useState("overview")

  // Mock data for demo purposes
  const document = {
    id: documentId,
    title: "Software License Agreement - TechCorp",
    type: "Contract",
    status: "Analyzed",
    riskLevel: "Medium",
    overallScore: 78,
    clauses: [
      {
        id: 1,
        type: "Termination",
        content: "Either party may terminate this Agreement with thirty (30) days written notice...",
        riskLevel: "Low",
        page: 3,
        recommendation: "Standard termination clause with reasonable notice period.",
      },
      {
        id: 2,
        type: "Liability Limitation",
        content: "In no event shall the total liability of either party exceed the amount paid under this Agreement...",
        riskLevel: "Medium",
        page: 7,
        recommendation: "Consider adding mutual liability caps and specific exclusions for certain damages.",
      },
      {
        id: 3,
        type: "Intellectual Property",
        content: "All intellectual property rights in the Software shall remain with Licensor...",
        riskLevel: "High",
        page: 5,
        recommendation:
          "Broad IP assignment clause may limit your ability to use derivative works. Consider negotiating more specific language.",
      },
    ],
    keyTerms: [
      { term: "Contract Value", value: "$250,000 annually" },
      { term: "Term Length", value: "3 years with auto-renewal" },
      { term: "Payment Terms", value: "Net 30 days" },
      { term: "Governing Law", value: "Delaware" },
    ],
    complianceChecks: [
      { rule: "GDPR Data Processing", status: "Compliant", details: "Adequate data protection clauses present" },
      { rule: "SOX Financial Controls", status: "At Risk", details: "Missing audit trail requirements" },
      { rule: "Industry Standards", status: "Compliant", details: "Meets software licensing best practices" },
    ],
  }

  const getRiskColor = (risk: string) => {
    switch (risk) {
      case "High":
        return "text-red-600 bg-red-50"
      case "Medium":
        return "text-yellow-600 bg-yellow-50"
      case "Low":
        return "text-green-600 bg-green-50"
      default:
        return "text-gray-600 bg-gray-50"
    }
  }

  const getComplianceColor = (status: string) => {
    switch (status) {
      case "Compliant":
        return "text-green-600"
      case "At Risk":
        return "text-yellow-600"
      case "Non-Compliant":
        return "text-red-600"
      default:
        return "text-gray-600"
    }
  }

  return (
    <div className="space-y-6">
      {/* Document Header */}
      <Card className="bg-slate-800 border-slate-700">
        <CardHeader>
          <div className="flex items-start justify-between">
            <div>
              <CardTitle className="text-xl text-white">{document.title}</CardTitle>
              <div className="flex items-center space-x-2 mt-2">
                <Badge variant="outline" className="border-slate-600 text-slate-300">
                  {document.type}
                </Badge>
                <Badge variant={document.riskLevel === "High" ? "destructive" : "outline"} className="border-slate-600">
                  {document.riskLevel} Risk
                </Badge>
                <span className="text-sm text-slate-400">• Analyzed 2 hours ago</span>
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
              <div className="text-3xl font-bold text-white">{document.overallScore}</div>
              <div className="text-sm text-slate-400">Overall Score</div>
              <Progress value={document.overallScore} className="mt-2" />
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-white">{document.clauses.length}</div>
              <div className="text-sm text-slate-400">Clauses Analyzed</div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-red-400">
                {document.clauses.filter((c) => c.riskLevel === "High").length}
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
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {document.keyTerms.map((term, index) => (
                  <div key={index} className="flex justify-between items-center p-3 bg-slate-700 rounded-lg">
                    <span className="font-medium text-white">{term.term}</span>
                    <span className="text-slate-300">{term.value}</span>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Risk Summary */}
          <Card className="bg-slate-800 border-slate-700">
            <CardHeader>
              <CardTitle className="text-lg text-white">Risk Summary</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {document.clauses.map((clause) => (
                  <div key={clause.id} className="flex items-start space-x-3 p-4 border border-slate-700 rounded-lg">
                    <AlertTriangle
                      className={`w-5 h-5 mt-0.5 ${
                        clause.riskLevel === "High"
                          ? "text-red-400"
                          : clause.riskLevel === "Medium"
                            ? "text-yellow-400"
                            : "text-green-400"
                      }`}
                    />
                    <div className="flex-1">
                      <div className="flex items-center justify-between mb-2">
                        <h4 className="font-medium text-white">{clause.type}</h4>
                        <Badge
                          variant={clause.riskLevel === "High" ? "destructive" : "outline"}
                          className="text-xs border-slate-600"
                        >
                          {clause.riskLevel} Risk
                        </Badge>
                      </div>
                      <p className="text-sm text-slate-300 mb-2">{clause.recommendation}</p>
                      <span className="text-xs text-slate-500">Page {clause.page}</span>
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
                {document.clauses.map((clause) => (
                  <div key={clause.id} className="border border-slate-700 rounded-lg p-4">
                    <div className="flex items-center justify-between mb-3">
                      <div className="flex items-center space-x-2">
                        <h4 className="font-medium text-white">{clause.type}</h4>
                        <Badge variant="outline" className="text-xs border-slate-600 text-slate-300">
                          Page {clause.page}
                        </Badge>
                      </div>
                      <div className="flex items-center space-x-2">
                        <Badge
                          variant={clause.riskLevel === "High" ? "destructive" : "outline"}
                          className="text-xs border-slate-600"
                        >
                          {clause.riskLevel} Risk
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
                {document.complianceChecks.map((check, index) => (
                  <div key={index} className="flex items-start space-x-3 p-4 border border-slate-700 rounded-lg">
                    <Shield className={`w-5 h-5 mt-0.5 ${getComplianceColor(check.status)}`} />
                    <div className="flex-1">
                      <div className="flex items-center justify-between mb-2">
                        <h4 className="font-medium text-white">{check.rule}</h4>
                        <Badge
                          variant={check.status === "Compliant" ? "outline" : "destructive"}
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
                        I've analyzed your Software License Agreement. I found 3 clauses that need attention, with 1
                        high-risk intellectual property clause. Would you like me to explain any specific section?
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
                  Explain IP clause
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
