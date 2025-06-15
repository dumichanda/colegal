"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Search, BookOpen, Scale, FileText, Lightbulb, Clock, Star } from "lucide-react"

export function AILegalResearch() {
  const [searchQuery, setSearchQuery] = useState("")
  const [isSearching, setIsSearching] = useState(false)
  const [searchResults, setSearchResults] = useState<any[]>([])

  const handleSearch = async () => {
    if (!searchQuery.trim()) return

    setIsSearching(true)

    // Simulate AI-powered legal research
    setTimeout(() => {
      setSearchResults([
        {
          id: 1,
          title: "POPIA Data Subject Rights - Section 24",
          type: "legislation",
          relevance: 95,
          summary:
            "Comprehensive overview of data subject rights under POPIA, including access, correction, and deletion rights.",
          source: "Protection of Personal Information Act 4 of 2013",
          lastUpdated: "2024-01-15",
        },
        {
          id: 2,
          title: "Rustenburg Platinum Mines Ltd v CCMA",
          type: "case_law",
          relevance: 88,
          summary: "Landmark case establishing precedent for unfair dismissal procedures in the mining sector.",
          source: "Labour Appeal Court",
          lastUpdated: "2023-11-20",
        },
        {
          id: 3,
          title: "B-BBEE Verification Standards 2024",
          type: "regulation",
          relevance: 82,
          summary: "Updated verification standards for Broad-Based Black Economic Empowerment compliance.",
          source: "Department of Trade, Industry and Competition",
          lastUpdated: "2024-02-01",
        },
      ])
      setIsSearching(false)
    }, 2000)
  }

  const getTypeIcon = (type: string) => {
    switch (type) {
      case "legislation":
        return <Scale className="w-4 h-4" />
      case "case_law":
        return <BookOpen className="w-4 h-4" />
      case "regulation":
        return <FileText className="w-4 h-4" />
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
            <Button variant="ghost" size="sm" className="text-xs text-slate-400 hover:text-white">
              POPIA compliance
            </Button>
            <Button variant="ghost" size="sm" className="text-xs text-slate-400 hover:text-white">
              Labour law disputes
            </Button>
            <Button variant="ghost" size="sm" className="text-xs text-slate-400 hover:text-white">
              B-BBEE requirements
            </Button>
            <Button variant="ghost" size="sm" className="text-xs text-slate-400 hover:text-white">
              Contract law
            </Button>
          </div>
        </CardContent>
      </Card>

      {searchResults.length > 0 && (
        <Card className="bg-slate-800 border-slate-700">
          <CardHeader>
            <CardTitle className="text-white">Research Results</CardTitle>
          </CardHeader>
          <CardContent>
            <Tabs defaultValue="all" className="w-full">
              <TabsList className="grid w-full grid-cols-4 bg-slate-700">
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
              </TabsList>

              <TabsContent value="all" className="space-y-4 mt-4">
                {searchResults.map((result) => (
                  <Card key={result.id} className="bg-slate-700 border-slate-600">
                    <CardContent className="p-4">
                      <div className="flex items-start justify-between mb-3">
                        <div className="flex items-center space-x-2">
                          {getTypeIcon(result.type)}
                          <h3 className="font-semibold text-white">{result.title}</h3>
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

                      <div className="flex items-center justify-between text-xs text-slate-400">
                        <span className="flex items-center">
                          <BookOpen className="w-3 h-3 mr-1" />
                          {result.source}
                        </span>
                        <span className="flex items-center">
                          <Clock className="w-3 h-3 mr-1" />
                          Updated {result.lastUpdated}
                        </span>
                      </div>

                      <div className="flex space-x-2 mt-3">
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
                        >
                          <Lightbulb className="w-3 h-3 mr-1" />
                          AI Summary
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

              <TabsContent value="legislation" className="mt-4">
                <div className="text-center text-slate-400 py-8">Filter results by legislation type</div>
              </TabsContent>

              <TabsContent value="case_law" className="mt-4">
                <div className="text-center text-slate-400 py-8">Filter results by case law</div>
              </TabsContent>

              <TabsContent value="regulation" className="mt-4">
                <div className="text-center text-slate-400 py-8">Filter results by regulations</div>
              </TabsContent>
            </Tabs>
          </CardContent>
        </Card>
      )}
    </div>
  )
}
