package handler

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"golang.org/x/crypto/bcrypt"

	"habitpal-backend/internal/models"
	"habitpal-backend/internal/repository"
	"habitpal-backend/internal/repository/mocks"
	"habitpal-backend/internal/service"
)

func init() {
	gin.SetMode(gin.TestMode)
}

func setupAuthHandler(mockUserRepo *mocks.MockUserRepository) (*AuthHandler, *gin.Engine) {
	authService := service.NewAuthService(mockUserRepo, "test-secret", 24)
	handler := NewAuthHandler(authService)
	router := gin.New()
	return handler, router
}

func TestHandleRegister_201(t *testing.T) {
	mockUserRepo := new(mocks.MockUserRepository)
	handler, router := setupAuthHandler(mockUserRepo)
	router.POST("/auth/register", handler.HandleRegister)

	mockUserRepo.On("Create", mock.Anything, mock.AnythingOfType("*models.User")).
		Run(func(args mock.Arguments) {
			user := args.Get(1).(*models.User)
			user.ID = "new-user-id"
			user.CreatedAt = time.Now()
			user.UpdatedAt = time.Now()
		}).
		Return(nil)

	body := `{"email":"test@example.com","password":"password123","display_name":"Test"}`
	req := httptest.NewRequest(http.MethodPost, "/auth/register", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusCreated, w.Code)

	var resp models.AuthResponse
	err := json.Unmarshal(w.Body.Bytes(), &resp)
	assert.NoError(t, err)
	assert.NotEmpty(t, resp.Token)
	assert.Equal(t, "test@example.com", resp.User.Email)
	mockUserRepo.AssertExpectations(t)
}

func TestHandleRegister_400_InvalidJSON(t *testing.T) {
	mockUserRepo := new(mocks.MockUserRepository)
	handler, router := setupAuthHandler(mockUserRepo)
	router.POST("/auth/register", handler.HandleRegister)

	req := httptest.NewRequest(http.MethodPost, "/auth/register", bytes.NewBufferString(`{invalid json`))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusBadRequest, w.Code)
	mockUserRepo.AssertNotCalled(t, "Create")
}

func TestHandleRegister_400_ValidationError(t *testing.T) {
	mockUserRepo := new(mocks.MockUserRepository)
	handler, router := setupAuthHandler(mockUserRepo)
	router.POST("/auth/register", handler.HandleRegister)

	// Missing email (empty string fails binding:"required")
	body := `{"password":"password123","display_name":"Test"}`
	req := httptest.NewRequest(http.MethodPost, "/auth/register", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusBadRequest, w.Code)
	mockUserRepo.AssertNotCalled(t, "Create")
}

func TestHandleRegister_409(t *testing.T) {
	mockUserRepo := new(mocks.MockUserRepository)
	handler, router := setupAuthHandler(mockUserRepo)
	router.POST("/auth/register", handler.HandleRegister)

	mockUserRepo.On("Create", mock.Anything, mock.AnythingOfType("*models.User")).
		Return(repository.ErrEmailTaken)

	body := `{"email":"taken@example.com","password":"password123","display_name":"Test"}`
	req := httptest.NewRequest(http.MethodPost, "/auth/register", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusConflict, w.Code)
	mockUserRepo.AssertExpectations(t)
}

func TestHandleLogin_200(t *testing.T) {
	mockUserRepo := new(mocks.MockUserRepository)
	handler, router := setupAuthHandler(mockUserRepo)
	router.POST("/auth/login", handler.HandleLogin)

	hashedPw, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	user := &models.User{
		ID:           "user-1",
		Email:        "test@example.com",
		PasswordHash: string(hashedPw),
		DisplayName:  "Test",
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	}

	mockUserRepo.On("GetByEmail", mock.Anything, "test@example.com").Return(user, nil)

	body := `{"email":"test@example.com","password":"password123"}`
	req := httptest.NewRequest(http.MethodPost, "/auth/login", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var resp models.AuthResponse
	err := json.Unmarshal(w.Body.Bytes(), &resp)
	assert.NoError(t, err)
	assert.NotEmpty(t, resp.Token)
	assert.Equal(t, "user-1", resp.User.ID)
	mockUserRepo.AssertExpectations(t)
}

func TestHandleLogin_401(t *testing.T) {
	mockUserRepo := new(mocks.MockUserRepository)
	handler, router := setupAuthHandler(mockUserRepo)
	router.POST("/auth/login", handler.HandleLogin)

	hashedPw, _ := bcrypt.GenerateFromPassword([]byte("correct-password"), bcrypt.DefaultCost)
	user := &models.User{
		ID:           "user-1",
		Email:        "test@example.com",
		PasswordHash: string(hashedPw),
		DisplayName:  "Test",
	}

	mockUserRepo.On("GetByEmail", mock.Anything, "test@example.com").Return(user, nil)

	body := `{"email":"test@example.com","password":"wrong-password"}`
	req := httptest.NewRequest(http.MethodPost, "/auth/login", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusUnauthorized, w.Code)
	mockUserRepo.AssertExpectations(t)
}

func TestHandleLogin_400(t *testing.T) {
	mockUserRepo := new(mocks.MockUserRepository)
	handler, router := setupAuthHandler(mockUserRepo)
	router.POST("/auth/login", handler.HandleLogin)

	req := httptest.NewRequest(http.MethodPost, "/auth/login", bytes.NewBufferString(`not json`))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusBadRequest, w.Code)
	mockUserRepo.AssertNotCalled(t, "GetByEmail")
}
