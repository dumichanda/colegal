"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Progress } from "@/components/ui/progress"
import { FileText, Brain, CheckCircle, AlertTriangle, Clock, Zap } from "lucide-react"

interface DocumentCopilotProps {
  documentId?: string
  documentName?: string
}

export function DocumentCopilot({ documentId, documentName = "Document" }: DocumentCopilotProps) {
  const [isAnalyzing, setIsAnalyzing] = useState(false)
  const [analysisProgress, setAnalysisProgress] = useState(0)
  const [analysisResults, setAnalysisResults] = useState<any>(null)

  const startAnalysis = async () => {
    setIsAnalyzing(true)
    setAnalysisProgress(0)

    // Simulate analysis progress
    const progressInterval = setInterval(() => {
      setAnalysisProgress((prev) => {
        if (prev >= 100) {
          clearInterval(progressInterval)
          setIsAnalyzing(false)
          setAnalysisResults({
            summary: "This contract contains standard terms and conditions with some areas requiring attention.",
            riskLevel: "medium",
            keyFindings: [
              "Force majeure clause needs clarification",
              "Termination conditions are favorable",
              "Payment terms are standard",
              "Liability limitations are reasonable",
            ],
            complianceIssues: [
              {
                issue: "POPIA compliance clause missing",
                severity: "high",
                recommendation: "Add data protection clause",
              },
              {
                issue: "Dispute resolution jurisdiction unclear",
                severity: "medium",
                recommendation: "Specify South African courts",
              },
            ],
            suggestions: [
              "Consider adding intellectual property protection clause",
              "Review indemnification terms",
              "Clarify service level agreements",
            ],
          })
          return 100
        }
        return prev + 10
      })
    }, 200)
  }

  const getRiskColor = (level: string) => {
    switch (level) {
      case "low":
        return "bg-green-500/10 text-green-400 border-green-500/20"
      case "medium":
        return "bg-yellow-500/10 text-yellow-400 border-yellow-500/20"
      case "high":
        return "bg-red-500/10 text-red-400 border-red-500/20"
      default:
        return "bg-gray-500/10 text-gray-400 border-gray-500/20"
    }
  }

  return (
    <Card className="bg-slate-800 border-slate-700">
      <CardHeader>
        <CardTitle className="flex items-center justify-between text-white">
          <div className="flex items-center">
            <Brain className="w-5 h-5 mr-2" />
            Document AI Assistant
          </div>
          <Badge variant="outline" className="border-slate-600 text-slate-300">
            {documentName}
          </Badge>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {!analysisResults && !isAnalyzing && (
          <div className="text-center py-8">
            <FileText className="w-16 h-16 mx-auto text-slate-600 mb-4" />
            <h3 className="text-lg font-semibold text-white mb-2">AI Document Analysis</h3>
            <p className="text-slate-400 mb-4">
              Get instant insights, risk assessment, and compliance checks for your legal documents.
            </p>
            <Button onClick={startAnalysis} className="bg-blue-600 hover:bg-blue-700">
              <Zap className="w-4 h-4 mr-2" />
              Start AI Analysis
            </Button>
          </div>
        )}

        {isAnalyzing && (
          <div className="space-y-4">
            <div className="text-center">
              <div className="w-16 h-16 mx-auto mb-4 relative">
                <div className="w-16 h-16 border-4 border-slate-600 border-t-blue-500 rounded-full animate-spin"></div>
                <Brain className="w-6 h-6 absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 text-blue-500" />
              </div>
              <h3 className="text-lg font-semibold text-white mb-2">Analyzing Document...</h3>
              <p className="text-slate-400 mb-4">AI is reviewing your document for insights and compliance</p>
            </div>
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-slate-400">Analysis Progress</span>
                <span className="text-slate-300">{analysisProgress}%</span>
              </div>
              <Progress value={analysisProgress} className="bg-slate-700" />
            </div>
          </div>
        )}

        {analysisResults && (
          <Tabs defaultValue="summary" className="w-full">
            <TabsList className="grid w-full grid-cols-4 bg-slate-700">
              <TabsTrigger value="summary" className="text-slate-300">
                Summary
              </TabsTrigger>
              <TabsTrigger value="risks" className="text-slate-300">
                Risks
              </TabsTrigger>
              <TabsTrigger value="compliance" className="text-slate-300">
                Compliance
              </TabsTrigger>
              <TabsTrigger value="suggestions" className="text-slate-300">
                Suggestions
              </TabsTrigger>
            </TabsList>

            <TabsContent value="summary" className="space-y-4 mt-4">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-semibold text-white">Document Summary</h3>
                <Badge className={getRiskColor(analysisResults.riskLevel)}>{analysisResults.riskLevel} Risk</Badge>
              </div>
              <p className="text-slate-300 leading-relaxed">{analysisResults.summary}</p>

              <div className="space-y-2">
                <h4 className="font-medium text-white">Key Findings:</h4>
                {analysisResults.keyFindings.map((finding: string, index: number) => (
                  <div key={index} className="flex items-center space-x-2">
                    <CheckCircle className="w-4 h-4 text-green-400" />
                    <span className="text-slate-300 text-sm">{finding}</span>
                  </div>
                ))}
              </div>
            </TabsContent>

            <TabsContent value="risks" className="mt-4">
              <div className="text-center text-slate-400 py-8">
                <AlertTriangle className="w-12 h-12 mx-auto mb-2 opacity-50" />
                <p>Risk analysis details would appear here</p>
              </div>
            </TabsContent>

            <TabsContent value="compliance" className="space-y-3 mt-4">
              {analysisResults.complianceIssues.map((issue: any, index: number) => (
                <div key={index} className="p-3 border border-slate-600 rounded-lg bg-slate-700/30">
                  <div className="flex items-start justify-between mb-2">
                    <h4 className="font-medium text-white">{issue.issue}</h4>
                    <Badge className={getRiskColor(issue.severity)}>{issue.severity}</Badge>
                  </div>
                  <p className="text-sm text-slate-300">{issue.recommendation}</p>
                </div>
              ))}
            </TabsContent>

            <TabsContent value="suggestions" className="space-y-3 mt-4">
              {analysisResults.suggestions.map((suggestion: string, index: number) => (
                <div
                  key={index}
                  className="flex items-start space-x-3 p-3 border border-slate-600 rounded-lg bg-slate-700/30"
                >
                  <Clock className="w-4 h-4 text-blue-400 mt-1" />
                  <span className="text-slate-300 text-sm">{suggestion}</span>
                </div>
              ))}
            </TabsContent>
          </Tabs>
        )}
      </CardContent>
    </Card>
  )
}
