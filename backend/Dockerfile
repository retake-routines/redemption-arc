# Stage 1: Build
FROM golang:1.23-alpine AS builder

WORKDIR /app

# Install git (needed for some Go modules) and ca-certificates
RUN apk add --no-cache git ca-certificates

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o server ./cmd/server

# Stage 2: Runtime
FROM alpine:3.20

RUN apk add --no-cache ca-certificates curl \
    && addgroup -S appgroup \
    && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /app/server .
COPY --from=builder /app/migrations/ ./migrations/

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -so /dev/null -w '%{http_code}' http://localhost:8080/api/v1/habits | grep -q '401' || exit 1

CMD ["./server"]
