/**
 * 대시보드 위젯 (Widget) 도메인 — DataSet 서비스 호출 래퍼.
 *
 * backend-core 의 `widget/*` 매핑에 1:1 대응.
 *   - widget/listAll
 *   - widget/listMine     (첫 호출 시 server-side default 6 위젯 자동 시드)
 *   - widget/saveLayout
 *   - widget/addWidget
 *   - widget/removeWidget
 *
 * Phase 14 트랙 7.
 */
import axios from 'axios';

const ENDPOINT = '/api/dataset/search';

interface DataSetEnvelope<T = any> {
  success: boolean;
  data?: T;
  message?: string;
}

export interface WidgetCatalog {
  widgetCode: string;
  title: string;
  description?: string;
  defaultW: number;
  defaultH: number;
  category?: string;
  active: boolean;
}

export interface UserWidget {
  id?: number;
  widgetCode: string;
  title: string;
  description?: string;
  category?: string;
  posX: number;
  posY: number;
  width: number;
  height: number;
  configJson?: any;
  sortOrder?: number;
  /** 클라이언트 전용 — saveLayout 시 _rowType='D' 면 삭제 처리 */
  _rowType?: 'C' | 'U' | 'D';
}

async function call<T = any>(serviceName: string, datasets: Record<string, any>): Promise<T> {
  const res = await axios.post<DataSetEnvelope<T>>(ENDPOINT, { serviceName, datasets });
  return (res.data?.data ?? {}) as T;
}

/** snake_case 응답 키 정규화 — db_user_widget JOIN 결과를 camelCase 로 */
function normalizeUserWidget(r: any): UserWidget {
  return {
    id:          r.id ?? r.ID,
    widgetCode:  r.widgetCode  ?? r.widget_code,
    title:       r.title       ?? '',
    description: r.description ?? '',
    category:    r.category,
    posX:        Number(r.posX  ?? r.pos_x ?? 0),
    posY:        Number(r.posY  ?? r.pos_y ?? 0),
    width:       Number(r.width  ?? 4),
    height:      Number(r.height ?? 1),
    configJson:  parseConfig(r.configJson ?? r.config_json),
    sortOrder:   Number(r.sortOrder ?? r.sort_order ?? 0)
  };
}

function normalizeCatalog(r: any): WidgetCatalog {
  return {
    widgetCode:  r.widgetCode  ?? r.widget_code,
    title:       r.title       ?? '',
    description: r.description ?? '',
    defaultW:    Number(r.defaultW ?? r.default_w ?? 4),
    defaultH:    Number(r.defaultH ?? r.default_h ?? 1),
    category:    r.category,
    active:      r.active !== false
  };
}

function parseConfig(v: any): any {
  if (v == null) return null;
  if (typeof v === 'object') return v;
  if (typeof v === 'string') {
    try { return JSON.parse(v); } catch { return null; }
  }
  return null;
}

export function useWidget() {
  return {
    /** 카탈로그 (활성 위젯 9건) */
    async listAll(): Promise<WidgetCatalog[]> {
      const data = await call('widget/listAll', { ds_search: {} });
      const rows = data?.ds_widgets?.rows || [];
      return rows.map(normalizeCatalog);
    },

    /**
     * 내 위젯 — 빈 결과면 backend 가 default 6 위젯 자동 INSERT 후 다시 반환.
     */
    async listMine(): Promise<UserWidget[]> {
      const data = await call('widget/listMine', { ds_search: {} });
      const rows = data?.ds_mine?.rows || [];
      return rows.map(normalizeUserWidget);
    },

    /** 편집 모드 종료 시 일괄 저장. 삭제 행은 _rowType='D' 로 표시. */
    async saveLayout(widgets: UserWidget[]): Promise<void> {
      const rows = widgets.map(w => ({
        widgetCode: w.widgetCode,
        posX:  w.posX,
        posY:  w.posY,
        width: w.width,
        height: w.height,
        sortOrder: w.sortOrder ?? 0,
        configJson: w.configJson ?? null,
        _rowType: w._rowType
      }));
      await call('widget/saveLayout', { ds_layout: { rows } });
    },

    /** 카탈로그에서 단건 추가 (default 위치/크기 사용) */
    async addWidget(widgetCode: string, opts?: Partial<UserWidget>): Promise<void> {
      await call('widget/addWidget', {
        ds_search: {
          widgetCode,
          posX:  opts?.posX,
          posY:  opts?.posY,
          width: opts?.width,
          height: opts?.height,
          sortOrder: opts?.sortOrder,
          configJson: opts?.configJson ?? null
        }
      });
    },

    /** 단건 제거 */
    async removeWidget(widgetCode: string): Promise<void> {
      await call('widget/removeWidget', { ds_search: { widgetCode } });
    }
  };
}
