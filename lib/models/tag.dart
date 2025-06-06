class Tag {
  final String id;
  String name;
  String description;
  String color;
  bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tag({
    this.id = '',
    required this.name,
    this.description = '',
    this.color = '',
    this.isDeleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime(0),
        updatedAt = updatedAt ?? DateTime(0);

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      color: json['color'] as String? ?? '',
      isDeleted: json['deleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime(0),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'deleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}