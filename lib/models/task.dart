class Task {
  String? id;
  String title;
  String description;
  bool isDone;
  bool isArchived;
  DateTime? dueDate;
  bool isDeleted;
  String? uniqueId;
  DateTime? createdAt;
  DateTime? updatedAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.isDone = false,
    this.isArchived = false,
    this.dueDate,
    this.isDeleted = false,
    this.uniqueId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uniqueId': uniqueId,
      'title': title,
      'description': description,
      'isDone': isDone,
      'isArchived': isArchived,
      'dueDate': dueDate?.toIso8601String(),
      'isDeleted': isDeleted,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForApi() {
    return {
      'title': title,
      'description': description,
      'completed': isDone,
      'archived': isArchived,
      'date': dueDate?.toIso8601String(),
      'deleted': isDeleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'],
      isDone: json['isDone'],
      isArchived: json['isArchived'],
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      isDeleted: json['isDeleted'] ?? false,
      id: json['_id'],
      uniqueId: json['uniqueId'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  factory Task.fromJsonApi(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      isDone: json['completed'],
      isArchived: json['archived'],
      dueDate: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      isDeleted: json['deleted'] ?? false,
      uniqueId: json['uniqueId'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  @override
  String toString() {
    return 'Task(title: $title, description: $description, isDone: $isDone, isArchived: $isArchived, dueDate: $dueDate)';
  }

}
