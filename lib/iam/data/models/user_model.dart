class UserModel {
  final String id;
  final String username;
  final String name;
  final String lastname;
  final String email;
  final List<String> roles;

  const UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.lastname,
    required this.email,
    required this.roles,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'name': name,
    'lastname': lastname,
    'email': email,
    'roles': roles,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    username: json['username'] as String,
    name: json['name'] as String,
    lastname: json['lastname'] as String,
    email: json['email'] as String,
    roles: List<String>.from(json['roles'] as List),
  );

  String get fullName => '$name $lastname';
}