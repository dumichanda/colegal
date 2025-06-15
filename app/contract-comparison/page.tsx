import { DashboardHeader } from "@/components/dashboard-header"
import { ContractComparison } from "@/components/contract-comparison"

export default function ContractComparisonPage() {
  return (
    <div className="min-h-screen bg-slate-950">
      <DashboardHeader />

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-white">Contract Comparison</h1>
          <p className="mt-2 text-slate-400">AI-powered side-by-side contract analysis and difference highlighting</p>
        </div>

        <ContractComparison />
      </main>
    </div>
  )
}
