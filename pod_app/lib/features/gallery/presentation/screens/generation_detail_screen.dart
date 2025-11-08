import 'package:flutter/material.dart';
import '../../../../core/models/generation_model.dart';

class GenerationDetailScreen extends StatelessWidget {
  final GenerationModel generation;
  
  const GenerationDetailScreen({super.key, required this.generation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generation Detail')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(generation.prompt),
            if (generation.imageUrl != null)
              Image.network(generation.imageUrl!),
          ],
        ),
      ),
    );
  }
}