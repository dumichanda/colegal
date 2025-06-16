import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Shield, AlertTriangle, CheckCircle, Clock } from "lucide-react"

export function ComplianceOverview() {
  const complianceData = [
    {
      category: "Data Privacy",
      score: 92,
      status: "Compliant",
      rules: 12,
      issues: 1,
      color: "bg-green-500",
    },
    {
      category: "Financial Compliance",
      score: 78,
      status: "At Risk",
      rules: 8,
      issues: 3,
      color: "bg-yellow-500",
    },
    {
      category: "Cybersecurity",
      score: 85,
      status: "Compliant",
      rules: 15,
      issues: 2,
      color: "bg-blue-500",
    },
    {
      category: "Healthcare",
      score: 95,
      status: "Compliant",
      rules: 6,
      issues: 0,
      color: "bg-green-500",
    },
  ]

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "Compliant":
        return CheckCircle
      case "At Risk":
        return AlertTriangle
      case "Non-Compliant":
        return AlertTriangle
      default:
        return Clock
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case "Compliant":
        return "text-green-400"
      case "At Risk":
        return "text-yellow-400"
      case "Non-Compliant":
        return "text-red-400"
      default:
        return "text-slate-400"
    }
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
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {complianceData.map((item) => {
            const StatusIcon = getStatusIcon(item.status)
            return (
              <div key={item.category} className="p-4 border border-slate-600 rounded-lg bg-slate-700/50">
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
                  <span className="text-slate-300">{item.rules} rules monitored</span>
                  <span className={item.issues > 0 ? "text-red-400" : "text-green-400"}>{item.issues} issues</span>
                </div>
              </div>
            )
          })}
        </div>
      </CardContent>
    </Card>
  )
}
