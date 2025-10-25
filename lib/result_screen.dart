import 'dart:io';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final File image;
  final String prediction;

  const ResultScreen({
    super.key,
    required this.image,
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prediction Result")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.file(image, height: 250),
            const SizedBox(height: 20),
            Text(
              "Predicted Class:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              prediction,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}