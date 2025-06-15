import { DashboardHeader } from "@/components/dashboard-header"
import { DashboardStats } from "@/components/dashboard-stats"
import { RecentDocuments } from "@/components/recent-documents"
import { ComplianceAlerts } from "@/components/compliance-alerts"
import { RegulatoryUpdates } from "@/components/regulatory-updates"
import { QuickActions } from "@/components/quick-actions"

export default function HomePage() {
  return (
    <div className="min-h-screen bg-slate-950">
      <DashboardHeader />

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-white">Legal & Compliance Dashboard</h1>
          <p className="mt-2 text-slate-400 no-underline">
            AI-powered legal analysis and compliance monitoring platform
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-8">
            <DashboardStats />
            <RecentDocuments />
            <RegulatoryUpdates />
          </div>

          {/* Sidebar */}
          <div className="space-y-8">
            <QuickActions />
            <ComplianceAlerts />
          </div>
        </div>
      </main>
    </div>
  )
}
