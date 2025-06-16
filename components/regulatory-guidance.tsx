"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Badge } from "@/components/ui/badge"
import { Search, BookOpen } from "lucide-react"

interface GuidanceResponse {
  guidance: string
  relatedDocuments: Array<{
    id: string
    title: string
    type: string
  }>
  relatedRules: Array<{
    id: string
    title: string
    description: string
    category: string
  }>
  confidence: number
  aiPowered: boolean
}

export function RegulatoryGuidance() {
  const [query, setQuery] = useState("")
  const [jurisdiction, setJurisdiction] = useState("South Africa")
  const [guidance, setGuidance] = useState<GuidanceResponse | null>(null)
  const [loading, setLoading] = useState(false)

  const handleSearch = async () => {
    if (!query.trim()) return

    setLoading(true)
    try {
      const response = await fetch("/api/search", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ query, jurisdiction }),
      })

      if (!response.ok) throw new Error("Search failed")

      const data = await response.json()
      setGuidance(data.data)
    } catch (error) {
      console.error("Failed to get guidance:", error)
      setGuidance({
        guidance: `Unable to fetch guidance for "${query}". Please try again or consult with a qualified legal professional.`,
        relatedDocuments: [],
        relatedRules: [],
        confidence: 0,
        aiPowered: false,
      })
    } finally {
      setLoading(false)
    }
  }

  const quickQueries = [
    "POPIA compliance requirements for financial services",
    "B-BBEE verification and compliance obligations",
    "Labour Relations Act employment termination procedures",
    "Companies Act director duties and liabilities",
    "Consumer Protection Act warranty requirements",
  ]

  return (
    <div className="space-y-6">
      <Card className="bg-slate-800 border-slate-700">
        <CardHeader>
          <CardTitle className="text-xl flex items-center text-white">
            <BookOpen className="w-5 h-5 mr-2" />
            Regulatory Guidance
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {/* Search Interface */}
          <div className="flex flex-col md:flex-row gap-4">
            <div className="flex-1">
              <Input
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder="Ask about South African regulations, compliance requirements, or legal guidance..."
                onKeyPress={(e) => e.key === "Enter" && handleSearch()}
                className="bg-slate-900 border-slate-600 text-white placeholder:text-slate-400"
              />
            </div>
            <Select value={jurisdiction} onValueChange={setJurisdiction}>
              <SelectTrigger className="w-48 bg-slate-900 border-slate-600 text-white">
                <SelectValue />
              </SelectTrigger>
              <SelectContent className="bg-slate-800 border-slate-700">
                <SelectItem value="South Africa">South Africa</SelectItem>
                <SelectItem value="Western Cape">Western Cape</SelectItem>
                <SelectItem value="Gauteng">Gauteng</SelectItem>
                <SelectItem value="KwaZulu-Natal">KwaZulu-Natal</SelectItem>
              </SelectContent>
            </Select>
            <Button
              onClick={handleSearch}
              disabled={loading || !query.trim()}
              className="bg-blue-600 hover:bg-blue-700"
            >
              <Search className="w-4 h-4 mr-2" />
              {loading ? "Searching..." : "Search"}
            </Button>
          </div>

          {/* Quick Query Buttons */}
          <div className="space-y-2">
            <p className="text-sm font-medium text-slate-300">Quick searches:</p>
            <div className="flex flex-wrap gap-2">
              {quickQueries.map((quickQuery, index) => (
                <Button
                  key={index}
                  variant="outline"
                  size="sm"
                  onClick={() => setQuery(quickQuery)}
                  className="text-xs border-slate-600 text-slate-300 hover:bg-slate-700"
                >
                  {quickQuery}
                </Button>
              ))}
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Guidance Results */}
      {guidance && (
        <Card className="bg-slate-800 border-slate-700">
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle className="text-lg text-white">Regulatory Guidance</CardTitle>
              <div className="flex items-center space-x-2">
                <Badge variant="outline" className="border-slate-600 text-slate-300">
                  {jurisdiction}
                </Badge>
                {guidance.aiPowered && (
                  <Badge variant="outline" className="border-blue-500 text-blue-300">
                    AI-Powered
                  </Badge>
                )}
                <Badge variant="outline" className="border-slate-600 text-slate-300">
                  {guidance.confidence}% Confidence
                </Badge>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <div className="prose prose-sm max-w-none">
              <div className="whitespace-pre-wrap text-slate-300 leading-relaxed">{guidance.guidance}</div>
            </div>

            {/* Related Documents */}
            {guidance.relatedDocuments.length > 0 && (
              <div className="mt-6">
                <h4 className="font-medium text-white mb-3">Related Documents</h4>
                <div className="space-y-2">
                  {guidance.relatedDocuments.map((doc) => (
                    <div key={doc.id} className="p-3 bg-slate-700 rounded-lg">
                      <div className="flex items-center justify-between">
                        <span className="text-slate-200">{doc.title}</span>
                        <Badge variant="outline" className="text-xs border-slate-500 text-slate-300">
                          {doc.type}
                        </Badge>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Related Rules */}
            {guidance.relatedRules.length > 0 && (
              <div className="mt-6">
                <h4 className="font-medium text-white mb-3">Related Compliance Rules</h4>
                <div className="space-y-2">
                  {guidance.relatedRules.map((rule) => (
                    <div key={rule.id} className="p-3 bg-slate-700 rounded-lg">
                      <div className="flex items-start justify-between mb-1">
                        <span className="text-slate-200 font-medium">{rule.title}</span>
                        <Badge variant="outline" className="text-xs border-slate-500 text-slate-300">
                          {rule.category}
                        </Badge>
                      </div>
                      <p className="text-sm text-slate-400">{rule.description}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}

            <div className="mt-4 pt-4 border-t border-slate-700">
              <p className="text-xs text-slate-500">
                This guidance is {guidance.aiPowered ? "AI-generated and" : ""} should be verified with authoritative
                legal sources. Always consult with qualified legal professionals for specific legal advice.
              </p>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  )
}
