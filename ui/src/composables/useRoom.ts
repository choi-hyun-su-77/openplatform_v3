/**
 * 회의실 예약 (Room Booking) 도메인 — DataSet 서비스 호출 래퍼.
 *
 * 모든 메서드는 backend-core `/api/dataset/search` 의 serviceName=`room/*` 에 매핑.
 * Phase 14 트랙 2.
 */
import axios from 'axios';

const ENDPOINT = '/api/dataset/search';

interface DataSetEnvelope<T = any> {
  success: boolean;
  data?: T;
  message?: string;
}

async function call<T = any>(serviceName: string, datasets: Record<string, any>): Promise<T> {
  const res = await axios.post<DataSetEnvelope<T>>(ENDPOINT, { serviceName, datasets });
  return (res.data?.data ?? {}) as T;
}

export interface Room {
  roomId: number;
  roomName: string;
  capacity: number;
  location?: string;
  hasVideo: boolean;
  hasPhone: boolean;
  amenities?: string;
  active?: boolean;
}

export interface Booking {
  bookingId: number;
  roomId: number;
  roomName: string;
  bookerNo: string;
  title: string;
  startAt: string;
  endAt: string;
  attendees?: string;
  livekitRoom?: string;
  status: string;
}

export interface ReserveInput {
  roomId: number;
  title: string;
  startAt: string;
  endAt: string;
  /** CSV employee_no */
  attendees?: string;
}

export function useRoom() {
  return {
    /** 회의실 목록 (필터: keyword/minCapacity/hasVideo) */
    async searchRooms(filter: { keyword?: string; minCapacity?: number; hasVideo?: boolean } = {}): Promise<Room[]> {
      const data = await call('room/searchRooms', { ds_search: filter });
      return data?.ds_rooms?.rows || [];
    },

    /** 입력 from~to 기준 가용 회의실 */
    async searchAvailable(from: string, to: string,
                          filter: { minCapacity?: number; hasVideo?: boolean } = {}): Promise<Room[]> {
      const data = await call('room/searchAvailable', {
        ds_search: { from, to, ...filter }
      });
      return data?.ds_rooms?.rows || [];
    },

    /** 예약 목록 (회의실/기간) */
    async searchBookings(roomId: number | null, from: string, to: string): Promise<Booking[]> {
      const data = await call('room/searchBookings', {
        ds_search: { roomId, from, to }
      });
      return data?.ds_bookings?.rows || [];
    },

    /** 본인 예약 (UPCOMING|PAST) */
    async searchMyBookings(scope: 'UPCOMING' | 'PAST' = 'UPCOMING'): Promise<Booking[]> {
      const data = await call('room/searchMyBookings', { ds_search: { scope } });
      return data?.ds_bookings?.rows || [];
    },

    /** 시간 충돌 체크 */
    async checkConflict(roomId: number, from: string, to: string,
                        excludeBookingId?: number): Promise<{ conflict: boolean; count: number }> {
      const data = await call<{ conflict: boolean; count: number }>('room/checkConflict', {
        ds_search: { roomId, from, to, excludeBookingId }
      });
      return data || { conflict: false, count: 0 };
    },

    /** 예약 (충돌 검증 + LiveKit 룸 자동 생성 + 알림 + 캘린더 자동 등록) */
    async reserve(input: ReserveInput) {
      return call('room/reserve', { ds_search: input });
    },

    /** 예약 취소 (본인 또는 관리자만) */
    async cancel(bookingId: number) {
      return call('room/cancel', { ds_search: { bookingId } });
    }
  };
}
