import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gymnázium Kladno | Přihlášení',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  Future<void> login() async {
    final String username = usernameController.text;
    final String password = passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('https://magistri.melonhost.cz/api/teachers/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final String loginToken = jsonResponse['token'];

        // Navigate to the dashboard
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(token: loginToken),
          ),
        );
      } else {
        setState(() {
          errorMessage = 'Login failed. Please check your credentials.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gymnázium Kladno | Přihlášení'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/logo.png', width: 300),
              SizedBox(height: 20),
              // Username field inside a container with width 200px
              Container(
                width: 400,
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Uživatelské jméno',
                    errorText: errorMessage.isNotEmpty ? errorMessage : null,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Password field inside a container with width 200px
              Container(
                width: 400,
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Heslo',
                    errorText: errorMessage.isNotEmpty ? errorMessage : null,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: login,
                child: Text('Přihlásit se'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(350, 40),
                  backgroundColor: Color(0xFF4290F1), // Button color
                  foregroundColor: Colors.white, // Text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
