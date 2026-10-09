import { createRequire } from 'node:module';
import { mkdir } from 'node:fs/promises';

const require = createRequire(import.meta.url);
const { chromium } = require('playwright');
const output = 'docs/screenshots';
await mkdir(output, { recursive: true });

const browser = await chromium.launch({
  executablePath: process.env.CHROMIUM_PATH || '/snap/bin/chromium',
  headless: true,
});
const page = await browser.newPage({ viewport: { width: 430, height: 840 } });
await page.goto('http://127.0.0.1:4173/web_demo/', { waitUntil: 'networkidle' });
await page.addStyleTag({
  content: '* { animation: none !important; transition: none !important; }',
});

const capture = async (screen, file, setup) => {
  await page.evaluate(id => show(id), screen);
  if (setup) await setup();
  await page.locator('main').evaluate(el => el.scrollTo(0, 0));
  await page.waitForTimeout(450);
  await page.locator('.phone').screenshot({ path: `${output}/${file}` });
};

await capture('home', 'overview.png');
await capture('scan', 'ocr-review.png');
await capture('transactions', 'transactions.png', async () => {
  await page.getByLabel('Tìm giao dịch').fill('');
});
await capture('analytics', 'analytics.png', async () => {
  await page.locator('.legend button').filter({ hasText: 'Ăn uống' }).click();
});
await capture('settings', 'settings.png');

await browser.close();
