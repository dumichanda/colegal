import { CopilotRuntime, OpenAIAdapter } from "@copilotkit/runtime"
import type { NextRequest } from "next/server"
import { openai } from "@ai-sdk/openai"

const runtime = new CopilotRuntime()

export async function POST(req: NextRequest) {
  try {
    const { handleRequest } = runtime

    // Check if OpenAI API key is available
    if (!process.env.OPENAI_API_KEY) {
      console.warn("OPENAI_API_KEY not found, CopilotKit features will be limited")
      return new Response(
        JSON.stringify({
          error: "AI service temporarily unavailable",
          message: "Please configure OpenAI API key for full functionality",
        }),
        {
          status: 503,
          headers: { "Content-Type": "application/json" },
        },
      )
    }

    return handleRequest(
      req,
      new OpenAIAdapter({
        model: openai("gpt-4o-mini"),
      }),
    )
  } catch (error) {
    console.error("CopilotKit API error:", error)
    return new Response(
      JSON.stringify({
        error: "Internal server error",
        message: "Failed to process AI request",
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      },
    )
  }
}
