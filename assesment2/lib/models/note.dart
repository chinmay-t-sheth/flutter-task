class Note {
  int? id;
  String title;
  String description;
  String createdAt;

  Note({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory Note.fromMap(Map<String, dynamic> json) => Note(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'created_at': createdAt,
  };
}
