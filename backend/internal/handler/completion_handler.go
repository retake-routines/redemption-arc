package handler

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"

	"habitpal-backend/internal/middleware"
	"habitpal-backend/internal/models"
	"habitpal-backend/internal/repository"
	"habitpal-backend/internal/service"
)

// CompletionHandler handles completion HTTP requests.
type CompletionHandler struct {
	CompletionRepo repository.CompletionRepository
	StreakService  *service.StreakService
}

// NewCompletionHandler creates a new CompletionHandler.
func NewCompletionHandler(completionRepo repository.CompletionRepository, streakService *service.StreakService) *CompletionHandler {
	return &CompletionHandler{
		CompletionRepo: completionRepo,
		StreakService:  streakService,
	}
}

// HandleComplete godoc
// @Summary Record a habit completion
// @Tags completions
// @Accept json
// @Produce json
// @Security BearerAuth
// @Param request body models.CompletionCreateRequest true "Completion data"
// @Success 201 {object} models.HabitCompletion
// @Failure 400 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Failure 409 {object} map[string]string
// @Router /completions [post]
func (h *CompletionHandler) HandleComplete(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	var req models.CompletionCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request body"})
		return
	}

	if req.HabitID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "habit_id is required"})
		return
	}

	completion, err := h.StreakService.RecordCompletion(c.Request.Context(), userID, req)
	if err != nil {
		if errors.Is(err, service.ErrHabitNotFound) {
			c.JSON(http.StatusBadRequest, gin.H{"error": "habit not found"})
			return
		}
		if errors.Is(err, repository.ErrDuplicateCompletion) {
			c.JSON(http.StatusConflict, gin.H{"error": "habit already completed at this time"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to record completion"})
		return
	}

	c.JSON(http.StatusCreated, completion)
}

// HandleUncomplete godoc
// @Summary Delete a completion record
// @Tags completions
// @Security BearerAuth
// @Param id path string true "Completion ID"
// @Success 204 "No Content"
// @Failure 401 {object} map[string]string
// @Failure 404 {object} map[string]string
// @Router /completions/{id} [delete]
func (h *CompletionHandler) HandleUncomplete(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	completionID := c.Param("id")
	if completionID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "completion id is required"})
		return
	}

	err := h.StreakService.RemoveCompletion(c.Request.Context(), userID, completionID)
	if err != nil {
		if errors.Is(err, repository.ErrCompletionNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "completion not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to delete completion"})
		return
	}

	c.Status(http.StatusNoContent)
}

// HandleGetCompletions godoc
// @Summary List completions, optionally filtered by habit_id
// @Tags completions
// @Produce json
// @Security BearerAuth
// @Param habit_id query string false "Filter by habit ID"
// @Success 200 {object} models.CompletionListResponse
// @Failure 401 {object} map[string]string
// @Router /completions [get]
func (h *CompletionHandler) HandleGetCompletions(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	habitID := c.Query("habit_id")

	var completions []models.HabitCompletion
	var total int
	var err error

	if habitID != "" {
		completions, err = h.CompletionRepo.GetByHabitID(c.Request.Context(), habitID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to get completions"})
			return
		}
		// Filter to only this user's completions
		filtered := make([]models.HabitCompletion, 0, len(completions))
		for _, comp := range completions {
			if comp.UserID == userID {
				filtered = append(filtered, comp)
			}
		}
		completions = filtered
		total = len(completions)
	} else {
		completions, err = h.CompletionRepo.GetByUserID(c.Request.Context(), userID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to get completions"})
			return
		}
		total = len(completions)
	}

	c.JSON(http.StatusOK, models.CompletionListResponse{
		Completions: completions,
		Total:       total,
		Page:        1,
		Limit:       total,
	})
}

// HandleGetStreak godoc
// @Summary Get streak info for a habit
// @Tags completions
// @Produce json
// @Security BearerAuth
// @Param habitId path string true "Habit ID"
// @Success 200 {object} models.Streak
// @Failure 400 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Router /completions/streak/{habitId} [get]
func (h *CompletionHandler) HandleGetStreak(c *gin.Context) {
	habitID := c.Param("habitId")
	if habitID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "habit id is required"})
		return
	}

	streak, err := h.StreakService.CalculateStreak(c.Request.Context(), habitID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to calculate streak"})
		return
	}

	c.JSON(http.StatusOK, streak)
}
