const { test, expect } = require('@playwright/test');
const path = require('path');

test('admin modules render on desktop', async ({ page }) => {
  const pageErrors = [];
  const consoleErrors = [];
  page.on('pageerror', (error) => pageErrors.push(error.message));
  page.on('console', (message) => {
    if (['error', 'warning'].includes(message.type())) {
      consoleErrors.push(`${message.type()}: ${message.text()}`);
    }
  });

  await page.goto('http://127.0.0.1:8088', { waitUntil: 'networkidle' });
  await page.locator('#offlineAdminBtn').click();
  await expect(page.locator('#appShell')).not.toHaveClass(/is-hidden/);

  const navs = await page.locator('.nav-item').evaluateAll((items) =>
    items.map((item) => ({
      view: item.dataset.view,
      text: item.innerText.trim(),
    })),
  );

  const results = [];
  for (const nav of navs) {
    await page.locator(`.nav-item[data-view="${nav.view}"]`).click();
    await page.waitForTimeout(120);
    const data = await page.evaluate((view) => {
      const root = document.querySelector('#viewRoot');
      const badText =
        document.body.innerText.match(/[\u00c3\u00c4\u00c2]|\u00ef\u00bf\u00bd|\ufffd/g)
          ?.length || 0;
      return {
        view,
        title: document.querySelector('#viewTitle')?.innerText || '',
        cards: document.querySelectorAll(
          '.metric,.panel,.table-panel,.topic-tile,.connection-card,.qa-item,.setting-row',
        ).length,
        buttons: root ? root.querySelectorAll('button').length : 0,
        tables: root ? root.querySelectorAll('table').length : 0,
        empty: !root || root.innerText.trim().length === 0,
        horizontalOverflow: document.documentElement.scrollWidth > window.innerWidth + 2,
        badText,
      };
    }, nav.view);
    results.push(data);
    expect(data.empty, `${nav.view} should render content`).toBeFalsy();
    expect(data.badText, `${nav.view} should not contain mojibake`).toBe(0);
  }

  await page.locator('.nav-item[data-view="dashboard"]').click();
  await page.screenshot({
    path: path.resolve(__dirname, 'admin-dashboard-check-desktop.png'),
    fullPage: true,
  });

  console.log(`ADMIN_UI_RESULTS=${JSON.stringify(results)}`);
  console.log(`ADMIN_UI_CONSOLE=${JSON.stringify(consoleErrors)}`);
  expect(pageErrors).toEqual([]);
});

test('admin dashboard fits mobile width', async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto('http://127.0.0.1:8088', { waitUntil: 'networkidle' });
  await page.locator('#offlineAdminBtn').click();
  await expect(page.locator('#appShell')).not.toHaveClass(/is-hidden/);

  const metrics = await page.evaluate(() => ({
    horizontalOverflow: document.documentElement.scrollWidth > window.innerWidth + 2,
    width: window.innerWidth,
    scrollWidth: document.documentElement.scrollWidth,
  }));

  await page.screenshot({
    path: path.resolve(__dirname, 'admin-dashboard-check-mobile.png'),
    fullPage: true,
  });

  console.log(`ADMIN_MOBILE_METRICS=${JSON.stringify(metrics)}`);
  expect(metrics.horizontalOverflow).toBeFalsy();
});
