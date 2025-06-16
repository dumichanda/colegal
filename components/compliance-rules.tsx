import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Search, AlertTriangle, CheckCircle, Clock } from "lucide-react"

export function ComplianceRules() {
  const rules = [
    {
      id: 1,
      title: "GDPR Data Processing Requirements",
      description: "Organizations must implement appropriate technical and organizational measures for data protection",
      category: "Data Privacy",
      jurisdiction: "EU",
      riskLevel: "High",
      status: "Compliant",
      lastChecked: "2 hours ago",
      nextCheck: "In 7 days",
    },
    {
      id: 2,
      title: "SOX Financial Reporting Controls",
      description: "Public companies must maintain adequate internal controls over financial reporting",
      category: "Financial Compliance",
      jurisdiction: "US Federal",
      riskLevel: "Critical",
      status: "At Risk",
      lastChecked: "1 day ago",
      nextCheck: "In 3 days",
    },
    {
      id: 3,
      title: "HIPAA Patient Data Security",
      description: "Healthcare entities must implement safeguards to protect patient health information",
      category: "Healthcare",
      jurisdiction: "US Federal",
      riskLevel: "High",
      status: "Compliant",
      lastChecked: "4 hours ago",
      nextCheck: "In 14 days",
    },
    {
      id: 4,
      title: "CCPA Consumer Rights",
      description: "Businesses must provide consumers with rights regarding their personal information",
      category: "Data Privacy",
      jurisdiction: "California",
      riskLevel: "Medium",
      status: "Compliant",
      lastChecked: "6 hours ago",
      nextCheck: "In 30 days",
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
        return "text-green-600"
      case "At Risk":
        return "text-yellow-600"
      case "Non-Compliant":
        return "text-red-600"
      default:
        return "text-gray-600"
    }
  }

  const getRiskColor = (risk: string) => {
    switch (risk) {
      case "Critical":
        return "destructive"
      case "High":
        return "destructive"
      case "Medium":
        return "default"
      case "Low":
        return "secondary"
      default:
        return "default"
    }
  }

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg font-semibold">Compliance Rules</CardTitle>
          <Button variant="outline" size="sm">
            Add Rule
          </Button>
        </div>

        {/* Search and Filters */}
        <div className="flex flex-col md:flex-row gap-4 mt-4">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <Input type="search" placeholder="Search compliance rules..." className="pl-10" />
          </div>
          <Select>
            <SelectTrigger className="w-48">
              <SelectValue placeholder="Category" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Categories</SelectItem>
              <SelectItem value="data-privacy">Data Privacy</SelectItem>
              <SelectItem value="financial">Financial Compliance</SelectItem>
              <SelectItem value="healthcare">Healthcare</SelectItem>
              <SelectItem value="cybersecurity">Cybersecurity</SelectItem>
            </SelectContent>
          </Select>
          <Select>
            <SelectTrigger className="w-48">
              <SelectValue placeholder="Status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Status</SelectItem>
              <SelectItem value="compliant">Compliant</SelectItem>
              <SelectItem value="at-risk">At Risk</SelectItem>
              <SelectItem value="non-compliant">Non-Compliant</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {rules.map((rule) => {
            const StatusIcon = getStatusIcon(rule.status)
            return (
              <div key={rule.id} className="p-4 border rounded-lg hover:bg-gray-50 transition-colors">
                <div className="flex items-start justify-between mb-3">
                  <div className="flex-1">
                    <h3 className="font-medium text-gray-100 mb-1">{rule.title}</h3>
                    <p className="text-sm text-gray-300 mb-2">{rule.description}</p>
                    <div className="flex items-center space-x-2">
                      <Badge variant="outline" className="text-xs">
                        {rule.category}
                      </Badge>
                      <Badge variant="outline" className="text-xs">
                        {rule.jurisdiction}
                      </Badge>
                      <Badge variant={getRiskColor(rule.riskLevel)} className="text-xs">
                        {rule.riskLevel} Risk
                      </Badge>
                    </div>
                  </div>
                  <div className="flex items-center space-x-2 ml-4">
                    <StatusIcon className={`w-5 h-5 ${getStatusColor(rule.status)}`} />
                    <Badge variant={rule.status === "Compliant" ? "default" : "destructive"} className="text-xs">
                      {rule.status}
                    </Badge>
                  </div>
                </div>

                <div className="flex items-center justify-between text-xs text-gray-400">
                  <span>Last checked: {rule.lastChecked}</span>
                  <span>Next check: {rule.nextCheck}</span>
                </div>
              </div>
            )
          })}
        </div>
      </CardContent>
    </Card>
  )
}
