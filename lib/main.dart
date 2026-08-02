import 'package:flutter/material.dart';
import 'package:simple_blog/UI/Signup/signup.dart';


void main() {
  runApp(simpleBlog());
}

class simpleBlog extends StatelessWidget {
  const simpleBlog({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Signup()
    );
  }
}
