class Config {
  final int radius;

  const Config({
    required this.radius
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
        radius: json['radius'],
    );
  }

}