import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const { chromium } = require('playwright');

const browser = await chromium.launch({
  executablePath: process.env.CHROMIUM_PATH || '/snap/bin/chromium',
  headless: true,
});
const page = await browser.newPage({
  viewport: { width: 430, height: 840 },
  recordVideo: { dir: 'docs', size: { width: 430, height: 840 } },
});
await page.goto('http://127.0.0.1:4173', { waitUntil: 'networkidle' });
const pause = ms => page.waitForTimeout(ms);
await pause(1200);
await page.getByRole('button', { name: /quét hóa đơn/i }).click();
await pause(2200);
await page.getByRole('button', { name: /lưu giao dịch/i }).click();
await pause(1800);
await page.getByRole('button', { name: /phân tích/i }).click();
await pause(1800);
await page.getByRole('button', { name: /ăn uống/i }).click();
await pause(1300);
await page.getByRole('button', { name: /cài đặt/i }).click();
await pause(1800);
await page.getByRole('button', { name: /tổng quan/i }).click();
await pause(1500);
await page.context().close();
await browser.close();
