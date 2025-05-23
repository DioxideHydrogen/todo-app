class Task {
  String title;
  String description;
  bool isDone;
  bool isArchived;
  DateTime? dueDate;

  Task({
    required this.title,
    required this.description,
    this.isDone = false,
    this.isArchived = false,
    this.dueDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'isArchived': isArchived,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'],
      isDone: json['isDone'],
      isArchived: json['isArchived'],
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,

    );
  }
}
