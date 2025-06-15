import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { ExternalLink, Calendar } from "lucide-react"

export function RegulatoryUpdates() {
  const updates = [
    {
      id: 1,
      title: "POPIA Amendment Bill Introduced",
      source: "Information Regulator South Africa",
      jurisdiction: "South Africa",
      category: "Data Privacy",
      impact: "High",
      effectiveDate: "March 15, 2025",
      summary:
        "Proposed amendments to POPIA include enhanced penalties and expanded data subject rights for cross-border data transfers.",
    },
    {
      id: 2,
      title: "Updated B-BBEE Codes of Good Practice",
      source: "Department of Trade, Industry and Competition",
      jurisdiction: "South Africa",
      category: "B-BBEE",
      impact: "Medium",
      effectiveDate: "January 1, 2025",
      summary:
        "Revised B-BBEE codes introduce new measurement criteria for digital transformation and youth employment.",
    },
  ]

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
          {updates.map((update) => (
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
                  Effective: {update.effectiveDate}
                </div>
                <Button variant="ghost" size="sm" className="text-xs text-slate-400 hover:text-white">
                  <ExternalLink className="w-3 h-3 mr-1" />
                  Read More
                </Button>
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  )
}
