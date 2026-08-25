import "package:flutter/material.dart";

import "screens/dashboard_screen.dart";
import "screens/login_screen.dart";
import "services/auth_service.dart";

void main() {
  runApp(const CpadDemoApp());
}

class CpadDemoApp extends StatelessWidget {
  const CpadDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "namma kadai.com",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routes: {
        "/login": (_) => const LoginScreen(),
      },
      home: const AppEntryScreen(),
    );
  }
}

class AppEntryScreen extends StatefulWidget {
  const AppEntryScreen({super.key});

  @override
  State<AppEntryScreen> createState() => _AppEntryScreenState();
}

class _AppEntryScreenState extends State<AppEntryScreen> {
  final _authService = AuthService();
  bool _loading = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final token = await _authService.getToken();
    if (!mounted) {
      return;
    }
    setState(() {
      _loggedIn = token != null && token.isNotEmpty;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_loggedIn) {
      return const DashboardScreen();
    }

    return const LoginScreen();
  }
}
