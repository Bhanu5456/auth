import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(authService: AuthService()),
        '/home': (context) => HomePage(),
      },
    );
  }
}

class AuthService {
  final String baseUrl = 'http://localhost:8000';
  late SharedPreferences _prefs;

  Future<bool> login(String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final token = responseData['access_token'];
      print(token);

      if (token != null && token is String) {
       
        // Save token to SharedPreferences
        _prefs = await SharedPreferences.getInstance();
        _prefs.setString('access_token', token);
        
        return true;
      } else {
        throw Exception('Token not found in response data');
      }
    } else {
      throw Exception('Failed to login. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print(e);
    throw Exception('Failed to login. Error: $e');
  }
}


  Future<void> logout() async {
    // Remove token from SharedPreferences
    _prefs = await SharedPreferences.getInstance();
    await _prefs.remove('token');
  }

  Future<String?> getToken() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.getString('token');
  }
}

class LoginPage extends StatefulWidget {
  final AuthService authService;

  const LoginPage({Key? key, required this.authService}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool loggedIn = await widget.authService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (loggedIn) {
        // Navigate to next screen upon successful login
        // Navigator.pushReplacementNamed(context, '/home');
        Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      // Handle login failure
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please try again.'),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Welcome!'),
      ),
    );
  }
}
