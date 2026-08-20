import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:email_validator/email_validator.dart';
import 'package:simple_blog/UI/BaceFook.dart';
import 'package:simple_blog/services/services.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _key = GlobalKey<FormState>();
  final _services = AuthService();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isloading = false;
  String? _errorMessage;
  Future<void> _signUp() async {
    if (_key.currentState!.validate()) {
      setState(() {
        _isloading = true;
        _errorMessage = null;
      });
      try {
        final response = await _services.signUp(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (response.user != null) {
          context.go('/BaceFook/Login');
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
                    'Sign Up',
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
                      final passRegex = RegExp(
                        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{8,}$',
                      );
                      if (password != null && passRegex.hasMatch(password)) {
                        return null;
                      }
                      return '''
Password needs to have at least 8 characters
1 uppercase letter 
1 lowercase letter 
1 number
1 special character''';
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
                  TextButton(
                    onPressed: _isloading ? null : _signUp,

                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 4, 1, 124),
                    ),
                    child: _isloading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Color.fromARGB(255, 90, 181, 250),
                              fontSize: 16,
                            ),
                          ),
                  ),
                  SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: Color.fromARGB(255, 90, 181, 250),
                          fontSize: 12,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/BaceFook/Login'),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                        ),
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            color: Color.fromARGB(255, 90, 181, 250),
                            fontSize: 12,
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
