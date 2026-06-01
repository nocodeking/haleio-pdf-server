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

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

function injectVariables(template, data) {
  let result = template;
  const stringVars = ['company', 'name', 'industry', 'revenue', 'yearsOnCrm', 'adminHours'];
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
    result = result.replace(/(#let\s+headacheLabels\s*=\s*)\([^)]*\)/, (_, prefix) => `${prefix}${formatted}`);
  } else if (typeof hv === 'string') {
    result = result.replace(/(#let\s+headacheLabels\s*=\s*)\([^)]*\)/, (_, prefix) => `${prefix}${hv}`);
  }
  return result;
}

function compileAndReturn(templateStr, safeName, res) {
  const ts = Date.now();
  const typFile = path.join(OUTPUT_DIR, `${safeName}_${ts}.typ`);
  const pdfFile = path.join(OUTPUT_DIR, `${safeName}_${ts}.pdf`);
  fs.writeFileSync(typFile, templateStr, 'utf-8');
  const cmd = `typst compile --font-path "${FONTS_DIR}" "${typFile}" "${pdfFile}"`;
  execSync(cmd, { timeout: 30000, cwd: __dirname });
  fs.unlinkSync(typFile);
  return fs.readFileSync(pdfFile);
}

app.post('/generate', (req, res) => {
  try {
    const data = { ...DEFAULTS, ...req.body };
    if (Array.isArray(data.headache)) {
      data.headacheLabels = data.headache.map(h => {
        const map = {
          'data': 'Data accuracy — records are out of date',
          'admin': 'Admin overhead — too much manual work',
          'followup': "Lost follow-ups — deals fall through the cracks",
          'process': 'Inconsistent process — everyone works differently',
          'visibility': "No visibility — can't get reliable reports",
        };
        return map[h] || h;
      });
    }
    let template = fs.readFileSync(TEMPLATE_SRC, 'utf-8');
    template = injectVariables(template, data);
    const safeName = data.company.replace(/[^a-zA-Z0-9]/g, '_').slice(0, 40);
    const pdfBuffer = compileAndReturn(template, safeName, res);
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="${safeName}_report.pdf"`);
    res.send(pdfBuffer);
    console.log(`Generated: ${safeName} (${(pdfBuffer.length/1024).toFixed(0)}KB)`);
  } catch (err) {
    console.error('Generation failed:', err.message);
    res.status(500).json({ error: 'PDF generation failed', details: err.message });
  }
});

app.post('/generate-and-send', async (req, res) => {
  try {
    const data = { ...DEFAULTS, ...req.body };
    if (Array.isArray(data.headache)) {
      data.headacheLabels = data.headache.map(h => {
        const map = {
          'data': 'Data accuracy — records are out of date',
          'admin': 'Admin overhead — too much manual work',
          'followup': 'Lost follow-ups — deals fall through the cracks',
          'process': 'Inconsistent process — everyone works differently',
          'visibility': 'No visibility — can\'t get reliable reports',
        };
        return map[h] || h;
      });
    }
    const email = data.email;
    if (!email) return res.status(400).json({ error: 'email is required' });

    let template = fs.readFileSync(TEMPLATE_SRC, 'utf-8');
    template = injectVariables(template, data);
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
            subject: `Revenue report for ${data.company}`,
            html: `<p>Hi ${firstName},</p><p>Your revenue performance report for <strong>${data.company}</strong> is attached.</p><p>It benchmarks your industry, revenue tier, and operational challenges against what similar businesses typically find. Think of it as a starting point. The full picture comes from running your actual CRM data through a diagnostic.</p><p>If you want the real numbers, book a diagnostic at <a href="https://haleio.com">haleio.com</a>.</p><table cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right:12px;vertical-align:middle"><img src="https://haleio.com/haleio-headshot-email.png" alt="Darren Hale" width="55" height="55" style="border-radius:50%"></td><td style="vertical-align:middle"><strong>Darren Hale</strong><br>Founder, HALEIO<br>Adelaide</td></tr></table>`,
            attachments: [{ filename: `${safeName}_report.pdf`, content: pdfBuffer.toString('base64') }],
          }),
        });
        if (resp.ok) emailSent = true; else emailError = `Resend: ${await resp.text()}`;
      } else {
        emailError = 'No email provider configured';
      }
    } catch (e) { emailError = e.message; }

    res.json({ success: true, email_sent: emailSent, email_error: emailError, company: data.company, pdf_size: pdfBuffer.length });
    console.log(`${safeName}: PDF ${(pdfBuffer.length/1024).toFixed(0)}KB, email ${emailSent ? 'sent' : emailError}`);
  } catch (err) {
    console.error('Pipeline failed:', err.message);
    res.status(500).json({ error: 'Pipeline failed', details: err.message });
  }
});

app.listen(PORT, '0.0.0.0', () => console.log(`HALEIO PDF on :${PORT}`));
