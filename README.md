# HabitPal - Habit Formation Assistant

[![Backend CI](../../actions/workflows/backend.yml/badge.svg)](../../actions/workflows/backend.yml)
[![Frontend CI](../../actions/workflows/frontend.yml/badge.svg)](../../actions/workflows/frontend.yml)
[![Deploy to GitHub Pages](../../actions/workflows/deploy.yml/badge.svg)](../../actions/workflows/deploy.yml)

HabitPal is a cross-platform habit tracking application that helps users build and maintain positive daily routines. Users can create habits with customizable frequencies, track completions, monitor streaks, and visualize their progress over time. The application features a Go backend with a RESTful API, a Flutter mobile/web frontend, and a PostgreSQL database, all orchestrated with Docker.

## Team Members

| Name | Role | Email |
|------|------|-------|
| TODO | Backend Lead | TODO@innopolis.university |
| TODO | Frontend Lead | TODO@innopolis.university |
| TODO | DevOps Engineer | TODO@innopolis.university |
| TODO | QA / Testing | TODO@innopolis.university |
| TODO | UI/UX Designer | TODO@innopolis.university |

## Tech Stack

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| Backend | Go + Gin | Go 1.23, Gin latest | REST API server |
| Frontend | Flutter + Riverpod | Flutter 3.x, Riverpod 2.6 | Cross-platform mobile & web UI |
| Database | PostgreSQL | 16 (Alpine) | Persistent data storage |
| Containerization | Docker & Docker Compose | Latest | Local development & deployment |
| CI/CD | GitHub Actions | N/A | Automated testing, linting, builds |
| Routing (frontend) | go_router | 14.8 | Declarative client-side navigation |
| HTTP Client | Dio | 5.7 | Frontend HTTP requests |
| Offline Storage | SharedPreferences | 2.3 | Local key-value persistence |
| API Docs | Swagger (swaggo) | latest | Interactive API documentation |

## Quick Start

### Prerequisites

- Docker & Docker Compose (v2)
- Flutter SDK 3.x
- Go 1.23+ (only needed if running the backend outside Docker)

### 1. Start the backend and database

```bash
docker compose up --build
```

This launches:
- **PostgreSQL 16** on port `5432` (user: `habitpal`, password: `habitpal_dev`, db: `habitpal`)
- **Go backend** on port `8080`

The backend waits for the database health check to pass before starting.

### 2. Run the Flutter frontend

```bash
cd frontend
flutter pub get
flutter run            # mobile emulator / device
flutter run -d chrome  # web browser
```

The app connects to the backend at `http://localhost:8080/api/v1`.

### 3. Access Swagger docs

Open [http://localhost:8080/swagger/index.html](http://localhost:8080/swagger/index.html) in your browser.

### 4. Stop everything

```bash
docker compose down        # stop containers
docker compose down -v     # stop and remove database volume
```

### Environment Configuration

Copy `configs/env.example` to `.env` in the backend directory and adjust values as needed. See [configs/env.example](configs/env.example) for all available variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8080` | Server listen port |
| `DATABASE_URL` | -- | PostgreSQL connection string |
| `JWT_SECRET` | -- | Secret for signing JWT tokens |
| `JWT_EXPIRATION_HOURS` | `24` | Token lifetime in hours |

## Architecture Overview

HabitPal follows a clean, layered architecture on both the backend and frontend. The **backend** is a Go REST API built with the Gin framework, structured into handlers (HTTP layer), services (business logic), and repositories (data access) that communicate with a PostgreSQL 16 database. Authentication is handled via JWT tokens issued at login and validated by middleware on protected routes. The **frontend** is a Flutter application using Riverpod for state management and go_router for navigation. It follows a feature-based directory structure where each feature (auth, habits, profile, statistics) is divided into data, domain, and presentation layers. The frontend communicates with the backend exclusively through the REST API, and supports offline persistence via SharedPreferences. Both frontend and backend are designed to be developed and tested independently, connected only by the API contract defined in `docs/api.md`.

## Documentation

- [Architecture & Design](docs/architecture.md) -- system diagrams, data flow, ER diagram, auth flow
- [API Reference](docs/api.md) -- full REST API contract with request/response schemas and curl examples
- [Team Roles & Workflow](docs/team-roles.md) -- roles, responsibilities, Git branching, PR policy

## Project Structure

```
flutter_course/
├── backend/                  # Go backend
│   ├── cmd/server/           # Application entrypoint
│   ├── internal/
│   │   ├── config/           # Configuration loading
│   │   ├── handler/          # HTTP request handlers
│   │   ├── middleware/       # JWT auth, CORS middleware
│   │   ├── models/           # Data models & DTOs
│   │   ├── repository/       # Database access layer
│   │   ├── router/           # Route definitions
│   │   └── service/          # Business logic
│   ├── migrations/           # SQL migration files
│   └── Dockerfile
├── frontend/                 # Flutter frontend
│   └── lib/
│       ├── core/
│       │   ├── l10n/         # Localization (EN, RU)
│       │   ├── network/      # API client (Dio)
│       │   ├── router/       # go_router configuration
│       │   ├── storage/      # SharedPreferences wrapper
│       │   └── theme/        # Light & dark theme
│       ├── features/
│       │   ├── auth/         # Login & registration
│       │   ├── habits/       # Habit CRUD & completion
│       │   ├── profile/      # User profile management
│       │   └── statistics/   # Streaks & progress charts
│       ├── shared/           # Shared widgets & utilities
│       ├── app.dart          # Root MaterialApp widget
│       └── main.dart         # Entry point
├── configs/                  # Environment config files
├── docs/                     # Project documentation
├── .github/workflows/        # CI/CD pipelines
├── docker-compose.yml        # Docker orchestration
└── CLAUDE.md                 # AI agent instructions (root)
```

## Build & Test Commands

### Backend

```bash
cd backend
go build ./...          # Compile
go vet ./...            # Static analysis
go test -v -cover ./... # Run tests with coverage
go run ./cmd/server/    # Run locally
```

### Frontend

```bash
cd frontend
flutter analyze         # Lint
flutter test --coverage # Run tests with coverage
flutter run -d chrome   # Run on web
flutter build web       # Build web release
flutter build apk       # Build Android APK
```

### Docker

```bash
docker compose up --build   # Start backend + database
docker compose down -v      # Stop and remove volumes
docker compose logs -f      # Follow container logs
```

## Implementation Checklist

### Technical requirements (20 points)
#### Backend development (8 points)
- [ ] Go-based microservices architecture (minimum 3 services) (3 points)
- [ ] RESTful API with Swagger documentation (1 point)
- [ ] gRPC implementation for communication between microservices (1 point)
- [ ] PostgreSQL database with proper schema design (1 point)
- [ ] JWT-based authentication and authorization (1 point)
- [ ] Comprehensive unit and integration tests (1 point)

#### Frontend development (8 points)
- [ ] Flutter-based cross-platform application (mobile + web) (3 points)
- [ ] Responsive UI design with custom widgets (1 point)
- [ ] State management implementation (1 point)
- [ ] Offline data persistence (1 point)
- [ ] Unit and widget tests (1 point)
- [ ] Support light and dark mode (1 point)

#### DevOps & deployment (4 points)
- [ ] Docker compose for all services (1 point)
- [ ] CI/CD pipeline implementation (1 point)
- [ ] Environment configuration management using config files (1 point)
- [ ] GitHub pages for the project (1 point)

### Non-Technical Requirements (10 points)
#### Project management (4 points)
- [ ] GitHub organization with well-maintained repository (1 point)
- [ ] Regular commits and meaningful pull requests from all team members (1 point)
- [ ] Project board (GitHub Projects) with task tracking (1 point)
- [ ] Team member roles and responsibilities documentation (1 point)

#### Documentation (4 points)
- [ ] Project overview and setup instructions (1 point)
- [ ] Screenshots and GIFs of key features (1 point)
- [ ] API documentation (1 point)
- [ ] Architecture diagrams and explanations (1 point)

#### Code quality (2 points)
- [ ] Consistent code style and formatting during CI/CD pipeline (1 point)
- [ ] Code review participation and resolution (1 point)

### Bonus Features (up to 10 points)
- [ ] Localization for Russian (RU) and English (ENG) languages (2 points)
- [ ] Good UI/UX design (up to 3 points)
- [ ] Integration with external APIs (fitness trackers, health devices) (up to 5 points)
- [ ] Comprehensive error handling and user feedback (up to 2 points)
- [ ] Advanced animations and transitions (up to 3 points)
- [ ] Widget implementation for native mobile elements (up to 2 points)

Total points implemented: XX/30 (excluding bonus points)

Note: For each implemented feature, provide a brief description or link to the relevant implementation below the checklist.

## License

This project was created as part of the Innopolis University Flutter Course.
