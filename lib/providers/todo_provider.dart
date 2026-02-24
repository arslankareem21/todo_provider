import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/todo_model.dart';

class TodoProvider extends ChangeNotifier {
  List<TodoModel> _todos = [];
  List<TodoModel> get todos => _todos;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<QuerySnapshot>? _todoSubscription;

  TodoProvider() {
    fetchTodos();
  }

  @override
  void dispose() {
    _todoSubscription?.cancel();
    super.dispose();
  }

  void fetchTodos() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _todoSubscription?.cancel();

    _todoSubscription = _db
        .collection('users')
        .doc(uid)
        .collection('todos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _todos = snapshot.docs.map((doc) {
              return TodoModel.fromMap(doc.data());
            }).toList();
            notifyListeners();
          },
          onError: (e) {
            debugPrint("Failed to fetch todos: $e");
          },
        );
  }

  Future<void> addTodo(String title, String description) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final id = _db.collection('users').doc(uid).collection('todos').doc().id;
    final todo = TodoModel(
      id: id,
      userId: uid,
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );

    _todos.insert(0, todo);
    notifyListeners();

    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('todos')
          .doc(id)
          .set(todo.toMap());
    } catch (e) {
      _todos.removeWhere((t) => t.id == id);
      notifyListeners();
      debugPrint("Failed to add todo: $e");
    }
  }

  Future<void> toggleDone(TodoModel todo) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final updated = TodoModel(
      id: todo.id,
      userId: uid,
      title: todo.title,
      description: todo.description,
      isDone: !todo.isDone,
      createdAt: todo.createdAt,
    );

    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index == -1) return;

    _todos[index] = updated;
    notifyListeners();

    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('todos')
          .doc(todo.id)
          .update({'isDone': updated.isDone});
    } catch (e) {
      _todos[index] = todo;
      notifyListeners();
      debugPrint("Failed to update todo: $e");
    }
  }

  Future<void> updateTodo(TodoModel todo) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index == -1) return;

    _todos[index] = todo;
    notifyListeners();

    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('todos')
          .doc(todo.id)
          .update(todo.toMap());
    } catch (e) {
      debugPrint("Failed to update todo: $e");
    }
  }

  Future<void> deleteTodo(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    TodoModel? removed;
    try {
      removed = _todos.firstWhere((t) => t.id == id);
    } catch (e) {
      removed = null;
    }

    _todos.removeWhere((t) => t.id == id);
    notifyListeners();

    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('todos')
          .doc(id)
          .delete();
    } catch (e) {
      if (removed != null) {
        _todos.add(removed);
        notifyListeners();
      }
      debugPrint("Failed to delete todo: $e");
    }
  }
}
