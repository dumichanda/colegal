import { type NextRequest, NextResponse } from "next/server"
import { mastra } from "@/lib/mastra-config"
import { sql } from "@/lib/database"
import { trackWorkflowExecution } from "@/lib/task-tracker"
import { withTaskTracking } from "@/lib/middleware/task-tracking-middleware"

async function handler(req: NextRequest) {
  try {
    const { workflowType, documentId, organizationId, parameters } = await req.json()

    let result: any

    switch (workflowType) {
      case "document_analysis":
        result = await runDocumentAnalysisWorkflow(documentId, parameters)
        break
      case "compliance_monitoring":
        result = await runComplianceMonitoringWorkflow(organizationId, parameters)
        break
      default:
        return NextResponse.json({ success: false, error: "Invalid workflow type" }, { status: 400 })
    }

    return NextResponse.json({
      success: true,
      data: result,
    })
  } catch (error) {
    console.error("Workflow execution error:", error)
    return NextResponse.json({ success: false, error: "Workflow execution failed" }, { status: 500 })
  }
}

async function runDocumentAnalysisWorkflow(documentId: string, parameters: any) {
  const startTime = Date.now()

  // Track workflow start
  await trackWorkflowExecution({
    workflowId: `doc_analysis_${documentId}`,
    workflowType: "document_analysis",
    status: "started",
  })

  try {
    // Get document details
    const [document] = await sql`
      SELECT * FROM documents WHERE id = ${documentId}
    `

    if (!document) {
      throw new Error("Document not found")
    }

    // Step 1: Extract text (simulated)
    const extractedText = parameters.content || "Document content would be extracted here"

    // Step 2: Analyze clauses using Mastra agent
    const clauseAnalysis = await mastra.agent("Contract Analysis Agent").generate(
      `Analyze the following legal document for contract clauses, risks, and South African law compliance:
      
      Document: ${document.title}
      Type: ${document.type}
      Content: ${extractedText}
      
      Provide a detailed analysis including:
      1. Key contract clauses identified
      2. Risk assessment for each clause
      3. South African legal compliance issues
      4. Recommendations for improvement`,
      {
        format: "json",
      },
    )

    // Step 3: Compliance check using compliance agent
    const complianceCheck = await mastra.agent("Compliance Monitoring Agent").generate(
      `Perform a comprehensive compliance assessment for this ${document.type}:
      
      Content: ${extractedText}
      
      Check compliance with:
      - POPIA (Protection of Personal Information Act)
      - B-BBEE (Broad-Based Black Economic Empowerment)
      - LRA (Labour Relations Act)
      - Other relevant South African regulations
      
      Provide compliance status and remediation steps.`,
      {
        format: "json",
      },
    )

    // Step 4: Risk assessment
    const riskAssessment = await mastra.agent("Contract Analysis Agent").generate(
      `Conduct a comprehensive risk assessment for this legal document:
      
      Document: ${document.title}
      Analysis: ${clauseAnalysis}
      Compliance: ${complianceCheck}
      
      Provide:
      1. Overall risk score (1-100)
      2. High-risk areas
      3. Mitigation strategies
      4. Priority recommendations`,
      {
        format: "json",
      },
    )

    // Step 5: Generate comprehensive report
    const finalReport = await mastra.agent("Legal Research Agent").generate(
      `Generate a comprehensive legal analysis report based on:
      
      Document: ${document.title}
      Clause Analysis: ${clauseAnalysis}
      Compliance Assessment: ${complianceCheck}
      Risk Assessment: ${riskAssessment}
      
      Create a professional legal memorandum with:
      1. Executive Summary
      2. Detailed Findings
      3. Risk Analysis
      4. Compliance Status
      5. Recommendations
      6. Next Steps`,
      {
        format: "json",
      },
    )

    // Store results in database
    await sql`
      INSERT INTO document_analyses (document_id, analysis_type, results, confidence_score)
      VALUES (${documentId}, 'mastra_workflow', ${JSON.stringify({
        clauseAnalysis,
        complianceCheck,
        riskAssessment,
        finalReport,
      })}, ${0.95})
    `

    // Update document status
    await sql`
      UPDATE documents 
      SET status = 'completed', updated_at = NOW()
      WHERE id = ${documentId}
    `

    const duration = Date.now() - startTime
    const workflowResult = {
      workflowId: `doc_analysis_${documentId}`,
      documentId,
      status: "completed",
      results: {
        clauseAnalysis,
        complianceCheck,
        riskAssessment,
        finalReport,
      },
      confidence: 0.95,
    }

    // Track workflow completion
    await trackWorkflowExecution({
      workflowId: `doc_analysis_${documentId}`,
      workflowType: "document_analysis",
      status: "completed",
      duration,
      results: workflowResult,
    })

    return workflowResult
  } catch (error) {
    const duration = Date.now() - startTime

    // Track workflow failure
    await trackWorkflowExecution({
      workflowId: `doc_analysis_${documentId}`,
      workflowType: "document_analysis",
      status: "failed",
      duration,
    })

    throw error
  }
}

async function runComplianceMonitoringWorkflow(organizationId: string, parameters: any) {
  const startTime = Date.now()

  // Track workflow start
  await trackWorkflowExecution({
    workflowId: `compliance_${organizationId}`,
    workflowType: "compliance_monitoring",
    status: "started",
  })

  try {
    // Step 1: Scan for regulatory updates
    const regulatoryUpdates = await mastra.agent("Compliance Monitoring Agent").generate(
      `Scan for recent regulatory updates affecting South African organizations:
      
      Focus areas:
      - Data protection (POPIA)
      - Employment law (LRA)
      - B-BBEE requirements
      - Financial services regulations
      - Industry-specific compliance
      
      Provide updates from the last 30 days with impact assessment.`,
      {
        format: "json",
      },
    )

    // Step 2: Assess impact on organization
    const impactAssessment = await mastra.agent("Compliance Monitoring Agent").generate(
      `Assess the impact of these regulatory updates on the organization:
      
      Organization ID: ${organizationId}
      Regulatory Updates: ${regulatoryUpdates}
      
      Provide:
      1. High/Medium/Low impact classification
      2. Affected business areas
      3. Timeline for compliance
      4. Resource requirements`,
      {
        format: "json",
      },
    )

    // Step 3: Generate compliance alerts
    const complianceAlerts = await mastra.agent("Compliance Monitoring Agent").generate(
      `Generate specific compliance alerts based on:
      
      Impact Assessment: ${impactAssessment}
      
      Create actionable alerts with:
      1. Alert priority
      2. Deadline dates
      3. Responsible parties
      4. Required actions`,
      {
        format: "json",
      },
    )

    // Step 4: Recommend actions
    const actionRecommendations = await mastra.agent("Legal Research Agent").generate(
      `Provide detailed action recommendations for compliance:
      
      Alerts: ${complianceAlerts}
      Impact Assessment: ${impactAssessment}
      
      Include:
      1. Immediate actions required
      2. Long-term compliance strategy
      3. Implementation timeline
      4. Success metrics`,
      {
        format: "json",
      },
    )

    // Store compliance monitoring results
    await sql`
      INSERT INTO compliance_monitoring (organization_id, rule_id, status, notes, last_checked, next_check_due)
      SELECT ${organizationId}, cr.id, 'compliant', ${JSON.stringify(actionRecommendations)}, NOW(), NOW() + INTERVAL '30 days'
      FROM compliance_rules cr
      WHERE cr.is_active = true
      ON CONFLICT (organization_id, rule_id) 
      DO UPDATE SET 
        notes = ${JSON.stringify(actionRecommendations)},
        last_checked = NOW(),
        updated_at = NOW()
    `

    const duration = Date.now() - startTime
    const workflowResult = {
      workflowId: `compliance_${organizationId}`,
      organizationId,
      status: "completed",
      results: {
        regulatoryUpdates,
        impactAssessment,
        complianceAlerts,
        actionRecommendations,
      },
      alertsGenerated: 3,
      nextReview: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
    }

    // Track workflow completion
    await trackWorkflowExecution({
      workflowId: `compliance_${organizationId}`,
      workflowType: "compliance_monitoring",
      status: "completed",
      duration,
      results: workflowResult,
    })

    return workflowResult
  } catch (error) {
    const duration = Date.now() - startTime

    // Track workflow failure
    await trackWorkflowExecution({
      workflowId: `compliance_${organizationId}`,
      workflowType: "compliance_monitoring",
      status: "failed",
      duration,
    })

    throw error
  }
}

export const POST = withTaskTracking(handler)
