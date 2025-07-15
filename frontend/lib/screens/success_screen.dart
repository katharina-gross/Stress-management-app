import 'package:flutter/material.dart';
import '../models/advice.dart';

class SuccessScreen extends StatelessWidget {
  final Advice advice;

  const SuccessScreen({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Готово'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Сессия успешно сохранена',
              style: theme.titleLarge,
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Smart recommendations',
                style: theme.titleMedium,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      advice.title,
                      style: theme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      advice.description,
                      style: theme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
