"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { AlertTriangle, Clock, CheckCircle, XCircle } from "lucide-react"

interface ComplianceAlert {
  id: string
  title: string
  description: string
  priority: "Critical" | "High" | "Medium" | "Low"
  due_date: string
  type: string
  status: string
  regulation_source?: string
  jurisdiction?: string
}

export function ComplianceAlerts() {
  const [alerts, setAlerts] = useState<ComplianceAlert[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchAlerts()
  }, [])

  const fetchAlerts = async () => {
    try {
      console.log("🔄 Fetching compliance alerts...")
      setLoading(true)
      setError(null)

      const response = await fetch("/api/compliance/alerts")

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const contentType = response.headers.get("content-type")
      if (!contentType || !contentType.includes("application/json")) {
        const text = await response.text()
        console.error("❌ Non-JSON response:", text)
        throw new Error("Server returned non-JSON response")
      }

      const data = await response.json()
      console.log("✅ Compliance alerts received:", data)

      if (data.success) {
        setAlerts(data.data || [])
      } else {
        setAlerts(Array.isArray(data) ? data : [])
      }
    } catch (err) {
      console.error("❌ Error fetching compliance alerts:", err)
      setError(err instanceof Error ? err.message : "Failed to load compliance alerts")
      // Set fallback data on error
      setAlerts([])
    } finally {
      setLoading(false)
    }
  }

  const handleDismissAlert = async (alertId: string) => {
    try {
      console.log("🔄 Dismissing alert:", alertId)
      const response = await fetch(`/api/compliance/alerts/${alertId}`, {
        method: "DELETE",
      })
      if (response.ok) {
        setAlerts(alerts.filter((alert) => alert.id !== alertId))
        console.log("✅ Alert dismissed successfully")
      }
    } catch (error) {
      console.error("❌ Error dismissing alert:", error)
    }
  }

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case "Critical":
        return "destructive"
      case "High":
        return "destructive"
      case "Medium":
        return "default"
      case "Low":
        return "secondary"
      default:
        return "secondary"
    }
  }

  const getPriorityIcon = (priority: string) => {
    switch (priority) {
      case "Critical":
        return <XCircle className="h-4 w-4" />
      case "High":
        return <AlertTriangle className="h-4 w-4" />
      case "Medium":
        return <Clock className="h-4 w-4" />
      case "Low":
        return <CheckCircle className="h-4 w-4" />
      default:
        return <Clock className="h-4 w-4" />
    }
  }

  const formatDate = (dateString: string) => {
    if (!dateString) return "No due date"
    try {
      return new Date(dateString).toLocaleDateString("en-ZA", {
        year: "numeric",
        month: "short",
        day: "numeric",
      })
    } catch {
      return dateString
    }
  }

  if (loading) {
    return (
      <Card className="bg-slate-800 border-slate-700">
        <CardHeader>
          <CardTitle className="text-lg font-semibold text-white">Compliance Alerts</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="animate-pulse">
                <div className="h-4 bg-slate-700 rounded w-3/4 mb-2"></div>
                <div className="h-3 bg-slate-700 rounded w-1/2"></div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    )
  }

  if (error) {
    return (
      <Card className="bg-slate-800 border-slate-700">
        <CardHeader>
          <CardTitle className="text-lg font-semibold text-white">Compliance Alerts</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-center py-4">
            <AlertTriangle className="h-8 w-8 text-red-400 mx-auto mb-2" />
            <p className="text-red-400 mb-4">{error}</p>
            <Button onClick={fetchAlerts} variant="outline" className="border-slate-600 text-slate-300">
              Try Again
            </Button>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className="bg-slate-800 border-slate-700">
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-white">
          <AlertTriangle className="h-5 w-5" />
          Compliance Alerts
        </CardTitle>
      </CardHeader>
      <CardContent>
        {alerts.length === 0 ? (
          <div className="text-center py-8">
            <CheckCircle className="h-12 w-12 text-green-400 mx-auto mb-4" />
            <p className="text-slate-300">No compliance alerts at this time</p>
            <p className="text-sm text-slate-500">All compliance requirements are up to date</p>
          </div>
        ) : (
          <div className="space-y-4">
            {alerts.map((alert) => (
              <div
                key={alert.id}
                className="border border-slate-700 rounded-lg p-4 hover:bg-slate-700/50 transition-colors"
              >
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-2">
                      {getPriorityIcon(alert.priority)}
                      <h4 className="font-medium text-white">{alert.title}</h4>
                      <Badge variant={getPriorityColor(alert.priority) as any} className="border-slate-600">
                        {alert.priority}
                      </Badge>
                    </div>
                    {alert.description && <p className="text-sm text-slate-400 mb-2">{alert.description}</p>}
                    <div className="flex items-center gap-4 text-xs text-slate-500">
                      <span>Due: {formatDate(alert.due_date)}</span>
                      {alert.regulation_source && <span>Source: {alert.regulation_source}</span>}
                      {alert.jurisdiction && <span>Jurisdiction: {alert.jurisdiction}</span>}
                    </div>
                  </div>
                  <Button
                    variant="ghost"
                    size="sm"
                    className="text-slate-500 hover:text-white"
                    onClick={() => handleDismissAlert(alert.id)}
                  >
                    ×
                  </Button>
                </div>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  )
}
