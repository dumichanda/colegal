"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Workflow, Bot, CheckCircle, Clock, AlertTriangle, Play } from "lucide-react"

interface WorkflowPanelProps {
  documentId?: string
  organizationId?: string
}

export function MastraWorkflowPanel({ documentId, organizationId }: WorkflowPanelProps) {
  const [activeWorkflows, setActiveWorkflows] = useState<any[]>([])
  const [workflowHistory, setWorkflowHistory] = useState<any[]>([
    {
      id: "wf_001",
      name: "Document Analysis Pipeline",
      status: "completed",
      progress: 100,
      startTime: "2024-12-15T10:30:00Z",
      endTime: "2024-12-15T10:35:00Z",
      results: {
        clausesAnalyzed: 18,
        riskLevel: "Medium",
        complianceScore: 85,
      },
    },
    {
      id: "wf_002",
      name: "Compliance Monitoring Pipeline",
      status: "running",
      progress: 60,
      startTime: "2024-12-15T11:00:00Z",
      endTime: null,
      results: null,
    },
  ])

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

    setActiveWorkflows([...activeWorkflows, newWorkflow])

    try {
      // Simulate workflow progress
      const progressInterval = setInterval(() => {
        setActiveWorkflows((workflows) =>
          workflows.map((wf) => (wf.id === newWorkflow.id ? { ...wf, progress: Math.min(wf.progress + 20, 90) } : wf)),
        )
      }, 1000)

      const response = await fetch("/api/mastra/workflow", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          workflowType,
          documentId,
          organizationId,
          parameters: {
            content: "Sample document content for analysis",
          },
        }),
      })

      const result = await response.json()

      clearInterval(progressInterval)

      if (result.success) {
        const completedWorkflow = {
          ...newWorkflow,
          status: "completed",
          progress: 100,
          endTime: new Date().toISOString(),
          results: result.data.results,
        }

        setActiveWorkflows((workflows) => workflows.filter((wf) => wf.id !== newWorkflow.id))
        setWorkflowHistory([completedWorkflow, ...workflowHistory])
      } else {
        throw new Error(result.error)
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

  return (
    <Card className="bg-slate-800 border-slate-700">
      <CardHeader>
        <CardTitle className="flex items-center text-white">
          <Workflow className="w-5 h-5 mr-2" />
          Mastra AI Workflows
        </CardTitle>
      </CardHeader>
      <CardContent>
        <Tabs defaultValue="active" className="space-y-4">
          <TabsList className="grid w-full grid-cols-2 bg-slate-700 border-slate-600">
            <TabsTrigger value="active" className="data-[state=active]:bg-slate-600 text-slate-200">
              Active Workflows
            </TabsTrigger>
            <TabsTrigger value="history" className="data-[state=active]:bg-slate-600 text-slate-200">
              Workflow History
            </TabsTrigger>
          </TabsList>

          <TabsContent value="active" className="space-y-4">
            {/* Workflow Triggers */}
            <div className="grid grid-cols-1 gap-3">
              <Button
                onClick={() => runWorkflow("document_analysis")}
                disabled={!documentId}
                className="bg-blue-600 hover:bg-blue-700 justify-start"
              >
                <Play className="w-4 h-4 mr-2" />
                Run Document Analysis Pipeline
              </Button>
              <Button
                onClick={() => runWorkflow("compliance_monitoring")}
                disabled={!organizationId}
                variant="outline"
                className="border-slate-600 text-slate-300 hover:bg-slate-700 justify-start"
              >
                <Bot className="w-4 h-4 mr-2" />
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
                    </div>
                  </div>
                ))}
              </div>
            )}

            {activeWorkflows.length === 0 && (
              <div className="text-center py-8 text-slate-400">
                <Workflow className="w-12 h-12 mx-auto mb-2 opacity-50" />
                <p>No active workflows</p>
                <p className="text-sm">Start a workflow to begin AI-powered analysis</p>
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
                    <h5 className="font-medium text-white mb-2">Results</h5>
                    <div className="grid grid-cols-3 gap-4 text-sm">
                      {Object.entries(workflow.results).map(([key, value]) => (
                        <div key={key}>
                          <div className="text-slate-400 capitalize">{key.replace(/([A-Z])/g, " $1")}</div>
                          <div className="text-white font-medium">{String(value)}</div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            ))}
          </TabsContent>
        </Tabs>
      </CardContent>
    </Card>
  )
}
