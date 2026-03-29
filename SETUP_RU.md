# Инструкция по запуску HabitPal

## Требования

- Docker Desktop (для бэкенда и базы данных)
- Flutter SDK 3.x (для фронтенда)
- Xcode (для запуска на iOS/macOS)

---

## 1. Запуск бэкенда

Бэкенд состоит из 4 микросервисов + PostgreSQL, все запускаются через Docker Compose.

```bash
cd flutter_course
docker compose up --build
```

После запуска будут доступны:
- **API Gateway:** http://localhost:8080
- **Swagger UI:** http://localhost:8080/swagger/index.html
- **PostgreSQL:** localhost:5432 (user: `habitpal`, password: `habitpal_dev`, db: `habitpal`)

Миграции выполняются автоматически при запуске auth-service.

Для остановки:
```bash
docker compose down      # остановить
docker compose down -v   # остановить и удалить данные БД
```

---

## 2. Настройка фронтенда

### Важно: настройка base URL

Перед запуском нужно изменить base URL в файле `frontend/lib/core/network/api_endpoints.dart`:

**Для macOS / iOS Simulator:**
```dart
static const String baseUrl = 'http://localhost:8080/api/v1';
```

**Для физического iOS-устройства (подключено к тому же Wi-Fi):**
```dart
// Замените на IP вашего Mac в локальной сети
static const String baseUrl = 'http://192.168.x.x:8080/api/v1';
```

> IP можно узнать: Системные настройки → Wi-Fi → Подробнее → IP-адрес

### Запуск на macOS

```bash
cd frontend
flutter pub get
flutter run -d macos
```

### Запуск на iOS Simulator

```bash
cd frontend
flutter pub get
flutter run -d ios
```

> Для физического iOS-устройства нужна настройка подписи в Xcode:
> Открыть `frontend/ios/Runner.xcworkspace` → Runner → Signing & Capabilities → выбрать свой Team.

### Запуск в браузере (Chrome)

```bash
cd frontend
flutter run -d chrome
```

---

## 3. Экраны приложения

### Авторизация

| Экран | Маршрут | Описание |
|-------|---------|----------|
| **Login** | `/login` | Вход по email + пароль |
| **Register** | `/register` | Регистрация: имя, email, пароль, подтверждение пароля |

### Основные экраны (требуют авторизации)

| Экран | Маршрут | Описание |
|-------|---------|----------|
| **Habits** | `/habits` | Список привычек с карточками, кнопка "+" для создания новой |
| **Habit Detail** | `/habits/:id` | Детали привычки: стрик, календарь, кнопка выполнения |
| **Statistics** | `/statistics` | Статистика: всего привычек, лучший стрик, процент выполнения |
| **Profile** | `/profile` | Профиль: темная тема, язык (EN/RU), выход из аккаунта |

Навигация между основными экранами — через нижнюю панель (BottomNavigationBar).

---

## 4. Как пройти авторизацию локально

### Вариант 1: Через UI приложения

1. Запустите бэкенд (`docker compose up --build`)
2. Запустите фронтенд (`flutter run`)
3. На экране Login нажмите "Don't have an account? Register"
4. Заполните форму: имя, email (любой, например `test@test.com`), пароль (мин. 6 символов)
5. Нажмите Register — вы будете автоматически авторизованы

### Вариант 2: Через curl (для тестирования API)

**Регистрация:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "test@test.com", "password": "123456", "display_name": "Test User"}'
```

Ответ будет содержать JWT-токен:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": { "id": "...", "email": "test@test.com", "display_name": "Test User" }
}
```

**Вход:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "test@test.com", "password": "123456"}'
```

**Использование токена для защищенных запросов:**
```bash
curl http://localhost:8080/api/v1/habits \
  -H "Authorization: Bearer <ваш_токен>"
```

---

## 5. Полезные команды

```bash
# Пересборка бэкенда после изменений
docker compose up --build

# Просмотр логов
docker compose logs -f

# Логи конкретного сервиса
docker compose logs -f auth-service

# Запуск линтера
cd frontend && flutter analyze
cd backend && golangci-lint run

# Запуск тестов
cd frontend && flutter test          # 146 тестов
cd backend && go test ./internal/... # 50 тестов

# Форматирование кода
make fmt
```

---

## 6. Возможные проблемы

| Проблема | Решение |
|----------|---------|
| `Connection refused` на iOS | Проверьте base URL — для iOS Simulator используйте `localhost`, для физического устройства — IP Mac |
| Docker не запускается | Убедитесь, что Docker Desktop запущен и имеет достаточно ресурсов |
| `flutter run` ошибка на macOS | Выполните `flutter doctor` и установите недостающие зависимости |
| БД не инициализирована | Удалите volume: `docker compose down -v && docker compose up --build` |
| Порт 8080 занят | Остановите другой процесс на порту или измените PORT в docker-compose.yml |
