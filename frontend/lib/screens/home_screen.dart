import 'package:flutter/material.dart';
import '../screens/add_session_screen.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color mintColor = const Color(0xFF7FC6A6);
  final Color lightMint = const Color(0xFFA3D9C9);

  String? userName;
  int? totalSessions;
  double? averageStress;
  bool loading = true;
  String? error;
  List<dynamic> recentSessions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { loading = true; error = null; });
    try {
      final auth = AuthService();
      final name = await auth.fetchNicknameFromBackend();
      final token = await auth.savedToken;
      if (token == null) throw Exception('Not authorized');
      final resp = await http.get(
        Uri.parse('${AuthService.baseUrl}/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final sessionsResp = await http.get(
        Uri.parse('${AuthService.baseUrl}/sessions'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (resp.statusCode == 200 && sessionsResp.statusCode == 200) {
        final data = json.decode(resp.body);
        final sessionsData = json.decode(sessionsResp.body) as List;
        setState(() {
          userName = name ?? 'User';
          totalSessions = data['total_sessions'] as int? ?? 0;
          averageStress = (data['average_stress'] as num?)?.toDouble() ?? 0.0;
          recentSessions = sessionsData.take(4).toList();
          loading = false;
        });
      } else if (resp.statusCode == 401 || resp.statusCode == 403 || sessionsResp.statusCode == 401 || sessionsResp.statusCode == 403) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } else {
        setState(() { error = 'Ошибка загрузки статистики или сессий'; loading = false; });
      }
    } catch (e) {
      if (e.toString().contains('Not authorized') && mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }
      setState(() { error = e.toString(); loading = false; });
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final weekdays = [
      'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
    ];
    final dayName   = weekdays[date.weekday - 1];
    final monthName = months[date.month   - 1];
    return '$dayName, $monthName ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stress Management', style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        )),
        backgroundColor: mintColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 22),
            tooltip: 'Logout',
            onPressed: () async {
              await AuthService().logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 28),
                          _buildStressIndicator(),
                          const SizedBox(height: 28),
                          _buildNewButtonsSection(context),
                          const SizedBox(height: 24),
                          _buildHistorySection(context),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hello, ${userName ?? "User"}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            )),
        const SizedBox(height: 6),
        Text(
          _formatDate(DateTime.now()),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStressIndicator() {
    final avg = averageStress ?? 0.0;
    final percent = (avg / 10).clamp(0.0, 1.0); // если шкала 0-10
    String levelText;
    Color indicatorColor;
    if (avg < 3) {
      levelText = 'Low';
      indicatorColor = const Color(0xFF8BC34A); // зелёный
    } else if (avg < 7) {
      levelText = 'Moderate';
      indicatorColor = const Color(0xFFFFB74D); // оранжевый
    } else {
      levelText = 'High';
      indicatorColor = const Color(0xFFE57373); // красный
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your Stress Level',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 18),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[100],
                  valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${(percent * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: indicatorColor,
                      )),
                  const SizedBox(height: 4),
                  Text(levelText,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLevelIndicator('Low', '0-30%', const Color(0xFF8BC34A)),
              _buildLevelIndicator('Moderate', '31-70%', const Color(0xFFFFB74D)),
              _buildLevelIndicator('High', '71-100%', const Color(0xFFE57373)),
            ],
          ),
          const SizedBox(height: 16),
          Text('Total sessions: ${totalSessions ?? 0}', style: TextStyle(color: Colors.grey[700], fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildLevelIndicator(String title, String range, Color color) {
    return Column(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        Text(range, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
      ],
    );
  }


  Widget _buildNewButtonsSection(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            //  "Add Session"
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/add_session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: mintColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: mintColor, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Add Session',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            //  "View Sessions"
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/sessions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: mintColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: mintColor, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'View Sessions',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // "Recommendations for relax"
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/recommendations'),
          style: ElevatedButton.styleFrom(
            backgroundColor: mintColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.spa, size: 20),
              SizedBox(width: 8),
              Text(
                'Recommendations for Relax',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    if (recentSessions.isEmpty) {
      return const Center(
        child: Text('There are no records, add the first session!'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent History',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/sessions'),
              child: Text(
                'View All',
                style: TextStyle(
                  color: mintColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recentSessions.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          final date = DateTime.parse(s['date'] as String? ?? '');
          final now = DateTime.now();
          final diff = now.difference(date).inDays;
          String dateLabel = diff == 0 ? 'Today' : '$diff days ago';
          final stressLevel = s['stress_level'] as int? ?? 0;
          final description = s['description'] as String? ?? '';
          final percent = (stressLevel / 10).clamp(0.0, 1.0);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.insights, color: mintColor, size: 20),
              ),
              title: Text(
                dateLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(description, style: const TextStyle(fontSize: 13)),
                    ),
                  LinearProgressIndicator(
                    value: percent,
                    minHeight: 6,
                    backgroundColor: Colors.grey[100],
                    valueColor: AlwaysStoppedAnimation<Color>(mintColor),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
              trailing: Text(
                '${(percent * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: mintColor,
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildHistoryItem(int index, double value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.insights, color: mintColor, size: 20),
        ),
        title: Text(
          '${index == 0 ? "Today" : "$index days ago"}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: Colors.grey[100],
            valueColor: AlwaysStoppedAnimation<Color>(mintColor),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        trailing: Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: mintColor,
          ),
        ),
      ),
    );
  }
}
