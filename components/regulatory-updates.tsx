"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { ExternalLink, Calendar } from "lucide-react"

interface RegulatoryUpdate {
  id: string
  title: string
  source: string
  jurisdiction: string
  category: string
  impact: string
  effective_date: string
  summary: string
  url?: string
}

export function RegulatoryUpdates() {
  const [updates, setUpdates] = useState<RegulatoryUpdate[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function fetchUpdates() {
      try {
        const response = await fetch("/api/regulatory-updates")
        if (!response.ok) throw new Error("Failed to fetch updates")
        const result = await response.json()

        // Handle the API response structure
        if (result.success && Array.isArray(result.data)) {
          setUpdates(result.data)
        } else {
          console.error("Invalid API response structure:", result)
          setUpdates([])
        }
      } catch (error) {
        console.error("Error fetching regulatory updates:", error)
        setUpdates([])
      } finally {
        setLoading(false)
      }
    }

    fetchUpdates()
  }, [])

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
    })
  }

  if (loading) {
    return (
      <Card className="bg-slate-800 border-slate-700">
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle className="text-lg font-semibold text-white">Regulatory Updates</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-6">
            {[1, 2].map((i) => (
              <div key={i} className="animate-pulse border-l-4 border-slate-600 pl-4">
                <div className="h-4 bg-slate-700 rounded w-3/4 mb-2"></div>
                <div className="h-3 bg-slate-700 rounded w-1/2 mb-2"></div>
                <div className="h-3 bg-slate-700 rounded w-full"></div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className="bg-slate-800 border-slate-700">
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle className="text-lg font-semibold text-white">Regulatory Updates</CardTitle>
        <Button variant="outline" size="sm" className="border-slate-600 text-slate-300 hover:bg-slate-700">
          View All Updates
        </Button>
      </CardHeader>
      <CardContent>
        <div className="space-y-6">
          {updates.length === 0 ? (
            <div className="text-center py-8 text-slate-400">
              <Calendar className="w-12 h-12 mx-auto mb-2 opacity-50" />
              <p>No regulatory updates available</p>
            </div>
          ) : (
            updates.map((update) => (
              <div key={update.id} className="border-l-4 border-blue-500 pl-4">
                <div className="flex items-start justify-between mb-2">
                  <h4 className="text-sm font-semibold text-white leading-tight">{update.title}</h4>
                  <Badge
                    variant={update.impact === "High" ? "destructive" : "outline"}
                    className="text-xs ml-2 border-slate-600"
                  >
                    {update.impact} Impact
                  </Badge>
                </div>

                <div className="flex items-center space-x-4 mb-2 text-xs text-slate-400">
                  <span>{update.source}</span>
                  <span>•</span>
                  <span>{update.jurisdiction}</span>
                  <span>•</span>
                  <Badge variant="outline" className="text-xs border-slate-600 text-slate-300">
                    {update.category}
                  </Badge>
                </div>

                <p className="text-sm text-slate-300 mb-3 leading-relaxed">{update.summary}</p>

                <div className="flex items-center justify-between">
                  <div className="flex items-center text-xs text-slate-500">
                    <Calendar className="w-3 h-3 mr-1" />
                    Effective: {formatDate(update.effective_date)}
                  </div>
                  {update.url && (
                    <Button
                      variant="ghost"
                      size="sm"
                      className="text-xs text-slate-400 hover:text-white"
                      onClick={() => window.open(update.url, "_blank")}
                    >
                      <ExternalLink className="w-3 h-3 mr-1" />
                      Read More
                    </Button>
                  )}
                </div>
              </div>
            ))
          )}
        </div>
      </CardContent>
    </Card>
  )
}
