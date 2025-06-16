"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Input } from "@/components/ui/input"
import { FileText, Search, Clock, User, Star } from "lucide-react"

interface Deposition {
  id: string
  title: string
  date: string
  witness: string
  role: string
  pages: number
  duration: string
  status: string
}

interface AnalysisResult {
  summary: {
    totalPages: number
    keyTestimonySegments: number
    credibilityScore: number
    inconsistencies: number
    importantAdmissions: number
  }
  keyTestimony: Array<{
    id: number
    page: number
    lineStart: number
    lineEnd: number
    topic: string
    importance: string
    content: string
    analysis: string
    tags: string[]
  }>
  timeline: Array<{
    date: string
    event: string
    page: number
    importance: string
  }>
  credibilityAnalysis: {
    overallScore: number
    factors: Array<{
      factor: string
      score: number
      notes: string
    }>
    redFlags: string[]
  }
}

export function DepositionReview() {
  const [depositions, setDepositions] = useState<Deposition[]>([])
  const [selectedDeposition, setSelectedDeposition] = useState<string | null>(null)
  const [searchQuery, setSearchQuery] = useState("")
  const [analysisResult, setAnalysisResult] = useState<AnalysisResult | null>(null)
  const [loading, setLoading] = useState(true)
  const [analyzing, setAnalyzing] = useState(false)

  useEffect(() => {
    fetchDepositions()
  }, [])

  const fetchDepositions = async () => {
    try {
      console.log("🔄 Fetching depositions...")
      setLoading(true)
      const response = await fetch("/api/depositions")
      if (!response.ok) throw new Error("Failed to fetch depositions")
      const data = await response.json()
      console.log("✅ Depositions received:", data)
      setDepositions(data.success ? data.data : [])
    } catch (error) {
      console.error("❌ Error fetching depositions:", error)
      setDepositions([])
    } finally {
      setLoading(false)
    }
  }

  const handleAnalyze = async (depositionId: string) => {
    try {
      console.log("🔄 Analyzing deposition:", depositionId)
      setSelectedDeposition(depositionId)
      setAnalyzing(true)

      const response = await fetch("/api/depositions/analyze", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ depositionId }),
      })

      if (!response.ok) throw new Error("Failed to analyze deposition")
      const data = await response.json()
      console.log("✅ Deposition analysis received:", data)
      setAnalysisResult(data.success ? data.data : null)
    } catch (error) {
      console.error("❌ Error analyzing deposition:", error)
    } finally {
      setAnalyzing(false)
    }
  }

  const handleSearch = async () => {
    if (!searchQuery.trim() || !selectedDeposition) return

    try {
      console.log("🔄 Searching deposition transcript...")
      const response = await fetch("/api/depositions/search", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          depositionId: selectedDeposition,
          query: searchQuery,
        }),
      })

      if (!response.ok) throw new Error("Failed to search transcript")
      const data = await response.json()
      console.log("✅ Search results received:", data)
      // Handle search results here
    } catch (error) {
      console.error("❌ Error searching transcript:", error)
    }
  }

  const getImportanceColor = (importance: string) => {
    switch (importance) {
      case "High":
        return "destructive"
      case "Medium":
        return "default"
      case "Low":
        return "secondary"
      default:
        return "outline"
    }
  }

  if (loading) {
    return (
      <Card className="bg-slate-800 border-slate-700">
        <CardHeader>
          <CardTitle className="flex items-center text-white">
            <FileText className="w-5 h-5 mr-2" />
            Deposition Review
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {[1, 2, 3].map((i) => (
              <div key={i} className="animate-pulse p-4 border border-slate-600 rounded-lg">
                <div className="h-4 bg-slate-700 rounded w-3/4 mb-2"></div>
                <div className="h-3 bg-slate-700 rounded w-1/2"></div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <div className="space-y-6">
      {/* Deposition List */}
      <Card className="bg-slate-800 border-slate-700">
        <CardHeader>
          <CardTitle className="flex items-center text-white">
            <FileText className="w-5 h-5 mr-2" />
            Deposition Review
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {depositions.length === 0 ? (
              <div className="text-center py-8 text-slate-400">
                <FileText className="w-12 h-12 mx-auto mb-2 opacity-50" />
                <p>No depositions available</p>
              </div>
            ) : (
              depositions.map((dep) => (
                <div
                  key={dep.id}
                  className={`p-4 border rounded-lg cursor-pointer transition-colors ${
                    selectedDeposition === dep.id
                      ? "bg-blue-500/10 border-blue-500/50"
                      : "border-slate-600 hover:bg-slate-700/50 hover:border-slate-500"
                  }`}
                  onClick={() => handleAnalyze(dep.id)}
                >
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <h3 className="font-medium text-white mb-2">{dep.title}</h3>
                      <div className="flex items-center space-x-4 text-sm text-slate-300 mb-2">
                        <div className="flex items-center">
                          <User className="w-4 h-4 mr-1" />
                          <span className="text-slate-200">{dep.witness}</span>
                          <span className="text-slate-400 ml-1">({dep.role})</span>
                        </div>
                        <div className="flex items-center">
                          <Clock className="w-4 h-4 mr-1" />
                          <span className="text-slate-200">{dep.duration}</span>
                        </div>
                        <span className="text-slate-200">{dep.pages} pages</span>
                      </div>
                      <div className="text-sm text-slate-300">{dep.date}</div>
                    </div>
                    <div className="flex items-center space-x-2">
                      <Badge
                        variant={dep.status === "Analyzed" ? "default" : "secondary"}
                        className="bg-slate-700 text-slate-200 border-slate-600"
                      >
                        {dep.status}
                      </Badge>
                      <Button
                        variant="outline"
                        size="sm"
                        className="border-slate-600 text-slate-200 hover:bg-slate-700"
                        disabled={analyzing && selectedDeposition === dep.id}
                      >
                        {analyzing && selectedDeposition === dep.id
                          ? "Analyzing..."
                          : dep.status === "Analyzed"
                            ? "View Analysis"
                            : "Analyze"}
                      </Button>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        </CardContent>
      </Card>

      {/* Analysis Results */}
      {analysisResult && (
        <div className="space-y-6">
          {/* Summary */}
          <Card className="bg-slate-800 border-slate-700">
            <CardHeader>
              <CardTitle className="text-white">Analysis Summary</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-white">{analysisResult.summary.totalPages}</div>
                  <div className="text-sm text-slate-300">Total Pages</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-blue-400">{analysisResult.summary.keyTestimonySegments}</div>
                  <div className="text-sm text-slate-300">Key Segments</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-green-400">{analysisResult.summary.credibilityScore}%</div>
                  <div className="text-sm text-slate-300">Credibility</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-red-400">{analysisResult.summary.inconsistencies}</div>
                  <div className="text-sm text-slate-300">Inconsistencies</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-purple-400">{analysisResult.summary.importantAdmissions}</div>
                  <div className="text-sm text-slate-300">Key Admissions</div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Detailed Analysis */}
          <Tabs defaultValue="testimony" className="bg-slate-800 border-slate-700 rounded-lg">
            <TabsList className="grid w-full grid-cols-4 bg-slate-700 border-slate-600">
              <TabsTrigger value="testimony" className="data-[state=active]:bg-slate-600 text-slate-200">
                Key Testimony
              </TabsTrigger>
              <TabsTrigger value="timeline" className="data-[state=active]:bg-slate-600 text-slate-200">
                Timeline
              </TabsTrigger>
              <TabsTrigger value="credibility" className="data-[state=active]:bg-slate-600 text-slate-200">
                Credibility Analysis
              </TabsTrigger>
              <TabsTrigger value="search" className="data-[state=active]:bg-slate-600 text-slate-200">
                Search Transcript
              </TabsTrigger>
            </TabsList>

            <TabsContent value="testimony" className="space-y-4 p-6">
              {analysisResult.keyTestimony.map((testimony) => (
                <Card key={testimony.id} className="bg-slate-700 border-slate-600">
                  <CardContent className="p-6">
                    <div className="flex items-start justify-between mb-4">
                      <div className="flex items-center space-x-2">
                        <Star className="w-4 h-4 text-yellow-400" />
                        <h3 className="font-medium text-white">{testimony.topic}</h3>
                        <Badge
                          variant={getImportanceColor(testimony.importance)}
                          className="bg-slate-600 text-slate-200 border-slate-500"
                        >
                          {testimony.importance}
                        </Badge>
                      </div>
                      <Badge variant="outline" className="border-slate-500 text-slate-300">
                        Page {testimony.page}, Lines {testimony.lineStart}-{testimony.lineEnd}
                      </Badge>
                    </div>

                    <div className="bg-slate-600 border border-slate-500 p-4 rounded mb-4">
                      <div className="text-sm font-mono text-slate-200">{testimony.content}</div>
                    </div>

                    <div className="bg-blue-500/10 border border-blue-500/30 rounded-lg p-3 mb-3">
                      <div className="text-sm text-slate-200">
                        <strong className="text-blue-300">Analysis:</strong> {testimony.analysis}
                      </div>
                    </div>

                    <div className="flex flex-wrap gap-2">
                      {testimony.tags.map((tag, index) => (
                        <Badge key={index} variant="outline" className="text-xs border-slate-500 text-slate-300">
                          {tag}
                        </Badge>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              ))}
            </TabsContent>

            <TabsContent value="search" className="p-6">
              <Card className="bg-slate-700 border-slate-600">
                <CardHeader>
                  <CardTitle className="text-white">Search Transcript</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="flex space-x-2">
                    <div className="flex-1 relative">
                      <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400 w-4 h-4" />
                      <Input
                        type="search"
                        placeholder="Search testimony, topics, or keywords..."
                        className="pl-10 bg-slate-600 border-slate-500 text-white placeholder:text-slate-400"
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        onKeyPress={(e) => e.key === "Enter" && handleSearch()}
                      />
                    </div>
                    <Button className="bg-blue-600 hover:bg-blue-700" onClick={handleSearch}>
                      Search
                    </Button>
                  </div>

                  <div className="text-sm text-slate-300">
                    Search across deposition transcript for specific topics, keywords, or phrases.
                  </div>

                  <div className="bg-slate-600 p-4 rounded text-center text-slate-300">
                    Enter a search term to find relevant testimony
                  </div>
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>
        </div>
      )}
    </div>
  )
}
