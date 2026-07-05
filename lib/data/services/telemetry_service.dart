import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class TelemetryService {
  static Database? _database;
  static bool _fallbackMode = false;
  static final List<Map<String, dynamic>> _inMemoryFallback = [];

  static Future<void> initialize() async {
    if (kIsWeb) {
      _fallbackMode = true;
      _seedFallbackData();
      return;
    }

    try {
      final dbPath = await getDatabasesPath();
      final pathString = join(dbPath, 'telemetry.db');

      _database = await openDatabase(
        pathString,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE user_telemetry_local (
              event_id TEXT PRIMARY KEY,
              user_id TEXT,
              timestamp TEXT,
              event_type TEXT,
              unit_id INTEGER,
              node_id TEXT,
              phase TEXT,
              interaction_mode TEXT,
              duration_ms INTEGER,
              is_correct INTEGER,
              active_streak INTEGER,
              remaining_hearts INTEGER,
              session_id TEXT
            )
          ''');
        },
      );

      // Seed some initial telemetry data if the database is empty
      final countResult = await _database!.rawQuery('SELECT COUNT(*) as count FROM user_telemetry_local');
      final count = countResult.first['count'] as int;
      if (count == 0) {
        await _seedDatabase();
      }
    } catch (e) {
      debugPrint("Telemetry DB Initialization failed: $e. Falling back to in-memory mode.");
      _fallbackMode = true;
      _seedFallbackData();
    }
  }

  static Future<void> logEvent({
    required String eventType,
    required int unitId,
    required String nodeId,
    required String phase,
    required String interactionMode,
    required int durationMs,
    required bool isCorrect,
    required int activeStreak,
    required int remainingHearts,
  }) async {
    final event = {
      'event_id': const Uuid().v4(),
      'user_id': 'guest_user',
      'timestamp': DateTime.now().toIso8601String(),
      'event_type': eventType,
      'unit_id': unitId,
      'node_id': nodeId,
      'phase': phase,
      'interaction_mode': interactionMode,
      'duration_ms': durationMs,
      'is_correct': isCorrect ? 1 : 0,
      'active_streak': activeStreak,
      'remaining_hearts': remainingHearts,
      'session_id': 'session_guest',
    };

    if (_fallbackMode || _database == null) {
      _inMemoryFallback.add(event);
      return;
    }

    try {
      await _database!.insert('user_telemetry_local', event);
    } catch (e) {
      debugPrint("Failed to insert telemetry event: $e");
      _inMemoryFallback.add(event);
    }
  }

  static Future<List<Map<String, dynamic>>> runRawQuery(String query) async {
    if (_fallbackMode || _database == null) {
      // Very basic Mock SQL parser for in-memory testing (Web/Desktop fallback)
      return _runMockQuery(query);
    }

    try {
      return await _database!.rawQuery(query);
    } catch (e) {
      return [
        {'error': e.toString()}
      ];
    }
  }

  static List<Map<String, dynamic>> _runMockQuery(String query) {
    final cleaned = query.trim().toLowerCase();
    
    // Fallback Mock Query 1: SELECT * FROM user_telemetry_local
    if (cleaned.contains('select') && cleaned.contains('from user_telemetry_local')) {
      if (cleaned.contains('count(')) {
        return [{'count': _inMemoryFallback.length}];
      }
      
      // Basic grouping by day of week query from PRD: strftime('%w', timestamp) as day_of_week
      if (cleaned.contains('group by day_of_week') || cleaned.contains('strftime')) {
        // Return dummy analytics grouped by day of week
        return [
          {'day_of_week': '0', 'avg_speed': 4200, 'errors': 1},
          {'day_of_week': '1', 'avg_speed': 3800, 'errors': 2},
          {'day_of_week': '2', 'avg_speed': 3100, 'errors': 0},
          {'day_of_week': '3', 'avg_speed': 5200, 'errors': 4},
          {'day_of_week': '4', 'avg_speed': 2900, 'errors': 0},
          {'day_of_week': '5', 'avg_speed': 3500, 'errors': 1},
          {'day_of_week': '6', 'avg_speed': 4100, 'errors': 3},
        ];
      }

      return _inMemoryFallback;
    }
    
    return [
      {'error': 'SQL Syntax Error: Only SELECT queries from user_telemetry_local are supported in mock mode.'}
    ];
  }

  static Future<void> _seedDatabase() async {
    if (_database == null) return;
    for (var event in _getInitialSeedData()) {
      await _database!.insert('user_telemetry_local', event);
    }
  }

  static void _seedFallbackData() {
    _inMemoryFallback.addAll(_getInitialSeedData());
  }

  static List<Map<String, dynamic>> _getInitialSeedData() {
    final now = DateTime.now();
    return [
      {
        'event_id': 'seed_1',
        'user_id': 'guest_user',
        'timestamp': now.subtract(const Duration(days: 3)).toIso8601String(),
        'event_type': 'lesson_action',
        'unit_id': 1,
        'node_id': 'node_1.1',
        'phase': 'phase_1',
        'interaction_mode': 'multiple_choice',
        'duration_ms': 5400,
        'is_correct': 1,
        'active_streak': 1,
        'remaining_hearts': 5,
        'session_id': 'session_seed',
      },
      {
        'event_id': 'seed_2',
        'user_id': 'guest_user',
        'timestamp': now.subtract(const Duration(days: 3)).toIso8601String(),
        'event_type': 'lesson_action',
        'unit_id': 1,
        'node_id': 'node_1.2',
        'phase': 'phase_1',
        'interaction_mode': 'syntax_scramble',
        'duration_ms': 12000,
        'is_correct': 0,
        'active_streak': 1,
        'remaining_hearts': 4,
        'session_id': 'session_seed',
      },
      {
        'event_id': 'seed_3',
        'user_id': 'guest_user',
        'timestamp': now.subtract(const Duration(days: 2)).toIso8601String(),
        'event_type': 'lesson_action',
        'unit_id': 1,
        'node_id': 'node_1.2',
        'phase': 'phase_1',
        'interaction_mode': 'syntax_scramble',
        'duration_ms': 8500,
        'is_correct': 1,
        'active_streak': 2,
        'remaining_hearts': 4,
        'session_id': 'session_seed',
      },
      {
        'event_id': 'seed_4',
        'user_id': 'guest_user',
        'timestamp': now.subtract(const Duration(days: 1)).toIso8601String(),
        'event_type': 'lesson_action',
        'unit_id': 1,
        'node_id': 'node_1.3',
        'phase': 'phase_1',
        'interaction_mode': 'side_quest_opt_in',
        'duration_ms': 15000,
        'is_correct': 1,
        'active_streak': 3,
        'remaining_hearts': 5,
        'session_id': 'session_seed',
      },
      {
        'event_id': 'seed_5',
        'user_id': 'guest_user',
        'timestamp': now.toIso8601String(),
        'event_type': 'lesson_action',
        'unit_id': 1,
        'node_id': 'node_2.1',
        'phase': 'phase_1',
        'interaction_mode': 'multiple_choice',
        'duration_ms': 6200,
        'is_correct': 1,
        'active_streak': 4,
        'remaining_hearts': 5,
        'session_id': 'session_seed',
      },
    ];
  }
}
