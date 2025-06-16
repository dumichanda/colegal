import { type NextRequest, NextResponse } from "next/server"
import { pdfGenerator, type DocumentData } from "@/lib/pdf-generator"
import { sql } from "@/lib/database"

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { title, type, category, organizationId, content } = body

    console.log(`Generating new document: ${title} (${type})`)

    // Create document record in database
    const result = await sql`
      INSERT INTO documents (
        organization_id, title, type, category, content, status, risk_level
      ) VALUES (
        ${organizationId}, ${title}, ${type}, ${category || type}, 
        ${content || ""}, 'active', 'medium'
      )
      RETURNING id, title, type, category, created_at
    `

    const document = result[0]

    // Get organization name
    const orgResult = await sql`
      SELECT name FROM organizations WHERE id = ${organizationId}
    `

    const organizationName = orgResult[0]?.name || "Legal AI Assistant"

    // Prepare document data for PDF generation
    const documentData: DocumentData = {
      id: document.id,
      title: document.title,
      type: document.category || document.type,
      content: content,
      organization: organizationName,
      createdDate: new Date(document.created_at).toLocaleDateString(),
      riskLevel: "medium",
    }

    // Generate PDF
    const pdfBuffer = pdfGenerator.generateDocument(documentData.type, documentData)

    // Update document with file information
    const fileName = `${document.title.replace(/[^a-zA-Z0-9]/g, "_")}_${Date.now()}.pdf`
    const filePath = `/generated-pdfs/${fileName}`

    await sql`
      UPDATE documents 
      SET 
        file_path = ${filePath},
        file_size = ${pdfBuffer.length},
        mime_type = 'application/pdf',
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ${document.id}
    `

    console.log(`Document created and PDF generated: ${fileName}`)

    return NextResponse.json({
      success: true,
      document: {
        id: document.id,
        title: document.title,
        type: document.type,
        filePath: filePath,
        fileSize: pdfBuffer.length,
      },
      message: "Document generated successfully",
    })
  } catch (error) {
    console.error("Error generating document:", error)
    return NextResponse.json({ success: false, error: "Failed to generate document" }, { status: 500 })
  }
}
