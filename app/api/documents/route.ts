import { type NextRequest, NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const type = searchParams.get("type")
    const search = searchParams.get("search")
    const limit = searchParams.get("limit")
    const sort = searchParams.get("sort")

    // Start with base query using only existing column names
    let documents

    if (!type && !search) {
      // No filters - simple query
      if (limit) {
        const limitNum = Number.parseInt(limit)
        if (sort === "recent") {
          documents = await sql`
            SELECT 
              id, title, type, status, created_at, updated_at,
              'medium' as risk_level,
              0 as clauses_count,
              1 as pages_count
            FROM documents 
            ORDER BY created_at DESC
            LIMIT ${limitNum}
          `
        } else {
          documents = await sql`
            SELECT 
              id, title, type, status, created_at, updated_at,
              'medium' as risk_level,
              0 as clauses_count,
              1 as pages_count
            FROM documents 
            ORDER BY updated_at DESC
            LIMIT ${limitNum}
          `
        }
      } else {
        if (sort === "recent") {
          documents = await sql`
            SELECT 
              id, title, type, status, created_at, updated_at,
              'medium' as risk_level,
              0 as clauses_count,
              1 as pages_count
            FROM documents 
            ORDER BY created_at DESC
          `
        } else {
          documents = await sql`
            SELECT 
              id, title, type, status, created_at, updated_at,
              'medium' as risk_level,
              0 as clauses_count,
              1 as pages_count
            FROM documents 
            ORDER BY updated_at DESC
          `
        }
      }
    } else {
      // Build filtered query
      if (type && type !== "all" && search) {
        // Both type and search filters
        documents = await sql`
          SELECT 
            id, title, type, status, created_at, updated_at,
            'medium' as risk_level,
            0 as clauses_count,
            1 as pages_count
          FROM documents 
          WHERE type = ${type} AND (title ILIKE ${"%" + search + "%"} OR content ILIKE ${"%" + search + "%"})
          ORDER BY updated_at DESC
          ${limit ? sql`LIMIT ${Number.parseInt(limit)}` : sql``}
        `
      } else if (type && type !== "all") {
        // Type filter only
        documents = await sql`
          SELECT 
            id, title, type, status, created_at, updated_at,
            'medium' as risk_level,
            0 as clauses_count,
            1 as pages_count
          FROM documents 
          WHERE type = ${type}
          ORDER BY updated_at DESC
          ${limit ? sql`LIMIT ${Number.parseInt(limit)}` : sql``}
        `
      } else if (search) {
        // Search filter only
        documents = await sql`
          SELECT 
            id, title, type, status, created_at, updated_at,
            'medium' as risk_level,
            0 as clauses_count,
            1 as pages_count
          FROM documents 
          WHERE title ILIKE ${"%" + search + "%"} OR content ILIKE ${"%" + search + "%"}
          ORDER BY updated_at DESC
          ${limit ? sql`LIMIT ${Number.parseInt(limit)}` : sql``}
        `
      }
    }

    return NextResponse.json(documents)
  } catch (error) {
    console.error("Database error:", error)
    return NextResponse.json({ error: "Failed to fetch documents" }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { title, type, content, file_path } = body

    const result = await sql`
      INSERT INTO documents (title, type, content, file_path, status)
      VALUES (${title}, ${type}, ${content}, ${file_path}, 'pending')
      RETURNING id, title, type, status, created_at, updated_at
    `

    return NextResponse.json(result[0])
  } catch (error) {
    console.error("Database error:", error)
    return NextResponse.json({ error: "Failed to create document" }, { status: 500 })
  }
}
