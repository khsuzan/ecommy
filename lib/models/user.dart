class User {
  final int id;
  final String email;
  final String username;
  final Map<String, dynamic> name;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      name: json['name'],
    );
  }

  String get fullName => "${name['firstname']} ${name['lastname']}";
}
