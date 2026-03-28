package models

import (
	"errors"
	"net/mail"
	"time"
)

// User represents a user in the database.
type User struct {
	ID           string    `json:"id" db:"id"`
	Email        string    `json:"email" db:"email"`
	PasswordHash string    `json:"-" db:"password_hash"`
	DisplayName  string    `json:"display_name" db:"display_name"`
	CreatedAt    time.Time `json:"created_at" db:"created_at"`
	UpdatedAt    time.Time `json:"updated_at" db:"updated_at"`
}

// UserDTO is the public representation of a user (excludes password).
type UserDTO struct {
	ID          string    `json:"id"`
	Email       string    `json:"email"`
	DisplayName string    `json:"display_name"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// ToDTO converts a User to a UserDTO.
func (u *User) ToDTO() UserDTO {
	return UserDTO{
		ID:          u.ID,
		Email:       u.Email,
		DisplayName: u.DisplayName,
		CreatedAt:   u.CreatedAt,
		UpdatedAt:   u.UpdatedAt,
	}
}

// RegisterRequest is the request body for user registration.
type RegisterRequest struct {
	Email       string `json:"email" binding:"required"`
	Password    string `json:"password" binding:"required"`
	DisplayName string `json:"display_name" binding:"required"`
}

// Validate checks that the register request fields are valid.
func (r *RegisterRequest) Validate() error {
	if _, err := mail.ParseAddress(r.Email); err != nil {
		return errors.New("invalid email address")
	}
	if len(r.Password) < 6 {
		return errors.New("password must be at least 6 characters")
	}
	if r.DisplayName == "" {
		return errors.New("display_name is required")
	}
	return nil
}

// LoginRequest is the request body for user login.
type LoginRequest struct {
	Email    string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// Validate checks that the login request fields are valid.
func (r *LoginRequest) Validate() error {
	if r.Email == "" {
		return errors.New("email is required")
	}
	if r.Password == "" {
		return errors.New("password is required")
	}
	return nil
}

// AuthResponse is returned from register and login endpoints.
type AuthResponse struct {
	Token string  `json:"token"`
	User  UserDTO `json:"user"`
}
