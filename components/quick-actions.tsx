"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Upload, Search, FileText, Shield, BarChart3, Users } from "lucide-react"
import { useState } from "react"

export function QuickActions() {
  const [activeAction, setActiveAction] = useState<string | null>(null)

  const handleAction = (actionTitle: string) => {
    setActiveAction(actionTitle)

    // Simulate action execution
    setTimeout(() => {
      setActiveAction(null)

      // Show success message or navigate
      switch (actionTitle) {
        case "Upload Document":
          alert("Document upload interface would open here")
          break
        case "Regulatory Search":
          window.location.href = "/regulatory-guidance"
          break
        case "Generate Report":
          // Simulate file download
          const element = document.createElement("a")
          const file = new Blob(["Sample compliance report"], { type: "text/plain" })
          element.href = URL.createObjectURL(file)
          element.download = "compliance-report.txt"
          document.body.appendChild(element)
          element.click()
          document.body.removeChild(element)
          break
        case "Compliance Check":
          alert("Running automated compliance assessment...")
          break
        case "View Analytics":
          alert("Analytics dashboard would open here")
          break
        case "Team Collaboration":
          alert("Team collaboration tools would open here")
          break
      }
    }, 1500)
  }

  const actions = [
    {
      title: "Upload Document",
      description: "Analyze contracts and legal documents",
      icon: Upload,
      color: "bg-blue-500 hover:bg-blue-600",
    },
    {
      title: "Regulatory Search",
      description: "Find relevant regulations and guidance",
      icon: Search,
      color: "bg-green-500 hover:bg-green-600",
    },
    {
      title: "Generate Report",
      description: "Create compliance and analysis reports",
      icon: FileText,
      color: "bg-purple-500 hover:bg-purple-600",
    },
    {
      title: "Compliance Check",
      description: "Run automated compliance assessment",
      icon: Shield,
      color: "bg-orange-500 hover:bg-orange-600",
    },
    {
      title: "View Analytics",
      description: "Access legal and compliance metrics",
      icon: BarChart3,
      color: "bg-indigo-500 hover:bg-indigo-600",
    },
    {
      title: "Team Collaboration",
      description: "Share documents and collaborate",
      icon: Users,
      color: "bg-pink-500 hover:bg-pink-600",
    },
  ]

  return (
    <Card className="bg-slate-800 border-slate-700">
      <CardHeader>
        <CardTitle className="text-lg font-semibold text-white">Quick Actions</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-2 gap-3">
          {actions.map((action) => (
            <Button
              key={action.title}
              variant="outline"
              className="h-auto p-3 flex flex-col items-center space-y-2 hover:shadow-md transition-all border-slate-600 text-slate-300 hover:bg-slate-700 disabled:opacity-50 min-h-[100px]"
              onClick={() => handleAction(action.title)}
              disabled={activeAction === action.title}
            >
              <div className={`p-2 rounded-lg ${action.color} text-white flex-shrink-0`}>
                {activeAction === action.title ? (
                  <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                ) : (
                  <action.icon className="w-5 h-5" />
                )}
              </div>
              <div className="text-center flex-1 min-w-0">
                <div className="text-xs font-medium text-white leading-tight mb-1 break-words">{action.title}</div>
                <div className="text-xs text-slate-400 leading-tight break-words line-clamp-2">
                  {action.description}
                </div>
              </div>
            </Button>
          ))}
        </div>
      </CardContent>
    </Card>
  )
}
