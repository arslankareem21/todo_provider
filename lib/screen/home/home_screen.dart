import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider_todo_app/model/todo_model.dart';

import 'package:provider_todo_app/providers/todo_provider.dart';
import 'package:provider_todo_app/providers/user_provider.dart';
import 'package:provider_todo_app/providers/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final theme = context.watch<ThemeProvider>();
    final appUser = userProvider.appUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Todo App"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: theme.toggleTheme,
            icon: Icon(
              theme.isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          if (appUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: PopupMenuButton<String>(
                tooltip: "User Menu",
                onSelected: (value) async {
                  if (value == 'logout') {
                    await FirebaseAuth.instance.signOut();
                    await userProvider.clearUser();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'logout', child: Text('Logout')),
                ],
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                      (appUser.photoURL != null && appUser.photoURL!.isNotEmpty)
                      ? NetworkImage(appUser.photoURL!)
                      : null,
                  child: (appUser.photoURL == null || appUser.photoURL!.isEmpty)
                      ? Text(
                          _getInitials(appUser.name),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          //Stack
          Stack(
            alignment: .centerLeft,
            children: [
              IconButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/notificationScreen'),
                icon: Icon(Icons.notifications_paused, size: 21),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, ${appUser?.name.isNotEmpty == true ? appUser!.name : "there"} 👋",
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Here's your todo list for today",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            /// TODO LIST
            const Expanded(child: _TodoListSection()),
          ],
        ),
      ),
    );
  }

  static String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

class _TodoListSection extends StatefulWidget {
  const _TodoListSection();

  @override
  State<_TodoListSection> createState() => _TodoListSectionState();
}

class _TodoListSectionState extends State<_TodoListSection> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final todoProvider = context.watch<TodoProvider>();
    final todos = todoProvider.todos;

    final activeTodos = todos.where((t) => !t.isDone).toList();
    final completedTodos = todos.where((t) => t.isDone).toList();

    return Column(
      children: [
        /// ACTIVE
        Expanded(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Active Todos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: activeTodos.isEmpty
                    ? const Center(child: Text("No Active Todos"))
                    : ListView.builder(
                        itemCount: activeTodos.length,
                        itemBuilder: (_, i) => _todoTile(activeTodos[i], false),
                      ),
              ),
            ],
          ),
        ),

        /// COMPLETED
        Expanded(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Completed Todos",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: completedTodos.isEmpty
                    ? const Center(child: Text("No Completed Todos"))
                    : ListView.builder(
                        itemCount: completedTodos.length,
                        itemBuilder: (_, i) =>
                            _todoTile(completedTodos[i], true),
                      ),
              ),
            ],
          ),
        ),

        FloatingActionButton(
          onPressed: () => _showAddDialog(context),
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _todoTile(TodoModel todo, bool completed) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);

    return Card(
      child: ListTile(
        leading: Checkbox(
          value: todo.isDone,
          onChanged: (_) => todoProvider.toggleDone(todo),
        ),
        title: Text(
          todo.title,
          style: completed
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: Text(todo.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!completed)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditDialog(todo),
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => todoProvider.deleteTodo(todo.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);

    titleController.clear();
    descController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Todo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty) {
                await todoProvider.addTodo(
                  titleController.text.trim(),
                  descController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(TodoModel todo) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);

    titleController.text = todo.title;
    descController.text = todo.description;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Todo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty) {
                final uid = FirebaseAuth.instance.currentUser?.uid ?? "";

                final updated = TodoModel(
                  id: todo.id,
                  userId: uid,
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  isDone: todo.isDone,
                  createdAt: todo.createdAt,
                );

                await todoProvider.updateTodo(updated);
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
