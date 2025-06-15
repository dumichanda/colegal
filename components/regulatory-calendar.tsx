import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Calendar, Clock } from "lucide-react"

export function RegulatoryCalendar() {
  const upcomingDeadlines = [
    {
      id: 1,
      title: "GDPR Data Retention Review",
      date: "Dec 18, 2024",
      daysLeft: 3,
      priority: "High",
      type: "Review",
    },
    {
      id: 2,
      title: "SOX Compliance Audit",
      date: "Dec 28, 2024",
      daysLeft: 13,
      priority: "Critical",
      type: "Audit",
    },
    {
      id: 3,
      title: "HIPAA Risk Assessment",
      date: "Jan 15, 2025",
      daysLeft: 31,
      priority: "Medium",
      type: "Assessment",
    },
    {
      id: 4,
      title: "Cybersecurity Training",
      date: "Jan 30, 2025",
      daysLeft: 46,
      priority: "Low",
      type: "Training",
    },
  ]

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
        return "default"
    }
  }

  const getUrgencyColor = (daysLeft: number) => {
    if (daysLeft <= 7) return "text-red-400"
    if (daysLeft <= 14) return "text-yellow-400"
    return "text-slate-300"
  }

  return (
    <Card className="bg-slate-800 border-slate-700">
      <CardHeader>
        <CardTitle className="text-lg font-semibold flex items-center text-white">
          <Calendar className="w-5 h-5 mr-2" />
          Upcoming Deadlines
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {upcomingDeadlines.map((deadline) => (
            <div key={deadline.id} className="p-3 border border-slate-600 rounded-lg bg-slate-700/30">
              <div className="flex items-start justify-between mb-2">
                <h4 className="font-medium text-white text-sm">{deadline.title}</h4>
                <Badge
                  variant={getPriorityColor(deadline.priority)}
                  className="text-xs bg-slate-600 text-slate-200 border-slate-500"
                >
                  {deadline.priority}
                </Badge>
              </div>

              <div className="flex items-center justify-between text-xs mb-2">
                <span className="text-slate-300">{deadline.date}</span>
                <Badge variant="outline" className="text-xs border-slate-500 text-slate-300">
                  {deadline.type}
                </Badge>
              </div>

              <div className="flex items-center space-x-1">
                <Clock className={`w-3 h-3 ${getUrgencyColor(deadline.daysLeft)}`} />
                <span className={`text-xs font-medium ${getUrgencyColor(deadline.daysLeft)}`}>
                  {deadline.daysLeft} days left
                </span>
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  )
}
