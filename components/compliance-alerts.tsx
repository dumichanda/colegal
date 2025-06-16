"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { AlertTriangle } from "lucide-react"
import { useState } from "react"
import { CheckCircle } from "lucide-react"

export function ComplianceAlerts() {
  const [alerts, setAlerts] = useState([
    {
      id: 1,
      title: "POPIA Data Retention Review Due",
      description: "Annual review of data retention policies required",
      priority: "High",
      dueDate: "In 3 days",
      type: "deadline",
      status: "pending",
    },
    {
      id: 2,
      title: "New B-BBEE Regulations",
      description: "Updated B-BBEE codes effective January 2025",
      priority: "Medium",
      dueDate: "6 months",
      type: "regulatory",
      status: "pending",
    },
    {
      id: 3,
      title: "Contract Renewal Alert",
      description: "Vendor agreement expires next month",
      priority: "Medium",
      dueDate: "In 28 days",
      type: "contract",
      status: "pending",
    },
  ])

  const handleReview = (alertId: number) => {
    setAlerts(alerts.map((alert) => (alert.id === alertId ? { ...alert, status: "reviewing" } : alert)))

    // Simulate review process
    setTimeout(() => {
      setAlerts(alerts.map((alert) => (alert.id === alertId ? { ...alert, status: "reviewed" } : alert)))
    }, 2000)
  }

  const handleDismiss = (alertId: number) => {
    setAlerts(alerts.filter((alert) => alert.id !== alertId))
  }

  return (
    <Card className="bg-slate-800 border-slate-700">
      <CardHeader>
        <CardTitle className="text-lg font-semibold text-white">Compliance Alerts</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {alerts.map((alert) => (
            <div key={alert.id} className="flex items-start space-x-3 p-3 border border-slate-700 rounded-lg">
              <AlertTriangle className="w-5 h-5 mt-0.5 text-yellow-400" />
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between mb-1">
                  <h4 className="text-sm font-medium text-white">{alert.title}</h4>
                  <Badge
                    variant={alert.priority === "High" ? "destructive" : "outline"}
                    className="text-xs border-slate-600"
                  >
                    {alert.priority}
                  </Badge>
                </div>
                <p className="text-xs text-slate-400 mb-2">{alert.description}</p>
                <div className="flex items-center justify-between">
                  <span className="text-xs text-slate-500">{alert.dueDate}</span>
                  <div className="flex space-x-1">
                    <Button
                      variant="outline"
                      size="sm"
                      className="text-xs border-slate-600 text-slate-300 hover:bg-slate-700"
                      onClick={() => handleReview(alert.id)}
                      disabled={alert.status === "reviewing" || alert.status === "reviewed"}
                    >
                      {alert.status === "reviewing"
                        ? "Reviewing..."
                        : alert.status === "reviewed"
                          ? "Reviewed"
                          : "Review"}
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      className="text-xs text-slate-500 hover:text-slate-300"
                      onClick={() => handleDismiss(alert.id)}
                    >
                      ×
                    </Button>
                  </div>
                </div>
              </div>
            </div>
          ))}
          {alerts.length === 0 && (
            <div className="text-center py-8">
              <CheckCircle className="w-12 h-12 text-green-400 mx-auto mb-2" />
              <p className="text-slate-300">All alerts reviewed!</p>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  )
}
