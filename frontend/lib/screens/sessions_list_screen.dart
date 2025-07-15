import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

class Session {
  final int id;
  final String description;
  final int stressLevel;
  final DateTime date;

  Session({
    required this.id,
    required this.description,
    required this.stressLevel,
    required this.date,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id'] ?? json['ID'] as int,
        description: json['description'] as String? ?? '',
        stressLevel: json['stress_level'] as int? ?? 0,
        date: DateTime.parse(json['date'] as String? ?? ''),
      );
}

class SessionsService {
  
  static Future<List<Session>> fetchSessions() async {
    final token = await AuthService().savedToken;
    if (token == null) throw Exception('The token was not found');

    final resp = await http.get(
      Uri.parse('${AuthService.baseUrl}/sessions'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body) as List;
      return data.map((e) => Session.fromJson(e)).toList();
    }
    throw Exception('Download error:  [${resp.statusCode}');
  }

  static Future<void> deleteSession(int id) async {
    final token = await AuthService().savedToken;
    if (token == null) throw Exception('The token was not found');
    final resp = await http.delete(
      Uri.parse('${AuthService.baseUrl}/session/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode != 200) {
      throw Exception('Delete error: ${resp.statusCode}');
    }
  }
}

// UI LAYER

class SessionsListScreen extends StatefulWidget {
  const SessionsListScreen({super.key});

  @override
  State<SessionsListScreen> createState() => _SessionsListScreenState();
}

class _SessionsListScreenState extends State<SessionsListScreen> {
  late StreamController<List<Session>> _sessionsController;
  late List<Session> _sessions;
  WebSocketChannel? _channel;
  StreamSubscription? _wsSubscription;

  @override
  void initState() {
    super.initState();
    _sessionsController = StreamController<List<Session>>.broadcast();
    _sessions = [];
    _loadSessions();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _channel?.sink.close();
    _sessionsController.close();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    try {
      final sessions = await SessionsService.fetchSessions();
      _sessions = sessions;
      _sessionsController.add(List.from(_sessions));
    } catch (e) {
      _sessionsController.addError(e);
    }
  }

  void _connectWebSocket() {
    final url = 'ws://localhost:8080/ws';
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _wsSubscription = _channel!.stream.listen((event) {
      try {
        final data = jsonDecode(event);
        if (data is Map && data['event'] == 'new_session') {
          final sessionJson = data['session'] as Map<String, dynamic>;
          final newSession = Session.fromJson(sessionJson);
          // Проверяем, нет ли уже такой сессии (например, если это наша)
          if (!_sessions.any((s) => s.id == newSession.id)) {
            _sessions.insert(0, newSession); // добавляем в начало
            _sessionsController.add(List.from(_sessions));
          }
        }
      } catch (_) {}
    });
  }

  Future<void> _deleteSessionWithConfirm(Session session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить сессию?'),
        content: const Text('Вы точно хотите удалить эту сессию?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await SessionsService.deleteSession(session.id);
        _sessions.removeWhere((s) => s.id == session.id);
        _sessionsController.add(List.from(_sessions));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка удаления: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mintColor = const Color(0xFF7FC6A6);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: mintColor,
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Назад',
        ),
        title: const SizedBox.shrink(), // убираем стандартный заголовок
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // листва сверху‑справа
          Positioned(
            top: -30,
            right: -10,
            child: Image.asset('assets/images/leaf_top.png', width: 180),
          ),
          // листва снизу‑слева
          Positioned(
            bottom: -20,
            left: -20,
            child: Image.asset('assets/images/leaf_bottom.png', width: 200),
          ),
          // контент
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'List of sessions',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<List<Session>>(
                      stream: _sessionsController.stream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              snapshot.error.toString(),
                              style: const TextStyle(color: Colors.redAccent),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        final sessions = snapshot.data ?? [];
                        if (sessions.isEmpty) {
                          return const Center(
                            child: Text('There are no records, add the first session!'),
                          );
                        }
                        return ListView.builder(
                          itemCount: sessions.length,
                          itemBuilder: (context, i) {
                            final s = sessions[i];
                            return _SessionCard(
                              session: s,
                              onDelete: () => _deleteSessionWithConfirm(s),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, this.onDelete});

  final Session session;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // уровень стресса как бейдж
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF7FC6A6),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              session.stressLevel.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // описание + дата
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDate(session.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Удалить',
              onPressed: onDelete,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}
