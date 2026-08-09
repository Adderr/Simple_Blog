import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_blog/UI/BaceFook.dart';
import 'package:simple_blog/services/services.dart';
import 'package:email_validator/email_validator.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _key = GlobalKey<FormState>();
  final _services = AuthService();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isloading = false;
  String? _errorMessage;
  Future<void> _signIn() async {
    if (_key.currentState!.validate()) {
      setState(() {
        _isloading = true;
        _errorMessage = null;
      });
      try {
        final response = await _services.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (response.user != null) {
          if (mounted) {
            context.go('/');
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        setState(() {
          _isloading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaceFook(),
      body: Form(
        key: _key,
        child: Align(
          alignment: AlignmentGeometry.topCenter,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500.00),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  SizedBox(height: 100.0),
                  Text(
                    'Sign In',
                    style: TextStyle(
                      color: Color.fromARGB(255, 90, 181, 250),
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _emailController,
                    validator: (email) {
                      if (email != null && EmailValidator.validate(email)) {
                        return null;
                      }
                      return 'Invalid email';
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Enter your email',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 90, 181, 250),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 90, 181, 250),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 90, 181, 250),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: _passwordController,
                    validator: (password) {
                      if (password == null || password.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },

                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Enter your password',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 90, 181, 250),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 90, 181, 250),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 90, 181, 250),
                        ),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: _isloading ? null : _signIn,
                        style: TextButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 4, 1, 124),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Color.fromARGB(255, 90, 181, 250),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/BaceFook/Signup'),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                        ),
                        child: Text(
                          'Signup',
                          style: TextStyle(
                            color: Color.fromARGB(255, 90, 181, 250),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 0, 21, 38),
    );
  }
}
