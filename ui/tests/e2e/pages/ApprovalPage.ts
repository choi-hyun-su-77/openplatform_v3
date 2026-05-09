import type { Page, Locator } from '@playwright/test'
import { expect } from '@playwright/test'
import { gotoMenu } from '../fixtures/auth.fixture'

export class ApprovalPage {
  readonly page: Page
  readonly heading: Locator
  readonly newButton: Locator
  readonly refreshButton: Locator
  readonly searchInput: Locator
  readonly inboxNav: Locator
  readonly table: Locator

  constructor(page: Page) {
    this.page = page
    this.heading = page.getByRole('heading', { level: 2 })
    this.newButton = page.locator('.header-actions button').first()
    this.refreshButton = page.locator('.header-actions button').nth(1)
    this.searchInput = page.locator('.search-bar input')
    this.inboxNav = page.locator('.inbox-nav')
    this.table = page.locator('table.p-datatable-table')
  }

  async goto() {
    await gotoMenu(this.page, '/approval')
    await expect(this.heading).toBeVisible()
  }

  /** boxCode: DRAFT/MY_DOCS/PENDING/IN_PROGRESS/COMPLETED/REJECTED/RECEIVED/CC_BOX/DEPT_BOX */
  async selectBox(boxCode: string) {
    // boxes 의 li 인덱스가 V18 에서 9 고정이므로 텍스트 매칭으로 안정 검색.
    // 텍스트는 i18n 이지만, ko 로케일 storageState 가 기본이라 V18 의 BOX_<code> ko 값 사용.
    await this.inboxNav.locator('li').filter({ has: this.page.locator(`i.${boxIcon(boxCode)}`) }).click()
    await this.page.waitForLoadState('networkidle')
  }

  async openNewDoc() {
    await this.newButton.click()
    await expect(this.page.locator('.p-dialog')).toBeVisible()
  }

  async fillSubmitForm(opts: { formCode: string; title: string; amount?: number; content?: string }) {
    const dialog = this.page.locator('.p-dialog')
    // 양식
    await dialog.locator('.p-select').first().click()
    await this.page.locator('.p-select-overlay li', { hasText: formLabel(opts.formCode) }).click()
    // 제목
    await dialog.locator('input[type="text"]').first().fill(opts.title)
    if (opts.amount != null) {
      await dialog.locator('input[type="text"]').nth(1).fill(String(opts.amount))
    }
    if (opts.content) {
      await dialog.locator('textarea').first().fill(opts.content)
    }
  }

  async submit() {
    const dialog = this.page.locator('.p-dialog')
    await dialog.locator('button', { hasText: /상신|Submit|提交|起案/ }).click()
  }

  async expectRowCount(min: number) {
    await expect(this.table.locator('tbody tr')).toHaveCount(min, { timeout: 10_000 })
  }
}

function boxIcon(code: string): string {
  const map: Record<string, string> = {
    DRAFT: 'pi-pencil', MY_DOCS: 'pi-folder', PENDING: 'pi-clock',
    IN_PROGRESS: 'pi-sync', COMPLETED: 'pi-check', REJECTED: 'pi-times',
    RECEIVED: 'pi-inbox', CC_BOX: 'pi-eye', DEPT_BOX: 'pi-building'
  }
  return map[code] || 'pi-folder'
}

function formLabel(code: string): RegExp {
  const map: Record<string, RegExp> = {
    LEAVE: /휴가|Leave|休假|休暇/,
    EXPENSE: /지출|Expense|支出/,
    PURCHASE: /구매|Purchase|采购|購買/,
    BIZTRIP: /출장|Business|出差|出張/
  }
  return map[code] || new RegExp(code)
}
