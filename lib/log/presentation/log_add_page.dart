import 'package:flutter/material.dart';

class LogAddPage extends StatelessWidget {
  const LogAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add food')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            const TextField(
              decoration: InputDecoration(
                labelText: 'Search or enter item',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Save (stub)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
