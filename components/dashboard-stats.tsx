import { FileText, Shield, AlertTriangle, CheckCircle } from "lucide-react"
import { Card, CardContent } from "@/components/ui/card"

export function DashboardStats() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <Card className="bg-slate-800 border-slate-700">
        <CardContent className="p-6">
          <div className="flex items-center justify-between">
            <div className="min-w-0 flex-1">
              <p className="text-sm font-medium text-slate-400 truncate">Total Documents</p>
              <p className="text-2xl font-bold text-white">2,847</p>
            </div>
            <FileText className="h-8 w-8 text-blue-400 flex-shrink-0" />
          </div>
          <p className="text-xs text-slate-400 mt-2">
            <span className="text-green-400">+12%</span> from last month
          </p>
        </CardContent>
      </Card>

      <Card className="bg-slate-800 border-slate-700">
        <CardContent className="p-6">
          <div className="flex items-center justify-between">
            <div className="min-w-0 flex-1">
              <p className="text-sm font-medium text-slate-400 truncate">Compliance Score</p>
              <p className="text-2xl font-bold text-white">94%</p>
            </div>
            <Shield className="h-8 w-8 text-green-400 flex-shrink-0" />
          </div>
          <p className="text-xs text-slate-400 mt-2">
            <span className="text-green-400">+3%</span> improvement
          </p>
        </CardContent>
      </Card>

      <Card className="bg-slate-800 border-slate-700">
        <CardContent className="p-6">
          <div className="flex items-center justify-between">
            <div className="min-w-0 flex-1">
              <p className="text-sm font-medium text-slate-400 truncate">Active Cases</p>
              <p className="text-2xl font-bold text-white">156</p>
            </div>
            <CheckCircle className="h-8 w-8 text-blue-400 flex-shrink-0" />
          </div>
          <p className="text-xs text-slate-400 mt-2">
            <span className="text-blue-400">23</span> new this week
          </p>
        </CardContent>
      </Card>

      <Card className="bg-slate-800 border-slate-700">
        <CardContent className="p-6">
          <div className="flex items-center justify-between">
            <div className="min-w-0 flex-1">
              <p className="text-sm font-medium text-slate-400 truncate">Risk Alerts</p>
              <p className="text-2xl font-bold text-white">8</p>
            </div>
            <AlertTriangle className="h-8 w-8 text-yellow-400 flex-shrink-0" />
          </div>
          <p className="text-xs text-slate-400 mt-2">
            <span className="text-red-400">2</span> critical
          </p>
        </CardContent>
      </Card>
    </div>
  )
}
