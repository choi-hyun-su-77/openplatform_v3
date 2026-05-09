import type { Page, Locator } from '@playwright/test'

/**
 * 레이아웃 (사이드바/헤더/탭바) 헬퍼.
 *
 * 사이드바 메뉴는 menuId 기반으로 탐색 (i18n 변경에 영향 받지 않음).
 * h2/그리드 헤더 등 본문 라벨은 도메인별 Page Object 가 책임.
 */
export class LayoutPage {
  readonly page: Page
  readonly sidebar: Locator
  readonly header: Locator
  readonly tabBar: Locator

  constructor(page: Page) {
    this.page = page
    this.sidebar = page.locator('.layout-sidebar')
    this.header = page.locator('.layout-header')
    this.tabBar = page.locator('.layout-tab-bar')
  }

  /** 사이드바 메뉴 클릭 — menuId 의 menuPath 로 navigate. 그룹이면 expand. */
  async goto(menuPath: string) {
    await this.page.goto(menuPath)
    await this.page.waitForLoadState('networkidle')
  }

  async openMenuByText(text: string) {
    const item = this.sidebar.locator('.menu-label', { hasText: text }).first()
    await item.click()
    await this.page.waitForLoadState('networkidle')
  }
}
