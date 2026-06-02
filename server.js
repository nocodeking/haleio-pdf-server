const express = require('express');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));

const PORT = process.env.PORT || 3002;
const FONTS_DIR = path.join(__dirname, 'fonts');
const TEMPLATE_SRC = path.join(__dirname, 'template.typ');
const OUTPUT_DIR = path.join(__dirname, 'output');
if (!fs.existsSync(OUTPUT_DIR)) fs.mkdirSync(OUTPUT_DIR, { recursive: true });

const DEFAULTS = {
  company: 'Your Company', name: 'Valued Client', industry: 'Manufacturing',
  revenue: '$5M – $10M', yearsOnCrm: '3–5 years', adminHours: '10–20 hrs/week',
  headacheLabels: '("Data accuracy — records are out of date",)',
};

// ── INDUSTRY DATA (mirrors template.typ percentages) ──
const INDUSTRY_DATA = [
  { match: 'Manufactur', decay: [28, 34], admin: 31, opp: [15, 22] },
  { match: 'Wholesale', decay: [30, 38], admin: 35, opp: [18, 25] },
  { match: 'Distribution', decay: [30, 38], admin: 35, opp: [18, 25] },
  { match: 'Professional Service', decay: [24, 30], admin: 28, opp: [12, 18] },
  { match: 'SaaS', decay: [22, 28], admin: 24, opp: [8, 14] },
  { match: 'Technology', decay: [22, 28], admin: 24, opp: [8, 14] },
  { match: 'Construction', decay: [32, 40], admin: 38, opp: [20, 30] },
  { match: 'Trades', decay: [32, 40], admin: 38, opp: [20, 30] },
  { match: 'Health', decay: [30, 36], admin: 30, opp: [10, 16] },
  { match: 'Retail', decay: [22, 28], admin: 24, opp: [10, 20] },
];

function getIndustryPcts(industry) {
  const fallback = { decay: [26, 32], admin: 29, opp: [10, 20] };
  if (!industry) return fallback;
  const match = INDUSTRY_DATA.find(d => industry.includes(d.match));
  return match || fallback;
}

function parseRevenue(str) {
  if (!str || str === 'Not specified' || str === '') return null;
  let s = str.replace(/[\$,]/g, '').trim();
  if (!s) return null;

  // "Under $X" → assume X as upper bound
  const underMatch = s.match(/Under\s*([\d.]+)\s*([MBK])?/i);
  if (underMatch) {
    let val = parseFloat(underMatch[1]);
    const unit = (underMatch[2] || 'M').toUpperCase();
    if (unit === 'K') val *= 1000;
    if (unit === 'M') val *= 1000000;
    if (unit === 'B') val *= 1000000000;
    return { low: Math.round(val * 0.3), high: Math.round(val), midpoint: Math.round(val * 0.65) };
  }

  // "X+" or "$XM+" → multiply by 1.5 for upper
  const plusMatch = s.match(/([\d.]+)\s*([MBK]?)\s*\+/i);
  if (plusMatch) {
    let val = parseFloat(plusMatch[1]);
    const unit = (plusMatch[2] || 'M').toUpperCase();
    if (unit === 'K') val *= 1000;
    if (unit === 'M') val *= 1000000;
    if (unit === 'B') val *= 1000000000;
    return { low: Math.round(val), high: Math.round(val * 1.5), midpoint: Math.round(val * 1.25) };
  }

  // "X — Y" or "X - Y" range
  const rangeMatch = s.match(/([\d.]+)\s*[MBK]?\s*[–—-]\s*([\d.]+)\s*([MBK])?/i);
  if (rangeMatch) {
    let low = parseFloat(rangeMatch[1]);
    let high = parseFloat(rangeMatch[2]);
    const unit = (rangeMatch[3] || 'M').toUpperCase();
    if (unit === 'K') { low *= 1000; high *= 1000; }
    if (unit === 'M') { low *= 1000000; high *= 1000000; }
    if (unit === 'B') { low *= 1000000000; high *= 1000000000; }
    return { low: Math.round(low), high: Math.round(high), midpoint: Math.round((low + high) / 2) };
  }

  // Single number
  const singleMatch = s.match(/([\d.]+)\s*([MBK])?/i);
  if (singleMatch) {
    let val = parseFloat(singleMatch[1]);
    const unit = (singleMatch[2] || 'M').toUpperCase();
    if (unit === 'K') val *= 1000;
    if (unit === 'M') val *= 1000000;
    if (unit === 'B') val *= 1000000000;
    return { low: Math.round(val * 0.8), high: Math.round(val * 1.2), midpoint: Math.round(val) };
  }

  return null;
}

function fmtDollar(val) {
  if (val >= 1000000000) return '$' + (val / 1000000000).toFixed(1) + 'B';
  if (val >= 1000000) return '$' + (val / 1000000).toFixed(1) + 'M';
  if (val >= 1000) return '$' + Math.round(val / 1000) + 'K';
  return '$' + Math.round(val);
}

function fmtDollarRange(low, high) {
  if (low === high) return fmtDollar(low);
  return fmtDollar(low) + '–' + fmtDollar(high);
}

function enrichWithEstimates(data) {
  const parsed = parseRevenue(data.revenue);
  if (!parsed) return;
  const pcts = getIndustryPcts(data.industry);

  data.estDecayLow = fmtDollar(Math.round(parsed.low * pcts.decay[0] / 100));
  data.estDecayHigh = fmtDollar(Math.round(parsed.high * pcts.decay[1] / 100));
  data.estAdmin = fmtDollarRange(
    Math.round(parsed.low * pcts.admin / 100),
    Math.round(parsed.high * pcts.admin / 100)
  );
  data.estOppLow = fmtDollar(Math.round(parsed.low * pcts.opp[0] / 100));
  data.estOppHigh = fmtDollar(Math.round(parsed.high * pcts.opp[1] / 100));
  // Total estimated range
  const totalLow = Math.round(parsed.low * (pcts.decay[0] + pcts.admin + pcts.opp[0]) / 100);
  const totalHigh = Math.round(parsed.high * (pcts.decay[1] + pcts.admin + pcts.opp[1]) / 100);
  data.estTotal = fmtDollarRange(totalLow, totalHigh);
  data.estSample = pcts.sample || (pcts.decay[0] + '%–' + pcts.decay[1] + '% decay');
}

function injectVariables(template, data) {
  let result = template;
  const stringVars = ['company', 'name', 'industry', 'revenue', 'yearsOnCrm', 'adminHours',
    'estDecayLow', 'estDecayHigh', 'estAdmin', 'estOppLow', 'estOppHigh', 'estTotal', 'estSample'];
  stringVars.forEach(key => {
    const val = data[key] || DEFAULTS[key] || '';
    const escaped = val.replace(/"/g, '\\"');
    const regex = new RegExp(`(#let\\s+${key}\\s*=\\s*)("[^"]*")`, 'g');
    result = result.replace(regex, (match, prefix) => `${prefix}"${escaped}"`);
  });

  const hv = data.headacheLabels || DEFAULTS.headacheLabels;
  if (Array.isArray(hv)) {
    const parts = hv.map(l => `"${l.replace(/"/g, '\\"')}"`);
    const formatted = '(' + parts.join(', ') + (parts.length === 1 ? ',)' : ')');
    result = result.replace(/(#let\s+headacheLabels\s*=\s*)\("[^)]*\)/, (_, prefix) => `${prefix}${formatted}`);
  } else if (typeof hv === 'string') {
    result = result.replace(/(#let\s+headacheLabels\s*=\s*)\("[^)]*\)/, (_, prefix) => `${prefix}${hv}`);
  }
  return result;
}

function compileAndReturn(templateStr, safeName, res) {
  const ts = Date.now();
  const typFile = path.join(OUTPUT_DIR, `${safeName}_${ts}.typ`);
  const pdfFile = path.join(OUTPUT_DIR, `${safeName}_${ts}.pdf`);
  fs.writeFileSync(typFile, templateStr, 'utf-8');
  // Copy assets so Typst can find them relative to the .typ file
  ['haleio-logo.svg', 'darren-headshot.jpg'].forEach(f => {
    const src = path.join(__dirname, f);
    if (fs.existsSync(src)) fs.copyFileSync(src, path.join(OUTPUT_DIR, f));
  });
  const cmd = `typst compile --font-path "${FONTS_DIR}" "${typFile}" "${pdfFile}"`;
  execSync(cmd, { timeout: 30000, cwd: __dirname });
  fs.unlinkSync(typFile);
  return fs.readFileSync(pdfFile);
}

function processRequest(data) {
  if (Array.isArray(data.headache)) {
    const map = {
      'data': 'Data accuracy — records are out of date',
      'admin': 'Admin overhead — too much manual work',
      'followup': "Lost follow-ups — deals fall through the cracks",
      'process': 'Inconsistent process — everyone works differently',
      'visibility': "No visibility — can't get reliable reports",
    };
    data.headacheLabels = data.headache.map(h => map[h] || h);
  }
  enrichWithEstimates(data);

  let template = fs.readFileSync(TEMPLATE_SRC, 'utf-8');
  template = injectVariables(template, data);
  return template;
}

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.post('/generate', (req, res) => {
  try {
    const data = { ...DEFAULTS, ...req.body };
    const template = processRequest(data);
    const safeName = data.company.replace(/[^a-zA-Z0-9]/g, '_').slice(0, 40);
    const pdfBuffer = compileAndReturn(template, safeName, res);
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="RevenueLeakReport-${safeName}-Haleio.pdf"`);
    res.send(pdfBuffer);
    const revStr = data.estTotal ? ` | Est. total: ${data.estTotal}` : '';
    console.log(`Generated: ${safeName} (${(pdfBuffer.length/1024).toFixed(0)}KB${revStr})`);
  } catch (err) {
    console.error('Generation failed:', err.message);
    res.status(500).json({ error: 'PDF generation failed', details: err.message });
  }
});

app.post('/generate-and-send', async (req, res) => {
  try {
    const data = { ...DEFAULTS, ...req.body };
    const template = processRequest(data);
    const email = data.email;
    if (!email) return res.status(400).json({ error: 'email is required' });

    const safeName = data.company.replace(/[^a-zA-Z0-9]/g, '_').slice(0, 40);
    const pdfBuffer = compileAndReturn(template, safeName, res);

    const firstName = data.name.split(' ')[0];
    let emailSent = false, emailError = null;

    try {
      if (process.env.RESEND_API_KEY) {
        const resp = await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${process.env.RESEND_API_KEY}`, 'Content-Type': 'application/json' },
          body: JSON.stringify({
            from: process.env.EMAIL_FROM || 'HALEIO <reports@haleio.com>', to: email,
            subject: `Your Revenue Report – ${data.company}`,
            html: `<p>Hi ${firstName},</p><p>Your report's attached. It shows where <strong>${data.company}</strong> is leaking revenue compared to other ${data.industry || 'businesses'} — the headline was <strong>${data.estTotal || 'significant'}</strong> per year.</p><p>This is based on your self-assessment. The accurate picture only comes from looking at your actual CRM data.</p><p>If you want the real diagnostic run on your CRM, book it here: <a href="https://cal.com/haleio/discovery">cal.com/haleio/discovery</a></p><table cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right:12px;vertical-align:middle"><img src="https://haleio.com/haleio-headshot-email.png" alt="Darren Hale" width="55" height="55" style="border-radius:50%"></td><td style="vertical-align:middle"><strong>Darren Hale</strong><br>Founder, HALEIO<br>Adelaide</td></tr></table>`,
            attachments: [{ filename: `RevenueLeakReport-${safeName}-Haleio.pdf`, content: pdfBuffer.toString('base64') }],
          }),
        });
        if (resp.ok) emailSent = true; else emailError = `Resend: ${await resp.text()}`;
      } else {
        emailError = 'No email provider configured';
      }
    } catch (e) { emailError = e.message; }

    res.json({ success: true, email_sent: emailSent, email_error: emailError, company: data.company, pdf_size: pdfBuffer.length, est_total: data.estTotal || null });
    console.log(`${safeName}: PDF ${(pdfBuffer.length/1024).toFixed(0)}KB, est ${data.estTotal || 'n/a'}, email ${emailSent ? 'sent' : emailError}`);
  } catch (err) {
    console.error('Pipeline failed:', err.message);
    res.status(500).json({ error: 'Pipeline failed', details: err.message });
  }
});

app.listen(PORT, '0.0.0.0', () => console.log(`HALEIO PDF on :${PORT}`));
