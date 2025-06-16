"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Workflow, Bot, CheckCircle, Clock, AlertTriangle, Play, Zap, Brain } from "lucide-react"

interface WorkflowPanelProps {
  documentId?: string
  organizationId?: string
}

export function MastraWorkflowPanel({ documentId, organizationId }: WorkflowPanelProps) {
  const [activeWorkflows, setActiveWorkflows] = useState<any[]>([])
  const [workflowHistory, setWorkflowHistory] = useState<any[]>([])
  const [isLoading, setIsLoading] = useState(true)

  // Load workflow history on component mount
  useEffect(() => {
    loadWorkflowHistory()
  }, [])

  const loadWorkflowHistory = async () => {
    try {
      console.log("Loading workflow history...")
      // Simulate loading workflow history - in a real app, this would come from an API
      setTimeout(() => {
        setWorkflowHistory([
          {
            id: "wf_001",
            name: "Document Analysis Pipeline",
            status: "completed",
            progress: 100,
            startTime: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(), // 2 hours ago
            endTime: new Date(Date.now() - 2 * 60 * 60 * 1000 + 5 * 60 * 1000).toISOString(), // 5 minutes later
            results: {
              clausesAnalyzed: 18,
              riskLevel: "Medium",
              complianceScore: 85,
              aiPowered: true,
            },
          },
          {
            id: "wf_002",
            name: "Compliance Monitoring Pipeline",
            status: "completed",
            progress: 100,
            startTime: new Date(Date.now() - 1 * 60 * 60 * 1000).toISOString(), // 1 hour ago
            endTime: new Date(Date.now() - 1 * 60 * 60 * 1000 + 3 * 60 * 1000).toISOString(), // 3 minutes later
            results: {
              alertsGenerated: 3,
              complianceStatus: "Mostly Compliant",
              nextReview: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
              aiPowered: false,
            },
          },
        ])
        setIsLoading(false)
      }, 1000)
    } catch (error) {
      console.error("Failed to load workflow history:", error)
      setIsLoading(false)
    }
  }

  const runWorkflow = async (workflowType: string) => {
    const newWorkflow = {
      id: `wf_${Date.now()}`,
      name: workflowType === "document_analysis" ? "Document Analysis Pipeline" : "Compliance Monitoring Pipeline",
      status: "running",
      progress: 0,
      startTime: new Date().toISOString(),
      endTime: null,
      results: null,
    }

    console.log(`Starting workflow: ${workflowType}`, { documentId, organizationId })
    setActiveWorkflows([...activeWorkflows, newWorkflow])

    try {
      // Simulate workflow progress
      const progressInterval = setInterval(() => {
        setActiveWorkflows((workflows) =>
          workflows.map((wf) =>
            wf.id === newWorkflow.id ? { ...wf, progress: Math.min(wf.progress + Math.random() * 25, 90) } : wf,
          ),
        )
      }, 1500)

      console.log("Making API call to /api/mastra/workflow")
      const response = await fetch("/api/mastra/workflow", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          workflowType,
          documentId: documentId || "sample-doc-id",
          organizationId: organizationId || "sample-org-id",
          parameters: {
            content: "Sample document content for analysis - this would normally be extracted from the actual document",
            analysisType: "comprehensive",
          },
        }),
      })

      const result = await response.json()
      console.log("Workflow API response:", result)

      clearInterval(progressInterval)

      if (result.success) {
        const completedWorkflow = {
          ...newWorkflow,
          status: "completed",
          progress: 100,
          endTime: new Date().toISOString(),
          results: result.data.results || result.data,
        }

        setActiveWorkflows((workflows) => workflows.filter((wf) => wf.id !== newWorkflow.id))
        setWorkflowHistory([completedWorkflow, ...workflowHistory])

        console.log("Workflow completed successfully:", completedWorkflow)
      } else {
        throw new Error(result.error || "Workflow failed")
      }
    } catch (error) {
      console.error("Workflow failed:", error)
      setActiveWorkflows((workflows) =>
        workflows.map((wf) => (wf.id === newWorkflow.id ? { ...wf, status: "failed", progress: 0 } : wf)),
      )
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "completed":
        return <CheckCircle className="w-4 h-4 text-green-400" />
      case "running":
        return <Clock className="w-4 h-4 text-blue-400 animate-spin" />
      case "failed":
        return <AlertTriangle className="w-4 h-4 text-red-400" />
      default:
        return <Clock className="w-4 h-4 text-slate-400" />
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case "completed":
        return "default"
      case "running":
        return "secondary"
      case "failed":
        return "destructive"
      default:
        return "outline"
    }
  }

  if (isLoading) {
    return (
      <Card className="bg-slate-800 border-slate-700">
        <CardHeader>
          <CardTitle className="flex items-center text-white">
            <Workflow className="w-5 h-5 mr-2" />
            Mastra AI Workflows
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-center py-8 text-slate-400">
            <div className="w-8 h-8 border-2 border-blue-400 border-t-transparent rounded-full animate-spin mx-auto mb-2" />
            <p>Loading workflows...</p>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className="bg-slate-800 border-slate-700">
      <CardHeader>
        <CardTitle className="flex items-center text-white">
          <Workflow className="w-5 h-5 mr-2" />
          Mastra AI Workflows
          <Badge variant="outline" className="ml-2 text-xs">
            {process.env.NEXT_PUBLIC_OPENAI_API_KEY ? "AI Enabled" : "Fallback Mode"}
          </Badge>
        </CardTitle>
      </CardHeader>
      <CardContent>
        <Tabs defaultValue="active" className="space-y-4">
          <TabsList className="grid w-full grid-cols-2 bg-slate-700 border-slate-600">
            <TabsTrigger value="active" className="data-[state=active]:bg-slate-600 text-slate-200">
              Active Workflows ({activeWorkflows.length})
            </TabsTrigger>
            <TabsTrigger value="history" className="data-[state=active]:bg-slate-600 text-slate-200">
              History ({workflowHistory.length})
            </TabsTrigger>
          </TabsList>

          <TabsContent value="active" className="space-y-4">
            {/* Workflow Triggers */}
            <div className="grid grid-cols-1 gap-3">
              <Button
                onClick={() => runWorkflow("document_analysis")}
                className="bg-blue-600 hover:bg-blue-700 justify-start"
              >
                <Play className="w-4 h-4 mr-2" />
                <Brain className="w-4 h-4 mr-2" />
                Run Document Analysis Pipeline
              </Button>
              <Button
                onClick={() => runWorkflow("compliance_monitoring")}
                variant="outline"
                className="border-slate-600 text-slate-300 hover:bg-slate-700 justify-start"
              >
                <Bot className="w-4 h-4 mr-2" />
                <Zap className="w-4 h-4 mr-2" />
                Run Compliance Monitoring
              </Button>
            </div>

            {/* Active Workflows */}
            {activeWorkflows.length > 0 && (
              <div className="space-y-3">
                <h4 className="font-medium text-white">Running Workflows</h4>
                {activeWorkflows.map((workflow) => (
                  <div key={workflow.id} className="p-3 border border-slate-600 rounded-lg bg-slate-700/30">
                    <div className="flex items-center justify-between mb-2">
                      <div className="flex items-center space-x-2">
                        {getStatusIcon(workflow.status)}
                        <span className="font-medium text-white">{workflow.name}</span>
                      </div>
                      <Badge variant={getStatusColor(workflow.status)} className="bg-slate-600 text-slate-200">
                        {workflow.status}
                      </Badge>
                    </div>
                    <Progress value={workflow.progress} className="mb-2 bg-slate-600" />
                    <div className="text-xs text-slate-400">
                      Started: {new Date(workflow.startTime).toLocaleTimeString()}
                      {workflow.progress > 0 && (
                        <span className="ml-2">• Progress: {Math.round(workflow.progress)}%</span>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}

            {activeWorkflows.length === 0 && (
              <div className="text-center py-8 text-slate-400">
                <Workflow className="w-12 h-12 mx-auto mb-2 opacity-50" />
                <p>No active workflows</p>
                <p className="text-sm">Click a button above to start AI-powered analysis</p>
              </div>
            )}
          </TabsContent>

          <TabsContent value="history" className="space-y-4">
            {workflowHistory.map((workflow) => (
              <div key={workflow.id} className="p-4 border border-slate-600 rounded-lg bg-slate-700/30">
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center space-x-2">
                    {getStatusIcon(workflow.status)}
                    <span className="font-medium text-white">{workflow.name}</span>
                    {workflow.results?.aiPowered && (
                      <Badge variant="outline" className="text-xs bg-blue-500/10 text-blue-400 border-blue-500/20">
                        <Brain className="w-3 h-3 mr-1" />
                        AI Powered
                      </Badge>
                    )}
                  </div>
                  <Badge variant={getStatusColor(workflow.status)} className="bg-slate-600 text-slate-200">
                    {workflow.status}
                  </Badge>
                </div>

                <div className="grid grid-cols-2 gap-4 text-sm text-slate-300 mb-3">
                  <div>
                    <span className="text-slate-400">Started:</span> {new Date(workflow.startTime).toLocaleString()}
                  </div>
                  {workflow.endTime && (
                    <div>
                      <span className="text-slate-400">Completed:</span> {new Date(workflow.endTime).toLocaleString()}
                    </div>
                  )}
                </div>

                {workflow.results && (
                  <div className="bg-slate-600 p-3 rounded border border-slate-500">
                    <h5 className="font-medium text-white mb-2 flex items-center">
                      Results
                      {workflow.results.aiPowered && <Zap className="w-3 h-3 ml-2 text-yellow-400" />}
                    </h5>
                    <div className="grid grid-cols-3 gap-4 text-sm">
                      {Object.entries(workflow.results)
                        .filter(([key]) => key !== "aiPowered")
                        .map(([key, value]) => (
                          <div key={key}>
                            <div className="text-slate-400 capitalize">{key.replace(/([A-Z])/g, " $1")}</div>
                            <div className="text-white font-medium">
                              {typeof value === "string" && value.includes("T") && value.includes("Z")
                                ? new Date(value).toLocaleDateString()
                                : String(value)}
                            </div>
                          </div>
                        ))}
                    </div>
                  </div>
                )}
              </div>
            ))}

            {workflowHistory.length === 0 && (
              <div className="text-center py-8 text-slate-400">
                <Clock className="w-12 h-12 mx-auto mb-2 opacity-50" />
                <p>No workflow history</p>
                <p className="text-sm">Completed workflows will appear here</p>
              </div>
            )}
          </TabsContent>
        </Tabs>
      </CardContent>
    </Card>
  )
}
