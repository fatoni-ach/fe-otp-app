import 'package:flutter_first_app/models/user.dart';

class ProfileGoogle {
  final String sub;
  final String name;
  final String givenName;
  final String familyName;
  final String picture;
  final String email;
  final bool emailVerified;
  bool isLogin;

  ProfileGoogle({
    required this.sub,
    required this.name,
    required this.givenName,
    required this.familyName,
    required this.picture,
    required this.email,
    required this.emailVerified,
    required this.isLogin,
  });

  factory ProfileGoogle.fromJson(Map<String, dynamic> json) {
    return ProfileGoogle(
      sub: json['sub'] ?? '',
      name: json['name'] ?? '',
      givenName: json['given_name'] ?? '',
      familyName: json['family_name'] ?? '',
      picture: json['picture'] ?? '',
      email: json['email'] ?? '',
      emailVerified: json['email_verified'] ?? false,
      isLogin: json['is_login'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub': sub,
      'name': name,
      'given_name': givenName,
      'family_name': familyName,
      'picture': picture,
      'email': email,
      'email_verified': emailVerified,
      'is_login': isLogin,
    };
  }
}

// USER INFO : {
//   "sub": "111852001413980658987",
//   "name": "Achmad Fatoni",
//   "given_name": "Achmad",
//   "family_name": "Fatoni",
//   "picture": "https://lh3.googleusercontent.com/a/ACg8ocKdDbWgeudoTe22AREv-yOdwBeLjfBjx_3VtGbZzP7UHoJ-aR8\u003ds96-c",
//   "email": "achmad.fatoni129@gmail.com",
//   "email_verified": true
// }
