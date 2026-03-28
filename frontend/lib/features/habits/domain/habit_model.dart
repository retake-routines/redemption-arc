/// Immutable model representing a user in auth responses.
class UserModel {
  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    this.displayName = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Immutable model representing a habit.
///
/// Property names kept compatible with existing presentation layer:
/// - [name] maps to API field `title`
/// - [frequency] maps to API field `frequency_type`
/// - [targetCount] maps to API field `frequency_value`
class HabitModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String icon;
  final String color;
  final String frequency;
  final int targetCount;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final StreakModel streak;
  final List<CompletionModel> completions;
  final bool completedToday;

  HabitModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.userId = '',
    this.description = '',
    this.icon = '',
    this.color = '',
    this.frequency = 'daily',
    this.targetCount = 1,
    this.isArchived = false,
    DateTime? updatedAt,
    this.streak = const StreakModel(),
    this.completions = const [],
    this.completedToday = false,
  }) : updatedAt = updatedAt ?? createdAt;

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      name: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      color: json['color'] as String? ?? '',
      frequency: json['frequency_type'] as String? ?? 'daily',
      targetCount: json['frequency_value'] as int? ?? 1,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      streak: json['streak'] != null
          ? StreakModel.fromJson(json['streak'] as Map<String, dynamic>)
          : const StreakModel(),
      completions: json['completions'] != null
          ? (json['completions'] as List<dynamic>)
              .map(
                  (e) => CompletionModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': name,
      'description': description,
      'icon': icon,
      'color': color,
      'frequency_type': frequency,
      'frequency_value': targetCount,
      'is_archived': isArchived,
    };
  }

  HabitModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? icon,
    String? color,
    String? frequency,
    int? targetCount,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    StreakModel? streak,
    List<CompletionModel>? completions,
    bool? completedToday,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      targetCount: targetCount ?? this.targetCount,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      streak: streak ?? this.streak,
      completions: completions ?? this.completions,
      completedToday: completedToday ?? this.completedToday,
    );
  }
}

/// Immutable model representing a habit completion entry.
class CompletionModel {
  final String id;
  final String habitId;
  final String userId;
  final DateTime completedAt;
  final String note;

  const CompletionModel({
    required this.id,
    required this.completedAt,
    this.habitId = '',
    this.userId = '',
    this.note = '',
  });

  factory CompletionModel.fromJson(Map<String, dynamic> json) {
    return CompletionModel(
      id: json['id'] as String? ?? '',
      habitId: json['habit_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : DateTime.now(),
      note: json['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'user_id': userId,
      'completed_at': completedAt.toIso8601String(),
      'note': note,
    };
  }
}

/// Immutable model representing streak data for a habit.
class StreakModel {
  final String habitId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedAt;

  const StreakModel({
    this.habitId = '',
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedAt,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      habitId: json['habit_id'] as String? ?? '',
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastCompletedAt: json['last_completed_at'] != null
          ? DateTime.parse(json['last_completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habit_id': habitId,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_completed_at': lastCompletedAt?.toIso8601String(),
    };
  }
}

/// Request DTO for creating a new habit.
class CreateHabitRequest {
  final String title;
  final String description;
  final String icon;
  final String color;
  final String frequencyType;
  final int frequencyValue;

  const CreateHabitRequest({
    required this.title,
    this.description = '',
    this.icon = '',
    this.color = '',
    this.frequencyType = 'daily',
    this.frequencyValue = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'icon': icon,
      'color': color,
      'frequency_type': frequencyType,
      'frequency_value': frequencyValue,
    };
  }
}

/// Request DTO for updating an existing habit. All fields are optional.
class UpdateHabitRequest {
  final String? title;
  final String? description;
  final String? icon;
  final String? color;
  final String? frequencyType;
  final int? frequencyValue;
  final bool? isArchived;

  const UpdateHabitRequest({
    this.title,
    this.description,
    this.icon,
    this.color,
    this.frequencyType,
    this.frequencyValue,
    this.isArchived,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (description != null) map['description'] = description;
    if (icon != null) map['icon'] = icon;
    if (color != null) map['color'] = color;
    if (frequencyType != null) map['frequency_type'] = frequencyType;
    if (frequencyValue != null) map['frequency_value'] = frequencyValue;
    if (isArchived != null) map['is_archived'] = isArchived;
    return map;
  }
}

/// Auth response DTO containing token and user.
class AuthResponse {
  final String token;
  final UserModel user;

  const AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? '',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
