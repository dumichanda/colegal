"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Calendar, Download, Share } from "lucide-react"

export function TimelineBuilder() {
  const [selectedDocuments, setSelectedDocuments] = useState<string[]>([])
  const [timelineData, setTimelineData] = useState<any>(null)
  const [isGenerating, setIsGenerating] = useState(false)

  const availableDocuments = [
    { id: "doc-1", title: "Software License Agreement - TechCorp", type: "Contract" },
    { id: "doc-2", title: "Employment Agreement - Senior Developer", type: "Contract" },
    { id: "doc-3", title: "Email Chain - Project Discussions", type: "Communication" },
    { id: "doc-4", title: "Meeting Minutes - Board Meeting", type: "Minutes" },
    { id: "doc-5", title: "Patent Filing Documents", type: "Legal Filing" },
  ]

  const mockTimelineData = {
    title: "Patent Infringement Case Timeline",
    totalEvents: 24,
    dateRange: { start: "2023-01-15", end: "2024-12-10" },
    events: [
      {
        id: 1,
        date: "2023-01-15",
        title: "Initial Patent Filing",
        description: "XYZ Corp files patent application for innovative software algorithm",
        category: "Patent",
        importance: "High",
        source: "Patent Filing Documents",
        page: 1,
        evidence: ["Patent application #12345678", "Technical specifications"],
      },
      {
        id: 2,
        date: "2023-03-22",
        title: "Competitor Product Development Begins",
        description: "ABC Inc. starts development of competing product with similar functionality",
        category: "Development",
        importance: "High",
        source: "Email Chain - Project Discussions",
        page: 15,
        evidence: ["Email from CTO to development team", "Project kickoff meeting notes"],
      },
      {
        id: 3,
        date: "2023-06-10",
        title: "Patent Granted",
        description: "USPTO grants patent to XYZ Corp after examination",
        category: "Patent",
        importance: "Critical",
        source: "Patent Filing Documents",
        page: 45,
        evidence: ["Patent grant certificate", "USPTO correspondence"],
      },
      {
        id: 4,
        date: "2023-08-15",
        title: "Competitor Product Launch",
        description: "ABC Inc. launches product with allegedly infringing features",
        category: "Product Launch",
        importance: "Critical",
        source: "Meeting Minutes - Board Meeting",
        page: 8,
        evidence: ["Product announcement", "Marketing materials", "Technical documentation"],
      },
      {
        id: 5,
        date: "2023-10-03",
        title: "Cease and Desist Letter Sent",
        description: "XYZ Corp sends formal notice of patent infringement to ABC Inc.",
        category: "Legal Action",
        importance: "High",
        source: "Legal Correspondence",
        page: 2,
        evidence: ["Cease and desist letter", "Delivery confirmation"],
      },
      {
        id: 6,
        date: "2023-11-20",
        title: "Settlement Negotiations Begin",
        description: "Parties engage in preliminary settlement discussions",
        category: "Settlement",
        importance: "Medium",
        source: "Email Chain - Legal Discussions",
        page: 23,
        evidence: ["Settlement proposal", "Counter-proposal", "Meeting notes"],
      },
      {
        id: 7,
        date: "2024-01-12",
        title: "Lawsuit Filed",
        description: "XYZ Corp files patent infringement lawsuit in federal court",
        category: "Litigation",
        importance: "Critical",
        source: "Court Filing",
        page: 1,
        evidence: ["Complaint", "Filing receipt", "Summons"],
      },
      {
        id: 8,
        date: "2024-12-10",
        title: "Discovery Phase Begins",
        description: "Court orders commencement of discovery proceedings",
        category: "Discovery",
        importance: "High",
        source: "Court Order",
        page: 3,
        evidence: ["Discovery order", "Scheduling conference notes"],
      },
    ],
    milestones: [
      { date: "2023-06-10", title: "Patent Granted", type: "Patent" },
      { date: "2023-08-15", title: "Product Launch", type: "Infringement" },
      { date: "2024-01-12", title: "Lawsuit Filed", type: "Litigation" },
    ],
    categories: [
      { name: "Patent", count: 3, color: "blue" },
      { name: "Development", count: 4, color: "green" },
      { name: "Legal Action", count: 6, color: "red" },
      { name: "Settlement", count: 2, color: "yellow" },
      { name: "Litigation", count: 9, color: "purple" },
    ],
  }

  const handleGenerateTimeline = async () => {
    setIsGenerating(true)
    // Simulate API call
    setTimeout(() => {
      setTimelineData(mockTimelineData)
      setIsGenerating(false)
    }, 3000)
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
          </div>

          <div className="flex justify-between items-center">
            <div className="text-sm text-slate-400">{selectedDocuments.length} documents selected</div>
            <Button onClick={handleGenerateTimeline} disabled={selectedDocuments.length === 0 || isGenerating}>
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
                  {timelineData.categories.map((category: any) => (
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
                  {timelineData.events.map((event: any, index: number) => (
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
                              {event.evidence.map((evidence: string, idx: number) => (
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
                {timelineData.milestones.map((milestone: any, index: number) => (
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
