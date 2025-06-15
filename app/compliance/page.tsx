import { DashboardHeader } from "@/components/dashboard-header"
import { ComplianceOverview } from "@/components/compliance-overview"
import { ComplianceRules } from "@/components/compliance-rules"
import { RegulatoryCalendar } from "@/components/regulatory-calendar"
import { ComplianceReports } from "@/components/compliance-reports"
import { MastraWorkflowPanel } from "@/components/mastra-workflow-panel"
import { CopilotChat } from "@/components/copilot-chat"

export default function CompliancePage() {
  return (
    <div className="min-h-screen bg-slate-950">
      <DashboardHeader />

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-white">Compliance Monitoring</h1>
          <p className="mt-2 text-slate-400">Real-time compliance tracking and regulatory guidance</p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-8">
            <ComplianceOverview />
            <ComplianceRules />
          </div>

          {/* Sidebar */}
          <div className="space-y-8">
            <RegulatoryCalendar />
            <ComplianceReports />
            <MastraWorkflowPanel organizationId="org-123" />
          </div>
        </div>
      </main>
      <CopilotChat context="Compliance monitoring and regulatory guidance" />
    </div>
  )
}
