import { notFound } from "next/navigation"
import { getDocumentById } from "@/lib/database"
import { DocumentViewer } from "@/components/document-viewer"
import { Button } from "@/components/ui/button"
import { ArrowLeft } from "lucide-react"
import Link from "next/link"

interface DocumentPageProps {
  params: {
    id: string
  }
}

export default async function DocumentPage({ params }: DocumentPageProps) {
  const document = await getDocumentById(params.id)

  if (!document) {
    notFound()
  }

  return (
    <div className="container mx-auto py-6 space-y-6">
      <div className="flex items-center gap-4">
        <Link href="/documents">
          <Button variant="outline" size="sm" className="flex items-center gap-2">
            <ArrowLeft className="h-4 w-4" />
            Back to Documents
          </Button>
        </Link>
        <h1 className="text-2xl font-bold">Document Details</h1>
      </div>

      <DocumentViewer document={document} />
    </div>
  )
}
