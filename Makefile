.PHONY: fmt lint test build run-backend run-frontend docker-up docker-down

# ---- Formatting ----

fmt:
	gofmt -w backend/
	cd frontend && dart format lib/ test/

# ---- Linting ----

lint:
	cd backend && golangci-lint run
	cd frontend && flutter analyze

# ---- Testing ----

test:
	cd backend && go test ./...
	cd frontend && flutter test

# ---- Building ----

build:
	cd backend && go build -o habitpal-server ./cmd/server/
	cd frontend && flutter build web

# ---- Running ----

run-backend:
	cd backend && go run ./cmd/server/

run-frontend:
	cd frontend && flutter run -d chrome

# ---- Docker ----

docker-up:
	docker-compose up --build

docker-down:
	docker-compose down -v
