import "package:flutter/material.dart";

import "../services/auth_service.dart";
import "dashboard_screen.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController(text: "customer@demo.com");
  final _passwordController = TextEditingController(text: "demo123");
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isSignupMode = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isSignupMode) {
        await _authService.signup(
          fullName: _fullNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await _authService.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst("Exception: ", "");
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _isSignupMode = !_isSignupMode;
      _error = null;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isSignupMode ? "Create Account" : "E-Commerce Login",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (_isSignupMode) ...[
                        TextFormField(
                          controller: _fullNameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: "Full name",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (!_isSignupMode) {
                              return null;
                            }
                            if (value == null || value.trim().length < 2) {
                              return "Enter your full name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Email is required";
                          }
                          if (!value.contains("@")) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: _isSignupMode ? TextInputAction.next : TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required";
                          }
                          if (_isSignupMode && value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          if (!_isSignupMode && !_isLoading) {
                            _submit();
                          }
                        },
                      ),
                      if (_isSignupMode) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: "Confirm password",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (!_isSignupMode) {
                              return null;
                            }
                            if (value == null || value.isEmpty) {
                              return "Please confirm your password";
                            }
                            if (value != _passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) {
                            if (!_isLoading) {
                              _submit();
                            }
                          },
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_isSignupMode ? "Sign Up" : "Login"),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _isLoading ? null : _toggleMode,
                        child: Text(
                          _isSignupMode
                              ? "Already have an account? Login"
                              : "New here? Create an account",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
