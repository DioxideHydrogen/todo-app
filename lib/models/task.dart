class Task {
  String title;
  String description;
  bool isDone;
  bool isArchived;

  Task({
    required this.title,
    required this.description,
    this.isDone = false,
    this.isArchived = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'isArchived': isArchived,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'],
      isDone: json['isDone'],
      isArchived: json['isArchived'],
    );
  }
}
