import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart'; // проверь, что здесь есть метод addSession
import 'home_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddSessionScreen extends StatefulWidget {
  const AddSessionScreen({super.key});

  @override
  State<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends State<AddSessionScreen> {
  final _descriptionController = TextEditingController();
  double _stressLevel = 5;
  DateTime _selectedDate = DateTime.now();
  final _storage = const FlutterSecureStorage();

  Future<void> _submit() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return;

    try {
      await AuthService().addSession(
        _descriptionController.text.trim(),
        _stressLevel.toInt(),
        _selectedDate,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Успешно сохранено'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить сессию')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Уровень стресса:'),
                Expanded(
                  child: Slider(
                    value: _stressLevel,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _stressLevel.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _stressLevel = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Дата: ${DateFormat.yMMMd().format(_selectedDate)}'),
                const Spacer(),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text('Изменить дату'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
