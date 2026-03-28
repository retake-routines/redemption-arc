# CLAUDE.md -- Backend Agent Instructions

## Overview

This is the Go backend for HabitPal, a habit formation assistant. It exposes a REST API consumed by the Flutter frontend. The backend uses the Gin web framework, PostgreSQL for persistence, and JWT for authentication.

## Tech Stack

- **Language:** Go 1.23
- **Framework:** Gin (HTTP router and middleware)
- **Database driver:** pgx / pgxpool
- **Auth:** JWT (HS256) via `golang-jwt/jwt/v5`, bcrypt for password hashing
- **API docs:** Swagger via `swaggo/gin-swagger`
- **Module name:** `habitpal-backend` (see `go.mod`)

## Directory Structure

```
backend/
├── cmd/
│   └── server/
│       └── main.go              # Application entrypoint
├── internal/
│   ├── config/                  # Configuration loading from env vars
│   │   └── config.go
│   ├── handler/                 # HTTP request handlers
│   │   ├── auth_handler.go      # Register, Login
│   │   ├── habit_handler.go     # CRUD for habits
│   │   └── completion_handler.go # Complete, uncomplete, list, streak
│   ├── middleware/               # Gin middleware
│   │   ├── cors.go              # CORS headers
│   │   └── jwt.go               # JWT token validation
│   ├── models/                  # Data structures
│   │   ├── user.go              # User, UserDTO
│   │   ├── habit.go             # Habit, HabitCreateRequest, HabitUpdateRequest
│   │   └── completion.go        # HabitCompletion, Streak
│   ├── repository/              # Database access layer
│   │   ├── user_repository.go
│   │   ├── habit_repository.go
│   │   └── completion_repository.go
│   ├── router/                  # Route definitions
│   │   └── router.go
│   └── service/                 # Business logic layer
│       ├── auth_service.go      # Register, login, JWT generation
│       ├── habit_service.go     # Habit CRUD logic
│       └── streak_service.go    # Streak calculation
├── migrations/
│   └── 001_init.sql             # Initial schema (users, habits, habit_completions)
├── Dockerfile
├── go.mod
└── go.sum
```

## How to Add a New Endpoint

Follow these steps in order. Each step builds on the previous one.

### Step 1: Add or update the model

File: `internal/models/`

Define the data struct, any DTOs, and request/response types.

```go
// internal/models/example.go
type Example struct {
    ID        string    `json:"id" db:"id"`
    Name      string    `json:"name" db:"name"`
    CreatedAt time.Time `json:"created_at" db:"created_at"`
}

type ExampleCreateRequest struct {
    Name string `json:"name" binding:"required"`
}
```

### Step 2: Add the repository method

File: `internal/repository/`

Define the interface method and implement it.

```go
// In the repository interface
type ExampleRepository interface {
    Create(ctx context.Context, example *models.Example) error
    GetByID(ctx context.Context, id string) (*models.Example, error)
}

// In the PostgreSQL implementation
func (r *PostgresExampleRepository) Create(ctx context.Context, example *models.Example) error {
    _, err := r.pool.Exec(ctx,
        `INSERT INTO examples (id, name, created_at) VALUES ($1, $2, $3)`,
        example.ID, example.Name, example.CreatedAt)
    return err
}
```

### Step 3: Add the service method

File: `internal/service/`

Implement business logic that calls the repository.

```go
func (s *ExampleService) Create(ctx context.Context, req models.ExampleCreateRequest) (*models.Example, error) {
    example := &models.Example{
        ID:        uuid.NewString(),
        Name:      req.Name,
        CreatedAt: time.Now(),
    }
    if err := s.repo.Create(ctx, example); err != nil {
        return nil, fmt.Errorf("failed to create example: %w", err)
    }
    return example, nil
}
```

### Step 4: Add the handler

File: `internal/handler/`

Parse the HTTP request, call the service, write the response.

```go
func (h *ExampleHandler) HandleCreate(c *gin.Context) {
    var req models.ExampleCreateRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }
    example, err := h.service.Create(c.Request.Context(), req)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to create example"})
        return
    }
    c.JSON(http.StatusCreated, example)
}
```

### Step 5: Register the route

File: `internal/router/router.go`

Add the route to the appropriate group (public or protected).

```go
examples := protected.Group("/examples")
{
    examples.POST("", exampleHandler.HandleCreate)
}
```

### Step 6: Wire up in main.go

File: `cmd/server/main.go`

Instantiate the repository, service, and handler. Pass the handler to `SetupRouter`.

### Step 7: Update the API docs

File: `docs/api.md`

Document the new endpoint with request/response schemas and a curl example.

## How to Add a Database Migration

1. Create a new SQL file in `migrations/` with the next sequence number:
   ```
   migrations/002_add_reminders.sql
   ```

2. Write idempotent SQL (use `IF NOT EXISTS` where possible):
   ```sql
   CREATE TABLE IF NOT EXISTS reminders (
       id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
       habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
       remind_at TIME NOT NULL,
       created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
   );
   ```

3. Migrations are applied in numeric order. Never modify an existing migration that has been merged to `master`. Instead, create a new migration to alter the schema.

## Error Handling Conventions

1. **Wrap errors** with context using `fmt.Errorf("doing X: %w", err)` so the call chain is visible in logs.
2. **Return appropriate HTTP status codes** from handlers:
   - `400` for validation errors (bad JSON, missing fields)
   - `401` for authentication failures (bad token, wrong password)
   - `404` for resources not found
   - `409` for conflicts (duplicate email, duplicate completion)
   - `500` for unexpected internal errors
3. **Never expose internal error details** to the client. Log the full error server-side; return a generic message to the client.
4. **All error responses** use the format: `{"error": "message"}`.

## Testing Conventions

- **Framework:** Use `testify` for assertions and `testify/mock` or manual mocks for repository interfaces.
- **File naming:** Test files live alongside the code they test: `auth_service_test.go` next to `auth_service.go`.
- **Repository mocking:** Every repository is defined as an interface, making it straightforward to create mock implementations for service tests.
- **Handler testing:** Use `httptest.NewRecorder()` and Gin's test mode to test handlers without a live server.
- **Database tests:** For integration tests that need a real database, use a Docker test container or a dedicated test database. Tag these with `//go:build integration`.

```bash
# Run all unit tests
go test ./...

# Run with verbose output and coverage
go test -v -cover ./...

# Run a specific package
go test ./internal/service/...

# Run integration tests (requires database)
go test -tags=integration ./...
```

## Common Commands

```bash
# Run the server locally
go run ./cmd/server/

# Build the binary
go build -o habitpal-server ./cmd/server/

# Run all tests
go test ./...

# Lint / static analysis
go vet ./...

# Format code
gofmt -w .

# Tidy dependencies
go mod tidy

# View Swagger docs (server must be running)
open http://localhost:8080/swagger/index.html
```

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DATABASE_URL` | Yes | -- | PostgreSQL connection string, e.g. `postgres://user:pass@host:5432/db?sslmode=disable` |
| `JWT_SECRET` | Yes | -- | Secret key for signing JWT tokens (use a strong random string in production) |
| `JWT_EXPIRATION_HOURS` | No | `24` | How long JWT tokens are valid |
| `PORT` | No | `8080` | HTTP server listen port |

## Current State

The backend is scaffolded with compilable stubs. Key TODOs:
- Connect to PostgreSQL with `pgxpool` (currently passing `nil` pool)
- Implement actual SQL queries in repository methods
- Add Swagger annotations to all handler functions
- Add comprehensive test suite
- Implement proper error handling in all layers
