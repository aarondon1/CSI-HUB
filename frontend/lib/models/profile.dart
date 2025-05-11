class Profile {
  final String userId;
  final String username;
  final String? bio;
  final String? email;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.userId,
    required this.username,
    this.bio,
    this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: json['user_id'],
      username: json['username'],
      bio: json['bio'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'bio': bio,
      'email': email,
    };
  }

  Profile copyWith({
    String? username,
    String? bio,
    String? email,
  }) {
    return Profile(
      userId: userId,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
