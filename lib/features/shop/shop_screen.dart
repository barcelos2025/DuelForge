import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loja')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Placeholder v0.1\n\nNo v0.2: recursos (ouro/cristais), baús, cosméticos (versos, arenas) e pacotes.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
      ),
    );
  }
}
