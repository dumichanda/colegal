"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Input } from "@/components/ui/input"
import { Progress } from "@/components/ui/progress"
import { FileText, Search, Clock, User, AlertTriangle, Star } from "lucide-react"

export function DepositionReview() {
  const [selectedDeposition, setSelectedDeposition] = useState<string | null>(null)
  const [searchQuery, setSearchQuery] = useState("")
  const [analysisResult, setAnalysisResult] = useState<any>(null)

  const depositions = [
    {
      id: "dep-1",
      title: "John Smith Deposition - Patent Infringement Case",
      date: "2024-12-10",
      witness: "John Smith",
      role: "Former CTO",
      pages: 287,
      duration: "6h 23m",
      status: "Analyzed",
    },
    {
      id: "dep-2",
      title: "Sarah Johnson Deposition - Employment Dispute",
      date: "2024-12-08",
      witness: "Sarah Johnson",
      role: "HR Director",
      pages: 156,
      duration: "3h 45m",
      status: "Processing",
    },
    {
      id: "dep-3",
      title: "Michael Chen Deposition - Contract Breach",
      date: "2024-12-05",
      witness: "Michael Chen",
      role: "Project Manager",
      pages: 203,
      duration: "4h 12m",
      status: "Analyzed",
    },
  ]

  const mockAnalysisResult = {
    summary: {
      totalPages: 287,
      keyTestimonySegments: 23,
      credibilityScore: 78,
      inconsistencies: 4,
      importantAdmissions: 7,
    },
    keyTestimony: [
      {
        id: 1,
        page: 45,
        lineStart: 12,
        lineEnd: 18,
        topic: "Knowledge of Patent",
        importance: "High",
        content:
          "Q: Were you aware of the XYZ patent when developing the competing product? A: Yes, I was familiar with it. We discussed it in several team meetings.",
        analysis: "Direct admission of knowledge - crucial for willful infringement claim",
        tags: ["Patent Knowledge", "Willful Infringement", "Key Admission"],
      },
      {
        id: 2,
        page: 78,
        lineStart: 5,
        lineEnd: 12,
        topic: "Timeline of Development",
        importance: "Medium",
        content:
          "Q: When did development begin? A: We started the initial design work in March 2023, but serious development didn't begin until June.",
        analysis: "Establishes timeline - important for damages calculation",
        tags: ["Timeline", "Development", "Damages"],
      },
      {
        id: 3,
        page: 156,
        lineStart: 20,
        lineEnd: 25,
        topic: "Communication with Legal",
        importance: "High",
        content:
          "Q: Did you consult with legal counsel about potential patent issues? A: I mentioned it to our legal team, but they said to proceed.",
        analysis: "Potential advice of counsel defense - need to explore further",
        tags: ["Legal Advice", "Defense Strategy", "Privilege Issues"],
      },
    ],
    timeline: [
      { date: "March 2023", event: "Initial design discussions", page: 78, importance: "Medium" },
      { date: "June 2023", event: "Serious development begins", page: 78, importance: "High" },
      { date: "August 2023", event: "Patent discussion with legal", page: 156, importance: "High" },
      { date: "October 2023", event: "Product launch", page: 203, importance: "High" },
    ],
    credibilityAnalysis: {
      overallScore: 78,
      factors: [
        { factor: "Consistency", score: 82, notes: "Generally consistent responses" },
        { factor: "Detail Level", score: 75, notes: "Good detail on technical matters" },
        { factor: "Evasiveness", score: 70, notes: "Some evasive answers on key topics" },
        { factor: "Memory", score: 85, notes: "Strong recall of technical details" },
      ],
      redFlags: [
        "Inconsistent testimony about meeting dates on pages 45 and 67",
        "Vague responses when asked about specific conversations with competitors",
      ],
    },
  }

  const handleAnalyze = (depositionId: string) => {
    setSelectedDeposition(depositionId)
    // Simulate analysis
    setTimeout(() => {
      setAnalysisResult(mockAnalysisResult)
    }, 2000)
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
            {depositions.map((dep) => (
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
                    <Button variant="outline" size="sm" className="border-slate-600 text-slate-200 hover:bg-slate-700">
                      {dep.status === "Analyzed" ? "View Analysis" : "Analyze"}
                    </Button>
                  </div>
                </div>
              </div>
            ))}
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
              {analysisResult.keyTestimony.map((testimony: any) => (
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
                      {testimony.tags.map((tag: string, index: number) => (
                        <Badge key={index} variant="outline" className="text-xs border-slate-500 text-slate-300">
                          {tag}
                        </Badge>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              ))}
            </TabsContent>

            <TabsContent value="timeline" className="p-6">
              <Card className="bg-slate-700 border-slate-600">
                <CardHeader>
                  <CardTitle className="text-white">Case Timeline</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {analysisResult.timeline.map((event: any, index: number) => (
                      <div
                        key={index}
                        className="flex items-start space-x-4 pb-4 border-b border-slate-600 last:border-b-0"
                      >
                        <div className="w-24 text-sm font-medium text-slate-300">{event.date}</div>
                        <div className="flex-1">
                          <div className="font-medium text-white">{event.event}</div>
                          <div className="text-sm text-slate-300">Referenced on page {event.page}</div>
                        </div>
                        <Badge
                          variant={getImportanceColor(event.importance)}
                          className="bg-slate-600 text-slate-200 border-slate-500"
                        >
                          {event.importance}
                        </Badge>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="credibility" className="p-6">
              <Card className="bg-slate-700 border-slate-600">
                <CardHeader>
                  <CardTitle className="text-white">Credibility Analysis</CardTitle>
                </CardHeader>
                <CardContent className="space-y-6">
                  <div className="text-center">
                    <div className="text-4xl font-bold text-white mb-2">
                      {analysisResult.credibilityAnalysis.overallScore}%
                    </div>
                    <div className="text-slate-300">Overall Credibility Score</div>
                  </div>

                  <div className="space-y-4">
                    <h4 className="font-medium text-white">Credibility Factors</h4>
                    {analysisResult.credibilityAnalysis.factors.map((factor: any, index: number) => (
                      <div key={index} className="space-y-2">
                        <div className="flex justify-between">
                          <span className="font-medium text-white">{factor.factor}</span>
                          <span className="text-slate-200">{factor.score}%</span>
                        </div>
                        <Progress value={factor.score} className="bg-slate-600" />
                        <div className="text-sm text-slate-300">{factor.notes}</div>
                      </div>
                    ))}
                  </div>

                  <div className="space-y-3">
                    <h4 className="font-medium flex items-center text-white">
                      <AlertTriangle className="w-4 h-4 mr-2 text-red-400" />
                      Red Flags
                    </h4>
                    {analysisResult.credibilityAnalysis.redFlags.map((flag: string, index: number) => (
                      <div
                        key={index}
                        className="p-3 bg-red-500/10 border border-red-500/30 rounded text-sm text-slate-200"
                      >
                        {flag}
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
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
                      />
                    </div>
                    <Button className="bg-blue-600 hover:bg-blue-700">Search</Button>
                  </div>

                  <div className="text-sm text-slate-300">
                    Search across 287 pages of testimony for specific topics, keywords, or phrases.
                  </div>

                  {/* Search results would appear here */}
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
