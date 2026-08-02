import 'package:flutter/material.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'BaceFook',
            style: TextStyle(
              color: Color.fromARGB(255, 90, 181, 250),
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 0, 21, 38),
        ),
        
        body: Align(
          alignment: AlignmentGeometry.topCenter,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500.00),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  TextButton(onPressed: () {}, style: TextButton.styleFrom(backgroundColor:   const Color.fromARGB(255, 4, 1, 124)),child: Text('Create Account', style: TextStyle(color: Color.fromARGB(255,90,181,250), fontSize: 16))),
                  SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Already have an account?', 
                      style: TextStyle(
                      color: Color.fromARGB(255, 90, 181, 250),
                          fontSize: 12,
                        ),
                        ),
                      TextButton(onPressed:() => (), style: TextButton.styleFrom(backgroundColor: Colors.transparent), 
                      child: Text('Sign in', style: TextStyle(color: Color.fromARGB(255,90,181,250), fontSize: 12))
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 21, 38),
      );
  }
}