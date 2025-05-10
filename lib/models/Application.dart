class Application {
  final int id;
  final String name;
  final String kodeOtp;

  Application({required this.id, required this.name, required this.kodeOtp});

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      kodeOtp: json['kode_otp'] ?? '',
    );
  }
}
