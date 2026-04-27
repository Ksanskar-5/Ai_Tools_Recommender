class AppUser {
  final int id;
  final String email;
  final String? name;
  final String token;

  AppUser({
    required this.id,
    required this.email,
    this.name,
    required this.token,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['user_id'] as int,
      email: json['email'] as String,
      name: json['name'] as String?,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': id,
        'email': email,
        'name': name,
        'token': token,
      };
}
