import 'dart:convert';
import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class Token {
  final String? accessToken;
  final String? idToken;

  Token({required this.accessToken, required this.idToken});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(onPressed: _getRequest, child: Text('Get request')),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: _postRequest, child: Text('Post request')),
          ],
        ),
      ),
    );
  }

  Future<void> _getRequest() async {
    // Generate a fake JWT token
    String token = _generateToken();

    // Send a get request to the server
    try {
      final response = await http.get(Uri.http('localhost:3456'), headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      });
      if (response.statusCode == 200) {
        debugPrint('Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error: $e');
      return;
    }
  }

  Future<void> _postRequest() async {
    // Generate a fake JWT token
    String token = _generateToken();

    // Send a post request to the server
    try {
      final response = await http.post(Uri.http('localhost:3456'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'Bearer $token',
          },
          body: jsonEncode({'body': 'Show me!'}));
      if (response.statusCode == 200) {
        // If the server returns an OK response, parse the JSON
        final jsonResponse = jsonDecode(response.body);
        debugPrint('Response: $jsonResponse');
      }
    } catch (e) {
      debugPrint('Error: $e');
      return;
    }
  }
}

String _generateToken() {
  // Create a fake JWT signed token to simulate a login.
  // At some point, this should be replaced with a real JWT token.
  return JWT({'app_secret': '1234567890'}).sign(SecretKey('secret passphrase'));
}
