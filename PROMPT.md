You are building a PDF report template for a company called HALEIO (an Adelaide-based AI consulting firm). The PDF is generated using Typst (0.14) — a LaTeX-like typesetting engine. The template receives form submission data and produces a personalised, visual, AI-framed Revenue Performance Report.

## TECH STACK
- Typst 0.14 with Inter + JetBrains Mono fonts (static, not variable)
- Dark theme: background #040404, neon accent #D4FF00, red #FF4444 for warnings
- Page: A4, 2.5cm top/bottom margin, 2.2cm left/right
- Header: company name, "CONFIDENTIAL"
- Footer: page number, HALEIO · REVENUE PERFORMANCE REPORT · hello@haleio.com

## DATA INJECTED (at top of template — these are the only variables you replace)
#let company = "Acme Industries"       // string
#let name = "Sarah"                     // string
#let industry = "Manufacturing"         // one of 8 industry strings below
#let revenue = "$5M – $10M"            // free-text string
#let yearsOnCrm = "5–10 years"          // one of 5 range strings below
#let adminHours = "10–20 hrs/week"      // one of 5 range strings below
#let headacheLabels = ("Data accuracy — records are out of date", "Admin overhead — too much manual work", "Lost follow-ups — deals fall through the cracks")  // array of 0-5 strings

## INDUSTRY OPTIONS (must branch content for each)
Manufacturing | Wholesale / Distribution | Professional Services | Technology / SaaS | Construction / Trades | Healthcare | Retail / E-Commerce | Other

## CRM AGE OPTIONS
Less than 1 year | 1–3 years | 3–5 years | 5–10 years | 10+ years

## ADMIN HOURS OPTIONS
Under 5 hrs/week | 5–10 hrs/week | 10–20 hrs/week | 20–40 hrs/week | 40+ hrs/week

## HEADACHE LABEL OPTIONS (checkbox selections)
- "Data accuracy — records are out of date"
- "Admin overhead — too much manual work"
- "Lost follow-ups — deals fall through the cracks"
- "Inconsistent process — everyone works differently"
- "No visibility — can't get reliable reports"

## TYPST GOTCHAS
- Dollar signs in strings need escaping: write "\$5,000" not "$5,000"
- Email @ signs need escaping in text: "hello\@haleio.com"
- Named arguments with #text() for reliable output
- Colors: rgb("#D4FF00") for neon, rgb("#FF4444") for red, rgb("#FFAA00") for amber
- Use content blocks [ ] not strings for multi-line or nested content
- Use luma(N) for greys (0-255 range, e.g. luma(240) for near-white)
- No «, —, or other Unicode chars that might break compilation

## REQUIRED PAGES & CONTENT

### PAGE 1 — EXECUTIVE SUMMARY
1. Neon yellow accent bar at top (full width, 3pt height)
2. Title: "Revenue Performance Report" in Inter Black, large
3. Subtitle: "Prepared for {company} · {name}"
4. **Performance Score Card** (prominent, 2-column layout):
   - Left: Big circle with score out of 100 (bold number + severity label: CRITICAL/SIGNIFICANT/MODERATE/MANAGED)
   - Right: Context paragraph explaining what the score means for THIS company, referencing their industry, CRM age, admin hours
   - Score calculation: yearsOnCrm (older=higher, 10-20pts) + adminHours (less=higher, 5-20pts) + headache count (fewer=higher, 5-25pts) + 35 base, capped at 100
   - Score color: ≤40 red, ≤55 amber, ≤70 neon, >70 green
5. **"Your Highest-Impact Opportunity"** card (neon-tinted background):
   - Text: "Based on your responses — {headacheLabels[0]} — your CRM is data-rich but process-poor..."
   - Mention AI-driven ROI: 40-60% admin time recovery, 15-25% more revenue from existing records
   - Two red stat cards: "CRM DATA DECAY" showing industry-specific decay % and "TEAM ADMIN LOSS" showing industry-specific admin %
6. **"At a Glance"** row: 3 cards showing Industry, Data Maturity (CRM years), Admin Load (hours/week)
7. Sources footer: CSIRO 2025, HubSpot 2026, Deloitte 2025, Gartner 2025 (as italic fine print)

### PAGE 2 — YOUR AI OPPORTUNITY MAP
Title: "Your AI Opportunity Map"
Subtitle: "How AI transforms each of your reported challenges — for {industry} specifically"

For EACH headache in headacheLabels, render an AI MODULE card:
- Problem statement (industry-specific, using the company's actual CRM age and admin hours)
- AI Solution (specific, actionable, mentions the tech — AI-powered enrichment, workflow agents, pipeline monitoring, guided workflows, dashboards)
- Benefit (real example with numbers where possible — reference the 3 HALEIO case studies: a welding distributor found +$1M in upsells, a manufacturer cut warranty claims from 21 days to 4, a Customer Success team pushed revenue per customer from 97% to 115%)

BEFORE vs AFTER comparison table (5 rows):
- Data Accuracy | Admin Time | Pipeline Visibility | Follow-up Rate | Team Consistency
- Before column: red text, shows current state (use their actual adminHours and industry decay %)
- After column: neon text, shows AI-improved state

### PAGE 3 — YOUR 90-DAY AI ROADMAP
Title: "Your 90-Day AI Roadmap"
Subtitle: "Fixed scope. Fixed timeline. Fixed fee. You own everything."

4 PHASE CARDS in a 2x2 grid:
1. WK 1–4: "Diagnostic & Foundation" — Full CRM audit, AI infra deployed on Australian servers
2. WK 5–8: "Automation Build" — Custom AI workflows for their N priority areas
3. WK 9–10: "Stress Test & Validate" — Live data runs, edge cases, documentation
4. WK 11–13: "Training & Handover" — Team trained, full documentation, you own everything

CTA card (neon-tinted background, centered):
- "Get the Real Numbers from Your CRM"
- "This report is based on your self-assessment and industry benchmarks."
- "A paid diagnostic examines your actual CRM data to find the exact dollar value of every opportunity."
- "Book a Diagnostic · $4,950"
- "Founding rate (reg. $15,000) · Limited availability · Delivered in 5 business days"
- "haleio.com · hello@haleio.com · Adelaide, Australia"

Sources footer with all citations

## BRAND CONSTANTS
- neon: rgb("#D4FF00")
- card-bg: rgb("#080808")
- border: luma(18) (= 0.4pt stroke for cards)
- t1 (primary text): luma(240)
- t2 (secondary): luma(160)
- t3 (tertiary): luma(90)
- red: rgb("#FF4444")
- amber: rgb("#FFAA00")

## HELPER FUNCTIONS (implement these)
- card(body) — dark card with border, radius, padding
- neon-card(body) — similar with yellow-tinted background
- accent-bar — full-width neon bar (3pt)
- aiModule(num, title, problem, aiFix, benefit) — the per-headache module card
- row(metric, before, after) — table row for Before vs After
- phase(num, days, title, desc) — roadmap phase card

## INDUSTRY DATA (hardcode as a dictionary/map)
For each industry, provide: name, sample size description, AI gap multiplier, gap detail sentence, decay percentage, decay detail sentence, admin percentage, admin detail sentence, opportunity description, AI short description (1 sentence).

Example for Manufacturing:
- name: "MANUFACTURING"
- sample: "850+ Australian manufacturers"
- gap: "2.5x"
- decay: "28-34%"
- admin: "31%"
- Admin detail: "of rep time lost to non-revenue admin (HubSpot 2026)"
- opportunity: "15-22% of annual revenue in untapped CRM data"
- AI short: "Automated order re-activation, warranty workflow, and gap detection."

Customise each industry branch appropriately (construction has highest decay, SaaS lowest, etc). Use real-sounding statistics sourced from CSIRO 2025, HubSpot 2026, Deloitte 2025, Gartner 2025.

## QUALITY STANDARD
- Every page must feel personalised to the specific company — their industry name, CRM age, admin hours, and headache selections should appear throughout
- Zero generic filler text
- Visual hierarchy: score is prominent, cards are well-spaced, comparison table is scannable
- AI is framed as the solution to every problem — not vague "technology," but specific: "AI-powered enrichment," "workflow agents," "pipeline monitoring"
- The report should make the reader feel like the next logical step is booking the $4,950 diagnostic
