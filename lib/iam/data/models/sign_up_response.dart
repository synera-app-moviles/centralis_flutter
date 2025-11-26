class SignUpResponse {
  final String id;
  final String username;
  final List<String> roles;
  final String createdAt;
  final String updatedAt;

  const SignUpResponse({
    required this.id,
    required this.username,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'roles': roles,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory SignUpResponse.fromJson(Map<String, dynamic> json) => SignUpResponse(
    id: json['id'] as String,
    username: json['username'] as String,
    roles: List<String>.from(json['roles'] as List),
    createdAt: json['createdAt'] as String,
    updatedAt: json['updatedAt'] as String,
  );
}