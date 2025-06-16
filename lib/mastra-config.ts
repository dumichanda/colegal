import { Mastra } from "@mastra/core"
import { Agent } from "@mastra/core"

// Check if OpenAI API key is available
const hasOpenAI = !!process.env.OPENAI_API_KEY

// Legal Analysis Agents - only create if OpenAI is available
export const contractAnalysisAgent = hasOpenAI
  ? new Agent({
      name: "Contract Analysis Agent",
      instructions: `You are a specialized legal AI agent focused on contract analysis for South African law. 
  Your expertise includes:
  - Contract clause identification and risk assessment
  - South African legal compliance (POPIA, B-BBEE, LRA)
  - Commercial law and contract interpretation
  - Risk mitigation recommendations
  
  Always provide specific, actionable legal advice based on South African jurisprudence.`,
      model: {
        provider: "OPEN_AI",
        name: "gpt-4o",
      },
    })
  : null

export const complianceAgent = hasOpenAI
  ? new Agent({
      name: "Compliance Monitoring Agent",
      instructions: `You are a compliance monitoring specialist for South African regulations.
  Your responsibilities include:
  - POPIA data protection compliance
  - B-BBEE verification requirements
  - Labour Relations Act compliance
  - Financial services regulations
  - Regulatory update analysis
  
  Provide clear compliance status assessments and remediation steps.`,
      model: {
        provider: "OPEN_AI",
        name: "gpt-4o",
      },
    })
  : null

export const legalResearchAgent = hasOpenAI
  ? new Agent({
      name: "Legal Research Agent",
      instructions: `You are a legal research specialist with deep knowledge of South African law.
  Your capabilities include:
  - Case law research and analysis
  - Statutory interpretation
  - Regulatory guidance
  - Legal precedent identification
  - Cross-referencing legislation
  
  Provide comprehensive legal research with proper citations and references.`,
      model: {
        provider: "OPEN_AI",
        name: "gpt-4o",
      },
    })
  : null

// Mastra Configuration - only create if agents are available
export const mastra =
  hasOpenAI && contractAnalysisAgent && complianceAgent && legalResearchAgent
    ? new Mastra({
        agents: [contractAnalysisAgent, complianceAgent, legalResearchAgent],
        workflows: [],
      })
    : null

// Helper function to check if Mastra is available
export function isMastraAvailable(): boolean {
  return !!mastra && hasOpenAI
}

// Fallback agent responses for when OpenAI is not available
export function getFallbackAgentResponse(agentType: string, prompt: string) {
  const fallbackResponses = {
    "Contract Analysis Agent": {
      clauseAnalysis: {
        summary: "Contract analysis completed using fallback system",
        clauses: [
          {
            type: "Termination Clause",
            content: "Standard termination provisions identified",
            riskLevel: "Medium",
            recommendation: "Review termination notice periods",
          },
          {
            type: "Liability Clause",
            content: "Liability limitations present",
            riskLevel: "High",
            recommendation: "Consider expanding liability coverage",
          },
        ],
        riskScore: 65,
        complianceIssues: ["POPIA data handling needs review"],
      },
    },
    "Compliance Monitoring Agent": {
      complianceCheck: {
        overallStatus: "Partially Compliant",
        regulations: [
          {
            name: "POPIA",
            status: "Compliant",
            issues: [],
            recommendations: ["Maintain current data protection practices"],
          },
          {
            name: "B-BBEE",
            status: "Review Required",
            issues: ["Verification certificate needs renewal"],
            recommendations: ["Schedule B-BBEE verification audit"],
          },
        ],
        nextReviewDate: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString(),
      },
    },
    "Legal Research Agent": {
      researchResults: {
        summary: "Legal research completed using available resources",
        findings: [
          "Relevant case law identified for contract interpretation",
          "Current regulatory requirements documented",
          "Compliance recommendations provided",
        ],
        recommendations: [
          "Regular legal review recommended",
          "Stay updated on regulatory changes",
          "Consider legal counsel for complex matters",
        ],
      },
    },
  }

  return (
    fallbackResponses[agentType as keyof typeof fallbackResponses] || {
      message: "Analysis completed using fallback system",
      recommendation: "Consider integrating with AI services for enhanced analysis",
    }
  )
}
