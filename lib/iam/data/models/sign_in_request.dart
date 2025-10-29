class SignInRequest {
  final String username;
  final String password;

  const SignInRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };

  factory SignInRequest.fromJson(Map<String, dynamic> json) => SignInRequest(
    username: json['username'] as String,
    password: json['password'] as String,
  );
}