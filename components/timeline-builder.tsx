"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Calendar, Download, Share } from "lucide-react"

interface Document {
  id: string
  title: string
  type: string
}

interface TimelineData {
  title: string
  totalEvents: number
  dateRange: { start: string; end: string }
  events: Array<{
    id: number
    date: string
    title: string
    description: string
    category: string
    importance: string
    source: string
    page: number
    evidence: string[]
  }>
  milestones: Array<{
    date: string
    title: string
    type: string
  }>
  categories: Array<{
    name: string
    count: number
    color: string
  }>
}

export function TimelineBuilder() {
  const [availableDocuments, setAvailableDocuments] = useState<Document[]>([])
  const [selectedDocuments, setSelectedDocuments] = useState<string[]>([])
  const [timelineData, setTimelineData] = useState<TimelineData | null>(null)
  const [isGenerating, setIsGenerating] = useState(false)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchDocuments()
  }, [])

  const fetchDocuments = async () => {
    try {
      console.log("🔄 Fetching documents for timeline...")
      setLoading(true)
      const response = await fetch("/api/documents")
      if (!response.ok) throw new Error("Failed to fetch documents")
      const data = await response.json()
      console.log("✅ Documents received:", data)
      setAvailableDocuments(Array.isArray(data) ? data : [])
    } catch (error) {
      console.error("❌ Error fetching documents:", error)
      setAvailableDocuments([])
    } finally {
      setLoading(false)
    }
  }

  const handleGenerateTimeline = async () => {
    if (selectedDocuments.length === 0) return

    try {
      console.log("🔄 Generating timeline for documents:", selectedDocuments)
      setIsGenerating(true)

      const response = await fetch("/api/timeline/generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ documentIds: selectedDocuments }),
      })

      if (!response.ok) throw new Error("Failed to generate timeline")
      const data = await response.json()
      console.log("✅ Timeline generated:", data)
      setTimelineData(data.success ? data.data : null)
    } catch (error) {
      console.error("❌ Error generating timeline:", error)
    } finally {
      setIsGenerating(false)
    }
  }

  const getImportanceColor = (importance: string) => {
    switch (importance) {
      case "Critical":
        return "bg-red-500"
      case "High":
        return "bg-orange-500"
      case "Medium":
        return "bg-yellow-500"
      case "Low":
        return "bg-green-500"
      default:
        return "bg-gray-500"
    }
  }

  const getCategoryColor = (category: string) => {
    const colors: { [key: string]: string } = {
      Patent: "bg-blue-500",
      Development: "bg-green-500",
      "Legal Action": "bg-red-500",
      Settlement: "bg-yellow-500",
      Litigation: "bg-purple-500",
      "Product Launch": "bg-indigo-500",
      Discovery: "bg-pink-500",
    }
    return colors[category] || "bg-gray-500"
  }

  if (loading) {
    return (
      <Card className="bg-slate-800 border-slate-700">
        <CardHeader>
          <CardTitle className="flex items-center text-white">
            <Calendar className="w-5 h-5 mr-2" />
            Timeline Builder
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="animate-pulse space-y-4">
            <div className="h-4 bg-slate-700 rounded w-1/2"></div>
            <div className="grid grid-cols-2 gap-2">
              {[1, 2, 3, 4].map((i) => (
                <div key={i} className="h-16 bg-slate-700 rounded"></div>
              ))}
            </div>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <div className="space-y-6">
      {/* Timeline Configuration */}
      <Card className="bg-slate-800 border-slate-700">
        <CardHeader>
          <CardTitle className="flex items-center text-white">
            <Calendar className="w-5 h-5 mr-2" />
            Timeline Builder
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div>
            <label className="block text-sm font-medium mb-2 text-slate-300">Select Documents for Timeline</label>
            {availableDocuments.length === 0 ? (
              <div className="text-center py-8 text-slate-400">
                <Calendar className="w-12 h-12 mx-auto mb-2 opacity-50" />
                <p>No documents available</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
                {availableDocuments.map((doc) => (
                  <label
                    key={doc.id}
                    className="flex items-center space-x-2 p-2 border border-slate-600 rounded cursor-pointer hover:bg-slate-700"
                  >
                    <input
                      type="checkbox"
                      checked={selectedDocuments.includes(doc.id)}
                      onChange={(e) => {
                        if (e.target.checked) {
                          setSelectedDocuments([...selectedDocuments, doc.id])
                        } else {
                          setSelectedDocuments(selectedDocuments.filter((id) => id !== doc.id))
                        }
                      }}
                    />
                    <div className="flex-1">
                      <div className="text-sm font-medium text-white">{doc.title}</div>
                      <div className="text-xs text-slate-400">{doc.type}</div>
                    </div>
                  </label>
                ))}
              </div>
            )}
          </div>

          <div className="flex justify-between items-center">
            <div className="text-sm text-slate-400">{selectedDocuments.length} documents selected</div>
            <Button
              onClick={handleGenerateTimeline}
              disabled={selectedDocuments.length === 0 || isGenerating}
              className="bg-blue-600 hover:bg-blue-700"
            >
              {isGenerating ? "Generating..." : "Generate Timeline"}
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Timeline Results */}
      {timelineData && (
        <div className="space-y-6">
          {/* Timeline Summary */}
          <Card className="bg-slate-800 border-slate-700">
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle className="text-white">{timelineData.title}</CardTitle>
                <div className="flex space-x-2">
                  <Button variant="outline" size="sm" className="border-slate-600 text-slate-300 hover:bg-slate-700">
                    <Download className="w-4 h-4 mr-2" />
                    Export
                  </Button>
                  <Button variant="outline" size="sm" className="border-slate-600 text-slate-300 hover:bg-slate-700">
                    <Share className="w-4 h-4 mr-2" />
                    Share
                  </Button>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-white">{timelineData.totalEvents}</div>
                  <div className="text-sm text-slate-400">Total Events</div>
                </div>
                <div className="text-center">
                  <div className="text-lg font-medium text-white">
                    {new Date(timelineData.dateRange.start).toLocaleDateString()}
                  </div>
                  <div className="text-sm text-slate-400">Start Date</div>
                </div>
                <div className="text-center">
                  <div className="text-lg font-medium text-white">
                    {new Date(timelineData.dateRange.end).toLocaleDateString()}
                  </div>
                  <div className="text-sm text-slate-400">End Date</div>
                </div>
              </div>

              {/* Category Legend */}
              <div className="mt-6">
                <h4 className="font-medium mb-3 text-white">Event Categories</h4>
                <div className="flex flex-wrap gap-2">
                  {timelineData.categories.map((category) => (
                    <div key={category.name} className="flex items-center space-x-2">
                      <div className={`w-3 h-3 rounded-full ${getCategoryColor(category.name)}`}></div>
                      <span className="text-sm text-slate-300">
                        {category.name} ({category.count})
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Timeline Visualization */}
          <Card className="bg-slate-800 border-slate-700">
            <CardHeader>
              <CardTitle className="text-white">Timeline Visualization</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="relative">
                {/* Timeline Line */}
                <div className="absolute left-8 top-0 bottom-0 w-0.5 bg-slate-600"></div>

                {/* Timeline Events */}
                <div className="space-y-6">
                  {timelineData.events.map((event) => (
                    <div key={event.id} className="relative flex items-start space-x-4">
                      {/* Timeline Dot */}
                      <div className="relative z-10">
                        <div
                          className={`w-4 h-4 rounded-full border-2 border-slate-800 ${getImportanceColor(event.importance)}`}
                        ></div>
                      </div>

                      {/* Event Content */}
                      <div className="flex-1 min-w-0 pb-6">
                        <div className="bg-slate-700 border border-slate-600 rounded-lg p-4 shadow-sm">
                          <div className="flex items-start justify-between mb-2">
                            <div className="flex items-center space-x-2">
                              <h3 className="font-medium text-white">{event.title}</h3>
                              <Badge variant="outline" className="text-xs border-slate-500 text-slate-300">
                                {event.category}
                              </Badge>
                              <Badge variant={event.importance === "Critical" ? "destructive" : "default"}>
                                {event.importance}
                              </Badge>
                            </div>
                            <div className="text-sm text-slate-400">{new Date(event.date).toLocaleDateString()}</div>
                          </div>

                          <p className="text-sm text-slate-300 mb-3">{event.description}</p>

                          <div className="flex items-center justify-between text-xs text-slate-400">
                            <div>Source: {event.source}</div>
                            <div>Page {event.page}</div>
                          </div>

                          {/* Evidence */}
                          <div className="mt-3">
                            <div className="text-xs font-medium text-slate-300 mb-1">Evidence:</div>
                            <div className="flex flex-wrap gap-1">
                              {event.evidence.map((evidence, idx) => (
                                <Badge key={idx} variant="outline" className="text-xs border-slate-500 text-slate-300">
                                  {evidence}
                                </Badge>
                              ))}
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Key Milestones */}
          <Card className="bg-slate-800 border-slate-700">
            <CardHeader>
              <CardTitle className="text-white">Key Milestones</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                {timelineData.milestones.map((milestone, index) => (
                  <div key={index} className="p-4 border border-slate-600 rounded-lg text-center">
                    <div className="text-lg font-bold text-white">{milestone.title}</div>
                    <div className="text-sm text-slate-400">{new Date(milestone.date).toLocaleDateString()}</div>
                    <Badge variant="outline" className="mt-2 border-slate-500 text-slate-300">
                      {milestone.type}
                    </Badge>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>
      )}
    </div>
  )
}
