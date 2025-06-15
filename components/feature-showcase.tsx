"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Input } from "@/components/ui/input"
import { Progress } from "@/components/ui/progress"
import {
  FileText,
  Shield,
  GitCompare,
  Calendar,
  BookOpen,
  Search,
  MessageSquare,
  AlertTriangle,
  CheckCircle,
  Download,
  Share,
  Gavel,
  Scale,
} from "lucide-react"

const features = [
  {
    id: "regulatory-guidance",
    title: "Regulatory Guidance",
    subtitle: "AI-Powered Legal Research",
    icon: BookOpen,
    color: "from-blue-500 to-cyan-500",
    description: "Navigate South African legal landscape with AI-powered insights",
  },
  {
    id: "contract-analysis",
    title: "Contract Analysis",
    subtitle: "Smart Document Review",
    icon: FileText,
    color: "from-purple-500 to-pink-500",
    description: "Analyze contracts with SA legal framework compliance",
  },
  {
    id: "compliance-monitoring",
    title: "Compliance Monitoring",
    subtitle: "Real-time Risk Assessment",
    icon: Shield,
    color: "from-green-500 to-emerald-500",
    description: "Monitor POPIA, B-BBEE, and LRA compliance in real-time",
  },
  {
    id: "document-qa",
    title: "Document Q&A",
    subtitle: "Natural Language Search",
    icon: MessageSquare,
    color: "from-orange-500 to-red-500",
    description: "Query legal documents using natural language",
  },
  {
    id: "contract-comparison",
    title: "Contract Comparison",
    subtitle: "Side-by-Side Analysis",
    icon: GitCompare,
    color: "from-teal-500 to-blue-500",
    description: "Compare contracts with SA legal standards",
  },
  {
    id: "deposition-review",
    title: "Deposition Review",
    subtitle: "Court Proceedings Analysis",
    icon: Gavel,
    color: "from-indigo-500 to-purple-500",
    description: "Analyze court transcripts and witness testimony",
  },
  {
    id: "timeline-builder",
    title: "Timeline Builder",
    subtitle: "Case Chronology",
    icon: Calendar,
    color: "from-yellow-500 to-orange-500",
    description: "Build comprehensive case timelines",
  },
]

export function FeatureShowcase() {
  const [activeFeature, setActiveFeature] = useState("regulatory-guidance")

  const activeFeatureData = features.find((f) => f.id === activeFeature)

  return (
    <div className="space-y-8">
      {/* Hero Section */}
      <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 p-8 border border-slate-700">
        <div className="absolute inset-0 bg-gradient-to-r from-green-500/10 via-yellow-500/10 to-red-500/10" />
        <div className="relative z-10">
          <div className="flex items-center space-x-3 mb-4">
            <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-green-500 to-yellow-500 flex items-center justify-center">
              <Scale className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-3xl font-bold text-white">Legal AI Assistant</h1>
              <p className="text-slate-300">South African Legal & Compliance Platform</p>
            </div>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mt-6">
            <div className="bg-white/5 backdrop-blur-sm rounded-lg p-4 border border-white/10">
              <div className="text-2xl font-bold text-white">2,847</div>
              <div className="text-sm text-slate-300">Documents Analyzed</div>
              <div className="text-xs text-green-400 mt-1">+12% from last month</div>
            </div>
            <div className="bg-white/5 backdrop-blur-sm rounded-lg p-4 border border-white/10">
              <div className="text-2xl font-bold text-white">94%</div>
              <div className="text-sm text-slate-300">Compliance Score</div>
              <div className="text-xs text-green-400 mt-1">+3% improvement</div>
            </div>
            <div className="bg-white/5 backdrop-blur-sm rounded-lg p-4 border border-white/10">
              <div className="text-2xl font-bold text-white">156</div>
              <div className="text-sm text-slate-300">Active Cases</div>
              <div className="text-xs text-blue-400 mt-1">23 new this week</div>
            </div>
            <div className="bg-white/5 backdrop-blur-sm rounded-lg p-4 border border-white/10">
              <div className="text-2xl font-bold text-white">R2.4M</div>
              <div className="text-sm text-slate-300">Risk Mitigated</div>
              <div className="text-xs text-green-400 mt-1">This quarter</div>
            </div>
          </div>
        </div>
      </div>

      {/* Feature Navigation */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 xl:grid-cols-7 gap-3">
        {features.map((feature) => {
          const Icon = feature.icon
          const isActive = activeFeature === feature.id
          return (
            <button
              key={feature.id}
              onClick={() => setActiveFeature(feature.id)}
              className={`group relative overflow-hidden rounded-xl p-4 text-left transition-all duration-300 ${
                isActive
                  ? "bg-gradient-to-br from-slate-800 to-slate-900 border-2 border-blue-500/50 shadow-lg shadow-blue-500/20"
                  : "bg-slate-800/50 border border-slate-700 hover:bg-slate-800 hover:border-slate-600"
              }`}
            >
              <div
                className={`absolute inset-0 bg-gradient-to-br ${feature.color} opacity-0 group-hover:opacity-10 transition-opacity`}
              />
              <div className="relative z-10">
                <div
                  className={`w-10 h-10 rounded-lg bg-gradient-to-br ${feature.color} flex items-center justify-center mb-3`}
                >
                  <Icon className="w-5 h-5 text-white" />
                </div>
                <h3 className="font-semibold text-white text-sm mb-1">{feature.title}</h3>
                <p className="text-xs text-slate-400">{feature.subtitle}</p>
                {isActive && (
                  <div className="absolute top-2 right-2">
                    <div className="w-2 h-2 bg-blue-500 rounded-full animate-pulse" />
                  </div>
                )}
              </div>
            </button>
          )
        })}
      </div>

      {/* Active Feature Content */}
      <div className="space-y-6">
        {/* Feature Header */}
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <div
              className={`w-12 h-12 rounded-xl bg-gradient-to-br ${activeFeatureData?.color} flex items-center justify-center`}
            >
              {activeFeatureData?.icon && <activeFeatureData.icon className="w-6 h-6 text-white" />}
            </div>
            <div>
              <h2 className="text-2xl font-bold text-white">{activeFeatureData?.title}</h2>
              <p className="text-slate-400">{activeFeatureData?.description}</p>
            </div>
          </div>
          <div className="flex space-x-2">
            <Button variant="outline" size="sm" className="bg-slate-800 border-slate-600 text-white hover:bg-slate-700">
              <Download className="w-4 h-4 mr-2" />
              Export
            </Button>
            <Button variant="outline" size="sm" className="bg-slate-800 border-slate-600 text-white hover:bg-slate-700">
              <Share className="w-4 h-4 mr-2" />
              Share
            </Button>
          </div>
        </div>

        {/* Feature Content */}
        <FeatureContent activeFeature={activeFeature} />
      </div>
    </div>
  )
}

function FeatureContent({ activeFeature }: { activeFeature: string }) {
  const [searchQuery, setSearchQuery] = useState("")
  const [searchResults, setSearchResults] = useState<any>(null)
  const [isSearching, setIsSearching] = useState(false)
  const [analysisResults, setAnalysisResults] = useState<any>(null)
  const [isAnalyzing, setIsAnalyzing] = useState(false)

  const handleSearch = async () => {
    if (!searchQuery.trim()) return

    setIsSearching(true)
    // Simulate API call
    await new Promise((resolve) => setTimeout(resolve, 2000))

    setSearchResults({
      query: searchQuery,
      results: "Detailed regulatory guidance results would appear here...",
      confidence: 95,
      sources: ["POPIA Act", "Information Regulator", "Legal Precedents"],
    })
    setIsSearching(false)
  }

  const handleAnalyze = async () => {
    setIsAnalyzing(true)
    await new Promise((resolve) => setTimeout(resolve, 3000))

    setAnalysisResults({
      clauses: 18,
      highRisk: 2,
      mediumRisk: 6,
      score: 82,
      completed: true,
    })
    setIsAnalyzing(false)
  }

  const handleExport = () => {
    // Simulate file download
    const element = document.createElement("a")
    const file = new Blob(["Sample export data"], { type: "text/plain" })
    element.href = URL.createObjectURL(file)
    element.download = `${activeFeature}-export.txt`
    document.body.appendChild(element)
    element.click()
    document.body.removeChild(element)
  }

  const handleShare = async () => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: `Legal AI Assistant - ${activeFeature}`,
          text: `Check out this ${activeFeature} analysis`,
          url: window.location.href,
        })
      } catch (err) {
        console.log("Error sharing:", err)
      }
    } else {
      // Fallback - copy to clipboard
      navigator.clipboard.writeText(window.location.href)
      alert("Link copied to clipboard!")
    }
  }

  switch (activeFeature) {
    case "regulatory-guidance":
      return (
        <div className="space-y-6">
          <Card className="bg-slate-800/50 border-slate-700">
            <CardHeader>
              <CardTitle className="text-white flex items-center">
                <Search className="w-5 h-5 mr-2" />
                AI-Powered Legal Research
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex space-x-4">
                <div className="flex-1">
                  <Input
                    placeholder="Ask about POPIA compliance requirements for fintech companies..."
                    className="bg-slate-900 border-slate-600 text-white placeholder:text-slate-400"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    onKeyPress={(e) => e.key === "Enter" && handleSearch()}
                  />
                </div>
                <Button
                  className="bg-blue-600 hover:bg-blue-700"
                  onClick={handleSearch}
                  disabled={isSearching || !searchQuery.trim()}
                >
                  <Search className="w-4 h-4 mr-2" />
                  {isSearching ? "Searching..." : "Research"}
                </Button>
              </div>
              <div className="flex space-x-2">
                <Badge
                  variant="outline"
                  className="border-slate-600 text-slate-300 cursor-pointer hover:bg-slate-700"
                  onClick={() => setSearchQuery("POPIA compliance for financial services")}
                >
                  South Africa
                </Badge>
                <Badge
                  variant="outline"
                  className="border-slate-600 text-slate-300 cursor-pointer hover:bg-slate-700"
                  onClick={() => setSearchQuery("POPIA data processing requirements")}
                >
                  POPIA
                </Badge>
                <Badge
                  variant="outline"
                  className="border-slate-600 text-slate-300 cursor-pointer hover:bg-slate-700"
                  onClick={() => setSearchQuery("Financial services compliance obligations")}
                >
                  Financial Services
                </Badge>
              </div>
            </CardContent>
          </Card>

          {searchResults && (
            <Card className="bg-slate-800/50 border-slate-700">
              <CardHeader className="flex flex-row items-center justify-between">
                <div>
                  <CardTitle className="text-white">POPIA Compliance Framework</CardTitle>
                  <Badge className="w-fit bg-green-500/20 text-green-400 border-green-500/30 mt-2">
                    {searchResults.confidence}% Confidence
                  </Badge>
                </div>
                <div className="flex space-x-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={handleExport}
                    className="border-slate-600 text-slate-300 hover:bg-slate-700"
                  >
                    <Download className="w-4 h-4 mr-2" />
                    Export
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={handleShare}
                    className="border-slate-600 text-slate-300 hover:bg-slate-700"
                  >
                    <Share className="w-4 h-4 mr-2" />
                    Share
                  </Button>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="bg-blue-500/10 border border-blue-500/20 rounded-lg p-4">
                  <h4 className="font-semibold text-blue-400 mb-2">Key Requirements:</h4>
                  <ul className="space-y-2 text-slate-300">
                    <li className="flex items-start">
                      <CheckCircle className="w-4 h-4 text-green-400 mr-2 mt-0.5 flex-shrink-0" />
                      <span>
                        <strong>Lawful Processing:</strong> Establish valid legal grounds under Section 11 of POPIA
                      </span>
                    </li>
                    <li className="flex items-start">
                      <CheckCircle className="w-4 h-4 text-green-400 mr-2 mt-0.5 flex-shrink-0" />
                      <span>
                        <strong>Data Minimisation:</strong> Process only necessary data for specified purposes
                      </span>
                    </li>
                    <li className="flex items-start">
                      <CheckCircle className="w-4 h-4 text-green-400 mr-2 mt-0.5 flex-shrink-0" />
                      <span>
                        <strong>Security Safeguards:</strong> Implement appropriate technical measures
                      </span>
                    </li>
                  </ul>
                </div>
                <div className="bg-slate-700 p-3 rounded-lg">
                  <p className="text-sm text-slate-300">
                    <strong>Sources:</strong> {searchResults.sources.join(", ")}
                  </p>
                </div>
              </CardContent>
            </Card>
          )}
        </div>
      )

    case "contract-analysis":
      return (
        <div className="space-y-6">
          <div className="flex justify-between items-center">
            <h3 className="text-xl font-semibold text-white">Contract Analysis Results</h3>
            <div className="flex space-x-2">
              <Button onClick={handleAnalyze} disabled={isAnalyzing} className="bg-blue-600 hover:bg-blue-700">
                {isAnalyzing ? "Analyzing..." : "Re-analyze"}
              </Button>
              <Button
                variant="outline"
                onClick={handleExport}
                className="border-slate-600 text-slate-300 hover:bg-slate-700"
              >
                <Download className="w-4 h-4 mr-2" />
                Export Report
              </Button>
            </div>
          </div>

          {isAnalyzing && (
            <Card className="bg-slate-800/50 border-slate-700">
              <CardContent className="p-6">
                <div className="flex items-center space-x-3">
                  <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-500"></div>
                  <span className="text-slate-300">Analyzing contract clauses and risk factors...</span>
                </div>
                <Progress value={66} className="mt-4" />
              </CardContent>
            </Card>
          )}

          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <Card className="bg-gradient-to-br from-blue-500/20 to-blue-600/20 border-blue-500/30">
              <CardContent className="p-4 text-center">
                <div className="text-2xl font-bold text-blue-400">{analysisResults?.clauses || 18}</div>
                <div className="text-sm text-slate-300">Clauses Found</div>
              </CardContent>
            </Card>
            <Card className="bg-gradient-to-br from-red-500/20 to-red-600/20 border-red-500/30">
              <CardContent className="p-4 text-center">
                <div className="text-2xl font-bold text-red-400">{analysisResults?.highRisk || 2}</div>
                <div className="text-sm text-slate-300">High Risk</div>
              </CardContent>
            </Card>
            <Card className="bg-gradient-to-br from-yellow-500/20 to-yellow-600/20 border-yellow-500/30">
              <CardContent className="p-4 text-center">
                <div className="text-2xl font-bold text-yellow-400">{analysisResults?.mediumRisk || 6}</div>
                <div className="text-sm text-slate-300">Medium Risk</div>
              </CardContent>
            </Card>
            <Card className="bg-gradient-to-br from-green-500/20 to-green-600/20 border-green-500/30">
              <CardContent className="p-4 text-center">
                <div className="text-2xl font-bold text-green-400">{analysisResults?.score || 82}%</div>
                <div className="text-sm text-slate-300">Overall Score</div>
              </CardContent>
            </Card>
          </div>

          <Card className="bg-slate-800/50 border-red-500/30">
            <CardContent className="p-4">
              <div className="flex items-start justify-between mb-3">
                <div className="flex items-center space-x-2">
                  <AlertTriangle className="w-5 h-5 text-red-400" />
                  <h4 className="font-medium text-white">Restraint of Trade Clause</h4>
                  <Badge className="bg-red-500/20 text-red-400 border-red-500/30">High Risk</Badge>
                </div>
                <div className="flex space-x-2">
                  <Badge variant="outline" className="border-slate-600 text-slate-300">
                    Clause 15.2
                  </Badge>
                  <Button variant="ghost" size="sm" className="text-slate-400 hover:text-white">
                    <MessageSquare className="w-4 h-4" />
                  </Button>
                </div>
              </div>

              <div className="bg-red-500/10 border border-red-500/20 rounded-lg p-3 mb-3">
                <div className="text-sm text-slate-300 font-mono">
                  "The Employee undertakes not to engage in any business similar to or competing with the Company's
                  business within the Republic of South Africa for a period of 24 months after termination of
                  employment."
                </div>
              </div>

              <div className="bg-blue-500/10 border border-blue-500/20 rounded-lg p-3 mb-3">
                <div className="text-sm text-slate-300">
                  <strong className="text-blue-400">Risk Analysis:</strong> Restraint clause may be unenforceable under
                  South African law. The Magna Alloys case established that restraints must be reasonable in scope,
                  duration, and geographical area.
                </div>
              </div>

              <div className="flex space-x-2">
                <Button size="sm" variant="outline" className="border-slate-600 text-slate-300 hover:bg-slate-700">
                  View Similar Cases
                </Button>
                <Button size="sm" variant="outline" className="border-slate-600 text-slate-300 hover:bg-slate-700">
                  Suggest Amendments
                </Button>
                <Button size="sm" variant="outline" className="border-slate-600 text-slate-300 hover:bg-slate-700">
                  Legal Precedents
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      )

    case "compliance-monitoring":
      return (
        <div className="space-y-6">
          <div className="flex justify-between items-center">
            <h3 className="text-xl font-semibold text-white">Compliance Dashboard</h3>
            <div className="flex space-x-2">
              <Button className="bg-green-600 hover:bg-green-700">
                <Shield className="w-4 h-4 mr-2" />
                Run Compliance Check
              </Button>
              <Button
                variant="outline"
                onClick={handleExport}
                className="border-slate-600 text-slate-300 hover:bg-slate-700"
              >
                <Download className="w-4 h-4 mr-2" />
                Export Report
              </Button>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <Card className="bg-gradient-to-br from-green-500/20 to-green-600/20 border-green-500/30">
              <CardContent className="p-6 text-center">
                <div className="text-3xl font-bold text-green-400">94%</div>
                <div className="text-sm text-slate-300 mb-3">Overall Compliance</div>
                <Button
                  size="sm"
                  variant="outline"
                  className="border-green-500/30 text-green-400 hover:bg-green-500/10"
                >
                  View Details
                </Button>
              </CardContent>
            </Card>
            <Card className="bg-gradient-to-br from-yellow-500/20 to-yellow-600/20 border-yellow-500/30">
              <CardContent className="p-6 text-center">
                <div className="text-3xl font-bold text-yellow-400">3</div>
                <div className="text-sm text-slate-300 mb-3">Pending Reviews</div>
                <Button
                  size="sm"
                  variant="outline"
                  className="border-yellow-500/30 text-yellow-400 hover:bg-yellow-500/10"
                >
                  Review Now
                </Button>
              </CardContent>
            </Card>
            <Card className="bg-gradient-to-br from-red-500/20 to-red-600/20 border-red-500/30">
              <CardContent className="p-6 text-center">
                <div className="text-3xl font-bold text-red-400">1</div>
                <div className="text-sm text-slate-300 mb-3">Critical Alert</div>
                <Button size="sm" variant="outline" className="border-red-500/30 text-red-400 hover:bg-red-500/10">
                  Address Now
                </Button>
              </CardContent>
            </Card>
          </div>

          <Card className="bg-slate-800/50 border-slate-700">
            <CardHeader>
              <CardTitle className="text-white">Recent Compliance Activities</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {[
                  { title: "POPIA Data Audit", status: "Completed", time: "2 hours ago", action: "View Report" },
                  { title: "B-BBEE Verification", status: "In Progress", time: "1 day ago", action: "Continue" },
                  { title: "LRA Compliance Check", status: "Pending", time: "3 days ago", action: "Start Review" },
                ].map((item, index) => (
                  <div key={index} className="flex items-center justify-between p-3 border border-slate-700 rounded-lg">
                    <div>
                      <h4 className="font-medium text-white">{item.title}</h4>
                      <p className="text-sm text-slate-400">
                        {item.status} • {item.time}
                      </p>
                    </div>
                    <Button size="sm" variant="outline" className="border-slate-600 text-slate-300 hover:bg-slate-700">
                      {item.action}
                    </Button>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>
      )

    default:
      return (
        <Card className="bg-slate-800/50 border-slate-700">
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle className="text-white">{activeFeature.replace("-", " ").toUpperCase()}</CardTitle>
            <div className="flex space-x-2">
              <Button
                variant="outline"
                onClick={handleExport}
                className="border-slate-600 text-slate-300 hover:bg-slate-700"
              >
                <Download className="w-4 h-4 mr-2" />
                Export
              </Button>
              <Button
                variant="outline"
                onClick={handleShare}
                className="border-slate-600 text-slate-300 hover:bg-slate-700"
              >
                <Share className="w-4 h-4 mr-2" />
                Share
              </Button>
            </div>
          </CardHeader>
          <CardContent>
            <p className="text-slate-300 mb-4">Interactive {activeFeature.replace("-", " ")} feature showcase</p>
            <div className="flex space-x-2">
              <Button className="bg-blue-600 hover:bg-blue-700">Try Feature</Button>
              <Button variant="outline" className="border-slate-600 text-slate-300 hover:bg-slate-700">
                Learn More
              </Button>
            </div>
          </CardContent>
        </Card>
      )
  }
}
