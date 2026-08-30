import 'package:flutter/material.dart';
import 'package:snacker/snacker.dart';

final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  runApp(const SnackerExampleApp());
}

class SnackerExampleApp extends StatelessWidget {
  const SnackerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snacker Example',
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final snacker = ScaffoldMessengerSnacker(_scaffoldMessengerKey);

    return Scaffold(
      appBar: AppBar(title: const Text('Snacker Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => snacker.showTextSnack(
            SnackData.error(message: 'This is an error snack'),
          ),
          child: const Text('Show Snack'),
        ),
      ),
    );
  }
}
