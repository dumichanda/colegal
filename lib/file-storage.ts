import { writeFile, mkdir, readFile } from "fs/promises"
import { existsSync } from "fs"
import path from "path"

export class FileStorage {
  private baseDir: string

  constructor(baseDir = "./public/generated-pdfs") {
    this.baseDir = baseDir
  }

  async ensureDirectory(): Promise<void> {
    if (!existsSync(this.baseDir)) {
      await mkdir(this.baseDir, { recursive: true })
    }
  }

  async saveFile(fileName: string, buffer: Buffer): Promise<string> {
    await this.ensureDirectory()
    const filePath = path.join(this.baseDir, fileName)
    await writeFile(filePath, buffer)
    return `/generated-pdfs/${fileName}`
  }

  async getFile(fileName: string): Promise<Buffer> {
    const filePath = path.join(this.baseDir, fileName)
    return await readFile(filePath)
  }

  async fileExists(fileName: string): Promise<boolean> {
    const filePath = path.join(this.baseDir, fileName)
    return existsSync(filePath)
  }

  generateFileName(title: string, extension = "pdf"): string {
    const sanitized = title.replace(/[^a-zA-Z0-9]/g, "_")
    const timestamp = Date.now()
    return `${sanitized}_${timestamp}.${extension}`
  }
}

export const fileStorage = new FileStorage()
