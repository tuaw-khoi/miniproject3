import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const { chromium } = require('playwright');
const browser = await chromium.launch({
  executablePath: process.env.CHROMIUM_PATH || '/snap/bin/chromium',
  headless: true,
});
const page = await browser.newPage();
await page.goto('http://127.0.0.1:4173/docs/ReceiptFlow_Report.html', {
  waitUntil: 'networkidle',
});
await page.pdf({
  path: 'docs/ReceiptFlow_Report.pdf',
  format: 'A4',
  printBackground: true,
  preferCSSPageSize: true,
});
await browser.close();
