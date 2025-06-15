import { Mastra } from "@mastra/core"
import { Agent } from "@mastra/core"

// Legal Analysis Agents
export const contractAnalysisAgent = new Agent({
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

export const complianceAgent = new Agent({
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

export const legalResearchAgent = new Agent({
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

// Mastra Configuration
export const mastra = new Mastra({
  agents: [contractAnalysisAgent, complianceAgent, legalResearchAgent],
  workflows: [],
})

// Workflow Definitions
export const documentAnalysisWorkflow = {
  name: "Document Analysis Pipeline",
  steps: [
    {
      id: "extract_text",
      name: "Extract Document Text",
      agent: contractAnalysisAgent,
    },
    {
      id: "analyze_clauses",
      name: "Analyze Contract Clauses",
      agent: contractAnalysisAgent,
    },
    {
      id: "compliance_check",
      name: "Compliance Assessment",
      agent: complianceAgent,
    },
    {
      id: "risk_assessment",
      name: "Risk Analysis",
      agent: contractAnalysisAgent,
    },
    {
      id: "generate_report",
      name: "Generate Analysis Report",
      agent: legalResearchAgent,
    },
  ],
}

export const complianceMonitoringWorkflow = {
  name: "Compliance Monitoring Pipeline",
  steps: [
    {
      id: "scan_regulations",
      name: "Scan for Regulatory Updates",
      agent: complianceAgent,
    },
    {
      id: "assess_impact",
      name: "Assess Impact on Organization",
      agent: complianceAgent,
    },
    {
      id: "generate_alerts",
      name: "Generate Compliance Alerts",
      agent: complianceAgent,
    },
    {
      id: "recommend_actions",
      name: "Recommend Remediation Actions",
      agent: legalResearchAgent,
    },
  ],
}
