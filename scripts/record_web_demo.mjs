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
await page.goto('http://127.0.0.1:4173/web_demo/', { waitUntil: 'networkidle' });
const pause = ms => page.waitForTimeout(ms);
const title = async (kicker, heading, body, duration = 4000) => {
  await page.evaluate(
    ([k, h, b]) => window.demoTitle(k, h, b, true),
    [kicker, heading, body],
  );
  await pause(duration);
  await page.evaluate(() => window.demoTitle('', '', '', false));
  await pause(500);
};
const caption = async (heading, body, duration = 6000) => {
  await page.evaluate(([h, b]) => window.demoChapter(h, b), [heading, body]);
  await pause(duration);
};

await title(
  'MINI-PROJECT 3 • FLUTTER ANDROID',
  'ReceiptFlow',
  'Quét hóa đơn, lưu chi tiêu và xem phân tích hoàn toàn ngoại tuyến.',
  5200,
);
await caption(
  '1. Tổng quan chi tiêu',
  'Dashboard tổng hợp chi tiêu tháng, số hóa đơn, số tiền hôm nay, biểu đồ tuần và các giao dịch gần nhất.',
  7000,
);

await page.locator('[data-screen="scan"]').first().click();
await caption(
  '2. OCR hóa đơn trên thiết bị',
  'APK dùng Camera, crop/rotate và Google ML Kit Latin OCR. Ảnh mẫu tổng hợp giúp demo mà không lộ dữ liệu cá nhân.',
  8000,
);
await page.locator('#scan').evaluate(el => el.scrollIntoView({ block: 'start' }));
await caption(
  '3. Kiểm tra trước khi lưu',
  'Merchant, tổng tiền, ngày và danh mục chỉ là gợi ý. Người dùng luôn có thể sửa; OCR không tự động ghi dữ liệu sai.',
  7500,
);
await page.getByRole('button', { name: /lưu giao dịch/i }).click();
await pause(2600);

await caption(
  '4. SQLite và quản lý giao dịch',
  'Mỗi khoản chi được lưu cục bộ, sắp xếp theo ngày và giữ nguyên sau khi đóng/mở lại ứng dụng.',
  6000,
);
await page.getByLabel('Tìm giao dịch').fill('Grab');
await caption(
  '5. Tìm kiếm tức thời',
  'Tìm theo tên cửa hàng hoặc ghi chú; bộ lọc danh mục và khoảng ngày kiểm soát cả danh sách lẫn file CSV.',
  5200,
);
await page.getByLabel('Tìm giao dịch').fill('');
await page.locator('#transactions .chip').filter({ hasText: 'Học tập' }).click();
await pause(3500);
await page.locator('#transactions-list .expense').first().click();
await caption(
  '6. Chi tiết, sửa và xóa',
  'Màn hình chi tiết hiển thị số tiền, ngày, danh mục và ảnh gốc. APK còn hỗ trợ sửa hoặc xóa cả bản ghi lẫn ảnh riêng tư.',
  6500,
);
await page.locator('.sheet .close').click();

await page.locator('nav [data-screen="analytics"]').click();
await caption(
  '7. Phân tích trực quan',
  'Donut chart tổng hợp theo danh mục; chạm từng mục để xem số tiền và tỷ lệ tương ứng.',
  6000,
);
await page.locator('.legend button').filter({ hasText: 'Ăn uống' }).click();
await pause(3800);
await page.locator('main').evaluate(el => el.scrollTo({ top: el.scrollHeight, behavior: 'smooth' }));
await pause(1300);
await page.locator('.interactive .bar').nth(3).click();
await caption(
  '8. Xu hướng theo tuần',
  'Biểu đồ CustomPainter trong APK hỗ trợ animation và chọn từng cột để xem giá trị theo ngày.',
  5700,
);

await page.evaluate(() => window.hideDemoChapter());
await page.evaluate(() => show('home'));
await page.locator('[data-screen="manual"]').click();
await caption(
  '9. Nhập khoản chi thủ công',
  'Khi không cần OCR, người dùng nhập cửa hàng, số tiền, ngày, danh mục và ghi chú bằng biểu mẫu kiểm tra dữ liệu.',
  6500,
);
await page.locator('#manual-merchant').fill('Căn tin VKU');
await page.locator('#manual-amount').fill('35000');
await page.getByRole('button', { name: /lưu khoản chi/i }).click();
await pause(2500);

await page.locator('nav [data-screen="settings"]').click();
await caption(
  '10. Cá nhân hóa và dữ liệu demo',
  'Tiếng Việt/English, sáng/tối/theo hệ thống và kho dữ liệu minh họa được tách khỏi dữ liệu chi tiêu cá nhân.',
  6500,
);
await page.locator('#settings .setting').nth(1).getByRole('button').click();
await pause(3000);
await page.locator('#settings .setting').first().getByRole('button').click();
await pause(3000);
await caption(
  '11. Xuất dữ liệu an toàn',
  'CSV dùng UTF-8, chỉ xuất kết quả sau khi lọc và trung hòa ký tự có thể bị bảng tính hiểu là công thức.',
  5500,
);
await page.locator('#settings .setting').nth(3).getByRole('button').click();
await pause(2500);

await page.evaluate(() => show('about'));
await caption(
  '12. Kiểm thử và APK',
  '51 test đã đạt; Dart analysis sạch; GitHub Actions build APK debug và lưu artifact để tải về.',
  6500,
);
await page.evaluate(() => window.hideDemoChapter());
await title(
  'RECEIPTFLOW 1.0.0',
  'Offline. Private. Practical.',
  'Flutter • ML Kit • SQLite • Riverpod • GitHub Actions',
  5200,
);
await page.context().close();
await browser.close();
