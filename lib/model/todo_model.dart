
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoModel {
  String id;
  String userId;
  String title;
  String description;
  bool isDone;
  DateTime createdAt;

  TodoModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.isDone = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'isDone': isDone,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      isDone: map['isDone'] ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
