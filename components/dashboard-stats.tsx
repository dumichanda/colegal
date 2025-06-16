"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { FileText, AlertTriangle, CheckCircle, TrendingUp } from "lucide-react"

interface DashboardStats {
  documents: {
    total: number
    active: number
    recent: number
  }
  compliance: {
    totalAlerts: number
    activeAlerts: number
    criticalAlerts: number
    overdueAlerts: number
    complianceRate: number
  }
  tasks: {
    total: number
    pending: number
    completed: number
    failed: number
    completionRate: number
  }
  recentActivity: Array<{
    type: string
    name: string
    createdAt: string
    status: string
  }>
}

export function DashboardStats() {
  const [stats, setStats] = useState<DashboardStats | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchStats = async () => {
      try {
        setLoading(true)
        setError(null)

        console.log("🔄 Fetching dashboard stats...")

        const response = await fetch("/api/dashboard/stats")

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()
        console.log("✅ Dashboard stats API response:", data)

        if (data.success) {
          setStats(data.data)
        } else {
          throw new Error(data.error || "Failed to fetch stats")
        }
      } catch (err) {
        console.error("❌ Error fetching dashboard stats:", err)
        setError(err instanceof Error ? err.message : "Failed to fetch stats")
        // Fallback data
        setStats({
          documents: { total: 0, active: 0, recent: 0 },
          compliance: { totalAlerts: 0, activeAlerts: 0, criticalAlerts: 0, overdueAlerts: 0, complianceRate: 0 },
          tasks: { total: 0, pending: 0, completed: 0, failed: 0, completionRate: 0 },
          recentActivity: [],
        })
      } finally {
        setLoading(false)
      }
    }

    fetchStats()
  }, [])

  const getComplianceColor = (rate: number) => {
    if (rate >= 90) return "text-green-600"
    if (rate >= 70) return "text-yellow-600"
    return "text-red-600"
  }

  const getTaskCompletionColor = (rate: number) => {
    if (rate >= 80) return "text-green-600"
    if (rate >= 50) return "text-yellow-600"
    return "text-red-600"
  }

  if (loading) {
    return (
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {[1, 2, 3, 4].map((i) => (
          <Card key={i}>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <div className="animate-pulse">
                <div className="h-4 bg-muted rounded w-20 mb-2"></div>
                <div className="h-8 bg-muted rounded w-16"></div>
              </div>
            </CardHeader>
          </Card>
        ))}
      </div>
    )
  }

  if (error) {
    return (
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardContent className="p-6">
            <p className="text-sm text-muted-foreground">Error: {error}</p>
          </CardContent>
        </Card>
      </div>
    )
  }

  if (!stats) return null

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Total Documents</CardTitle>
          <FileText className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{stats.documents.total}</div>
          <p className="text-xs text-muted-foreground">
            {stats.documents.active} active • {stats.documents.recent} recent
          </p>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Compliance Status</CardTitle>
          <CheckCircle className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className={`text-2xl font-bold ${getComplianceColor(stats.compliance.complianceRate)}`}>
            {stats.compliance.complianceRate}%
          </div>
          <p className="text-xs text-muted-foreground">
            {stats.compliance.activeAlerts} active alerts • {stats.compliance.criticalAlerts} critical
          </p>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Task Progress</CardTitle>
          <TrendingUp className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className={`text-2xl font-bold ${getTaskCompletionColor(stats.tasks.completionRate)}`}>
            {stats.tasks.completionRate}%
          </div>
          <p className="text-xs text-muted-foreground">
            {stats.tasks.completed}/{stats.tasks.total} completed • {stats.tasks.pending} pending
          </p>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Active Alerts</CardTitle>
          <AlertTriangle className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold text-orange-600">{stats.compliance.activeAlerts}</div>
          <p className="text-xs text-muted-foreground">
            {stats.compliance.overdueAlerts} overdue • {stats.compliance.criticalAlerts} critical
          </p>
        </CardContent>
      </Card>
    </div>
  )
}
