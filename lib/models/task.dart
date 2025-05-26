class Task {
  String? id;
  String title;
  String description;
  bool isDone;
  bool isArchived;
  DateTime? dueDate;
  bool isDeleted;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.isDone = false,
    this.isArchived = false,
    this.dueDate,
    this.isDeleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'isArchived': isArchived,
      'dueDate': dueDate?.toIso8601String(),
      'isDeleted': isDeleted,
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
    );
  }

  @override
  String toString() {
    return 'Task(title: $title, description: $description, isDone: $isDone, isArchived: $isArchived, dueDate: $dueDate)';
  }

}
