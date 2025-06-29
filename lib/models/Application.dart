import 'dart:convert';

class Application {
  final int id;
  final String name;
  String kodeOtp;
  final String issuer;
  final String secretKey;

  Application({
    required this.id,
    required this.name,
    required this.kodeOtp,
    required this.issuer,
    required this.secretKey,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      kodeOtp: json['kode_otp'] ?? '',
      issuer: json['issuer'] ?? '',
      secretKey: json['secret_key'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'kode_otp': kodeOtp,
      'issuer': issuer,
      'secret_key': secretKey,
    };
  }
}

List<Application> decodeUserList(String jsonString) {
  final List<dynamic> jsonList = jsonDecode(jsonString);
  return jsonList.map((json) => Application.fromJson(json)).toList();
}

String encodeAppllicationList(List<Application> users) {
  final List<Map<String, dynamic>> jsonList =
      users.map((u) => u.toJson()).toList();
  return jsonEncode(jsonList);
}
