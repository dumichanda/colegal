"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Progress } from "@/components/ui/progress"
import { Activity, Clock, Users, CheckCircle, RefreshCw, Download } from "lucide-react"

interface TaskEvent {
  id: string
  timestamp: string
  type: string
  action: string
  details: Record<string, any>
  userId?: string
}

interface TaskSummary {
  totalEvents: number
  eventsByType: Record<string, number>
  recentActivity: TaskEvent[]
  activeUsers: string[]
  systemHealth: {
    status: "healthy" | "warning" | "error"
    lastUpdate: string
    performance: {
      averageResponseTime: number
      errorRate: number
    }
  }
}

export function TaskMonitor() {
  const [summary, setSummary] = useState<TaskSummary | null>(null)
  const [events, setEvents] = useState<TaskEvent[]>([])
  const [loading, setLoading] = useState(true)
  const [autoRefresh, setAutoRefresh] = useState(true)

  const fetchSummary = async () => {
    try {
      const response = await fetch("/api/tasks/summary")
      const result = await response.json()
      if (result.success) {
        setSummary(result.data)
      }
    } catch (error) {
      console.error("Failed to fetch task summary:", error)
    }
  }

  const fetchEvents = async () => {
    try {
      const response = await fetch("/api/tasks?limit=50")
      const result = await response.json()
      if (result.success) {
        setEvents(result.data)
      }
    } catch (error) {
      console.error("Failed to fetch events:", error)
    }
  }

  const refreshData = async () => {
    setLoading(true)
    await Promise.all([fetchSummary(), fetchEvents()])
    setLoading(false)
  }

  useEffect(() => {
    refreshData()
  }, [])

  useEffect(() => {
    if (autoRefresh) {
      const interval = setInterval(refreshData, 10000) // Refresh every 10 seconds
      return () => clearInterval(interval)
    }
  }, [autoRefresh])

  const getStatusColor = (status: string) => {
    switch (status) {
      case "healthy":
        return "text-green-400"
      case "warning":
        return "text-yellow-400"
      case "error":
        return "text-red-400"
      default:
        return "text-slate-400"
    }
  }

  const getEventTypeColor = (type: string) => {
    const colors: Record<string, string> = {
      chat: "bg-blue-500/20 text-blue-400 border-blue-500/30",
      file: "bg-green-500/20 text-green-400 border-green-500/30",
      workflow: "bg-purple-500/20 text-purple-400 border-purple-500/30",
      document: "bg-orange-500/20 text-orange-400 border-orange-500/30",
      compliance: "bg-red-500/20 text-red-400 border-red-500/30",
      user: "bg-cyan-500/20 text-cyan-400 border-cyan-500/30",
      system: "bg-slate-500/20 text-slate-400 border-slate-500/30",
    }
    return colors[type] || colors.system
  }

  const formatTimestamp = (timestamp: string) => {
    return new Date(timestamp).toLocaleString()
  }

  const exportTasks = async () => {
    try {
      const response = await fetch("/api/tasks?limit=1000")
      const result = await response.json()
      if (result.success) {
        const dataStr = JSON.stringify(result.data, null, 2)
        const dataBlob = new Blob([dataStr], { type: "application/json" })
        const url = URL.createObjectURL(dataBlob)
        const link = document.createElement("a")
        link.href = url
        link.download = `tasks-export-${new Date().toISOString().split("T")[0]}.json`
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
        URL.revokeObjectURL(url)
      }
    } catch (error) {
      console.error("Failed to export tasks:", error)
    }
  }

  if (loading && !summary) {
    return (
      <Card className="bg-slate-800 border-slate-700">
        <CardContent className="p-6 text-center">
          <RefreshCw className="w-8 h-8 animate-spin text-blue-400 mx-auto mb-2" />
          <p className="text-slate-300">Loading task monitor...</p>
        </CardContent>
      </Card>
    )
  }

  return (
    <div className="space-y-6">
      {/* System Health Overview */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card className="bg-slate-800 border-slate-700">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-400">System Status</p>
                <div className="flex items-center space-x-2">
                  <div
                    className={`w-2 h-2 rounded-full ${
                      summary?.systemHealth.status === "healthy"
                        ? "bg-green-400"
                        : summary?.systemHealth.status === "warning"
                          ? "bg-yellow-400"
                          : "bg-red-400"
                    }`}
                  />
                  <p className={`font-medium capitalize ${getStatusColor(summary?.systemHealth.status || "unknown")}`}>
                    {summary?.systemHealth.status || "Unknown"}
                  </p>
                </div>
              </div>
              <Activity className="w-8 h-8 text-slate-400" />
            </div>
          </CardContent>
        </Card>

        <Card className="bg-slate-800 border-slate-700">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-400">Total Events</p>
                <p className="text-2xl font-bold text-white">{summary?.totalEvents || 0}</p>
              </div>
              <Clock className="w-8 h-8 text-slate-400" />
            </div>
          </CardContent>
        </Card>

        <Card className="bg-slate-800 border-slate-700">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-400">Active Users</p>
                <p className="text-2xl font-bold text-white">{summary?.activeUsers.length || 0}</p>
              </div>
              <Users className="w-8 h-8 text-slate-400" />
            </div>
          </CardContent>
        </Card>

        <Card className="bg-slate-800 border-slate-700">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-slate-400">Avg Response</p>
                <p className="text-2xl font-bold text-white">
                  {Math.round(summary?.systemHealth.performance.averageResponseTime || 0)}ms
                </p>
              </div>
              <CheckCircle className="w-8 h-8 text-slate-400" />
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Main Task Monitor */}
      <Card className="bg-slate-800 border-slate-700">
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle className="flex items-center text-white">
              <Activity className="w-5 h-5 mr-2" />
              Real-time Task Monitor
            </CardTitle>
            <div className="flex items-center space-x-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setAutoRefresh(!autoRefresh)}
                className={`border-slate-600 ${autoRefresh ? "text-green-400" : "text-slate-300"} hover:bg-slate-700`}
              >
                <RefreshCw className={`w-4 h-4 mr-2 ${autoRefresh ? "animate-spin" : ""}`} />
                Auto Refresh
              </Button>
              <Button
                variant="outline"
                size="sm"
                onClick={refreshData}
                className="border-slate-600 text-slate-300 hover:bg-slate-700"
              >
                <RefreshCw className="w-4 h-4 mr-2" />
                Refresh
              </Button>
              <Button
                variant="outline"
                size="sm"
                onClick={exportTasks}
                className="border-slate-600 text-slate-300 hover:bg-slate-700"
              >
                <Download className="w-4 h-4 mr-2" />
                Export
              </Button>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <Tabs defaultValue="events" className="space-y-4">
            <TabsList className="grid w-full grid-cols-3 bg-slate-700 border-slate-600">
              <TabsTrigger value="events" className="data-[state=active]:bg-slate-600 text-slate-200">
                Recent Events
              </TabsTrigger>
              <TabsTrigger value="analytics" className="data-[state=active]:bg-slate-600 text-slate-200">
                Analytics
              </TabsTrigger>
              <TabsTrigger value="performance" className="data-[state=active]:bg-slate-600 text-slate-200">
                Performance
              </TabsTrigger>
            </TabsList>

            <TabsContent value="events" className="space-y-4">
              <div className="space-y-3 max-h-96 overflow-y-auto">
                {events.map((event) => (
                  <div key={event.id} className="p-3 border border-slate-600 rounded-lg bg-slate-700/30">
                    <div className="flex items-start justify-between mb-2">
                      <div className="flex items-center space-x-2">
                        <Badge className={getEventTypeColor(event.type)}>{event.type}</Badge>
                        <span className="font-medium text-white">{event.action}</span>
                      </div>
                      <span className="text-xs text-slate-400">{formatTimestamp(event.timestamp)}</span>
                    </div>
                    <div className="text-sm text-slate-300">
                      {JSON.stringify(event.details, null, 2).substring(0, 200)}
                      {JSON.stringify(event.details).length > 200 && "..."}
                    </div>
                    {event.userId && (
                      <div className="mt-2">
                        <Badge variant="outline" className="text-xs border-slate-600 text-slate-300">
                          User: {event.userId}
                        </Badge>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </TabsContent>

            <TabsContent value="analytics" className="space-y-4">
              <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                {Object.entries(summary?.eventsByType || {}).map(([type, count]) => (
                  <div key={type} className="p-3 border border-slate-600 rounded-lg bg-slate-700/30">
                    <div className="text-center">
                      <div className="text-2xl font-bold text-white">{count}</div>
                      <div className="text-sm text-slate-300 capitalize">{type} Events</div>
                    </div>
                  </div>
                ))}
              </div>
            </TabsContent>

            <TabsContent value="performance" className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <Card className="bg-slate-700 border-slate-600">
                  <CardHeader>
                    <CardTitle className="text-white text-sm">Response Time</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="text-2xl font-bold text-white mb-2">
                      {Math.round(summary?.systemHealth.performance.averageResponseTime || 0)}ms
                    </div>
                    <Progress
                      value={Math.min((summary?.systemHealth.performance.averageResponseTime || 0) / 10, 100)}
                      className="bg-slate-600"
                    />
                  </CardContent>
                </Card>

                <Card className="bg-slate-700 border-slate-600">
                  <CardHeader>
                    <CardTitle className="text-white text-sm">Error Rate</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="text-2xl font-bold text-white mb-2">
                      {summary?.systemHealth.performance.errorRate.toFixed(2) || 0}%
                    </div>
                    <Progress value={summary?.systemHealth.performance.errorRate || 0} className="bg-slate-600" />
                  </CardContent>
                </Card>
              </div>
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>
    </div>
  )
}
