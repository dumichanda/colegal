"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Progress } from "@/components/ui/progress"
import { CheckCircle, Clock, AlertTriangle, Play, Pause, RotateCcw } from "lucide-react"

interface Task {
  id: string
  name: string
  status: string
  progress: number
  type: string
  created_at: string
  updated_at: string
  estimated_completion?: string
  error_message?: string
}

export function TaskMonitor() {
  const [tasks, setTasks] = useState<Task[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function fetchTasks() {
      try {
        const response = await fetch("/api/tasks")
        if (!response.ok) throw new Error("Failed to fetch tasks")
        const data = await response.json()
        setTasks(data)
      } catch (error) {
        console.error("Error fetching tasks:", error)
        setTasks([])
      } finally {
        setLoading(false)
      }
    }

    fetchTasks()

    // Poll for updates every 5 seconds
    const interval = setInterval(fetchTasks, 5000)
    return () => clearInterval(interval)
  }, [])

  const handleTaskAction = async (taskId: string, action: string) => {
    try {
      const response = await fetch(`/api/tasks/${taskId}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ action }),
      })

      if (!response.ok) throw new Error("Failed to update task")

      // Refresh tasks
      const updatedResponse = await fetch("/api/tasks")
      if (updatedResponse.ok) {
        const data = await updatedResponse.json()
        setTasks(data)
      }
    } catch (error) {
      console.error("Error updating task:", error)
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status.toLowerCase()) {
      case "completed":
        return <CheckCircle className="w-4 h-4 text-green-400" />
      case "running":
        return <Clock className="w-4 h-4 text-blue-400" />
      case "failed":
        return <AlertTriangle className="w-4 h-4 text-red-400" />
      case "paused":
        return <Pause className="w-4 h-4 text-yellow-400" />
      default:
        return <Clock className="w-4 h-4 text-slate-400" />
    }
  }

  const getStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case "completed":
        return "bg-green-500/20 text-green-400 border-green-500/30"
      case "running":
        return "bg-blue-500/20 text-blue-400 border-blue-500/30"
      case "failed":
        return "bg-red-500/20 text-red-400 border-red-500/30"
      case "paused":
        return "bg-yellow-500/20 text-yellow-400 border-yellow-500/30"
      default:
        return "bg-slate-500/20 text-slate-400 border-slate-500/30"
    }
  }

  const formatTimeAgo = (dateString: string) => {
    const date = new Date(dateString)
    const now = new Date()
    const diffInMinutes = Math.floor((now.getTime() - date.getTime()) / (1000 * 60))

    if (diffInMinutes < 1) return "Just now"
    if (diffInMinutes < 60) return `${diffInMinutes}m ago`
    const diffInHours = Math.floor(diffInMinutes / 60)
    if (diffInHours < 24) return `${diffInHours}h ago`
    const diffInDays = Math.floor(diffInHours / 24)
    return `${diffInDays}d ago`
  }

  if (loading) {
    return (
      <Card className="bg-slate-800 border-slate-700">
        <CardHeader>
          <CardTitle className="text-lg font-semibold text-white">Task Monitor</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {[1, 2, 3].map((i) => (
              <div key={i} className="animate-pulse p-4 border border-slate-700 rounded-lg">
                <div className="h-4 bg-slate-700 rounded w-3/4 mb-2"></div>
                <div className="h-2 bg-slate-700 rounded mb-2"></div>
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
      <CardHeader>
        <CardTitle className="text-lg font-semibold text-white">Task Monitor</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {tasks.length === 0 ? (
            <div className="text-center py-8 text-slate-400">
              <CheckCircle className="w-12 h-12 mx-auto mb-2 opacity-50" />
              <p>No active tasks</p>
            </div>
          ) : (
            tasks.map((task) => (
              <div key={task.id} className="p-4 border border-slate-700 rounded-lg">
                <div className="flex items-start justify-between mb-3">
                  <div className="flex items-center space-x-2">
                    {getStatusIcon(task.status)}
                    <h4 className="font-medium text-white">{task.name}</h4>
                    <Badge variant="outline" className="text-xs border-slate-600 text-slate-300">
                      {task.type}
                    </Badge>
                  </div>
                  <Badge className={`text-xs border ${getStatusColor(task.status)}`}>{task.status}</Badge>
                </div>

                {task.status === "running" && (
                  <div className="mb-3">
                    <div className="flex justify-between text-sm mb-1">
                      <span className="text-slate-300">Progress</span>
                      <span className="text-slate-200">{task.progress}%</span>
                    </div>
                    <Progress value={task.progress} className="bg-slate-700" />
                  </div>
                )}

                {task.error_message && (
                  <div className="mb-3 p-2 bg-red-500/10 border border-red-500/30 rounded text-sm text-red-300">
                    {task.error_message}
                  </div>
                )}

                <div className="flex items-center justify-between text-xs text-slate-400">
                  <span>Started {formatTimeAgo(task.created_at)}</span>
                  {task.estimated_completion && <span>ETA: {task.estimated_completion}</span>}
                </div>

                <div className="flex space-x-2 mt-3">
                  {task.status === "running" && (
                    <Button
                      variant="outline"
                      size="sm"
                      className="text-xs border-slate-600 text-slate-300 hover:bg-slate-700"
                      onClick={() => handleTaskAction(task.id, "pause")}
                    >
                      <Pause className="w-3 h-3 mr-1" />
                      Pause
                    </Button>
                  )}
                  {task.status === "paused" && (
                    <Button
                      variant="outline"
                      size="sm"
                      className="text-xs border-slate-600 text-slate-300 hover:bg-slate-700"
                      onClick={() => handleTaskAction(task.id, "resume")}
                    >
                      <Play className="w-3 h-3 mr-1" />
                      Resume
                    </Button>
                  )}
                  {task.status === "failed" && (
                    <Button
                      variant="outline"
                      size="sm"
                      className="text-xs border-slate-600 text-slate-300 hover:bg-slate-700"
                      onClick={() => handleTaskAction(task.id, "retry")}
                    >
                      <RotateCcw className="w-3 h-3 mr-1" />
                      Retry
                    </Button>
                  )}
                </div>
              </div>
            ))
          )}
        </div>
      </CardContent>
    </Card>
  )
}
