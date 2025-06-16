import { type NextRequest, NextResponse } from "next/server"
import { pdfGenerator, type DocumentData } from "@/lib/pdf-generator"
import { sql } from "@/lib/database"

export async function GET(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    console.log(`Generating PDF for document ID: ${params.id}`)

    // Fetch document from database
    const result = await sql`
      SELECT 
        d.id,
        d.title,
        d.type,
        d.category,
        d.content,
        d.risk_level,
        d.created_at,
        o.name as organization_name
      FROM documents d
      LEFT JOIN organizations o ON d.organization_id = o.id
      WHERE d.id = ${params.id}
    `

    if (result.length === 0) {
      return new NextResponse("Document not found", { status: 404 })
    }

    const document = result[0]

    // Prepare document data for PDF generation
    const documentData: DocumentData = {
      id: document.id,
      title: document.title,
      type: document.category || document.type,
      content: document.content,
      organization: document.organization_name,
      createdDate: new Date(document.created_at).toLocaleDateString(),
      riskLevel: document.risk_level,
    }

    console.log(`Generating PDF for document type: ${documentData.type}`)

    // Generate PDF
    const pdfBuffer = pdfGenerator.generateDocument(documentData.type, documentData)

    // Store PDF file path in database
    const fileName = `${document.title.replace(/[^a-zA-Z0-9]/g, "_")}_${Date.now()}.pdf`
    const filePath = `/generated-pdfs/${fileName}`

    await sql`
      UPDATE documents 
      SET 
        file_path = ${filePath},
        file_size = ${pdfBuffer.length},
        mime_type = 'application/pdf',
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ${params.id}
    `

    console.log(`PDF generated successfully: ${fileName}`)

    return new NextResponse(pdfBuffer, {
      headers: {
        "Content-Type": "application/pdf",
        "Content-Disposition": `inline; filename="${fileName}"`,
        "Cache-Control": "public, max-age=3600",
      },
    })
  } catch (error) {
    console.error("Error generating PDF:", error)
    return new NextResponse("Error generating PDF", { status: 500 })
  }
}
