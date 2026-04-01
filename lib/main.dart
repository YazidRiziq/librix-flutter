import 'package:flutter/material.dart';

void main() {
  runApp(const LibrixApp());
}

class LibrixApp extends StatelessWidget {
  const LibrixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Librix',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Librix Frontend Ready!'),
        ),
      ),
    );
  }
}