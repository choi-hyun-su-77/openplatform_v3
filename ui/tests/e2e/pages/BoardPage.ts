import type { Page, Locator } from '@playwright/test'
import { expect } from '@playwright/test'
import { gotoMenu } from '../fixtures/auth.fixture'

export class BoardPage {
  readonly page: Page
  readonly heading: Locator
  readonly searchInput: Locator
  readonly searchButton: Locator
  readonly newPostButton: Locator
  readonly table: Locator

  constructor(page: Page) {
    this.page = page
    this.heading = page.getByRole('heading', { level: 2 })
    this.searchInput = page.locator('.toolbar input').first()
    this.searchButton = page.locator('.toolbar button').nth(0)
    this.newPostButton = page.locator('.toolbar button').nth(1)
    this.table = page.locator('table.p-datatable-table')
  }

  async goto() {
    await gotoMenu(this.page, '/board')
    await expect(this.heading).toBeVisible()
  }

  async openForm() {
    await this.newPostButton.click()
    await expect(this.page.locator('.p-dialog')).toBeVisible()
  }

  async fillPost(title: string, content?: string) {
    const dialog = this.page.locator('.p-dialog')
    await dialog.locator('input[type="text"]').first().fill(title)
    if (content) {
      await dialog.locator('textarea').first().fill(content)
    }
  }

  async savePost() {
    const dialog = this.page.locator('.p-dialog')
    await dialog.locator('button.p-button').last().click()
    await expect(dialog).toBeHidden({ timeout: 10_000 })
  }

  async search(keyword: string) {
    await this.searchInput.fill(keyword)
    await this.searchButton.click()
    await this.page.waitForLoadState('networkidle')
  }
}
