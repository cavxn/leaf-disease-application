import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreviewCard extends StatelessWidget {
  final File image;
  final VoidCallback onClear;

  const ImagePreviewCard({
    super.key,
    required this.image,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              image,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClear,
                iconSize: 20,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 