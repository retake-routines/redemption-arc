# Stage 1: Build
FROM golang:1.23-alpine AS builder

WORKDIR /app

# Install git (needed for some Go modules) and ca-certificates
RUN apk add --no-cache git ca-certificates

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Build all four binaries
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app/auth-service ./cmd/auth-service/
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app/habit-service ./cmd/habit-service/
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app/completion-service ./cmd/completion-service/
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app/gateway ./cmd/gateway/

# Also build the legacy monolithic server for backward compatibility
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app/server ./cmd/server/

# Stage 2: Runtime
FROM alpine:3.20

RUN apk add --no-cache ca-certificates curl \
    && addgroup -S appgroup \
    && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /app/auth-service .
COPY --from=builder /app/habit-service .
COPY --from=builder /app/completion-service .
COPY --from=builder /app/gateway .
COPY --from=builder /app/server .
COPY --from=builder /app/migrations/ ./migrations/

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8080 8081 8082 8083 9091

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -sf http://localhost:${HEALTHCHECK_PORT:-8080}/api/v1/auth/login -o /dev/null -w '%{http_code}' | grep -qE '(400|405)' || exit 1

CMD ["./server"]
