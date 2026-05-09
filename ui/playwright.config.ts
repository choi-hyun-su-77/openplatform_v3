import { defineConfig, devices } from '@playwright/test'

/**
 * openplatform_v3 E2E 테스트 설정
 *
 * - baseURL: Vite dev server (25174). prod 빌드 검증 시 19173 (UI nginx).
 * - storageState: Keycloak SSO 토큰 1회 로그인 후 .auth/user.json 에 캐시.
 *   각 spec 의 use: { storageState } 로 재사용 — directAccessGrantsEnabled=false 우회.
 * - trace/screenshot/video: 실패 시 캡처. CI/회귀 디버깅용.
 * - workers: 도메인 단위 spec 이 ~25개 → 4 worker 병렬.
 */
export default defineConfig({
  testDir: './tests/e2e',
  timeout: 60_000,
  expect: { timeout: 10_000 },
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  workers: process.env.CI ? 2 : 4,
  reporter: [
    ['list'],
    ['html', { outputFolder: 'playwright-report', open: 'never' }]
  ],
  outputDir: 'test-results',
  use: {
    baseURL: process.env.E2E_BASE_URL || 'http://localhost:25174',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 10_000,
    navigationTimeout: 30_000,
    locale: 'ko-KR',
    timezoneId: 'Asia/Seoul',
    extraHTTPHeaders: {
      'Accept-Language': 'ko'
    }
  },
  projects: [
    {
      name: 'chromium',
      testMatch: /specs[\\/].*\.spec\.ts/,
      use: {
        ...devices['Desktop Chrome']
      }
    },
    // 필요 시 활성화 — 1차 회귀에서는 chromium 만 운영
    // {
    //   name: 'firefox',
    //   use: { ...devices['Desktop Firefox'], storageState: 'tests/e2e/.auth/user.json' },
    //   dependencies: ['setup']
    // },
    // {
    //   name: 'webkit',
    //   use: { ...devices['Desktop Safari'], storageState: 'tests/e2e/.auth/user.json' },
    //   dependencies: ['setup']
    // }
  ]
})
