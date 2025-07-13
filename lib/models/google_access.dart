import 'dart:convert';

class GoogleAccess {
  final String accessToken;
  final String refreshToken;
  final bool isLogin;

  GoogleAccess({
    required this.accessToken,
    required this.refreshToken,
    required this.isLogin,
  });

  factory GoogleAccess.fromJson(Map<String, dynamic> json) {
    return GoogleAccess(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      isLogin: json['is_login'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'is_login': isLogin,
    };
  }
}

List<GoogleAccess> decodeGoogleAccessList(String jsonString) {
  final List<dynamic> jsonList = jsonDecode(jsonString);
  return jsonList.map((json) => GoogleAccess.fromJson(json)).toList();
}

String encodeGoogleAccessList(List<GoogleAccess> users) {
  final List<Map<String, dynamic>> jsonList =
      users.map((u) => u.toJson()).toList();
  return jsonEncode(jsonList);
}
