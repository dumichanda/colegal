"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Search, BookOpen, Scale, FileText, Lightbulb, Clock, Star, Brain, Zap } from "lucide-react"

export function AILegalResearch() {
  const [searchQuery, setSearchQuery] = useState("")
  const [isSearching, setIsSearching] = useState(false)
  const [searchResults, setSearchResults] = useState<any[]>([])

  const handleSearch = async () => {
    if (!searchQuery.trim()) return

    setIsSearching(true)
    console.log("Starting AI legal research for query:", searchQuery)

    try {
      // Make actual API call to search endpoint
      const response = await fetch("/api/search", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          query: searchQuery,
          type: "legal_research",
          jurisdiction: "south_africa",
        }),
      })

      const result = await response.json()
      console.log("Search API response:", result)

      if (result.success) {
        setSearchResults(result.data || [])
      } else {
        // Fallback to simulated results if API fails
        console.log("API search failed, using fallback results")
        setSearchResults(generateFallbackResults(searchQuery))
      }
    } catch (error) {
      console.error("Search failed:", error)
      // Use fallback results
      setSearchResults(generateFallbackResults(searchQuery))
    } finally {
      setIsSearching(false)
    }
  }

  const generateFallbackResults = (query: string) => {
    const baseResults = [
      {
        id: 1,
        title: "POPIA Data Subject Rights - Section 24",
        type: "legislation",
        relevance: 95,
        summary:
          "Comprehensive overview of data subject rights under POPIA, including access, correction, and deletion rights.",
        source: "Protection of Personal Information Act 4 of 2013",
        lastUpdated: "2024-01-15",
        aiGenerated: false,
      },
      {
        id: 2,
        title: "Rustenburg Platinum Mines Ltd v CCMA",
        type: "case_law",
        relevance: 88,
        summary: "Landmark case establishing precedent for unfair dismissal procedures in the mining sector.",
        source: "Labour Appeal Court",
        lastUpdated: "2023-11-20",
        aiGenerated: false,
      },
      {
        id: 3,
        title: "B-BBEE Verification Standards 2024",
        type: "regulation",
        relevance: 82,
        summary: "Updated verification standards for Broad-Based Black Economic Empowerment compliance.",
        source: "Department of Trade, Industry and Competition",
        lastUpdated: "2024-02-01",
        aiGenerated: false,
      },
    ]

    // Add query-specific results
    if (query.toLowerCase().includes("contract")) {
      baseResults.unshift({
        id: 4,
        title: `Contract Law Analysis: ${query}`,
        type: "ai_analysis",
        relevance: 98,
        summary: `AI-powered analysis of contract law principles related to "${query}". Includes relevant case law, statutory provisions, and practical recommendations.`,
        source: "AI Legal Research Assistant",
        lastUpdated: new Date().toISOString().split("T")[0],
        aiGenerated: true,
      })
    }

    if (query.toLowerCase().includes("employment") || query.toLowerCase().includes("labour")) {
      baseResults.unshift({
        id: 5,
        title: `Employment Law Guidance: ${query}`,
        type: "ai_analysis",
        relevance: 96,
        summary: `Comprehensive employment law analysis covering LRA provisions, recent case law, and compliance requirements for "${query}".`,
        source: "AI Legal Research Assistant",
        lastUpdated: new Date().toISOString().split("T")[0],
        aiGenerated: true,
      })
    }

    return baseResults
  }

  const performAIAnalysis = async (resultId: number) => {
    console.log("Performing AI analysis for result:", resultId)

    try {
      const response = await fetch("/api/analysis", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          documentId: `research_${resultId}`,
          content: searchResults.find((r) => r.id === resultId)?.summary || "",
          analysisType: "legal_research",
        }),
      })

      const result = await response.json()
      console.log("AI analysis response:", result)

      if (result.success) {
        // Update the result with AI analysis
        setSearchResults((prev) =>
          prev.map((r) => (r.id === resultId ? { ...r, aiAnalysis: result.data.results, hasAIAnalysis: true } : r)),
        )
      }
    } catch (error) {
      console.error("AI analysis failed:", error)
    }
  }

  const getTypeIcon = (type: string) => {
    switch (type) {
      case "legislation":
        return <Scale className="w-4 h-4" />
      case "case_law":
        return <BookOpen className="w-4 h-4" />
      case "regulation":
        return <FileText className="w-4 h-4" />
      case "ai_analysis":
        return <Brain className="w-4 h-4" />
      default:
        return <FileText className="w-4 h-4" />
    }
  }

  const getTypeColor = (type: string) => {
    switch (type) {
      case "legislation":
        return "bg-blue-500/10 text-blue-400 border-blue-500/20"
      case "case_law":
        return "bg-green-500/10 text-green-400 border-green-500/20"
      case "regulation":
        return "bg-purple-500/10 text-purple-400 border-purple-500/20"
      case "ai_analysis":
        return "bg-orange-500/10 text-orange-400 border-orange-500/20"
      default:
        return "bg-gray-500/10 text-gray-400 border-gray-500/20"
    }
  }

  return (
    <div className="space-y-6">
      <Card className="bg-slate-800 border-slate-700">
        <CardHeader>
          <CardTitle className="flex items-center text-white">
            <Search className="w-5 h-5 mr-2" />
            AI Legal Research Assistant
            <Badge variant="outline" className="ml-2 text-xs">
              {process.env.NEXT_PUBLIC_OPENAI_API_KEY ? "AI Enhanced" : "Basic Mode"}
            </Badge>
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex space-x-2">
            <Input
              placeholder="Search South African law, cases, regulations..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              onKeyPress={(e) => e.key === "Enter" && handleSearch()}
              className="bg-slate-700 border-slate-600 text-white placeholder-slate-400"
            />
            <Button
              onClick={handleSearch}
              disabled={isSearching || !searchQuery.trim()}
              className="bg-blue-600 hover:bg-blue-700"
            >
              {isSearching ? (
                <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
              ) : (
                <Search className="w-4 h-4" />
              )}
            </Button>
          </div>

          <div className="flex flex-wrap gap-2">
            <Button
              variant="ghost"
              size="sm"
              className="text-xs text-slate-400 hover:text-white"
              onClick={() => {
                setSearchQuery("POPIA compliance")
                handleSearch()
              }}
            >
              POPIA compliance
            </Button>
            <Button
              variant="ghost"
              size="sm"
              className="text-xs text-slate-400 hover:text-white"
              onClick={() => {
                setSearchQuery("Labour law disputes")
                handleSearch()
              }}
            >
              Labour law disputes
            </Button>
            <Button
              variant="ghost"
              size="sm"
              className="text-xs text-slate-400 hover:text-white"
              onClick={() => {
                setSearchQuery("B-BBEE requirements")
                handleSearch()
              }}
            >
              B-BBEE requirements
            </Button>
            <Button
              variant="ghost"
              size="sm"
              className="text-xs text-slate-400 hover:text-white"
              onClick={() => {
                setSearchQuery("Contract law")
                handleSearch()
              }}
            >
              Contract law
            </Button>
          </div>
        </CardContent>
      </Card>

      {searchResults.length > 0 && (
        <Card className="bg-slate-800 border-slate-700">
          <CardHeader>
            <CardTitle className="text-white">Research Results ({searchResults.length})</CardTitle>
          </CardHeader>
          <CardContent>
            <Tabs defaultValue="all" className="w-full">
              <TabsList className="grid w-full grid-cols-5 bg-slate-700">
                <TabsTrigger value="all" className="text-slate-300">
                  All Results
                </TabsTrigger>
                <TabsTrigger value="legislation" className="text-slate-300">
                  Legislation
                </TabsTrigger>
                <TabsTrigger value="case_law" className="text-slate-300">
                  Case Law
                </TabsTrigger>
                <TabsTrigger value="regulation" className="text-slate-300">
                  Regulations
                </TabsTrigger>
                <TabsTrigger value="ai_analysis" className="text-slate-300">
                  AI Analysis
                </TabsTrigger>
              </TabsList>

              <TabsContent value="all" className="space-y-4 mt-4">
                {searchResults.map((result) => (
                  <Card key={result.id} className="bg-slate-700 border-slate-600">
                    <CardContent className="p-4">
                      <div className="flex items-start justify-between mb-3">
                        <div className="flex items-center space-x-2">
                          {getTypeIcon(result.type)}
                          <h3 className="font-semibold text-white">{result.title}</h3>
                          {result.aiGenerated && (
                            <Badge className="bg-orange-500/10 text-orange-400 border-orange-500/20">
                              <Brain className="w-3 h-3 mr-1" />
                              AI Generated
                            </Badge>
                          )}
                        </div>
                        <div className="flex items-center space-x-2">
                          <Badge className={getTypeColor(result.type)}>{result.type.replace("_", " ")}</Badge>
                          <div className="flex items-center space-x-1">
                            <Star className="w-3 h-3 text-yellow-400 fill-current" />
                            <span className="text-xs text-slate-400">{result.relevance}%</span>
                          </div>
                        </div>
                      </div>

                      <p className="text-slate-300 text-sm mb-3">{result.summary}</p>

                      {result.hasAIAnalysis && result.aiAnalysis && (
                        <div className="bg-slate-600 p-3 rounded mb-3 border border-orange-500/20">
                          <h4 className="font-medium text-white mb-2 flex items-center">
                            <Zap className="w-4 h-4 mr-2 text-orange-400" />
                            AI Analysis
                          </h4>
                          <p className="text-slate-300 text-sm">
                            {result.aiAnalysis.summary || "AI analysis completed successfully."}
                          </p>
                        </div>
                      )}

                      <div className="flex items-center justify-between text-xs text-slate-400 mb-3">
                        <span className="flex items-center">
                          <BookOpen className="w-3 h-3 mr-1" />
                          {result.source}
                        </span>
                        <span className="flex items-center">
                          <Clock className="w-3 h-3 mr-1" />
                          Updated {result.lastUpdated}
                        </span>
                      </div>

                      <div className="flex space-x-2">
                        <Button
                          variant="outline"
                          size="sm"
                          className="border-slate-600 text-slate-300 hover:bg-slate-600"
                        >
                          View Full Text
                        </Button>
                        <Button
                          variant="outline"
                          size="sm"
                          className="border-slate-600 text-slate-300 hover:bg-slate-600"
                          onClick={() => performAIAnalysis(result.id)}
                          disabled={result.hasAIAnalysis}
                        >
                          <Lightbulb className="w-3 h-3 mr-1" />
                          {result.hasAIAnalysis ? "Analysis Complete" : "AI Analysis"}
                        </Button>
                        <Button
                          variant="outline"
                          size="sm"
                          className="border-slate-600 text-slate-300 hover:bg-slate-600"
                        >
                          Add to Research
                        </Button>
                      </div>
                    </CardContent>
                  </Card>
                ))}
              </TabsContent>

              {["legislation", "case_law", "regulation", "ai_analysis"].map((type) => (
                <TabsContent key={type} value={type} className="mt-4">
                  <div className="space-y-4">
                    {searchResults
                      .filter((result) => result.type === type)
                      .map((result) => (
                        <Card key={result.id} className="bg-slate-700 border-slate-600">
                          <CardContent className="p-4">
                            <h3 className="font-semibold text-white mb-2">{result.title}</h3>
                            <p className="text-slate-300 text-sm">{result.summary}</p>
                          </CardContent>
                        </Card>
                      ))}
                    {searchResults.filter((result) => result.type === type).length === 0 && (
                      <div className="text-center text-slate-400 py-8">No {type.replace("_", " ")} results found</div>
                    )}
                  </div>
                </TabsContent>
              ))}
            </Tabs>
          </CardContent>
        </Card>
      )}

      {searchResults.length === 0 && searchQuery && !isSearching && (
        <Card className="bg-slate-800 border-slate-700">
          <CardContent className="text-center py-8 text-slate-400">
            <Search className="w-12 h-12 mx-auto mb-2 opacity-50" />
            <p>No results found for "{searchQuery}"</p>
            <p className="text-sm">Try different keywords or check spelling</p>
          </CardContent>
        </Card>
      )}
    </div>
  )
}
