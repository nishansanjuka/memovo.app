import 'package:flutter/material.dart';

void main() {
  runApp(const MemovoApp());
}

class MemovoApp extends StatelessWidget {
  const MemovoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Welcome to Memovo',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
