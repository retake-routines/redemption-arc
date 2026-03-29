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

func setupCompletionHandler(
	mockCompRepo *mocks.MockCompletionRepository,
	mockHabitRepo *mocks.MockHabitRepository,
) (*CompletionHandler, *gin.Engine) {
	streakService := service.NewStreakService(mockCompRepo)
	if mockHabitRepo != nil {
		streakService.SetHabitRepo(mockHabitRepo)
	}
	handler := NewCompletionHandler(mockCompRepo, streakService)
	router := gin.New()
	return handler, router
}

func TestHandleComplete_201(t *testing.T) {
	mockCompRepo := new(mocks.MockCompletionRepository)
	mockHabitRepo := new(mocks.MockHabitRepository)
	handler, router := setupCompletionHandler(mockCompRepo, mockHabitRepo)
	router.POST("/completions", authMiddleware("user-1"), handler.HandleComplete)

	habit := &models.Habit{
		ID:     "habit-1",
		UserID: "user-1",
	}

	mockHabitRepo.On("GetByID", mock.Anything, "habit-1").Return(habit, nil)
	mockCompRepo.On("Create", mock.Anything, mock.AnythingOfType("*models.HabitCompletion")).
		Run(func(args mock.Arguments) {
			comp := args.Get(1).(*models.HabitCompletion)
			comp.ID = "comp-new"
			comp.CompletedAt = time.Now()
		}).
		Return(nil)

	body := `{"habit_id":"habit-1","note":"Done!"}`
	req := httptest.NewRequest(http.MethodPost, "/completions", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusCreated, w.Code)

	var comp models.HabitCompletion
	err := json.Unmarshal(w.Body.Bytes(), &comp)
	assert.NoError(t, err)
	assert.Equal(t, "comp-new", comp.ID)
	assert.Equal(t, "habit-1", comp.HabitID)
	mockCompRepo.AssertExpectations(t)
	mockHabitRepo.AssertExpectations(t)
}

func TestHandleComplete_409(t *testing.T) {
	mockCompRepo := new(mocks.MockCompletionRepository)
	mockHabitRepo := new(mocks.MockHabitRepository)
	handler, router := setupCompletionHandler(mockCompRepo, mockHabitRepo)
	router.POST("/completions", authMiddleware("user-1"), handler.HandleComplete)

	habit := &models.Habit{
		ID:     "habit-1",
		UserID: "user-1",
	}

	mockHabitRepo.On("GetByID", mock.Anything, "habit-1").Return(habit, nil)
	mockCompRepo.On("Create", mock.Anything, mock.AnythingOfType("*models.HabitCompletion")).
		Return(repository.ErrDuplicateCompletion)

	body := `{"habit_id":"habit-1"}`
	req := httptest.NewRequest(http.MethodPost, "/completions", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusConflict, w.Code)
	mockCompRepo.AssertExpectations(t)
	mockHabitRepo.AssertExpectations(t)
}

func TestHandleUncomplete_204(t *testing.T) {
	mockCompRepo := new(mocks.MockCompletionRepository)
	handler, router := setupCompletionHandler(mockCompRepo, nil)
	router.DELETE("/completions/:id", authMiddleware("user-1"), handler.HandleUncomplete)

	completion := &models.HabitCompletion{
		ID:      "comp-1",
		HabitID: "habit-1",
		UserID:  "user-1",
	}

	mockCompRepo.On("GetByID", mock.Anything, "comp-1").Return(completion, nil)
	mockCompRepo.On("Delete", mock.Anything, "comp-1").Return(nil)

	req := httptest.NewRequest(http.MethodDelete, "/completions/comp-1", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusNoContent, w.Code)
	mockCompRepo.AssertExpectations(t)
}

func TestHandleUncomplete_404(t *testing.T) {
	mockCompRepo := new(mocks.MockCompletionRepository)
	handler, router := setupCompletionHandler(mockCompRepo, nil)
	router.DELETE("/completions/:id", authMiddleware("user-1"), handler.HandleUncomplete)

	mockCompRepo.On("GetByID", mock.Anything, "nonexistent").
		Return(nil, repository.ErrCompletionNotFound)

	req := httptest.NewRequest(http.MethodDelete, "/completions/nonexistent", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusNotFound, w.Code)
	mockCompRepo.AssertExpectations(t)
}

func TestHandleGetCompletions_200(t *testing.T) {
	mockCompRepo := new(mocks.MockCompletionRepository)
	handler, router := setupCompletionHandler(mockCompRepo, nil)
	router.GET("/completions", authMiddleware("user-1"), handler.HandleGetCompletions)

	completions := []models.HabitCompletion{
		{ID: "c1", HabitID: "h1", UserID: "user-1", CompletedAt: time.Now()},
		{ID: "c2", HabitID: "h2", UserID: "user-1", CompletedAt: time.Now()},
	}

	mockCompRepo.On("GetByUserID", mock.Anything, "user-1").Return(completions, nil)

	req := httptest.NewRequest(http.MethodGet, "/completions", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var resp models.CompletionListResponse
	err := json.Unmarshal(w.Body.Bytes(), &resp)
	assert.NoError(t, err)
	assert.Len(t, resp.Completions, 2)
	assert.Equal(t, 2, resp.Total)
	mockCompRepo.AssertExpectations(t)
}

func TestHandleGetStreak_200(t *testing.T) {
	mockCompRepo := new(mocks.MockCompletionRepository)
	handler, router := setupCompletionHandler(mockCompRepo, nil)
	router.GET("/completions/streak/:habitId", authMiddleware("user-1"), handler.HandleGetStreak)

	lastCompleted := time.Now()
	streak := &models.Streak{
		HabitID:         "habit-1",
		CurrentStreak:   3,
		LongestStreak:   7,
		LastCompletedAt: &lastCompleted,
	}

	mockCompRepo.On("GetStreakByHabitID", mock.Anything, "habit-1").Return(streak, nil)

	req := httptest.NewRequest(http.MethodGet, "/completions/streak/habit-1", nil)
	w := httptest.NewRecorder()

	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var resp models.Streak
	err := json.Unmarshal(w.Body.Bytes(), &resp)
	assert.NoError(t, err)
	assert.Equal(t, 3, resp.CurrentStreak)
	assert.Equal(t, 7, resp.LongestStreak)
	mockCompRepo.AssertExpectations(t)
}
