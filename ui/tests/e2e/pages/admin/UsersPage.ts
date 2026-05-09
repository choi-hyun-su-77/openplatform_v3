import type { Page, Locator } from '@playwright/test'
import { expect } from '@playwright/test'
import { gotoMenu } from '../../fixtures/auth.fixture'

export class UsersPage {
  readonly page: Page
  readonly heading: Locator
  readonly searchInput: Locator
  readonly addButton: Locator
  readonly table: Locator

  constructor(page: Page) {
    this.page = page
    this.heading = page.getByRole('heading', { level: 2 })
    this.searchInput = page.locator('.toolbar input').first()
    this.addButton = page.locator('.toolbar button').nth(1)
    this.table = page.locator('table.p-datatable-table')
  }

  async goto() {
    await gotoMenu(this.page, '/admin/users')
    await expect(this.heading).toBeVisible()
  }

  async openCreate() {
    await this.addButton.click()
    await expect(this.page.locator('.p-dialog')).toBeVisible()
  }

  async cancelDialog() {
    const dialog = this.page.locator('.p-dialog')
    await dialog.locator('button', { hasText: /취소|Cancel|取消|キャンセル/ }).click()
    await expect(dialog).toBeHidden()
  }
}
