"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Shield, AlertTriangle, CheckCircle, Clock } from "lucide-react"

interface ComplianceCategory {
  category: string
  score: number
  status: string
  rules_count: number
  issues_count: number
}

export function ComplianceOverview() {
  const [complianceData, setComplianceData] = useState<ComplianceCategory[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    async function fetchComplianceData() {
      try {
        console.log("🔄 Fetching compliance overview data...")
        setLoading(true)
        const response = await fetch("/api/compliance/overview")
        if (!response.ok) throw new Error("Failed to fetch compliance data")
        const data = await response.json()
        console.log("✅ Compliance overview data received:", data)
        setComplianceData(data.success ? data.data : [])
      } catch (error) {
        console.error("❌ Error fetching compliance data:", error)
        setError(error instanceof Error ? error.message : "An error occurred")
        setComplianceData([])
      } finally {
        setLoading(false)
      }
    }

    fetchComplianceData()
  }, [])

  const getStatusIcon = (status: string) => {
    switch (status.toLowerCase()) {
      case "compliant":
        return CheckCircle
      case "at risk":
        return AlertTriangle
      case "non-compliant":
        return AlertTriangle
      default:
        return Clock
    }
  }

  const getStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case "compliant":
        return "text-green-400"
      case "at risk":
        return "text-yellow-400"
      case "non-compliant":
        return "text-red-400"
      default:
        return "text-slate-400"
    }
  }

  if (loading) {
    return (
      <Card className="bg-slate-800 border-slate-700">
        <CardHeader>
          <CardTitle className="text-lg font-semibold flex items-center text-white">
            <Shield className="w-5 h-5 mr-2" />
            Compliance Overview
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {[1, 2, 3, 4].map((i) => (
              <div key={i} className="animate-pulse p-4 border border-slate-600 rounded-lg bg-slate-700/50">
                <div className="h-4 bg-slate-600 rounded w-3/4 mb-3"></div>
                <div className="h-2 bg-slate-600 rounded mb-3"></div>
                <div className="h-3 bg-slate-600 rounded w-1/2"></div>
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
          <CardTitle className="text-lg font-semibold flex items-center text-white">
            <Shield className="w-5 h-5 mr-2" />
            Compliance Overview
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-center py-8 text-red-400">
            <AlertTriangle className="w-12 h-12 mx-auto mb-2" />
            <p>Error loading compliance data: {error}</p>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className="bg-slate-800 border-slate-700">
      <CardHeader>
        <CardTitle className="text-lg font-semibold flex items-center text-white">
          <Shield className="w-5 h-5 mr-2" />
          Compliance Overview
        </CardTitle>
      </CardHeader>
      <CardContent>
        {complianceData.length === 0 ? (
          <div className="text-center py-8 text-slate-400">
            <Shield className="w-12 h-12 mx-auto mb-2 opacity-50" />
            <p>No compliance data available</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {complianceData.map((item, index) => {
              const StatusIcon = getStatusIcon(item.status)
              return (
                <div key={index} className="p-4 border border-slate-600 rounded-lg bg-slate-700/50">
                  <div className="flex items-center justify-between mb-3">
                    <h3 className="font-medium text-white">{item.category}</h3>
                    <div className="flex items-center space-x-1">
                      <StatusIcon className={`w-4 h-4 ${getStatusColor(item.status)}`} />
                      <Badge
                        variant={item.status === "Compliant" ? "default" : "destructive"}
                        className="text-xs bg-slate-600 text-slate-200 border-slate-500"
                      >
                        {item.status}
                      </Badge>
                    </div>
                  </div>

                  <div className="mb-3">
                    <div className="flex justify-between text-sm mb-1">
                      <span className="text-slate-200">Compliance Score</span>
                      <span className="font-medium text-white">{item.score}%</span>
                    </div>
                    <Progress value={item.score} className="h-2 bg-slate-600" />
                  </div>

                  <div className="flex justify-between text-sm">
                    <span className="text-slate-300">{item.rules_count} rules monitored</span>
                    <span className={item.issues_count > 0 ? "text-red-400" : "text-green-400"}>
                      {item.issues_count} issues
                    </span>
                  </div>
                </div>
              )
            })}
          </div>
        )}
      </CardContent>
    </Card>
  )
}
