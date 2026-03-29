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

	"habitpal-backend/internal/models"
	"habitpal-backend/internal/repository"
	"habitpal-backend/internal/repository/mocks"
	"habitpal-backend/internal/service"
)

func setupHabitHandler(mockHabitRepo *mocks.MockHabitRepository) (*HabitHandler, *gin.Engine) {
	habitService := service.NewHabitService(mockHabitRepo)
	handler := NewHabitHandler(habitService)
	router := gin.New()
	return handler, router
}

// authMiddleware is a test helper that sets userID in gin context.
func authMiddleware(userID string) gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Set("userID", userID)
		c.Next()
	}
}

func TestHandleCreate_201(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	handler, router := setupHabitHandler(mockRepo)
	router.POST("/habits", authMiddleware("user-1"), handler.HandleCreate)

	mockRepo.On("Create", mock.Anything, mock.AnythingOfType("*models.Habit")).
		Run(func(args mock.Arguments) {
			h := args.Get(1).(*models.Habit)
			h.ID = "habit-new"
			h.CreatedAt = time.Now()
			h.UpdatedAt = time.Now()
		}).
		Return(nil)

	body := `{"title":"Exercise","description":"Gym","frequency_type":"daily","frequency_value":1}`
	req := httptest.NewRequest(http.MethodPost, "/habits", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusCreated, w.Code)

	var habit models.Habit
	err := json.Unmarshal(w.Body.Bytes(), &habit)
	assert.NoError(t, err)
	assert.Equal(t, "habit-new", habit.ID)
	assert.Equal(t, "Exercise", habit.Title)
	mockRepo.AssertExpectations(t)
}

func TestHandleCreate_400(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	handler, router := setupHabitHandler(mockRepo)
	router.POST("/habits", authMiddleware("user-1"), handler.HandleCreate)

	req := httptest.NewRequest(http.MethodPost, "/habits", bytes.NewBufferString(`{invalid`))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusBadRequest, w.Code)
	mockRepo.AssertNotCalled(t, "Create")
}

func TestHandleGetAll_200(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	handler, router := setupHabitHandler(mockRepo)
	router.GET("/habits", authMiddleware("user-1"), handler.HandleGetAll)

	habits := []models.Habit{
		{ID: "h1", UserID: "user-1", Title: "Exercise", FrequencyType: "daily", FrequencyValue: 1},
		{ID: "h2", UserID: "user-1", Title: "Read", FrequencyType: "weekly", FrequencyValue: 3},
	}

	mockRepo.On("GetByUserID", mock.Anything, "user-1").Return(habits, nil)

	req := httptest.NewRequest(http.MethodGet, "/habits", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var resp models.HabitListResponse
	err := json.Unmarshal(w.Body.Bytes(), &resp)
	assert.NoError(t, err)
	assert.Len(t, resp.Habits, 2)
	assert.Equal(t, 2, resp.Total)
	mockRepo.AssertExpectations(t)
}

func TestHandleGetByID_200(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	handler, router := setupHabitHandler(mockRepo)
	router.GET("/habits/:id", authMiddleware("user-1"), handler.HandleGetByID)

	habit := &models.Habit{
		ID:     "habit-1",
		UserID: "user-1",
		Title:  "Exercise",
	}

	mockRepo.On("GetByID", mock.Anything, "habit-1").Return(habit, nil)

	req := httptest.NewRequest(http.MethodGet, "/habits/habit-1", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var resp models.Habit
	err := json.Unmarshal(w.Body.Bytes(), &resp)
	assert.NoError(t, err)
	assert.Equal(t, "habit-1", resp.ID)
	mockRepo.AssertExpectations(t)
}

func TestHandleGetByID_404(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	handler, router := setupHabitHandler(mockRepo)
	router.GET("/habits/:id", authMiddleware("user-1"), handler.HandleGetByID)

	mockRepo.On("GetByID", mock.Anything, "nonexistent").
		Return(nil, repository.ErrHabitNotFound)

	req := httptest.NewRequest(http.MethodGet, "/habits/nonexistent", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusNotFound, w.Code)
	mockRepo.AssertExpectations(t)
}

func TestHandleUpdate_200(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	handler, router := setupHabitHandler(mockRepo)
	router.PUT("/habits/:id", authMiddleware("user-1"), handler.HandleUpdate)

	existingHabit := &models.Habit{
		ID:             "habit-1",
		UserID:         "user-1",
		Title:          "Exercise",
		Description:    "Old",
		FrequencyType:  "daily",
		FrequencyValue: 1,
	}

	mockRepo.On("GetByID", mock.Anything, "habit-1").Return(existingHabit, nil)
	mockRepo.On("Update", mock.Anything, mock.AnythingOfType("*models.Habit")).
		Run(func(args mock.Arguments) {
			h := args.Get(1).(*models.Habit)
			h.UpdatedAt = time.Now()
		}).
		Return(nil)

	body := `{"title":"Updated Exercise"}`
	req := httptest.NewRequest(http.MethodPut, "/habits/habit-1", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var resp models.Habit
	err := json.Unmarshal(w.Body.Bytes(), &resp)
	assert.NoError(t, err)
	assert.Equal(t, "Updated Exercise", resp.Title)
	mockRepo.AssertExpectations(t)
}

func TestHandleUpdate_404(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	handler, router := setupHabitHandler(mockRepo)
	router.PUT("/habits/:id", authMiddleware("user-1"), handler.HandleUpdate)

	mockRepo.On("GetByID", mock.Anything, "nonexistent").
		Return(nil, repository.ErrHabitNotFound)

	body := `{"title":"Updated"}`
	req := httptest.NewRequest(http.MethodPut, "/habits/nonexistent", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusNotFound, w.Code)
	mockRepo.AssertExpectations(t)
}

func TestHandleDelete_204(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	handler, router := setupHabitHandler(mockRepo)
	router.DELETE("/habits/:id", authMiddleware("user-1"), handler.HandleDelete)

	existingHabit := &models.Habit{
		ID:     "habit-1",
		UserID: "user-1",
		Title:  "Exercise",
	}

	mockRepo.On("GetByID", mock.Anything, "habit-1").Return(existingHabit, nil)
	mockRepo.On("Delete", mock.Anything, "habit-1").Return(nil)

	req := httptest.NewRequest(http.MethodDelete, "/habits/habit-1", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusNoContent, w.Code)
	mockRepo.AssertExpectations(t)
}

func TestHandleDelete_404(t *testing.T) {
	mockRepo := new(mocks.MockHabitRepository)
	handler, router := setupHabitHandler(mockRepo)
	router.DELETE("/habits/:id", authMiddleware("user-1"), handler.HandleDelete)

	mockRepo.On("GetByID", mock.Anything, "nonexistent").
		Return(nil, repository.ErrHabitNotFound)

	req := httptest.NewRequest(http.MethodDelete, "/habits/nonexistent", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusNotFound, w.Code)
	mockRepo.AssertExpectations(t)
}
