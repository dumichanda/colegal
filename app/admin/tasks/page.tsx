import { DashboardHeader } from "@/components/dashboard-header"
import { TaskMonitor } from "@/components/task-monitor"

export default function TasksPage() {
  return (
    <div className="min-h-screen bg-slate-950">
      <DashboardHeader />

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-white">Task Monitor</h1>
          <p className="mt-2 text-slate-400">Real-time application activity tracking and monitoring</p>
        </div>

        <TaskMonitor />
      </main>
    </div>
  )
}
