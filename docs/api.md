# HabitPal -- REST API Reference

Base URL: `http://localhost:8080/api/v1`

Swagger UI (when running): [http://localhost:8080/swagger/index.html](http://localhost:8080/swagger/index.html)

---

## Table of Contents

1. [General Information](#1-general-information)
2. [Authentication](#2-authentication)
   - [Register](#21-register)
   - [Login](#22-login)
3. [Habits](#3-habits)
   - [Create Habit](#31-create-habit)
   - [List Habits](#32-list-habits)
   - [Get Habit by ID](#33-get-habit-by-id)
   - [Update Habit](#34-update-habit)
   - [Delete Habit](#35-delete-habit)
4. [Completions](#4-completions)
   - [Complete a Habit](#41-complete-a-habit)
   - [Uncomplete (Delete Completion)](#42-uncomplete-delete-completion)
   - [List Completions](#43-list-completions)
   - [Get Streak](#44-get-streak)
5. [Error Handling](#5-error-handling)
6. [Pagination](#6-pagination)

---

## 1. General Information

### Authentication

All endpoints under `/api/v1/habits` and `/api/v1/completions` require a valid JWT token. Include it in the `Authorization` header:

```
Authorization: Bearer <token>
```

Tokens are obtained from the `/auth/register` or `/auth/login` endpoints.

### Content Type

All request and response bodies use `application/json`.

### Error Response Format

Every error response follows this shape:

```json
{
  "error": "Human-readable error message"
}
```

---

## 2. Authentication

### 2.1 Register

Create a new user account and receive a JWT token.

**Endpoint:** `POST /api/v1/auth/register`

**Auth required:** No

**Request body:**

```json
{
  "email": "user@example.com",
  "password": "securepassword123",
  "display_name": "John Doe"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes | Valid email address. Must be unique across all users. |
| `password` | string | Yes | Minimum 6 characters. |
| `display_name` | string | Yes | User's display name. |

**Response:** `201 Created`

```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "email": "user@example.com",
    "display_name": "John Doe",
    "created_at": "2026-03-23T12:00:00Z",
    "updated_at": "2026-03-23T12:00:00Z"
  }
}
```

**Error responses:**

| Status | Condition |
|--------|-----------|
| `400 Bad Request` | Missing or invalid fields |
| `409 Conflict` | Email already registered |

**curl example:**

```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "securepassword123",
    "display_name": "John Doe"
  }'
```

---

### 2.2 Login

Authenticate an existing user and receive a JWT token.

**Endpoint:** `POST /api/v1/auth/login`

**Auth required:** No

**Request body:**

```json
{
  "email": "user@example.com",
  "password": "securepassword123"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes | Registered email address. |
| `password` | string | Yes | Account password. |

**Response:** `200 OK`

```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "email": "user@example.com",
    "display_name": "John Doe",
    "created_at": "2026-03-23T12:00:00Z",
    "updated_at": "2026-03-23T12:00:00Z"
  }
}
```

**Error responses:**

| Status | Condition |
|--------|-----------|
| `400 Bad Request` | Missing or invalid fields |
| `401 Unauthorized` | Wrong email or password |

**curl example:**

```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "securepassword123"
  }'
```

---

## 3. Habits

All habit endpoints require authentication.

### 3.1 Create Habit

**Endpoint:** `POST /api/v1/habits`

**Auth required:** Yes

**Request body:**

```json
{
  "title": "Morning Meditation",
  "description": "10 minutes of guided meditation after waking up",
  "icon": "self_improvement",
  "color": "#4CAF50",
  "frequency_type": "daily",
  "frequency_value": 1
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | Yes | Habit name (max 255 chars). |
| `description` | string | No | Detailed description. Defaults to `""`. |
| `icon` | string | No | Material icon name. Defaults to `""`. |
| `color` | string | No | Hex color code. Defaults to `""`. |
| `frequency_type` | string | Yes | `"daily"` or `"weekly"`. |
| `frequency_value` | integer | Yes | How many times per period (e.g., 1 = once daily). |

**Response:** `201 Created`

```json
{
  "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "title": "Morning Meditation",
  "description": "10 minutes of guided meditation after waking up",
  "icon": "self_improvement",
  "color": "#4CAF50",
  "frequency_type": "daily",
  "frequency_value": 1,
  "is_archived": false,
  "created_at": "2026-03-23T12:00:00Z",
  "updated_at": "2026-03-23T12:00:00Z"
}
```

**Error responses:**

| Status | Condition |
|--------|-----------|
| `400 Bad Request` | Missing required fields or invalid frequency_type |
| `401 Unauthorized` | Missing or invalid token |

**curl example:**

```bash
curl -X POST http://localhost:8080/api/v1/habits \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "title": "Morning Meditation",
    "description": "10 minutes of guided meditation",
    "icon": "self_improvement",
    "color": "#4CAF50",
    "frequency_type": "daily",
    "frequency_value": 1
  }'
```

---

### 3.2 List Habits

Get all habits for the authenticated user.

**Endpoint:** `GET /api/v1/habits`

**Auth required:** Yes

**Query parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | integer | `1` | Page number (1-based). |
| `limit` | integer | `20` | Items per page (max 100). |

**Response:** `200 OK`

```json
{
  "habits": [
    {
      "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
      "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "title": "Morning Meditation",
      "description": "10 minutes of guided meditation",
      "icon": "self_improvement",
      "color": "#4CAF50",
      "frequency_type": "daily",
      "frequency_value": 1,
      "is_archived": false,
      "created_at": "2026-03-23T12:00:00Z",
      "updated_at": "2026-03-23T12:00:00Z"
    }
  ],
  "total": 1,
  "page": 1,
  "limit": 20
}
```

**curl example:**

```bash
curl -X GET "http://localhost:8080/api/v1/habits?page=1&limit=20" \
  -H "Authorization: Bearer <token>"
```

---

### 3.3 Get Habit by ID

**Endpoint:** `GET /api/v1/habits/:id`

**Auth required:** Yes

**Path parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | UUID | Habit ID. |

**Response:** `200 OK`

```json
{
  "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "title": "Morning Meditation",
  "description": "10 minutes of guided meditation",
  "icon": "self_improvement",
  "color": "#4CAF50",
  "frequency_type": "daily",
  "frequency_value": 1,
  "is_archived": false,
  "created_at": "2026-03-23T12:00:00Z",
  "updated_at": "2026-03-23T12:00:00Z"
}
```

**Error responses:**

| Status | Condition |
|--------|-----------|
| `401 Unauthorized` | Missing or invalid token |
| `404 Not Found` | Habit does not exist or belongs to another user |

**curl example:**

```bash
curl -X GET http://localhost:8080/api/v1/habits/f47ac10b-58cc-4372-a567-0e02b2c3d479 \
  -H "Authorization: Bearer <token>"
```

---

### 3.4 Update Habit

Partially update a habit. Only include the fields you want to change.

**Endpoint:** `PUT /api/v1/habits/:id`

**Auth required:** Yes

**Path parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | UUID | Habit ID. |

**Request body (all fields optional):**

```json
{
  "title": "Evening Meditation",
  "description": "15 minutes before bed",
  "icon": "bedtime",
  "color": "#9C27B0",
  "frequency_type": "daily",
  "frequency_value": 1,
  "is_archived": false
}
```

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | New habit name. |
| `description` | string | New description. |
| `icon` | string | New icon name. |
| `color` | string | New hex color. |
| `frequency_type` | string | `"daily"` or `"weekly"`. |
| `frequency_value` | integer | New frequency value. |
| `is_archived` | boolean | Archive or unarchive the habit. |

**Response:** `200 OK`

Returns the full updated habit object (same schema as Create response).

**Error responses:**

| Status | Condition |
|--------|-----------|
| `400 Bad Request` | Invalid field values |
| `401 Unauthorized` | Missing or invalid token |
| `404 Not Found` | Habit not found or not owned by user |

**curl example:**

```bash
curl -X PUT http://localhost:8080/api/v1/habits/f47ac10b-58cc-4372-a567-0e02b2c3d479 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "title": "Evening Meditation",
    "is_archived": false
  }'
```

---

### 3.5 Delete Habit

Permanently delete a habit and all its completions (cascading delete).

**Endpoint:** `DELETE /api/v1/habits/:id`

**Auth required:** Yes

**Path parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | UUID | Habit ID. |

**Response:** `204 No Content`

No response body.

**Error responses:**

| Status | Condition |
|--------|-----------|
| `401 Unauthorized` | Missing or invalid token |
| `404 Not Found` | Habit not found or not owned by user |

**curl example:**

```bash
curl -X DELETE http://localhost:8080/api/v1/habits/f47ac10b-58cc-4372-a567-0e02b2c3d479 \
  -H "Authorization: Bearer <token>"
```

---

## 4. Completions

All completion endpoints require authentication.

### 4.1 Complete a Habit

Record a completion for a habit.

**Endpoint:** `POST /api/v1/completions`

**Auth required:** Yes

**Request body:**

```json
{
  "habit_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "note": "Felt very calm afterwards"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `habit_id` | UUID | Yes | The habit being completed. |
| `note` | string | No | Optional note about this completion. |

**Response:** `201 Created`

```json
{
  "id": "c3d4e5f6-a7b8-9012-cdef-345678901234",
  "habit_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "completed_at": "2026-03-23T08:30:00Z",
  "note": "Felt very calm afterwards"
}
```

**Error responses:**

| Status | Condition |
|--------|-----------|
| `400 Bad Request` | Missing habit_id or invalid data |
| `401 Unauthorized` | Missing or invalid token |
| `409 Conflict` | Habit already completed at this timestamp (unique constraint) |

**curl example:**

```bash
curl -X POST http://localhost:8080/api/v1/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "habit_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "note": "Felt very calm afterwards"
  }'
```

---

### 4.2 Uncomplete (Delete Completion)

Remove a previously recorded completion.

**Endpoint:** `DELETE /api/v1/completions/:id`

**Auth required:** Yes

**Path parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | UUID | Completion ID. |

**Response:** `204 No Content`

No response body.

**Error responses:**

| Status | Condition |
|--------|-----------|
| `401 Unauthorized` | Missing or invalid token |
| `404 Not Found` | Completion not found or not owned by user |

**curl example:**

```bash
curl -X DELETE http://localhost:8080/api/v1/completions/c3d4e5f6-a7b8-9012-cdef-345678901234 \
  -H "Authorization: Bearer <token>"
```

---

### 4.3 List Completions

Get completions, optionally filtered by habit.

**Endpoint:** `GET /api/v1/completions`

**Auth required:** Yes

**Query parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `habit_id` | UUID | (none) | Filter completions by habit. If omitted, returns all user completions. |
| `page` | integer | `1` | Page number. |
| `limit` | integer | `20` | Items per page (max 100). |

**Response:** `200 OK`

```json
{
  "completions": [
    {
      "id": "c3d4e5f6-a7b8-9012-cdef-345678901234",
      "habit_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
      "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "completed_at": "2026-03-23T08:30:00Z",
      "note": "Felt very calm afterwards"
    }
  ],
  "total": 1,
  "page": 1,
  "limit": 20
}
```

**curl example:**

```bash
# All completions for the user
curl -X GET "http://localhost:8080/api/v1/completions?page=1&limit=20" \
  -H "Authorization: Bearer <token>"

# Completions for a specific habit
curl -X GET "http://localhost:8080/api/v1/completions?habit_id=f47ac10b-58cc-4372-a567-0e02b2c3d479&page=1&limit=50" \
  -H "Authorization: Bearer <token>"
```

---

### 4.4 Get Streak

Get the current and longest streak for a specific habit.

**Endpoint:** `GET /api/v1/completions/streak/:habitId`

**Auth required:** Yes

**Path parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `habitId` | UUID | Habit ID to calculate streak for. |

**Response:** `200 OK`

```json
{
  "habit_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "current_streak": 7,
  "longest_streak": 14,
  "last_completed_at": "2026-03-23T08:30:00Z"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `habit_id` | UUID | The habit this streak applies to. |
| `current_streak` | integer | Consecutive days/weeks the habit has been completed without a gap. |
| `longest_streak` | integer | All-time best streak for this habit. |
| `last_completed_at` | string (ISO 8601) or null | Timestamp of the most recent completion, or `null` if never completed. |

**curl example:**

```bash
curl -X GET http://localhost:8080/api/v1/completions/streak/f47ac10b-58cc-4372-a567-0e02b2c3d479 \
  -H "Authorization: Bearer <token>"
```

---

## 5. Error Handling

All errors return a JSON body with a single `error` field:

```json
{
  "error": "description of what went wrong"
}
```

### Common HTTP status codes

| Status | Meaning | When it occurs |
|--------|---------|----------------|
| `200` | OK | Successful read or update |
| `201` | Created | Successful resource creation |
| `204` | No Content | Successful deletion |
| `400` | Bad Request | Malformed JSON, missing required fields, invalid values |
| `401` | Unauthorized | Missing `Authorization` header, expired or invalid JWT |
| `404` | Not Found | Resource does not exist or is not owned by the requesting user |
| `409` | Conflict | Unique constraint violation (duplicate email, duplicate completion) |
| `500` | Internal Server Error | Unexpected server-side failure |

---

## 6. Pagination

Endpoints that return lists support pagination via query parameters:

| Parameter | Type | Default | Max | Description |
|-----------|------|---------|-----|-------------|
| `page` | integer | `1` | -- | 1-based page number |
| `limit` | integer | `20` | `100` | Number of items per page |

Paginated responses include metadata:

```json
{
  "items": [...],
  "total": 42,
  "page": 2,
  "limit": 20
}
```

- `total`: Total number of items matching the query (across all pages).
- `page`: The current page number.
- `limit`: The page size used.

To iterate through all pages:

```bash
# Page 1
curl "http://localhost:8080/api/v1/habits?page=1&limit=20" -H "Authorization: Bearer <token>"
# Page 2
curl "http://localhost:8080/api/v1/habits?page=2&limit=20" -H "Authorization: Bearer <token>"
# Continue until returned items count < limit
```
