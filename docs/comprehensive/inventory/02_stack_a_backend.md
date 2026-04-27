# Stack A (Backend-Core) Inventory

**Location:** `/backend-core/src/main/java/com/platform/v3/core/`

## Core Architecture

- **Framework:** Spring Boot 3.2.5 + Spring Data + Spring Security (OAuth2 Resource Server)
- **Persistence:** MyBatis 3.0.4 + PostgreSQL 15+ + Flyway 10.10.0
- **Workflow:** Flowable 7.1.0 (BPMN + DMN)
- **Storage:** MinIO 8.5.7 (S3-compatible)
- **Cache:** Redis (optional, configured)
- **Port:** 19090 (configured)

## Service & Controller Inventory

### Controllers (4 total)

| File | Endpoint | Role |
|------|----------|------|
| `code/CodeController.java` | `/api/codes` | GET common codes (dropdown data) |
| `i18n/I18nController.java` | `/api/i18n/*` | GET/POST i18n labels (locale support) |
| `notification/NotificationController.java` | `/api/notifications` | GET notifications, SSE stream |
| `dataset/DataSetController.java` | `/api/dataset` | POST single entry point (DataSet pattern) |

### Services (21 total)

| Domain | Service | Primary Methods |
|--------|---------|-----------------|
| admin | AdminService | getAuditLogs(), getUserActivity() |
| approval | ApprovalService | submitApproval(), approveApproval(), rejectApproval(), getApprovalLine() |
| attendance | AttendanceService | checkIn(), checkOut(), getMonthlyAttendance() |
| board | BoardService | createPost(), updatePost(), deletePost(), getComments() |
| calendar | CalendarService | createEvent(), updateEvent(), getYearCalendar() |
| code | CodeService | getCodesByGroup() |
| datalib | DataLibraryService | createFolder(), uploadFile(), deleteFile(), getPresignedUrl() |
| dataset | DataSetService | invoke() [router pattern via ServiceRegistry] |
| i18n | I18nService | getLabel(), saveLabel() |
| leave | LeaveService | submitLeaveRequest(), getLeaveBalance(), calculateRemaining() |
| menu | MenuService | getMenuTreeByRole(), getMenuPermissions() |
| notification | NotificationService | notify(), getByUser(), markAsRead() |
| org | OrgService | getDeptTree(), getUsersByDept(), getHierarchy() |
| room | RoomService | createBooking(), cancelBooking(), getAvailableRooms() |
| ux | FavoriteService | addFavorite(), removeFavorite(), getFavorites() |
| ux | NotifyPrefService | updatePreferences() |
| ux | SearchService | search() |
| widget | WidgetService | getWidgetConfig() |
| worklog | WorkReportService | submitWorklog(), getTeamWorklog() |

### Flowable Delegates & Listeners (Approval Workflow)

| File | Type | Role |
|------|------|------|
| `approval/flowable/ApprovalAssigneeResolver.java` | AssigneeResolver | Dynamic task assignee resolution (delegation chain) |
| `approval/flowable/ApprovalCompleteDelegate.java` | ServiceTask Delegate | Final approval completion logic |
| `approval/flowable/ApprovalNotificationListener.java` | ExecutionListener | Notify approvers when task created |
| `approval/flowable/ApprovalProcessStartListener.java` | ExecutionListener | Initialize approval metadata |

### Mappers (MyBatis, XML-based) - 17 total

All mappers use XML-based queries. See resources/mapper/ directory.

## Flyway Migrations (17 versions, platform_v3 schema)

| Ver | Filename | Key Tables |
|-----|----------|-----------|
| V1 | V1__baseline.sql | user, dept, role, permission |
| V2 | V2__org_schema.sql | org, hierarchy, members |
| V3 | V3__common_code_notification.sql | common_code, notification |
| V4 | V4__board_calendar.sql | board, board_post, board_comment, calendar_event |
| V5 | V5__seed_data.sql | seed users, depts, codes |
| V6 | V6__menu_permission.sql | menu, role_permission |
| V7 | V7__seed_data.sql | extended seed |
| V8 | V8__approval_and_extras.sql | approval_request, approval_line |
| V9 | V9__i18n_labels_and_seed_data.sql | i18n_label |
| V10 | V10__attendance_leave.sql | attendance, leave_request, leave_balance |
| V11 | V11__room_booking.sql | room, room_booking |
| V12 | V12__data_library.sql | data_lib_folder, data_lib_file |
| V13 | V13__work_report.sql | work_report, work_report_item |
| V14 | V14__admin_audit.sql | admin_audit, system_audit |
| V15 | V15__ux_features.sql | favorite, notify_pref, search_history |
| V16 | V16__dashboard_widget.sql | widget, widget_config |
| V17 | V17__phase14_menus.sql | menu updates |

**Flowable:** Separate `flowable_v3` schema (auto-created)

## Domain Statistics

Total: 21 Services, 4 Controllers, 17 Mappers, 17 Flyway migrations across 16 domains

## Key Utilities

- `common/ApiResponse.java` - Standard REST wrapper
- `common/BffClient.java` - HTTP client to backend-bff
- `common/BusinessException.java` - Custom exception handling
- `config/MinioConfig.java`, `SecurityConfig.java` - Infrastructure
- `admin/AdminAuditAspect.java` - AOP audit logging
- `dataset/ServiceRegistry.java`, `DataSetServiceMapping.java` - DataSet router pattern

## Entry Points

- **POST /api/dataset** → DataSetController → ServiceRegistry dispatch
- **GET /api/codes, /api/i18n, /api/notifications** → specific controllers
- All JWT-protected via OAuth2 ResourceServer

**Approx size:** ~12 KB aggregate (56 Java files + SQL migrations)
