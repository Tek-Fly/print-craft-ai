import 'dart:convert';

enum UserPlan { free, pro, enterprise }

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserPlan plan;
  final int freeGenerationsUsed;
  final int freeGenerationsLimit;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final Map<String, dynamic>? preferences;
  final List<String>? favoriteStyles;
  final bool isEmailVerified;
  final String? fcmToken;
  
  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.plan = UserPlan.free,
    this.freeGenerationsUsed = 0,
    this.freeGenerationsLimit = 3,
    required this.createdAt,
    this.lastActiveAt,
    this.preferences,
    this.favoriteStyles,
    this.isEmailVerified = false,
    this.fcmToken,
  });
  
  bool get hasGenerationsLeft => 
      plan != UserPlan.free || freeGenerationsUsed < freeGenerationsLimit;
  
  int get generationsRemaining => 
      plan != UserPlan.free 
          ? 999999 // Unlimited for pro/enterprise
          : freeGenerationsLimit - freeGenerationsUsed;
  
  bool get isPro => plan == UserPlan.pro || plan == UserPlan.enterprise;
  
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    UserPlan? plan,
    int? freeGenerationsUsed,
    int? freeGenerationsLimit,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    Map<String, dynamic>? preferences,
    List<String>? favoriteStyles,
    bool? isEmailVerified,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      plan: plan ?? this.plan,
      freeGenerationsUsed: freeGenerationsUsed ?? this.freeGenerationsUsed,
      freeGenerationsLimit: freeGenerationsLimit ?? this.freeGenerationsLimit,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      preferences: preferences ?? this.preferences,
      favoriteStyles: favoriteStyles ?? this.favoriteStyles,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'plan': plan.name,
      'freeGenerationsUsed': freeGenerationsUsed,
      'freeGenerationsLimit': freeGenerationsLimit,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'preferences': preferences,
      'favoriteStyles': favoriteStyles,
      'isEmailVerified': isEmailVerified,
      'fcmToken': fcmToken,
    };
  }
  
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      plan: UserPlan.values.byName(map['plan'] as String? ?? 'free'),
      freeGenerationsUsed: map['freeGenerationsUsed'] as int? ?? 0,
      freeGenerationsLimit: map['freeGenerationsLimit'] as int? ?? 3,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastActiveAt: map['lastActiveAt'] != null
          ? DateTime.parse(map['lastActiveAt'] as String)
          : null,
      preferences: map['preferences'] as Map<String, dynamic>?,
      favoriteStyles: (map['favoriteStyles'] as List<dynamic>?)?.cast<String>(),
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
      fcmToken: map['fcmToken'] as String?,
    );
  }
  
  String toJson() => json.encode(toMap());
  
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
  
  // Factory for creating a new user after signup
  factory UserModel.newUser({
    required String id,
    required String email,
    String? displayName,
  }) {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
      plan: UserPlan.free,
      freeGenerationsUsed: 0,
      freeGenerationsLimit: 3,
    );
  }
}
