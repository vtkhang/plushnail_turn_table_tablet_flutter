class Skill {
  final int id;
  final String name;
  final String? abbr;
  final int durationMinutes;
  final double? price;
  final int? categoryId;

  Skill({
    required this.id,
    required this.name,
    this.abbr,
    required this.durationMinutes,
    this.price,
    this.categoryId,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      abbr: json['abbr'] ?? json['code'] ?? (json['name'] as String?)?.substring(0, 2).toUpperCase(),
      durationMinutes: json['expected_finished_minute'] ?? json['durationMinutes'] ?? 0,
      price: (json['price'] != null) ? double.tryParse(json['price'].toString()) : null,
      categoryId: json['category_id'] is int ? json['category_id'] : (json['category_id'] != null ? int.tryParse(json['category_id'].toString()) : null),
    );
  }
}

class SkillCategory {
  final int id;
  final String name;
  final List<Skill> skills;

  SkillCategory({
    required this.id,
    required this.name,
    required this.skills,
  });

  factory SkillCategory.fromJson(Map<String, dynamic> json) {
    return SkillCategory(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      skills: (json['skills'] as List? ?? []).map((s) => Skill.fromJson(s)).toList(),
    );
  }
}
