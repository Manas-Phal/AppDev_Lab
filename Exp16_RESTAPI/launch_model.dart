class Launch {
  final String name;
  final DateTime dateUtc;
  final String? imageUrl;

  Launch({required this.name, required this.dateUtc, this.imageUrl});

  factory Launch.fromJson(Map<String, dynamic> json) {
    // Some launches may not have patch image
    String? image;
    try {
      image = json['links']?['patch']?['small'];
    } catch (_) {
      image = null;
    }

    return Launch(
      name: json['name'] ?? 'Unnamed Launch',
      dateUtc: DateTime.parse(json['date_utc']),
      imageUrl: image,
    );
  }
}
