import { type NextRequest, NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

export async function GET(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const documentId = params.id

    const [document] = await sql`
      SELECT id, title, file_path, mime_type
      FROM documents 
      WHERE id = ${documentId}
    `

    if (!document) {
      return NextResponse.json({ error: "Document not found" }, { status: 404 })
    }

    // In a real implementation, you would fetch the file from your storage service
    // For now, we'll return a placeholder response
    const content = `Document: ${document.title}\n\nThis is a placeholder for the actual document content.`

    return new NextResponse(content, {
      headers: {
        "Content-Type": document.mime_type || "text/plain",
        "Content-Disposition": `attachment; filename="${document.title}.txt"`,
      },
    })
  } catch (error) {
    console.error("Database error:", error)
    return NextResponse.json({ error: "Failed to download document" }, { status: 500 })
  }
}
