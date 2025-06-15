import Link from "next/link"
import { Bell, Search, User } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"

export function DashboardHeader() {
  return (
    <header className="bg-slate-900 border-b border-slate-800">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          {/* Logo and Navigation */}
          <div className="flex items-center space-x-8">
            <Link href="/" className="flex items-center space-x-2">
              <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-sm">LA</span>
              </div>
              <span className="text-xl font-semibold text-white">LegalAI</span>
            </Link>

            <nav className="hidden md:flex space-x-6">
              <Link href="/documents" className="text-slate-400 hover:text-white font-medium">
                Documents
              </Link>
              <Link href="/compliance" className="text-slate-400 hover:text-white font-medium">
                Compliance
              </Link>
              <Link href="/contract-comparison" className="text-slate-400 hover:text-white font-medium">
                Comparison
              </Link>
              <Link href="/deposition-review" className="text-slate-400 hover:text-white font-medium">
                Depositions
              </Link>
              <Link href="/timeline-builder" className="text-slate-400 hover:text-white font-medium">
                Timeline
              </Link>
              <Link href="/regulatory-guidance" className="text-slate-400 hover:text-white font-medium">
                Research
              </Link>
              <Link href="/showcase" className="text-blue-400 hover:text-blue-300 font-medium">
                Showcase
              </Link>
            </nav>
          </div>

          {/* Search and User Actions */}
          <div className="flex items-center space-x-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400 w-4 h-4" />
              <Input
                type="search"
                placeholder="Search documents, regulations..."
                className="pl-10 w-64 bg-slate-800 border-slate-700 text-white placeholder:text-slate-400"
              />
            </div>

            <Button variant="ghost" size="sm" className="text-slate-400 hover:text-white">
              <Bell className="w-4 h-4" />
            </Button>

            <Button variant="ghost" size="sm" className="text-slate-400 hover:text-white">
              <User className="w-4 h-4" />
            </Button>
          </div>
        </div>
      </div>
    </header>
  )
}
