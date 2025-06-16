import { type NextRequest, NextResponse } from "next/server"
import { getDocuments, createDocument } from "@/lib/database"

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const organizationId = searchParams.get("organizationId")

    const documents = await getDocuments(organizationId || undefined)

    return NextResponse.json({
      success: true,
      data: documents,
    })
  } catch (error) {
    console.error("Error fetching documents:", error)
    return NextResponse.json({ success: false, error: "Failed to fetch documents" }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData()
    const file = formData.get("file") as File
    const title = formData.get("title") as string
    const type = formData.get("type") as string
    const organizationId = formData.get("organizationId") as string

    if (!file || !title || !type) {
      return NextResponse.json({ success: false, error: "Missing required fields" }, { status: 400 })
    }

    // In a real app, you'd upload to cloud storage (Vercel Blob, S3, etc.)
    const filePath = `/uploads/${Date.now()}-${file.name}`

    const document = await createDocument({
      title,
      type,
      file_path: filePath,
      file_size: file.size,
      mime_type: file.type,
      organization_id: organizationId,
    })

    // Trigger document analysis (async)
    fetch(`${process.env.NEXTAUTH_URL}/api/analysis`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ documentId: document.id }),
    }).catch(console.error)

    return NextResponse.json({
      success: true,
      data: document,
    })
  } catch (error) {
    console.error("Error uploading document:", error)
    return NextResponse.json({ success: false, error: "Failed to upload document" }, { status: 500 })
  }
}
