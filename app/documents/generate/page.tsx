"use client"

import { DocumentGenerator } from "@/components/document-generator"
import { useRouter } from "next/navigation"

export default function GenerateDocumentPage() {
  const router = useRouter()

  const handleDocumentGenerated = (document: any) => {
    // Redirect to the generated document
    router.push(`/documents/${document.id}`)
  }

  return (
    <div className="container mx-auto py-8">
      <div className="max-w-4xl mx-auto">
        <div className="mb-8">
          <h1 className="text-3xl font-bold">Generate Legal Document</h1>
          <p className="text-gray-600 mt-2">Create professional legal documents with AI-powered templates</p>
        </div>

        <div className="flex justify-center">
          <DocumentGenerator onDocumentGenerated={handleDocumentGenerated} />
        </div>

        <div className="mt-8 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div className="bg-blue-50 p-6 rounded-lg">
            <h3 className="font-semibold text-blue-900 mb-2">Employment Contracts</h3>
            <p className="text-blue-700 text-sm">
              Generate compliant employment agreements with South African labor law requirements
            </p>
          </div>
          <div className="bg-green-50 p-6 rounded-lg">
            <h3 className="font-semibold text-green-900 mb-2">NDAs</h3>
            <p className="text-green-700 text-sm">
              Create comprehensive non-disclosure agreements with POPIA compliance
            </p>
          </div>
          <div className="bg-purple-50 p-6 rounded-lg">
            <h3 className="font-semibold text-purple-900 mb-2">Partnership Agreements</h3>
            <p className="text-purple-700 text-sm">
              Draft partnership agreements compliant with Companies Act requirements
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}
