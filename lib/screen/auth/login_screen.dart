import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  String? localError;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        actions: [
          IconButton(
            onPressed: theme.toggleTheme,
            icon: Icon(
              theme.isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              size: 21,
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "Welcome Back",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 30),

                  // EMAIL
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Email required";
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v))
                        return "Invalid email";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // PASSWORD
                  TextFormField(
                    controller: passController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Password required";
                      if (v.length < 6) return "Minimum 6 characters";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.loading
                          ? null
                          : () async {
                              setState(() => localError = null);
                              if (_formKey.currentState!.validate()) {
                                await auth.login(
                                  emailController.text.trim(),
                                  passController.text.trim(),
                                );

                                // Check if login succeeded by verifying no error and user exists
                                if (auth.error == null &&
                                    auth.user != null &&
                                    context.mounted) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/home',
                                  );
                                } else {
                                  setState(
                                    () => localError =
                                        auth.error ?? "Login failed",
                                  );
                                }
                              }
                            },
                      child: auth.loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Login"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // FORGOT PASSWORD
                  TextButton(
                    onPressed: () async {
                      if (emailController.text.isEmpty) {
                        setState(
                          () => localError = "Enter email to reset password",
                        );
                        return;
                      }
                      await auth.resetPassword(emailController.text.trim());
                      setState(() => localError = "Password reset email sent");
                    },
                    child: const Text("Forgot password?"),
                  ),

                  const SizedBox(height: 20),

                  // OR Divider
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("OR"),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // GOOGLE + FACEBOOK ICON BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // GOOGLE
                      IconButton(
                        icon: Image.asset(
                          "assets/icons/google.png",
                          fit: BoxFit.cover,
                          width: 32,
                          height: 32,
                        ),
                        onPressed: () async {
                          setState(() => localError = null);
                          try {
                            await auth.loginWithGoogle();
                            if (auth.error == null &&
                                auth.user != null &&
                                context.mounted) {
                              Navigator.pushReplacementNamed(context, '/home');
                            } else {
                              setState(
                                () => localError =
                                    auth.error ?? "Google login failed",
                              );
                            }
                          } catch (e) {
                            setState(() => localError = e.toString());
                          }
                        },
                      ),

                      const SizedBox(width: 20),

                      // FACEBOOK
                      IconButton(
                        icon: Image.asset(
                          "assets/icons/facebook.png",
                          fit: BoxFit.cover,
                          width: 32,
                          height: 32,
                        ),
                        onPressed: () async {
                          setState(() => localError = null);
                          try {
                            await auth.loginWithFacebook();
                            if (auth.error == null &&
                                auth.user != null &&
                                context.mounted) {
                              Navigator.pushReplacementNamed(context, '/home');
                            } else {
                              setState(
                                () => localError =
                                    auth.error ?? "Facebook login failed",
                              );
                            }
                          } catch (e) {
                            setState(() => localError = e.toString());
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // NAVIGATE TO REGISTER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("No account? "),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/register'),
                        child: const Text("Register"),
                      ),
                    ],
                  ),

                  // ERROR MESSAGE
                  if (localError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        localError!,
                        style: TextStyle(
                          color: colors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
