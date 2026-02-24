import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo_app/providers/todo_provider.dart';
import 'package:provider_todo_app/providers/user_provider.dart';

import 'theme_provider.dart';
import 'auth_provider.dart';
import 'notification_provider.dart';
import '../my_app.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      
        
      ],
      child: const MyApp(),
    );
  }
}
