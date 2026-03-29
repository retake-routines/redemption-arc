package service

import (
	"context"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"golang.org/x/crypto/bcrypt"

	"habitpal-backend/internal/models"
	"habitpal-backend/internal/repository"
	"habitpal-backend/internal/repository/mocks"
)

const testJWTSecret = "test-secret-key-for-unit-tests"

func newTestAuthService(userRepo repository.UserRepository) *AuthService {
	return NewAuthService(userRepo, testJWTSecret, 24)
}

func TestRegister_Success(t *testing.T) {
	mockRepo := new(mocks.MockUserRepository)
	svc := newTestAuthService(mockRepo)

	req := models.RegisterRequest{
		Email:       "test@example.com",
		Password:    "password123",
		DisplayName: "Test User",
	}

	mockRepo.On("Create", mock.Anything, mock.AnythingOfType("*models.User")).
		Run(func(args mock.Arguments) {
			user := args.Get(1).(*models.User)
			user.ID = "generated-uuid"
			user.CreatedAt = time.Now()
			user.UpdatedAt = time.Now()
		}).
		Return(nil)

	resp, err := svc.Register(context.Background(), req)

	assert.NoError(t, err)
	assert.NotNil(t, resp)
	assert.NotEmpty(t, resp.Token)
	assert.Equal(t, "test@example.com", resp.User.Email)
	assert.Equal(t, "Test User", resp.User.DisplayName)
	assert.Equal(t, "generated-uuid", resp.User.ID)
	mockRepo.AssertExpectations(t)
}

func TestRegister_DuplicateEmail(t *testing.T) {
	mockRepo := new(mocks.MockUserRepository)
	svc := newTestAuthService(mockRepo)

	req := models.RegisterRequest{
		Email:       "existing@example.com",
		Password:    "password123",
		DisplayName: "Test User",
	}

	mockRepo.On("Create", mock.Anything, mock.AnythingOfType("*models.User")).
		Return(repository.ErrEmailTaken)

	resp, err := svc.Register(context.Background(), req)

	assert.Error(t, err)
	assert.Nil(t, resp)
	assert.ErrorIs(t, err, ErrEmailTaken)
	mockRepo.AssertExpectations(t)
}

func TestRegister_ValidationError(t *testing.T) {
	mockRepo := new(mocks.MockUserRepository)
	svc := newTestAuthService(mockRepo)

	req := models.RegisterRequest{
		Email:       "not-an-email",
		Password:    "password123",
		DisplayName: "Test User",
	}

	resp, err := svc.Register(context.Background(), req)

	assert.Error(t, err)
	assert.Nil(t, resp)
	assert.Contains(t, err.Error(), "validation")
	mockRepo.AssertNotCalled(t, "Create")
}

func TestLogin_Success(t *testing.T) {
	mockRepo := new(mocks.MockUserRepository)
	svc := newTestAuthService(mockRepo)

	hashedPw, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	user := &models.User{
		ID:           "user-123",
		Email:        "test@example.com",
		PasswordHash: string(hashedPw),
		DisplayName:  "Test User",
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	}

	mockRepo.On("GetByEmail", mock.Anything, "test@example.com").Return(user, nil)

	req := models.LoginRequest{
		Email:    "test@example.com",
		Password: "password123",
	}

	resp, err := svc.Login(context.Background(), req)

	assert.NoError(t, err)
	assert.NotNil(t, resp)
	assert.NotEmpty(t, resp.Token)
	assert.Equal(t, "user-123", resp.User.ID)
	assert.Equal(t, "test@example.com", resp.User.Email)
	mockRepo.AssertExpectations(t)
}

func TestLogin_WrongPassword(t *testing.T) {
	mockRepo := new(mocks.MockUserRepository)
	svc := newTestAuthService(mockRepo)

	hashedPw, _ := bcrypt.GenerateFromPassword([]byte("correct-password"), bcrypt.DefaultCost)
	user := &models.User{
		ID:           "user-123",
		Email:        "test@example.com",
		PasswordHash: string(hashedPw),
		DisplayName:  "Test User",
	}

	mockRepo.On("GetByEmail", mock.Anything, "test@example.com").Return(user, nil)

	req := models.LoginRequest{
		Email:    "test@example.com",
		Password: "wrong-password",
	}

	resp, err := svc.Login(context.Background(), req)

	assert.Error(t, err)
	assert.Nil(t, resp)
	assert.ErrorIs(t, err, ErrInvalidCredentials)
	mockRepo.AssertExpectations(t)
}

func TestLogin_UserNotFound(t *testing.T) {
	mockRepo := new(mocks.MockUserRepository)
	svc := newTestAuthService(mockRepo)

	mockRepo.On("GetByEmail", mock.Anything, "nonexistent@example.com").
		Return(nil, repository.ErrUserNotFound)

	req := models.LoginRequest{
		Email:    "nonexistent@example.com",
		Password: "password123",
	}

	resp, err := svc.Login(context.Background(), req)

	assert.Error(t, err)
	assert.Nil(t, resp)
	assert.ErrorIs(t, err, ErrInvalidCredentials)
	mockRepo.AssertExpectations(t)
}

func TestGenerateToken(t *testing.T) {
	mockRepo := new(mocks.MockUserRepository)
	svc := newTestAuthService(mockRepo)

	tokenStr, err := svc.GenerateToken("user-123")
	assert.NoError(t, err)
	assert.NotEmpty(t, tokenStr)

	// Parse the token and verify user_id claim
	token, err := jwt.Parse(tokenStr, func(token *jwt.Token) (interface{}, error) {
		return []byte(testJWTSecret), nil
	})
	assert.NoError(t, err)
	assert.True(t, token.Valid)

	claims, ok := token.Claims.(jwt.MapClaims)
	assert.True(t, ok)
	assert.Equal(t, "user-123", claims["user_id"])
}

func TestValidateToken_Valid(t *testing.T) {
	mockRepo := new(mocks.MockUserRepository)
	svc := newTestAuthService(mockRepo)

	tokenStr, err := svc.GenerateToken("user-456")
	assert.NoError(t, err)

	userID, err := svc.ValidateToken(tokenStr)
	assert.NoError(t, err)
	assert.Equal(t, "user-456", userID)
}

func TestValidateToken_Expired(t *testing.T) {
	svc := &AuthService{
		JWTSecret:       testJWTSecret,
		ExpirationHours: 24,
	}

	// Create a token that expired in the past
	claims := jwt.MapClaims{
		"user_id": "user-789",
		"exp":     time.Now().Add(-1 * time.Hour).Unix(),
		"iat":     time.Now().Add(-25 * time.Hour).Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenStr, err := token.SignedString([]byte(testJWTSecret))
	assert.NoError(t, err)

	userID, err := svc.ValidateToken(tokenStr)
	assert.Error(t, err)
	assert.Empty(t, userID)
	assert.Contains(t, err.Error(), "token")
}

func TestValidateToken_InvalidSignature(t *testing.T) {
	svc := &AuthService{
		JWTSecret:       testJWTSecret,
		ExpirationHours: 24,
	}

	// Create a token signed with a different secret
	claims := jwt.MapClaims{
		"user_id": "user-789",
		"exp":     time.Now().Add(1 * time.Hour).Unix(),
		"iat":     time.Now().Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenStr, err := token.SignedString([]byte("wrong-secret-key"))
	assert.NoError(t, err)

	userID, err := svc.ValidateToken(tokenStr)
	assert.Error(t, err)
	assert.Empty(t, userID)
}
