import 'package:flutter/material.dart';

class ComprovePage extends StatelessWidget {
  const ComprovePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprove'),
      ),
      body: Center(
        child: const Text(
          'Esta é a página Comprove!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
