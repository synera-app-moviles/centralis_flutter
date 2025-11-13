class SignUpRequest {
  final String username;
  final String password;
  final String name;
  final String lastname;
  final String email;
  final List<String> roles;

  const SignUpRequest({
    required this.username,
    required this.password,
    required this.name,
    required this.lastname,
    required this.email,
    required this.roles,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'name': name,
    'lastname': lastname,
    'email': email,
    'roles': roles,
  };

  factory SignUpRequest.fromJson(Map<String, dynamic> json) => SignUpRequest(
    username: json['username'] as String,
    password: json['password'] as String,
    name: json['name'] as String,
    lastname: json['lastname'] as String,
    email: json['email'] as String,
    roles: List<String>.from(json['roles'] as List),
  );
}