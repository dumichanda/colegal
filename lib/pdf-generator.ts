import jsPDF from "jspdf"

export interface DocumentData {
  id: string
  title: string
  type: string
  content?: string
  organization?: string
  createdDate?: string
  riskLevel?: string
  metadata?: Record<string, any>
}

export class PDFGenerator {
  private doc: jsPDF

  constructor() {
    this.doc = new jsPDF()
  }

  private addHeader(title: string, organization = "Legal AI Assistant") {
    this.doc.setFontSize(20)
    this.doc.setFont("helvetica", "bold")
    this.doc.text(title, 20, 30)

    this.doc.setFontSize(12)
    this.doc.setFont("helvetica", "normal")
    this.doc.text(organization, 20, 40)

    this.doc.setLineWidth(0.5)
    this.doc.line(20, 45, 190, 45)
  }

  private addFooter(pageNumber = 1) {
    const pageHeight = this.doc.internal.pageSize.height
    this.doc.setFontSize(10)
    this.doc.setFont("helvetica", "normal")
    this.doc.text(`Page ${pageNumber}`, 20, pageHeight - 20)
    this.doc.text(`Generated on ${new Date().toLocaleDateString()}`, 150, pageHeight - 20)
  }

  private addText(text: string, x: number, y: number, maxWidth = 170): number {
    const lines = this.doc.splitTextToSize(text, maxWidth)
    this.doc.text(lines, x, y)
    return y + lines.length * 7
  }

  generateEmploymentContract(data: DocumentData): Buffer {
    this.doc = new jsPDF()
    this.addHeader("Employment Contract", data.organization)

    let yPosition = 60

    // Contract details
    this.doc.setFontSize(14)
    this.doc.setFont("helvetica", "bold")
    yPosition = this.addText("EMPLOYMENT AGREEMENT", 20, yPosition)
    yPosition += 10

    this.doc.setFontSize(12)
    this.doc.setFont("helvetica", "normal")

    const contractContent = `
This Employment Agreement ("Agreement") is entered into between ${data.organization || "[Company Name]"} ("Company") and [Employee Name] ("Employee").

1. POSITION AND DUTIES
The Employee shall serve as [Position Title] and shall perform duties as assigned by the Company.

2. COMPENSATION
The Employee shall receive a salary of R[Amount] per month, payable in accordance with Company payroll practices.

3. BENEFITS
The Employee shall be entitled to benefits including:
- Medical aid contribution
- Provident fund contribution
- Annual leave as per Basic Conditions of Employment Act
- Sick leave as per applicable legislation

4. CONFIDENTIALITY
The Employee agrees to maintain confidentiality of all proprietary information and trade secrets.

5. TERMINATION
Either party may terminate this agreement with [Notice Period] written notice.

6. GOVERNING LAW
This agreement shall be governed by the laws of South Africa and subject to the Labour Relations Act.

7. COMPLIANCE
This agreement complies with:
- Basic Conditions of Employment Act (Act 75 of 1997)
- Labour Relations Act (Act 66 of 1995)
- Employment Equity Act (Act 55 of 1998)
- Skills Development Act (Act 97 of 1998)

IN WITNESS WHEREOF, the parties have executed this Agreement.

Company: _________________________    Date: ___________

Employee: _________________________   Date: ___________
    `

    yPosition = this.addText(contractContent.trim(), 20, yPosition)
    this.addFooter()

    return Buffer.from(this.doc.output("arraybuffer"))
  }

  generateNDA(data: DocumentData): Buffer {
    this.doc = new jsPDF()
    this.addHeader("Non-Disclosure Agreement", data.organization)

    let yPosition = 60

    this.doc.setFontSize(14)
    this.doc.setFont("helvetica", "bold")
    yPosition = this.addText("NON-DISCLOSURE AGREEMENT", 20, yPosition)
    yPosition += 10

    this.doc.setFontSize(12)
    this.doc.setFont("helvetica", "normal")

    const ndaContent = `
This Non-Disclosure Agreement ("Agreement") is entered into between ${data.organization || "[Disclosing Party]"} ("Disclosing Party") and [Receiving Party] ("Receiving Party").

1. DEFINITION OF CONFIDENTIAL INFORMATION
Confidential Information includes all technical, business, financial, and other information disclosed by the Disclosing Party.

2. OBLIGATIONS OF RECEIVING PARTY
The Receiving Party agrees to:
- Hold all Confidential Information in strict confidence
- Not disclose Confidential Information to third parties
- Use Confidential Information solely for evaluation purposes
- Return or destroy all Confidential Information upon request

3. EXCEPTIONS
This Agreement does not apply to information that:
- Is publicly available through no breach of this Agreement
- Was known to Receiving Party prior to disclosure
- Is independently developed without use of Confidential Information

4. TERM
This Agreement shall remain in effect for [Duration] years from the date of execution.

5. REMEDIES
Breach of this Agreement may result in irreparable harm, entitling the Disclosing Party to seek injunctive relief.

6. GOVERNING LAW
This Agreement shall be governed by South African law and comply with the Protection of Personal Information Act (POPIA).

7. DATA PROTECTION COMPLIANCE
This Agreement complies with:
- Protection of Personal Information Act (Act 4 of 2013)
- Electronic Communications and Transactions Act (Act 25 of 2002)

Disclosing Party: _________________________    Date: ___________

Receiving Party: _________________________     Date: ___________
    `

    yPosition = this.addText(ndaContent.trim(), 20, yPosition)
    this.addFooter()

    return Buffer.from(this.doc.output("arraybuffer"))
  }

  generateSoftwareLicense(data: DocumentData): Buffer {
    this.doc = new jsPDF()
    this.addHeader("Software License Agreement", data.organization)

    let yPosition = 60

    this.doc.setFontSize(14)
    this.doc.setFont("helvetica", "bold")
    yPosition = this.addText("SOFTWARE LICENSE AGREEMENT", 20, yPosition)
    yPosition += 10

    this.doc.setFontSize(12)
    this.doc.setFont("helvetica", "normal")

    const licenseContent = `
This Software License Agreement ("Agreement") governs the use of software provided by ${data.organization || "[Licensor]"} ("Licensor") to [Licensee] ("Licensee").

1. GRANT OF LICENSE
Licensor grants Licensee a non-exclusive, non-transferable license to use the Software.

2. PERMITTED USES
Licensee may:
- Install and use the Software on authorized devices
- Make backup copies for archival purposes
- Use the Software in accordance with documentation

3. RESTRICTIONS
Licensee may not:
- Reverse engineer, decompile, or disassemble the Software
- Distribute, rent, lease, or sublicense the Software
- Remove or modify copyright notices

4. INTELLECTUAL PROPERTY
All rights, title, and interest in the Software remain with Licensor.

5. WARRANTY DISCLAIMER
THE SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.

6. LIMITATION OF LIABILITY
Licensor's liability shall not exceed the amount paid for the Software license.

7. TERMINATION
This license terminates automatically upon breach of terms.

8. COMPLIANCE
This Agreement complies with:
- Copyright Act (Act 98 of 1978)
- Electronic Communications and Transactions Act (Act 25 of 2002)
- Consumer Protection Act (Act 68 of 2008)

Licensor: _________________________    Date: ___________

Licensee: _________________________    Date: ___________
    `

    yPosition = this.addText(licenseContent.trim(), 20, yPosition)
    this.addFooter()

    return Buffer.from(this.doc.output("arraybuffer"))
  }

  generatePartnershipAgreement(data: DocumentData): Buffer {
    this.doc = new jsPDF()
    this.addHeader("Partnership Agreement", data.organization)

    let yPosition = 60

    this.doc.setFontSize(14)
    this.doc.setFont("helvetica", "bold")
    yPosition = this.addText("PARTNERSHIP AGREEMENT", 20, yPosition)
    yPosition += 10

    this.doc.setFontSize(12)
    this.doc.setFont("helvetica", "normal")

    const partnershipContent = `
This Partnership Agreement ("Agreement") is entered into between the parties to establish a business partnership.

1. PARTNERSHIP FORMATION
The parties agree to form a partnership under South African law for the purpose of [Business Purpose].

2. CAPITAL CONTRIBUTIONS
Each partner shall contribute capital as follows:
- Partner A: R[Amount] ([Percentage]%)
- Partner B: R[Amount] ([Percentage]%)

3. PROFIT AND LOSS SHARING
Profits and losses shall be shared in proportion to capital contributions.

4. MANAGEMENT AND DECISION MAKING
- Day-to-day operations: [Management Structure]
- Major decisions require unanimous consent
- Each partner has equal voting rights

5. DUTIES AND RESPONSIBILITIES
Partners shall:
- Devote time and effort to partnership business
- Act in good faith and in the partnership's best interests
- Maintain confidentiality of partnership information

6. WITHDRAWAL AND DISSOLUTION
- Partners may withdraw with [Notice Period] written notice
- Partnership dissolves upon mutual agreement or legal requirements

7. DISPUTE RESOLUTION
Disputes shall be resolved through mediation, then arbitration if necessary.

8. COMPLIANCE
This Agreement complies with:
- Companies Act (Act 71 of 2008)
- Partnership Act (Act 34 of 1961)
- B-BBEE Act (Act 53 of 2003)
- Competition Act (Act 89 of 1998)

Partner A: _________________________    Date: ___________

Partner B: _________________________    Date: ___________
    `

    yPosition = this.addText(partnershipContent.trim(), 20, yPosition)
    this.addFooter()

    return Buffer.from(this.doc.output("arraybuffer"))
  }

  generateServiceLevelAgreement(data: DocumentData): Buffer {
    this.doc = new jsPDF()
    this.addHeader("Service Level Agreement", data.organization)

    let yPosition = 60

    this.doc.setFontSize(14)
    this.doc.setFont("helvetica", "bold")
    yPosition = this.addText("SERVICE LEVEL AGREEMENT", 20, yPosition)
    yPosition += 10

    this.doc.setFontSize(12)
    this.doc.setFont("helvetica", "normal")

    const slaContent = `
This Service Level Agreement ("SLA") defines the level of service expected between ${data.organization || "[Service Provider]"} ("Provider") and [Client] ("Client").

1. SERVICE DESCRIPTION
Provider shall deliver [Service Description] in accordance with the terms herein.

2. SERVICE LEVELS
- Availability: 99.9% uptime
- Response Time: Within 4 hours for critical issues
- Resolution Time: Within 24 hours for critical issues
- Performance: [Performance Metrics]

3. MONITORING AND REPORTING
- Continuous monitoring of service levels
- Monthly reports provided to Client
- Quarterly service level reviews

4. SERVICE CREDITS
If service levels are not met:
- 95-99.8% availability: 10% service credit
- 90-94.9% availability: 25% service credit
- Below 90% availability: 50% service credit

5. RESPONSIBILITIES
Provider Responsibilities:
- Maintain service infrastructure
- Provide technical support
- Ensure data security and backup

Client Responsibilities:
- Provide accurate requirements
- Timely payment of fees
- Reasonable use of services

6. ESCALATION PROCEDURES
Level 1: Technical Support (Response: 1 hour)
Level 2: Senior Technical (Response: 2 hours)
Level 3: Management (Response: 4 hours)

7. COMPLIANCE
This SLA complies with:
- Consumer Protection Act (Act 68 of 2008)
- Electronic Communications and Transactions Act (Act 25 of 2002)
- Protection of Personal Information Act (Act 4 of 2013)

Provider: _________________________    Date: ___________

Client: _________________________      Date: ___________
    `

    yPosition = this.addText(slaContent.trim(), 20, yPosition)
    this.addFooter()

    return Buffer.from(this.doc.output("arraybuffer"))
  }

  generateDocument(type: string, data: DocumentData): Buffer {
    switch (type.toLowerCase()) {
      case "employment":
      case "contract":
        return this.generateEmploymentContract(data)
      case "nda":
      case "confidentiality":
        return this.generateNDA(data)
      case "software":
      case "licensing":
        return this.generateSoftwareLicense(data)
      case "partnership":
        return this.generatePartnershipAgreement(data)
      case "service":
      case "sla":
        return this.generateServiceLevelAgreement(data)
      default:
        return this.generateGenericDocument(data)
    }
  }

  private generateGenericDocument(data: DocumentData): Buffer {
    this.doc = new jsPDF()
    this.addHeader(data.title, data.organization)

    let yPosition = 60

    this.doc.setFontSize(12)
    this.doc.setFont("helvetica", "normal")

    const content =
      data.content ||
      `
This is a legal document generated by the Legal AI Assistant.

Document Type: ${data.type}
Risk Level: ${data.riskLevel || "Medium"}
Created: ${data.createdDate || new Date().toLocaleDateString()}

This document serves as a template and should be reviewed by qualified legal counsel before use.

For more information, please consult with your legal advisor.
    `

    yPosition = this.addText(content.trim(), 20, yPosition)
    this.addFooter()

    return Buffer.from(this.doc.output("arraybuffer"))
  }
}

export const pdfGenerator = new PDFGenerator()
