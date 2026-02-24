import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_todo_app/providers/user_provider.dart';
import 'package:provider_todo_app/screen/auth/login_screen.dart';
import 'package:provider_todo_app/screen/auth/register_screen.dart';
import 'package:provider_todo_app/screen/home/home_screen.dart';

import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Provider App',
        theme: themeProvider.theme,
        initialRoute: authProvider.user == null ? '/login' : '/home',
        routes: {
          '/': (context) => authProvider.user == null
              ? const LoginScreen()
              : const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          
        },
      ),
    );
  }
}
