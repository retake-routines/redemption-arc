// Package docs contains the embedded Swagger specification for HabitPal API.
package docs

import "github.com/swaggo/swag"

const docTemplate = `{
    "swagger": "2.0",
    "info": {
        "title": "HabitPal API",
        "description": "REST API for HabitPal habit tracking application",
        "version": "1.0"
    },
    "host": "localhost:8080",
    "basePath": "/api/v1",
    "securityDefinitions": {
        "BearerAuth": {
            "type": "apiKey",
            "name": "Authorization",
            "in": "header"
        }
    },
    "paths": {
        "/auth/register": {
            "post": {
                "summary": "Register a new user",
                "tags": ["auth"],
                "consumes": ["application/json"],
                "produces": ["application/json"],
                "parameters": [
                    {
                        "in": "body",
                        "name": "request",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/RegisterRequest"
                        }
                    }
                ],
                "responses": {
                    "201": {
                        "description": "Created",
                        "schema": { "$ref": "#/definitions/AuthResponse" }
                    },
                    "400": {
                        "description": "Bad Request",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    },
                    "409": {
                        "description": "Conflict",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    }
                }
            }
        },
        "/auth/login": {
            "post": {
                "summary": "Login with email and password",
                "tags": ["auth"],
                "consumes": ["application/json"],
                "produces": ["application/json"],
                "parameters": [
                    {
                        "in": "body",
                        "name": "request",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/LoginRequest"
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": { "$ref": "#/definitions/AuthResponse" }
                    },
                    "400": {
                        "description": "Bad Request",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    },
                    "401": {
                        "description": "Unauthorized",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    }
                }
            }
        },
        "/habits": {
            "get": {
                "summary": "List all habits for the authenticated user",
                "tags": ["habits"],
                "produces": ["application/json"],
                "security": [{ "BearerAuth": [] }],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": { "$ref": "#/definitions/HabitListResponse" }
                    },
                    "401": {
                        "description": "Unauthorized",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    }
                }
            },
            "post": {
                "summary": "Create a new habit",
                "tags": ["habits"],
                "consumes": ["application/json"],
                "produces": ["application/json"],
                "security": [{ "BearerAuth": [] }],
                "parameters": [
                    {
                        "in": "body",
                        "name": "request",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/HabitCreateRequest"
                        }
                    }
                ],
                "responses": {
                    "201": {
                        "description": "Created",
                        "schema": { "$ref": "#/definitions/Habit" }
                    },
                    "400": {
                        "description": "Bad Request",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    },
                    "401": {
                        "description": "Unauthorized",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    }
                }
            }
        },
        "/habits/{id}": {
            "get": {
                "summary": "Get a habit by ID",
                "tags": ["habits"],
                "produces": ["application/json"],
                "security": [{ "BearerAuth": [] }],
                "parameters": [
                    {
                        "in": "path",
                        "name": "id",
                        "required": true,
                        "type": "string"
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": { "$ref": "#/definitions/Habit" }
                    },
                    "401": {
                        "description": "Unauthorized",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    },
                    "404": {
                        "description": "Not Found",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    }
                }
            },
            "put": {
                "summary": "Update a habit",
                "tags": ["habits"],
                "consumes": ["application/json"],
                "produces": ["application/json"],
                "security": [{ "BearerAuth": [] }],
                "parameters": [
                    {
                        "in": "path",
                        "name": "id",
                        "required": true,
                        "type": "string"
                    },
                    {
                        "in": "body",
                        "name": "request",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/HabitUpdateRequest"
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": { "$ref": "#/definitions/Habit" }
                    },
                    "400": {
                        "description": "Bad Request",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    },
                    "401": {
                        "description": "Unauthorized",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    },
                    "404": {
                        "description": "Not Found",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    }
                }
            },
            "delete": {
                "summary": "Delete a habit",
                "tags": ["habits"],
                "security": [{ "BearerAuth": [] }],
                "parameters": [
                    {
                        "in": "path",
                        "name": "id",
                        "required": true,
                        "type": "string"
                    }
                ],
                "responses": {
                    "204": {
                        "description": "No Content"
                    },
                    "401": {
                        "description": "Unauthorized",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    },
                    "404": {
                        "description": "Not Found",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    }
                }
            }
        },
        "/completions": {
            "get": {
                "summary": "List completions, optionally filtered by habit_id",
                "tags": ["completions"],
                "produces": ["application/json"],
                "security": [{ "BearerAuth": [] }],
                "parameters": [
                    {
                        "in": "query",
                        "name": "habit_id",
                        "type": "string",
                        "required": false
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": { "$ref": "#/definitions/CompletionListResponse" }
                    },
                    "401": {
                        "description": "Unauthorized",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    }
                }
            },
            "post": {
                "summary": "Record a habit completion",
                "tags": ["completions"],
                "consumes": ["application/json"],
                "produces": ["application/json"],
                "security": [{ "BearerAuth": [] }],
                "parameters": [
                    {
                        "in": "body",
                        "name": "request",
                        "required": true,
                        "schema": {
                            "$ref": "#/definitions/CompletionCreateRequest"
                        }
                    }
                ],
                "responses": {
                    "201": {
                        "description": "Created",
                        "schema": { "$ref": "#/definitions/HabitCompletion" }
                    },
                    "400": {
                        "description": "Bad Request",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    },
                    "401": {
                        "description": "Unauthorized",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    },
                    "409": {
                        "description": "Conflict",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    }
                }
            }
        },
        "/completions/{id}": {
            "delete": {
                "summary": "Delete a completion",
                "tags": ["completions"],
                "security": [{ "BearerAuth": [] }],
                "parameters": [
                    {
                        "in": "path",
                        "name": "id",
                        "required": true,
                        "type": "string"
                    }
                ],
                "responses": {
                    "204": {
                        "description": "No Content"
                    },
                    "401": {
                        "description": "Unauthorized",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    },
                    "404": {
                        "description": "Not Found",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    }
                }
            }
        },
        "/completions/streak/{habitId}": {
            "get": {
                "summary": "Get streak info for a habit",
                "tags": ["completions"],
                "produces": ["application/json"],
                "security": [{ "BearerAuth": [] }],
                "parameters": [
                    {
                        "in": "path",
                        "name": "habitId",
                        "required": true,
                        "type": "string"
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": { "$ref": "#/definitions/Streak" }
                    },
                    "400": {
                        "description": "Bad Request",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    },
                    "401": {
                        "description": "Unauthorized",
                        "schema": { "$ref": "#/definitions/ErrorResponse" }
                    }
                }
            }
        }
    },
    "definitions": {
        "RegisterRequest": {
            "type": "object",
            "required": ["email", "password", "display_name"],
            "properties": {
                "email": { "type": "string" },
                "password": { "type": "string" },
                "display_name": { "type": "string" }
            }
        },
        "LoginRequest": {
            "type": "object",
            "required": ["email", "password"],
            "properties": {
                "email": { "type": "string" },
                "password": { "type": "string" }
            }
        },
        "AuthResponse": {
            "type": "object",
            "properties": {
                "token": { "type": "string" },
                "user": { "$ref": "#/definitions/UserDTO" }
            }
        },
        "UserDTO": {
            "type": "object",
            "properties": {
                "id": { "type": "string" },
                "email": { "type": "string" },
                "display_name": { "type": "string" },
                "created_at": { "type": "string", "format": "date-time" },
                "updated_at": { "type": "string", "format": "date-time" }
            }
        },
        "Habit": {
            "type": "object",
            "properties": {
                "id": { "type": "string" },
                "user_id": { "type": "string" },
                "title": { "type": "string" },
                "description": { "type": "string" },
                "icon": { "type": "string" },
                "color": { "type": "string" },
                "frequency_type": { "type": "string" },
                "frequency_value": { "type": "integer" },
                "is_archived": { "type": "boolean" },
                "created_at": { "type": "string", "format": "date-time" },
                "updated_at": { "type": "string", "format": "date-time" }
            }
        },
        "HabitCreateRequest": {
            "type": "object",
            "required": ["title", "frequency_type", "frequency_value"],
            "properties": {
                "title": { "type": "string" },
                "description": { "type": "string" },
                "icon": { "type": "string" },
                "color": { "type": "string" },
                "frequency_type": { "type": "string" },
                "frequency_value": { "type": "integer" }
            }
        },
        "HabitUpdateRequest": {
            "type": "object",
            "properties": {
                "title": { "type": "string" },
                "description": { "type": "string" },
                "icon": { "type": "string" },
                "color": { "type": "string" },
                "frequency_type": { "type": "string" },
                "frequency_value": { "type": "integer" },
                "is_archived": { "type": "boolean" }
            }
        },
        "HabitListResponse": {
            "type": "object",
            "properties": {
                "habits": {
                    "type": "array",
                    "items": { "$ref": "#/definitions/Habit" }
                },
                "total": { "type": "integer" },
                "page": { "type": "integer" },
                "limit": { "type": "integer" }
            }
        },
        "HabitCompletion": {
            "type": "object",
            "properties": {
                "id": { "type": "string" },
                "habit_id": { "type": "string" },
                "user_id": { "type": "string" },
                "completed_at": { "type": "string", "format": "date-time" },
                "note": { "type": "string" }
            }
        },
        "CompletionCreateRequest": {
            "type": "object",
            "required": ["habit_id"],
            "properties": {
                "habit_id": { "type": "string" },
                "note": { "type": "string" }
            }
        },
        "CompletionListResponse": {
            "type": "object",
            "properties": {
                "completions": {
                    "type": "array",
                    "items": { "$ref": "#/definitions/HabitCompletion" }
                },
                "total": { "type": "integer" },
                "page": { "type": "integer" },
                "limit": { "type": "integer" }
            }
        },
        "Streak": {
            "type": "object",
            "properties": {
                "habit_id": { "type": "string" },
                "current_streak": { "type": "integer" },
                "longest_streak": { "type": "integer" },
                "last_completed_at": { "type": "string", "format": "date-time" }
            }
        },
        "ErrorResponse": {
            "type": "object",
            "properties": {
                "error": { "type": "string" }
            }
        }
    }
}`

// SwaggerInfo holds exported Swagger Info so clients can modify it.
var SwaggerInfo = &swag.Spec{
	Version:          "1.0",
	Host:             "localhost:8080",
	BasePath:         "/api/v1",
	Schemes:          []string{},
	Title:            "HabitPal API",
	Description:      "REST API for HabitPal habit tracking application",
	InfoInstanceName: "swagger",
	SwaggerTemplate:  docTemplate,
}

func init() {
	swag.Register(SwaggerInfo.InstanceName(), SwaggerInfo)
}
