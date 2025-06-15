"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Badge } from "@/components/ui/badge"
import { Search, BookOpen } from "lucide-react"

export function RegulatoryGuidance() {
  const [query, setQuery] = useState("")
  const [jurisdiction, setJurisdiction] = useState("South Africa")
  const [guidance, setGuidance] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  const handleSearch = async () => {
    if (!query.trim()) return

    setLoading(true)
    try {
      // Simulate API call with mock response
      await new Promise((resolve) => setTimeout(resolve, 2000))

      setGuidance(`
**POPIA Compliance Requirements for Financial Services**

The Protection of Personal Information Act (POPIA) establishes comprehensive data protection requirements for financial institutions in South Africa:

**Key Requirements:**

1. **Lawful Processing (Section 11):**
   - Establish valid legal grounds for processing personal information
   - Common grounds include consent, contract performance, and legitimate interests
   - Financial institutions often rely on contractual necessity and legal obligations

2. **Data Minimisation (Section 12):**
   - Process only personal information that is adequate, relevant, and not excessive
   - Limit collection to what is necessary for the specified purpose
   - Regular review of data collection practices required

3. **Security Safeguards (Section 19):**
   - Implement appropriate technical and organisational measures
   - Protect against unauthorised access, loss, or destruction
   - Regular security assessments and updates required

4. **Cross-Border Transfers (Section 72):**
   - Ensure adequate level of protection in recipient country
   - Implement appropriate safeguards for international transfers
   - Consider adequacy decisions by the Information Regulator

**Compliance Timeline:**
- POPIA became fully effective on 1 July 2021
- One-year grace period ended on 30 June 2022
- Full enforcement and penalties now applicable

**Penalties:**
- Administrative fines up to R10 million
- Criminal penalties up to R10 million or 10 years imprisonment
- Reputational damage and regulatory sanctions

**Recommendations:**
1. Conduct comprehensive data audit
2. Update privacy policies and notices
3. Implement data subject rights procedures
4. Establish incident response protocols
5. Provide staff training on POPIA requirements
      `)
    } catch (error) {
      console.error("Failed to get guidance:", error)
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
              <Badge variant="outline" className="border-slate-600 text-slate-300">
                {jurisdiction}
              </Badge>
            </div>
          </CardHeader>
          <CardContent>
            <div className="prose prose-sm max-w-none">
              <div className="whitespace-pre-wrap text-slate-300 leading-relaxed">{guidance}</div>
            </div>
            <div className="mt-4 pt-4 border-t border-slate-700">
              <p className="text-xs text-slate-500">
                This guidance is AI-generated and should be verified with authoritative legal sources. Always consult
                with qualified legal professionals for specific legal advice.
              </p>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  )
}
