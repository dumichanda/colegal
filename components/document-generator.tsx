"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Textarea } from "@/components/ui/textarea"
import { FileText, Loader2 } from "lucide-react"

interface DocumentGeneratorProps {
  organizationId?: string
  onDocumentGenerated?: (document: any) => void
}

export function DocumentGenerator({ organizationId, onDocumentGenerated }: DocumentGeneratorProps) {
  const [isGenerating, setIsGenerating] = useState(false)
  const [formData, setFormData] = useState({
    title: "",
    type: "",
    category: "",
    content: "",
  })

  const documentTypes = [
    { value: "employment", label: "Employment Contract" },
    { value: "nda", label: "Non-Disclosure Agreement" },
    { value: "software", label: "Software License Agreement" },
    { value: "partnership", label: "Partnership Agreement" },
    { value: "service", label: "Service Level Agreement" },
  ]

  const handleGenerate = async () => {
    if (!formData.title || !formData.type) {
      alert("Please fill in required fields")
      return
    }

    setIsGenerating(true)
    try {
      const response = await fetch("/api/documents/generate", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          ...formData,
          organizationId: organizationId || "550e8400-e29b-41d4-a716-446655440001",
        }),
      })

      const result = await response.json()

      if (result.success) {
        alert("Document generated successfully!")
        onDocumentGenerated?.(result.document)

        // Reset form
        setFormData({
          title: "",
          type: "",
          category: "",
          content: "",
        })
      } else {
        alert("Failed to generate document: " + result.error)
      }
    } catch (error) {
      console.error("Error generating document:", error)
      alert("Failed to generate document")
    } finally {
      setIsGenerating(false)
    }
  }

  return (
    <Card className="w-full max-w-2xl">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <FileText className="h-5 w-5" />
          Generate Legal Document
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-2">
            <Label htmlFor="title">Document Title *</Label>
            <Input
              id="title"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              placeholder="Enter document title"
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="type">Document Type *</Label>
            <Select
              value={formData.type}
              onValueChange={(value) => setFormData({ ...formData, type: value, category: value })}
            >
              <SelectTrigger>
                <SelectValue placeholder="Select document type" />
              </SelectTrigger>
              <SelectContent>
                {documentTypes.map((type) => (
                  <SelectItem key={type.value} value={type.value}>
                    {type.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </div>

        <div className="space-y-2">
          <Label htmlFor="content">Additional Content (Optional)</Label>
          <Textarea
            id="content"
            value={formData.content}
            onChange={(e) => setFormData({ ...formData, content: e.target.value })}
            placeholder="Enter any specific clauses or requirements..."
            rows={4}
          />
        </div>

        <Button
          onClick={handleGenerate}
          disabled={isGenerating || !formData.title || !formData.type}
          className="w-full"
        >
          {isGenerating ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              Generating PDF...
            </>
          ) : (
            <>
              <FileText className="mr-2 h-4 w-4" />
              Generate Document
            </>
          )}
        </Button>

        <div className="text-sm text-gray-600">
          <p>* Required fields</p>
          <p>Generated documents will include South African legal compliance templates.</p>
        </div>
      </CardContent>
    </Card>
  )
}
