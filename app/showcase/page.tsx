import { DashboardHeader } from "@/components/dashboard-header"
import { FeatureShowcase } from "@/components/feature-showcase"

export default function ShowcasePage() {
  return (
    <div className="min-h-screen bg-slate-950">
      <DashboardHeader />
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <FeatureShowcase />
      </main>
    </div>
  )
}
