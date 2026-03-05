class Salon {
  final int id;
  final String name;

  Salon({required this.id, required this.name});

  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
    );
  }
}
