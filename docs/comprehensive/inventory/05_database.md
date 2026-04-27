# Database & Data Migrations Inventory

**Database:** PostgreSQL 15+ (schema: platform_v3, separate flowable_v3)

## Flyway Migration Chain (V1 ~ V17)

All files located: `/backend-core/src/main/resources/db/migration/`

### Baseline & Core Schema (V1-V3)

| Version | File | Size | Key Entities | Changes |
|---------|------|------|--------------|---------|
| V1 | V1__baseline.sql | ~8 KB | user, dept, role, role_permission, org_code, org_level | Initial core tables, indexes, constraints |
| V2 | V2__org_schema.sql | ~3 KB | org, org_relation, org_hierarchy, member, member_role | Organizational structure (tree, multi-level) |
| V3 | V3__common_code_notification.sql | ~2 KB | common_code, common_code_detail, notification, notify_pref | Dropdown codes, notification basics |

### Feature Schemas (V4-V9)

| Version | File | Size | Key Entities | Purpose |
|---------|------|------|--------------|---------|
| V4 | V4__board_calendar.sql | ~5 KB | board, board_post, board_comment, board_attachment, calendar_event | Public notice board, personal/shared calendar |
| V5 | V5__seed_data.sql | ~10 KB | (insert statements) | Admin, Test1, Test2 users; 10 depts; 50+ codes (approval types, leave types, etc.) |
| V6 | V6__menu_permission.sql | ~3 KB | menu, menu_permission (role_id, menu_id, can_read, can_write, can_delete) | App navigation tree + RBAC matrix |
| V7 | V7__seed_data.sql | ~5 KB | (seed extension) | Extended user/dept test data, approval line templates |
| V8 | V8__approval_and_extras.sql | ~6 KB | approval_request, approval_line, approval_signature, approval_attachment | Flowable workflow integration (Keycloak event + approval_request.process_id points to flowable_v3 process instance) |
| V9 | V9__i18n_labels_and_seed_data.sql | ~15 KB | i18n_label (locale, key, label_text, module) | Multi-language support (ko, en, ja, zh-CN) |

### Phase 14 & Domain-Specific (V10-V17)

| Version | File | Size | Key Entities | Domains |
|---------|------|------|--------------|---------|
| V10 | V10__attendance_leave.sql | ~4 KB | attendance (daily check-in/out), leave_request, leave_balance, leave_type | Attendance tracking, leave management |
| V11 | V11__room_booking.sql | ~3 KB | room, room_equipment, room_booking, room_booking_item | Facility/room reservation |
| V12 | V12__data_library.sql | ~3 KB | data_lib_folder, data_lib_file (minio_key, minio_size, upload_date) | File library (MinIO integration) |
| V13 | V13__work_report.sql | ~4 KB | work_report, work_report_item (daily task log) | Team worklog / daily standup |
| V14 | V14__admin_audit.sql | ~3 KB | admin_audit, system_audit, system_log | Audit trail for compliance |
| V15 | V15__ux_features.sql | ~2 KB | favorite, notify_pref, search_history | User preferences (starred items, notification settings, search) |
| V16 | V16__dashboard_widget.sql | ~2 KB | widget, widget_config, widget_position | Customizable dashboard (drag-drop) |
| V17 | V17__phase14_menus.sql | ~1 KB | (menu inserts) | Phase 14 navigation updates (admin pages, new features) |

## Key Table Relationships

```
┌────────────┐
│    user    │ (id, keycloak_id, login, email, name, status, created_at)
└─────┬──────┘
      │ one-to-many
      ├─→ member_role (user_id, role_id)
      ├─→ approval_request (created_by, status=draft/submitted/approved/rejected)
      ├─→ approval_line (assignee_id)
      ├─→ attendance (user_id, date, check_in_time, check_out_time)
      ├─→ leave_request (user_id)
      ├─→ room_booking (created_by)
      ├─→ data_lib_folder (owner_id)
      ├─→ work_report (user_id, report_date)
      ├─→ notification (recipient_id)
      └─→ favorite (user_id, item_id, item_type)

┌────────────┐
│    dept    │ (id, parent_id, name, code, sort)
└──────┬─────┘
       │ one-to-many
       ├─→ user (dept_id)
       ├─→ member (dept_id)
       └─→ approval_line (dept_id) [for dept-level approval]

┌────────────────────┐
│   approval_request │ (id, user_id, form_type, status, flowable_process_id)
└──────┬─────────────┘
       │ one-to-many
       └─→ approval_line (request_id, seq, assignee_id, approver_id, status=draft/pending/approved/rejected, signature_date)
           └─→ approval_attachment (line_id, attachment_key [MinIO])
```

## Important Indexes

- **approval_request(status, created_by, created_at)** - Dashboard pending count
- **approval_line(assignee_id, status, created_at)** - User approval tasks
- **attendance(user_id, date)** - Daily check-in/out lookup
- **leave_request(user_id, status, start_date, end_date)** - Leave calendar
- **calendar_event(user_id, start_date, end_date)** - Calendar queries
- **board_post(board_id, created_at)** - Board listing
- **work_report(user_id, report_date)** - Worklog queries
- **notification(recipient_id, created_at, is_read)** - Notification bell
- **data_lib_file(folder_id, created_at)** - File listing
- **room_booking(room_id, booking_date, start_time, end_time)** - Availability check

## Constraint & Trigger Patterns

### Foreign Keys (sample)

```sql
-- approval_request → user (on delete set null for historical records)
ALTER TABLE approval_request
  ADD CONSTRAINT fk_approval_req_user
  FOREIGN KEY (created_by) REFERENCES "user"(id) ON DELETE SET NULL;

-- approval_line → approval_request (on delete cascade)
ALTER TABLE approval_line
  ADD CONSTRAINT fk_approval_line_request
  FOREIGN KEY (request_id) REFERENCES approval_request(id) ON DELETE CASCADE;

-- room_booking → room (on delete cascade, reservations deleted if room removed)
ALTER TABLE room_booking
  ADD CONSTRAINT fk_room_booking_room
  FOREIGN KEY (room_id) REFERENCES room(id) ON DELETE CASCADE;
```

### Triggers

- **before insert on approval_request:** auto-populate status='draft', created_at=now()
- **after update on approval_line (status):** send notification, update parent approval_request status if all lines approved
- **after insert on notification:** trigger SSE event to NotificationService

## Flyway & Versioning

- **Location:** `/backend-core/src/main/resources/db/migration/`
- **Naming:** V{VERSION}__description.sql
- **Execution:** On startup if flyway.enabled=true (default)
- **Schema:** platform_v3 (isolated from flowable_v3)
- **Baseline:** V1 is base, no baseline-on-migrate rollback
- **Flowable Schema:** Auto-created by Flowable engine (separate transaction)

**Important:** If corrupted, manual `DELETE FROM flyway_schema_history WHERE version >= X;` required

## Flowable Schema (flowable_v3 schema)

**Not version-controlled via Flyway.** Auto-created by Flowable engine on first run.

Key tables:
- **act_re_deployment** - BPMN/DMN file uploads
- **act_re_procdef** - Process definitions (approval workflow)
- **act_ru_execution** - Running process instances
- **act_ru_task** - User tasks (approval tasks)
- **act_ru_variable** - Process variables (approval metadata, delegation info)
- **act_hi_procinst** - Historical process instances (audit trail)
- **act_hi_taskinst** - Historical task instances

## MyBatis Mappers & SQL

All SQL queries in XML: `/backend-core/src/main/resources/mapper/{domain}/`

Dynamic SQL via:
- `<if test="condition">` - conditional WHERE clauses
- `<foreach>` - batch operations
- `<choose>` - if-else logic (approve vs reject counts)
- `#{param}` - parameterized queries (SQL injection safe)

Example (Approval):
```sql
<!-- approval/ApprovalMapper.xml -->
<select id="selectByStatus" resultType="map">
  SELECT * FROM approval_request
  WHERE status = #{status}
    AND created_by = #{userId}
  ORDER BY created_at DESC
  LIMIT #{limit}
</select>
```

## Data Integrity & Consistency

1. **Transactions:** Service layer @Transactional (REQUIRED)
2. **Concurrency:** Optimistic locking (version column) on high-contention tables (approval_line)
3. **Audit:** AdminAuditAspect logs all inserts/updates (who, when, what)
4. **Soft Delete:** Users/depts marked status='inactive' (not physically deleted)
5. **Cascade Delete:** approval_line deleted if approval_request deleted

## Domain Statistics (30+ tables)

| Domain | Tables | Key Entities |
|--------|--------|--------------|
| admin | 2 | admin_audit, system_log |
| approval | 3 | approval_request, approval_line, approval_attachment |
| attendance | 2 | attendance, attendance_month |
| board | 3 | board, board_post, board_comment, board_attachment |
| calendar | 1 | calendar_event |
| code | 2 | common_code, common_code_detail |
| datalib | 2 | data_lib_folder, data_lib_file |
| i18n | 1 | i18n_label |
| leave | 3 | leave_request, leave_balance, leave_type |
| menu | 2 | menu, menu_permission |
| notification | 1 | notification |
| org | 4 | org, member, member_role, org_hierarchy |
| room | 2 | room, room_booking |
| ux | 3 | favorite, notify_pref, search_history |
| widget | 2 | widget, widget_config |
| worklog | 2 | work_report, work_report_item |

## Backup & Recovery Strategy

- **Backup Script:** `/scripts/backup.sh` (pg_dump → platform_v3_backup_YYYYMMDD.sql)
- **Restore Script:** `/scripts/restore.sh` (psql restore)
- **Frequency:** Daily (recommended) or on-demand
- **Encryption:** Backup file should be encrypted in production (age, gpg, etc.)
- **Point-in-Time:** WAL archiving (optional, depends on infrastructure)

**Approx database size:** ~100 MB (with test data)
