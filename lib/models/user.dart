class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;
  final String nama;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
    required this.nama,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      avatar: json['avatar'] ?? '',
      nama: json['name'] ?? '',
    );
  }
}
