import 'package:flutter_first_app/models/user.dart';

class Client {
  final int id;
  final String name;
  final String key;
  final bool active;
  final User creator;

  Client({
    required this.id,
    required this.name,
    required this.key,
    required this.active,
    required this.creator,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      key: json['key'] ?? '',
      active: json['active'] ?? false,
      creator: User.fromJson(json['creator']),
    );
  }
}
