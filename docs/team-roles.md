# HabitPal -- Team Roles & Workflow

---

## 1. Role Descriptions

### Backend Lead

**Owner of:** `backend/` directory

**Responsibilities:**
- Design and implement all REST API endpoints (handlers, services, repositories)
- Define and maintain the PostgreSQL database schema and migrations
- Implement JWT authentication and authorization middleware
- Write Swagger/OpenAPI annotations for all endpoints
- Write unit tests for services and integration tests for handlers
- Review all backend-related pull requests
- Keep `docs/api.md` in sync with the actual implementation

### Frontend Lead

**Owner of:** `frontend/` directory

**Responsibilities:**
- Implement all Flutter screens and widgets following the feature-based architecture
- Set up and maintain Riverpod state management providers
- Integrate with the backend REST API using Dio
- Implement offline data persistence with SharedPreferences
- Build responsive layouts that work on mobile and web
- Implement light and dark theme support
- Write widget tests and unit tests for providers
- Review all frontend-related pull requests

### DevOps Engineer

**Owner of:** `docker-compose.yml`, `.github/`, `configs/`, `Dockerfile`

**Responsibilities:**
- Maintain Docker and Docker Compose configurations
- Set up and maintain the CI/CD pipeline (GitHub Actions)
- Configure environment variable management across environments
- Set up GitHub Pages deployment
- Ensure the build pipeline runs linting, tests, and builds for both backend and frontend
- Monitor build health and fix pipeline failures
- Manage secrets and environment configurations

### QA / Testing

**Shared responsibility across all directories**

**Responsibilities:**
- Define the testing strategy (unit, widget, integration, E2E)
- Write and maintain test suites for both backend and frontend
- Set up test coverage reporting in CI
- Perform manual testing of features before release
- Report bugs with clear reproduction steps
- Verify bug fixes before PR approval
- Maintain a test plan document for each feature

### UI/UX Designer

**Owner of:** Design assets, `frontend/lib/core/theme/`, wireframes

**Responsibilities:**
- Create wireframes and mockups for all screens
- Define the color palette, typography, and spacing system
- Design the app icon and branding assets
- Ensure accessibility standards are met (contrast ratios, touch target sizes)
- Provide design specifications to the Frontend Lead
- Review UI pull requests for design consistency
- Create screenshots and GIFs for documentation

---

## 2. Responsibility Matrix (RACI)

| Task | Backend Lead | Frontend Lead | DevOps | QA | UI/UX |
|------|:---:|:---:|:---:|:---:|:---:|
| API endpoint implementation | **R/A** | I | I | C | -- |
| Database schema design | **R/A** | I | I | C | -- |
| Flutter screen implementation | I | **R/A** | -- | C | **C** |
| State management | I | **R/A** | -- | C | -- |
| Docker configuration | C | C | **R/A** | I | -- |
| CI/CD pipeline | C | C | **R/A** | C | -- |
| Unit tests (backend) | **R/A** | -- | -- | **C** | -- |
| Widget tests (frontend) | -- | **R/A** | -- | **C** | -- |
| API documentation | **R/A** | C | I | I | -- |
| Architecture documentation | **R/A** | **C** | C | I | -- |
| UI/UX design | -- | C | -- | -- | **R/A** |
| Code review | **R** | **R** | **R** | **R** | I |
| Release management | C | C | **R/A** | **C** | -- |

**Legend:** R = Responsible, A = Accountable, C = Consulted, I = Informed

---

## 3. Git Branching Strategy

### Branch structure

```
main
 ├── feature/auth-login
 ├── feature/habits-crud
 ├── feature/completions-api
 ├── feature/statistics-screen
 ├── fix/streak-calculation
 └── chore/ci-pipeline
```

### Rules

1. **`master` is the stable branch.** It must always build and pass all tests.
2. **All work happens on feature branches.** Branch from `master`, merge back to `master`.
3. **Branch naming convention:** `type/short-description`
   - `feature/` -- new functionality
   - `fix/` -- bug fixes
   - `chore/` -- maintenance, CI, docs, refactoring
   - `hotfix/` -- urgent production fixes
4. **Never push directly to `master`.** All changes go through pull requests.
5. **Keep branches short-lived.** Aim to merge within 1-3 days to minimize conflicts.
6. **Rebase or merge from `master` regularly** to stay up to date.

### Branch lifecycle

```
1. git checkout main && git pull
2. git checkout -b feature/my-feature
3. ... make changes, commit ...
4. git push -u origin feature/my-feature
5. Open PR on GitHub
6. Pass CI checks + get 1 approval
7. Merge (squash or merge commit)
8. Delete the feature branch
```

---

## 4. Pull Request Policy

### Before opening a PR

- [ ] Code compiles without errors (`go build ./...` or `flutter analyze`)
- [ ] All existing tests pass (`go test ./...` or `flutter test`)
- [ ] New code has corresponding tests
- [ ] Code follows the project style guide
- [ ] API changes are reflected in `docs/api.md`

### PR template

```markdown
## What does this PR do?
Brief description of the change.

## Type
- [ ] Feature
- [ ] Bug fix
- [ ] Chore / Refactor
- [ ] Documentation

## Checklist
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No breaking API changes (or documented in description)
- [ ] Screenshots attached (for UI changes)

## How to test
Steps for the reviewer to verify the change.
```

### Review requirements

- **Minimum 1 approving review** required before merging.
- The reviewer should be someone familiar with the area of code being changed:
  - Backend changes: reviewed by Backend Lead or QA
  - Frontend changes: reviewed by Frontend Lead or UI/UX
  - DevOps changes: reviewed by DevOps or Backend Lead
- **CI must pass.** A PR with failing checks cannot be merged.
- **Address all review comments** before merging. Use "Resolve conversation" in GitHub.

### Review guidelines for reviewers

1. **Be constructive.** Suggest improvements, do not just criticize.
2. **Focus on:** correctness, readability, test coverage, performance, security.
3. **Approve promptly.** Aim to review within 24 hours of being requested.
4. **Use GitHub suggestions** for small fixes so the author can apply them in one click.
5. **Block only for real issues.** Style preferences that are not in the style guide are not blockers.

---

## 5. Commit Message Convention

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Format

```
type(scope): description

[optional body]

[optional footer]
```

### Types

| Type | When to use |
|------|------------|
| `feat` | A new feature for the user |
| `fix` | A bug fix |
| `docs` | Documentation-only changes |
| `style` | Code style changes (formatting, semicolons) that do not affect logic |
| `refactor` | Code restructuring without changing behavior |
| `test` | Adding or updating tests |
| `chore` | Build process, CI, dependency updates, tooling |
| `perf` | Performance improvements |

### Scopes

| Scope | Applies to |
|-------|-----------|
| `auth` | Authentication (login, register, JWT) |
| `habits` | Habit CRUD operations |
| `completions` | Habit completion tracking |
| `streak` | Streak calculation logic |
| `db` | Database schema, migrations |
| `api` | API routing, middleware |
| `ui` | Frontend screens and widgets |
| `state` | State management (Riverpod providers) |
| `theme` | Theming and styling |
| `l10n` | Localization |
| `ci` | CI/CD pipeline |
| `docker` | Docker configuration |
| `deps` | Dependency updates |

### Examples

```
feat(auth): add JWT-based login endpoint
fix(streak): handle edge case when habit has zero completions
docs(api): add curl examples for completion endpoints
test(habits): add unit tests for HabitService.Create
chore(ci): add flutter analyze step to GitHub Actions
refactor(ui): extract habit card into reusable widget
style(backend): run gofmt on all Go files
```

### Rules

1. **Use imperative mood** in the description: "add feature" not "added feature" or "adds feature".
2. **Keep the first line under 72 characters.**
3. **Do not end the description with a period.**
4. **Reference issue numbers** in the footer when applicable: `Closes #42`.
5. **Breaking changes** must include `BREAKING CHANGE:` in the footer or `!` after the type: `feat(api)!: change habit response format`.
