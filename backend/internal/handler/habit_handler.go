package handler

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"

	"habitpal-backend/internal/middleware"
	"habitpal-backend/internal/models"
	"habitpal-backend/internal/service"
)

// HabitHandler handles habit HTTP requests.
type HabitHandler struct {
	HabitService *service.HabitService
}

// NewHabitHandler creates a new HabitHandler.
func NewHabitHandler(habitService *service.HabitService) *HabitHandler {
	return &HabitHandler{HabitService: habitService}
}

// HandleCreate creates a new habit for the authenticated user.
func (h *HabitHandler) HandleCreate(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	var req models.HabitCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request body"})
		return
	}

	if err := req.Validate(); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	habit, err := h.HabitService.CreateHabit(c.Request.Context(), userID, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to create habit"})
		return
	}

	c.JSON(http.StatusCreated, habit)
}

// HandleGetAll returns all habits for the authenticated user.
func (h *HabitHandler) HandleGetAll(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	habits, err := h.HabitService.GetUserHabits(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to get habits"})
		return
	}

	total := len(habits)
	c.JSON(http.StatusOK, models.HabitListResponse{
		Habits: habits,
		Total:  total,
		Page:   1,
		Limit:  total,
	})
}

// HandleGetByID returns a single habit by ID for the authenticated user.
func (h *HabitHandler) HandleGetByID(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	habitID := c.Param("id")
	if habitID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "habit id is required"})
		return
	}

	habit, err := h.HabitService.GetHabit(c.Request.Context(), habitID, userID)
	if err != nil {
		if errors.Is(err, service.ErrHabitNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "habit not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to get habit"})
		return
	}

	c.JSON(http.StatusOK, habit)
}

// HandleUpdate partially updates a habit for the authenticated user.
func (h *HabitHandler) HandleUpdate(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	habitID := c.Param("id")
	if habitID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "habit id is required"})
		return
	}

	var req models.HabitUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request body"})
		return
	}

	if err := req.Validate(); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	habit, err := h.HabitService.UpdateHabit(c.Request.Context(), habitID, userID, req)
	if err != nil {
		if errors.Is(err, service.ErrHabitNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "habit not found"})
			return
		}
		if errors.Is(err, service.ErrForbidden) {
			c.JSON(http.StatusForbidden, gin.H{"error": "you do not have access to this habit"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to update habit"})
		return
	}

	c.JSON(http.StatusOK, habit)
}

// HandleDelete deletes a habit for the authenticated user.
func (h *HabitHandler) HandleDelete(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	habitID := c.Param("id")
	if habitID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "habit id is required"})
		return
	}

	err := h.HabitService.DeleteHabit(c.Request.Context(), habitID, userID)
	if err != nil {
		if errors.Is(err, service.ErrHabitNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "habit not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to delete habit"})
		return
	}

	c.Status(http.StatusNoContent)
}
