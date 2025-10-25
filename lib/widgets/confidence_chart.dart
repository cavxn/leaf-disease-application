import 'package:flutter/material.dart';

class ConfidenceChart extends StatelessWidget {
  final double confidence;

  const ConfidenceChart({
    super.key,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (confidence * 100).round();
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$percentage%',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getConfidenceColor(confidence),
              ),
            ),
            Text(
              _getConfidenceLabel(confidence),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _getConfidenceColor(confidence),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: confidence,
          backgroundColor: theme.colorScheme.surface,
          valueColor: AlwaysStoppedAnimation<Color>(_getConfidenceColor(confidence)),
          minHeight: 8,
        ),
      ],
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getConfidenceLabel(double confidence) {
    if (confidence >= 0.8) return 'High Confidence';
    if (confidence >= 0.6) return 'Medium Confidence';
    return 'Low Confidence';
  }
} 