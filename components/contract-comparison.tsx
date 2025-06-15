"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Progress } from "@/components/ui/progress"
import { GitCompare, Download, AlertTriangle, CheckCircle, Clock } from "lucide-react"

export function ContractComparison() {
  const [selectedDocuments, setSelectedDocuments] = useState<string[]>([])
  const [comparisonResult, setComparisonResult] = useState<any>(null)
  const [isComparing, setIsComparing] = useState(false)

  const availableDocuments = [
    { id: "doc-1", title: "Software License Agreement - TechCorp v1.0", type: "Contract" },
    { id: "doc-2", title: "Software License Agreement - TechCorp v2.0", type: "Contract" },
    { id: "doc-3", title: "Standard Software License Template", type: "Template" },
    { id: "doc-4", title: "Employment Agreement - Senior Developer", type: "Contract" },
    { id: "doc-5", title: "Vendor Service Agreement - CloudProvider", type: "Contract" },
  ]

  const mockComparisonResult = {
    summary: {
      totalChanges: 23,
      highRiskChanges: 3,
      mediumRiskChanges: 8,
      lowRiskChanges: 12,
      overallRiskScore: 72,
    },
    changes: [
      {
        id: 1,
        type: "Liability Limitation",
        changeType: "Modified",
        riskLevel: "High",
        description: "Liability cap reduced from $1M to $500K",
        document1Text: "Total liability shall not exceed $1,000,000",
        document2Text: "Total liability shall not exceed $500,000",
        impact: "Increased financial exposure for client",
        recommendation: "Negotiate to restore original liability cap",
        page: 7,
      },
      {
        id: 2,
        type: "Termination Clause",
        changeType: "Added",
        riskLevel: "Medium",
        description: "Added immediate termination for convenience clause",
        document1Text: "",
        document2Text: "Either party may terminate this agreement immediately for convenience with written notice",
        impact: "Reduces contract stability and predictability",
        recommendation: "Add minimum notice period requirement",
        page: 12,
      },
      {
        id: 3,
        type: "Payment Terms",
        changeType: "Modified",
        riskLevel: "Low",
        description: "Payment terms extended from Net 30 to Net 45",
        document1Text: "Payment due within thirty (30) days",
        document2Text: "Payment due within forty-five (45) days",
        impact: "Improved cash flow for client",
        recommendation: "Acceptable change",
        page: 4,
      },
    ],
    clauseComparison: [
      {
        clauseType: "Intellectual Property",
        status: "Unchanged",
        riskLevel: "Medium",
        present: true,
      },
      {
        clauseType: "Confidentiality",
        status: "Modified",
        riskLevel: "Low",
        present: true,
      },
      {
        clauseType: "Force Majeure",
        status: "Added",
        riskLevel: "Low",
        present: true,
      },
    ],
  }

  const handleCompare = async () => {
    if (selectedDocuments.length < 2) return

    setIsComparing(true)
    // Simulate API call
    setTimeout(() => {
      setComparisonResult(mockComparisonResult)
      setIsComparing(false)
    }, 3000)
  }

  const getRiskColor = (risk: string) => {
    switch (risk) {
      case "High":
        return "border-red-500/30 bg-red-500/10"
      case "Medium":
        return "border-yellow-500/30 bg-yellow-500/10"
      case "Low":
        return "border-green-500/30 bg-green-500/10"
      default:
        return "border-slate-600 bg-slate-700/30"
    }
  }

  const getChangeIcon = (changeType: string) => {
    switch (changeType) {
      case "Added":
        return <CheckCircle className="w-4 h-4 text-green-500" />
      case "Modified":
        return <AlertTriangle className="w-4 h-4 text-yellow-500" />
      case "Removed":
        return <Clock className="w-4 h-4 text-red-500" />
      default:
        return <GitCompare className="w-4 h-4 text-gray-500" />
    }
  }

  return (
    <div className="space-y-6">
      {/* Document Selection */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center">
            <GitCompare className="w-5 h-5 mr-2" />
            Contract Comparison
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium mb-2">Primary Document</label>
              <Select
                value={selectedDocuments[0] || ""}
                onValueChange={(value) => setSelectedDocuments([value, selectedDocuments[1]].filter(Boolean))}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Select primary document" />
                </SelectTrigger>
                <SelectContent>
                  {availableDocuments.map((doc) => (
                    <SelectItem key={doc.id} value={doc.id}>
                      {doc.title}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Comparison Document</label>
              <Select
                value={selectedDocuments[1] || ""}
                onValueChange={(value) => setSelectedDocuments([selectedDocuments[0], value].filter(Boolean))}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Select comparison document" />
                </SelectTrigger>
                <SelectContent>
                  {availableDocuments
                    .filter((doc) => doc.id !== selectedDocuments[0])
                    .map((doc) => (
                      <SelectItem key={doc.id} value={doc.id}>
                        {doc.title}
                      </SelectItem>
                    ))}
                </SelectContent>
              </Select>
            </div>
          </div>

          <div className="flex justify-between items-center">
            <div className="text-sm text-gray-600">{selectedDocuments.length}/2 documents selected</div>
            <Button onClick={handleCompare} disabled={selectedDocuments.length < 2 || isComparing}>
              {isComparing ? "Comparing..." : "Compare Documents"}
            </Button>
          </div>

          {isComparing && (
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span>Analyzing documents...</span>
                <span>Processing</span>
              </div>
              <Progress value={66} />
            </div>
          )}
        </CardContent>
      </Card>

      {/* Comparison Results */}
      {comparisonResult && (
        <div className="space-y-6">
          {/* Summary */}
          <Card>
            <CardHeader>
              <CardTitle>Comparison Summary</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-gray-900">{comparisonResult.summary.totalChanges}</div>
                  <div className="text-sm text-gray-600">Total Changes</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-red-600">{comparisonResult.summary.highRiskChanges}</div>
                  <div className="text-sm text-gray-600">High Risk</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-yellow-600">{comparisonResult.summary.mediumRiskChanges}</div>
                  <div className="text-sm text-gray-600">Medium Risk</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-gray-900">{comparisonResult.summary.overallRiskScore}</div>
                  <div className="text-sm text-gray-600">Risk Score</div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Detailed Changes */}
          <Tabs defaultValue="changes">
            <TabsList>
              <TabsTrigger value="changes">Detailed Changes</TabsTrigger>
              <TabsTrigger value="clauses">Clause Comparison</TabsTrigger>
              <TabsTrigger value="side-by-side">Side-by-Side</TabsTrigger>
            </TabsList>

            <TabsContent value="changes" className="space-y-4">
              {comparisonResult.changes.map((change: any) => (
                <Card key={change.id} className="bg-slate-800 border-slate-700">
                  <CardContent className="p-6">
                    <div className="flex items-start justify-between mb-4">
                      <div className="flex items-center space-x-2">
                        {getChangeIcon(change.changeType)}
                        <h3 className="font-medium text-white">{change.type}</h3>
                        <Badge variant="outline" className="border-slate-600 text-slate-300">
                          {change.changeType}
                        </Badge>
                        <Badge
                          variant={change.riskLevel === "High" ? "destructive" : "default"}
                          className="bg-slate-700 text-slate-200 border-slate-600"
                        >
                          {change.riskLevel} Risk
                        </Badge>
                      </div>
                      <Badge variant="outline" className="border-slate-600 text-slate-300">
                        Page {change.page}
                      </Badge>
                    </div>

                    <p className="text-sm text-slate-300 mb-4">{change.description}</p>

                    <div className="space-y-3 mb-4">
                      {change.document1Text && (
                        <div className="p-3 rounded border border-green-500/30 bg-green-500/10">
                          <div className="text-xs font-medium mb-1 text-green-400">Original</div>
                          <div className="text-sm text-slate-200">{change.document1Text}</div>
                        </div>
                      )}
                      <div
                        className={`p-3 rounded border ${
                          change.riskLevel === "High"
                            ? "border-red-500/30 bg-red-500/10"
                            : change.riskLevel === "Medium"
                              ? "border-yellow-500/30 bg-yellow-500/10"
                              : "border-blue-500/30 bg-blue-500/10"
                        }`}
                      >
                        <div className="text-xs font-medium mb-1 text-slate-300">
                          {change.changeType === "Added" ? "Added" : "Modified"}
                        </div>
                        <div className="text-sm text-slate-200">{change.document2Text}</div>
                      </div>
                    </div>

                    <div className="bg-blue-500/10 border border-blue-500/30 p-3 rounded">
                      <div className="text-sm text-slate-200">
                        <strong className="text-blue-400">Impact:</strong> {change.impact}
                      </div>
                      <div className="text-sm mt-1 text-slate-200">
                        <strong className="text-blue-400">Recommendation:</strong> {change.recommendation}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </TabsContent>

            <TabsContent value="clauses" className="space-y-4">
              <Card>
                <CardHeader>
                  <CardTitle>Clause-by-Clause Comparison</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-3">
                    {comparisonResult.clauseComparison.map((clause: any, index: number) => (
                      <div key={index} className="flex items-center justify-between p-3 border rounded">
                        <div className="flex items-center space-x-3">
                          <div className="font-medium">{clause.clauseType}</div>
                          <Badge variant={clause.status === "Unchanged" ? "secondary" : "default"}>
                            {clause.status}
                          </Badge>
                        </div>
                        <Badge variant={clause.riskLevel === "High" ? "destructive" : "outline"}>
                          {clause.riskLevel} Risk
                        </Badge>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="side-by-side">
              <Card>
                <CardHeader>
                  <div className="flex justify-between items-center">
                    <CardTitle>Side-by-Side Comparison</CardTitle>
                    <Button variant="outline" size="sm">
                      <Download className="w-4 h-4 mr-2" />
                      Export Report
                    </Button>
                  </div>
                </CardHeader>
                <CardContent>
                  <div className="grid grid-cols-2 gap-4 h-96">
                    <div className="border rounded p-4 overflow-y-auto">
                      <h4 className="font-medium mb-2">Document 1</h4>
                      <div className="text-sm text-gray-700">
                        [Document content would be displayed here with highlighting for changes]
                      </div>
                    </div>
                    <div className="border rounded p-4 overflow-y-auto">
                      <h4 className="font-medium mb-2">Document 2</h4>
                      <div className="text-sm text-gray-700">
                        [Document content would be displayed here with highlighting for changes]
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>
        </div>
      )}
    </div>
  )
}
