// HALEIO Revenue Performance Report v5
// Typst 0.14 · Inter + JetBrains Mono · Dark theme

// ── DATA ──
#let company = "Acme Industries"
#let name = "Sarah"
#let industry = "Manufacturing"
#let revenue = "$5M – $10M"
#let yearsOnCrm = "5–10 years"
#let adminHours = "10–20 hrs/week"
#let headacheLabels = ("Data accuracy — records are out of date", "Admin overhead — too much manual work", "Lost follow-ups — deals fall through the cracks")

// ── SETUP ──
#set page(paper: "a4", margin: (top: 2.2cm, bottom: 2cm, left: 2cm, right: 2cm), fill: rgb("#040404"))
#set text(font: "Inter", size: 10pt, fill: luma(220))

// ── COLOURS ──
#let neon = rgb("#D4FF00")
#let neon-dim = rgb("#889900")
#let red = rgb("#FF4444")
#let amber = rgb("#FFAA00")
#let green = rgb("#00CC66")
#let card-bg = rgb("#080808")
#let bg-dark = rgb("#040404")
#let neo = rgb("#0A0F00")
#let t1 = luma(240)
#let t2 = luma(155)
#let t3 = luma(85)

// ── HELPERS ──
#let edge = rect(width: 100%, height: 2.5pt, fill: neon)
#let spacer = { v(0.4cm) }
#let small-spacer = { v(0.25cm) }

#let card(body) = block(width: 100%, fill: card-bg, stroke: 0.3pt + luma(15), radius: 3pt, inset: 14pt, body)
#let neon-card(body) = block(width: 100%, fill: neo, stroke: 0.4pt + neon-dim, radius: 3pt, inset: 14pt, body)

#let metric-card(label, value) = {
  card[
    #set align(center)
    #text(font: "JetBrains Mono", size: 5.5pt, fill: t3, weight: "bold", label)
    #v(0.15cm)
    #text(font: "Inter", size: 16pt, weight: "black", fill: red, value)
  ]
}

#let h1(body) = { text(font: "Inter", size: 18pt, weight: "black", fill: t1, body) }
#let h2(body) = { text(font: "Inter", size: 12pt, weight: "black", fill: t1, body) }
#let bdy(fill: t2, size: 7.5pt, body) = { text(font: "Inter", size: size, fill: fill, body) }
#let mono(size: 6pt, fill: t3, body) = { text(font: "JetBrains Mono", size: size, fill: fill, weight: "bold", body) }

// ── INDUSTRY DATA ──
#let ind = if industry.contains("Manufactur") {
  (n: "MANUFACTURING", sample: "850+ manufacturers", gap: "2.5×", decay: "28–34%", admin: "31%", opp: "15–22%",
   ai: "Order re-activation, warranty automation, gap detection.",
   detail: "Manufacturing AI adoption lags SaaS by 2.5× (CSIRO 2025).", admn: "of rep time lost to admin (HubSpot 2026).")
} else if industry.contains("Wholesale") or industry.contains("Distribution") {
  (n: "WHOLESALE & DISTRIBUTION", sample: "600+ distributors", gap: "3.1×", decay: "30–38%", admin: "35%", opp: "18–25%",
   ai: "Re-order triggers, customer segmentation, quote follow-ups.",
   detail: "Distribution AI gap — fastest data decay of any sector (Deloitte 2025).", admn: "of team time on manual processing (HubSpot 2026).")
} else if industry.contains("Professional Service") {
  (n: "PROFESSIONAL SERVICES", sample: "400+ firms", gap: "2.0×", decay: "24–30%", admin: "28%", opp: "12–18%",
   ai: "Client lifecycle automation, referral tracking, engagement scoring.",
   detail: "Services AI adoption growing fast but still behind SaaS.", admn: "of billable time lost to admin (HubSpot 2026).")
} else if industry.contains("SaaS") or industry.contains("Technology") {
  (n: "TECHNOLOGY & SAAS", sample: "1,200+ firms", gap: "1.0×", decay: "22–28%", admin: "24%", opp: "8–14%",
   ai: "Deal scoring, churn prediction, automated enrichment, pipeline alerts.",
   detail: "SaaS leads AI adoption — benchmark, not laggard.", admn: "of selling time on CRM admin (HubSpot 2026).")
} else if industry.contains("Construction") or industry.contains("Trades") {
  (n: "CONSTRUCTION & TRADES", sample: "500+ firms", gap: "3.5×", decay: "32–40%", admin: "38%", opp: "20–30%",
   ai: "Quote-to-project automation, re-quote triggers, sub tracking.",
   detail: "Largest AI adoption gap of any B2B sector (CSIRO 2025).", admn: "of office time on paperwork (HubSpot 2026).")
} else if industry.contains("Health") {
  (n: "HEALTHCARE", sample: "300+ providers", gap: "2.8×", decay: "30–36%", admin: "30%", opp: "10–16%",
   ai: "Referral automation, patient re-engagement, compliance trails.",
   detail: "Healthcare AI gap driven by compliance complexity (Deloitte 2025).", admn: "of clinical admin on non-patient CRM work.")
} else {
  (n: "BUSINESS SERVICES", sample: "1,000+ firms", gap: "2.2×", decay: "26–32%", admin: "29%", opp: "10–20%",
   ai: "Workflow automation, data enrichment, follow-up sequencing.",
   detail: "General B2B AI gap vs SaaS (CSIRO 2025).", admn: "of team time lost to CRM admin.")
}

// ── SCORE ──
#let yrScore = if yearsOnCrm.contains("10") { 18 } else if yearsOnCrm.contains("5") { 14 } else if yearsOnCrm.contains("3") { 10 } else if yearsOnCrm.contains("1") { 6 } else { 10 }
#let adScore = if adminHours.contains("40") { 4 } else if adminHours.contains("20") { 10 } else if adminHours.contains("10") { 16 } else if adminHours.contains("5") or adminHours.contains("Under") { 22 } else { 12 }
#let hdScore = calc.max(5, 25 - headacheLabels.len() * 6)
#let score = calc.min(yrScore + adScore + hdScore + 30, 100)
#let sev = if score <= 40 { "CRITICAL" } else if score <= 55 { "SIGNIFICANT" } else if score <= 70 { "MODERATE" } else { "MANAGED" }
#let sevCol = if score <= 40 { red } else if score <= 55 { amber } else if score <= 70 { neon } else { green }

// ── PRE-COMPUTE MODULE COUNTS ──
#let hasData = headacheLabels.any(l => l.contains("Data accuracy"))
#let hasAdmin = headacheLabels.any(l => l.contains("Admin"))
#let hasFollowup = headacheLabels.any(l => l.contains("follow-up") or l.contains("cracks"))
#let hasProcess = headacheLabels.any(l => l.contains("Inconsistent") or l.contains("differently"))
#let hasVis = headacheLabels.any(l => l.contains("visibility") or l.contains("reports"))

#let n1 = 1
#let n2a = if hasData { 2 } else { 1 }
#let n2b = if hasData and hasAdmin { 3 } else { if hasData or hasAdmin { 2 } else { 1 } }
#let n3 = if hasData and hasAdmin and hasFollowup { 3 } else { if (hasData and hasFollowup) or (hasAdmin and hasFollowup) { 2 } else { 1 } }
#let n4 = if hasData and hasAdmin and hasFollowup and hasProcess { 4 } else { 3 }
#let n5 = if hasData and hasAdmin and hasFollowup and hasProcess and hasVis { 5 } else { 4 }

// ═══════════════════════════ PAGE 1 ═══════════════════════════

#edge
#v(0.4cm)

#h1[Revenue Performance Report]
#v(0.1cm)
#bdy(size: 7pt, fill: t3)[Prepared for #company · #name]
#spacer

// ── SCORE CARD ──
#card[
  #grid(columns: (1fr, 2fr), gutter: 0.5cm,
    align(center + horizon, [
      #mono(size: 5pt)[PERFORMANCE SCORE]
      #v(0.3cm)
      #block(width: 70pt, height: 70pt, fill: none, stroke: 2.5pt + luma(18),
        align(center + horizon,
          text(font: "Inter", size: 24pt, weight: "black", fill: sevCol, str(score))))
      #v(0.15cm)
      #text(font: "JetBrains Mono", size: 6pt, fill: sevCol, weight: "black", sev)
      #v(0.25cm)
      #grid(columns: 3, gutter: 0.15cm,
        text(font: "JetBrains Mono", size: 4.5pt, fill: t3, "DATA"),
        text(font: "JetBrains Mono", size: 4.5pt, fill: t3, "ADMIN"),
        text(font: "JetBrains Mono", size: 4.5pt, fill: t3, "PROCESS"),
      )
      #grid(columns: 3, gutter: 0.15cm,
        text(font: "Inter", size: 7pt, weight: "black", fill: green, str(yrScore)),
        text(font: "Inter", size: 7pt, weight: "black", fill: if adScore >= 15 { green } else { amber }, str(adScore)),
        text(font: "Inter", size: 7pt, weight: "black", fill: if hdScore >= 15 { green } else { amber }, str(hdScore)),
      )
    ]),
    [
      #h2[What This Means]
      #v(0.25cm)
      #bdy[
        #company operates in #ind.n. This sector
        has a #text(fill: neon, ind.gap) AI adoption gap.
        #ind.detail With #yearsOnCrm in CRM and
        #adminHours on admin, your data is underutilised.
        #v(0.25cm)
        #text(fill: neon)[#ind.ai]
      ]
    ],
  )
]

#spacer

// ── KEY FINDING ──
#neon-card[
  #h2[Your #text(fill: neon)[Highest-Impact Opportunity]]
  #v(0.2cm)
  #bdy[Based on your top concern — _#headacheLabels.at(0)_ — your CRM is data-rich
    but process-poor. Automated AI workflows typically recover
    #text(fill: neon)[40–60% of admin time] and surface
    #text(fill: neon)[15–25% more revenue] from existing records.]
  #small-spacer
  #grid(columns: 2, gutter: 0.4cm,
    metric-card("CRM DATA DECAY", ind.decay),
    metric-card("TEAM ADMIN LOSS", ind.admin),
  )
  #v(0.2cm)
  #text(font: "Inter", size: 5.5pt, fill: t3, style: "italic")[
    Sources: CSIRO 2025 · HubSpot 2026 · Deloitte 2025 · Gartner 2025
  ]
]

#spacer

// ── AT A GLANCE ──
#mono(size: 6pt)[AT A GLANCE]
#small-spacer
#grid(columns: 3, gutter: 0.3cm,
  card[#mono(size: 5pt)[INDUSTRY] #v(0.1cm) #text(font: "Inter", size: 10pt, weight: "black", fill: neon, industry)],
  card[#mono(size: 5pt)[DATA MATURITY] #v(0.1cm) #text(font: "Inter", size: 10pt, weight: "black", fill: neon, yearsOnCrm)],
  card[#mono(size: 5pt)[ADMIN LOAD] #v(0.1cm) #text(font: "Inter", size: 10pt, weight: "black", fill: neon, adminHours)],
)

#pagebreak()
// ═══════════════════════════ PAGE 2 ═══════════════════════════

#h1[Your #text(fill: neon)[AI] Opportunity Map]
#v(0.1cm)
#bdy(size: 7pt, fill: t3)[How AI transforms each of your reported challenges — for #industry]

#v(0.5cm)

// ── AI MODULE ──
#let ai-module(n, title, problem, solution, benefit, example) = {
  card[
    #grid(columns: (auto, 1fr), gutter: 0.4cm,
      [
        #block(width: 26pt, height: 26pt, fill: neon, align(center + horizon,
          text(font: "Inter", size: 10pt, weight: "black", fill: bg-dark, str(n))
        ))
        #v(0.15cm)
        #mono(size: 5pt, fill: neon)[FIX]
      ],
      [
        #text(font: "Inter", size: 9pt, weight: "black", fill: t1)[#title]
        #v(0.15cm)
        #bdy(size: 7pt, fill: t3)[PROBLEM:] #bdy[#problem]
        #v(0.1cm)
        #bdy(size: 7pt, fill: neon)[AI SOLUTION:] #bdy(fill: t1)[#solution]
        #v(0.1cm)
        #text(font: "Inter", size: 6.5pt, fill: green)[✓ #benefit]
        #v(0.05cm)
        #text(font: "Inter", size: 6pt, fill: t3, style: "italic")[Example: #example]
      ]
    )
  ]
}

// Data accuracy
#if hasData {
  ai-module(n1, "CRM Data That Actually Works",
    ind.n + " CRMs decay at " + ind.decay + " per year. " + yearsOnCrm + " of accumulated records — expired contacts, duplicates, stale data.",
    "AI enrichment scans every record. Fills gaps from public data. Deduplicates. Flags decay. Runs continuously on your infrastructure — private, sovereign, yours.",
    "80% less manual data entry. Accuracy typically 65% → 90%+ within 30 days.",
    "A welding distributor surfaced +$1M in upsells from their existing Sage 50 data — no new records needed."
  )
  small-spacer
}

// Admin overhead
#if hasAdmin {
  ai-module(n2a, "Admin Workflows That Run Themselves",
    adminHours + " on CRM admin. " + ind.admn,
    "AI workflow agents automate data entry, report generation, call logging, and field updates. Your team works — the AI keeps the CRM current.",
    "Frees 12+ hours/week for revenue work. One manufacturer cut claims processing 5× — from 21 days to 4.",
    "Warranty manufacturer: 21-day manual triage → 4-day automated workflow. No new hires needed."
  )
  small-spacer
}

// Follow-up
#if hasFollowup {
  ai-module(n2b, "No Deal Goes Cold Again",
    "CSO Insights (2025): automated alerts recover 2–3 stalled deals per rep per month. In " + ind.n + ", the most common leak is nobody being reminded.",
    "AI monitors your pipeline real-time. Flags stalled deals. Drafts personalised follow-ups. Alerts the right person on Slack or Teams.",
    "Recovers \$40k–\$120k per rep per year. One distributor recovered \$180k in 60 days.",
    "Customer Success team: zero post-sale process → 90-day automated triggers pushed revenue 97% → 115% of base."
  )
  small-spacer
}

// Inconsistent
#if hasProcess {
  ai-module(n3, "One Process. Everyone Follows It.",
    "Inconsistent CRM usage is the #1 cause of bad data in " + industry + ". When every rep works differently, management flies blind.",
    "AI-guided workflows enforce consistent entry, stage progression, and follow-up cadence. Reps get nudges — not mandates.",
    "CRM adoption improves 40–60% with AI guidance vs top-down enforcement.",
    "Same methodology behind all three HALEIO client outcomes above."
  )
  small-spacer
}

// Visibility
#if hasVis {
  ai-module(n4, "See Everything. In Real Time.",
    "Managers in " + industry + " rely on weekly spreadsheets. Reports are stale by the time they reach leadership.",
    "AI dashboards update continuously from live CRM. Pipeline health, rep activity, deal velocity — real time, zero manual work.",
    "Pipeline review cut from 4 hours to 15 minutes. Decisions made on live data, not last week's exports.",
    "Reports that used to take a full day now generate automatically every morning."
  )
  small-spacer
}

#v(0.3cm)

// ── BEFORE vs AFTER ──
#mono(size: 6pt)[BEFORE vs AFTER AI — #ind.n]
#small-spacer

#let comp-row(metric, before, after) = {
  grid(columns: (1.5fr, 1.7fr, 1.7fr), gutter: 0.2cm,
    text(font: "Inter", size: 6.5pt, weight: "bold", fill: t2, metric),
    text(font: "Inter", size: 6.5pt, fill: red, before),
    text(font: "Inter", size: 6.5pt, fill: green, "→ " + after),
  )
}

#card[
  #comp-row("Data Accuracy", ind.decay + " annual decay", "85-95% stable")
  #v(0.15cm)
  #comp-row("Admin Time", adminHours + " manual CRM", "60-80% reduction")
  #v(0.15cm)
  #comp-row("Pipeline Visibility", "Weekly reports, stale", "Real-time, automated")
  #v(0.15cm)
  #comp-row("Follow-up Rate", "Missed opportunities", "0-2hr auto-response")
  #v(0.15cm)
  #comp-row("Team Consistency", "Every rep, own system", "AI-guided standard")
]


#pagebreak()

// ═══════════════════════════ PAGE 3 ═══════════════════════════

#h1[Your #text(fill: neon)[90-Day] AI Roadmap]
#v(0.1cm)
#bdy(size: 7pt, fill: t3)[Fixed scope. Fixed timeline. Fixed fee. Four phases. You own everything.]

#v(0.4cm)

// ── PHASE CARDS ──
#let phase(pn, days, title, desc) = block(
  width: 100%, fill: card-bg, stroke: 0.3pt + luma(15), radius: 3pt, inset: 12pt,
  [
    #grid(columns: (auto, 1fr), gutter: 0.35cm,
      align(center + horizon, [
        #block(width: 26pt, height: 26pt, fill: neon,
          align(center + horizon, text(font: "Inter", size: 10pt, weight: "black", fill: bg-dark, str(pn)))
        )
        #v(0.12cm)
        #mono(size: 4.5pt, fill: neon, days)
      ]),
      [
        #text(font: "Inter", size: 9pt, weight: "black", fill: t1)[#title]
        #v(0.1cm)
        #bdy(size: 6.5pt)[#desc]
      ]
    )
  ]
)

#grid(columns: 2, gutter: 0.3cm,
  phase(1, "WK 1-4", "Diagnostic & Foundation",
    "Full CRM audit. Every record checked. Leaks quantified against real data. AI infrastructure deployed — private, sovereign, Australian-hosted."
  ),
  phase(2, "WK 5–8", "Automation Build",
    "Custom AI workflows deployed for your " + str(headacheLabels.len()) + " priority areas. Lead triage, enrichment, deal alerts, Slack/Teams. Live on your data."
  ),
)

#v(0.3cm)

#grid(columns: 2, gutter: 0.3cm,
  phase(3, "WK 9-10", "Stress Test & Validate",
    "Your team sees the engine working on actual CRM data. Edge cases tested. Documentation written. No surprises on handover day."
  ),
  phase(4, "WK 11–13", "Training & Handover",
    "Your team trained. Full documentation delivered. Quarterly reviews optional. You own the workflows, the logic, the IP — permanently."
  ),
)

#v(0.5cm)

// ── CTA ──
#neon-card[
  #align(center, [
    #h2[Get the Real Numbers from Your CRM]
    #v(0.2cm)
    #bdy(size: 7.5pt)[This report is based on your self-assessment and industry benchmarks.]
    #bdy(size: 7.5pt)[A paid diagnostic examines your actual CRM data to find the exact dollar value of every opportunity.]
    #v(0.35cm)
    #text(font: "Inter", size: 14pt, weight: "black", fill: neon)[Book a Diagnostic · \$4,950]
    #v(0.15cm)
    #bdy(size: 7pt, fill: t3)[Founding rate (reg. \$15,000) · Limited availability · Delivered in 5 business days]
    #v(0.15cm)
    #mono(size: 5pt)[haleio.com · hello\@haleio.com · Adelaide, Australia]
  ])
]

#v(0.4cm)

// ── SOURCES ──
#set text(font: "JetBrains Mono", size: 4.5pt, fill: luma(35))
#align(center, [
  Sources: CSIRO AI Adoption in Australian Industry 2025 · HubSpot Sales Benchmarks 2026 ·
  Deloitte AI in B2B Distribution & Manufacturing 2025 · CSO Insights 2025 · Gartner 2025.
  Industry benchmarks from public research. Results vary. Not a guarantee of specific outcomes.
  Prepared in Adelaide, Australia.
])
