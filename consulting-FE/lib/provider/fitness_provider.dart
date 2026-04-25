import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:consulting_fe/api/fitness_api.dart';
import 'package:consulting_fe/api/models/fitness_models.dart';
import 'package:consulting_fe/mock/mock_fitness.dart';

class FitnessProvider extends ChangeNotifier {
  static const _kPlanKey = 'fitness_plan_v1';
  static const _kPromptKey = 'fitness_prompt_v1';

  FitnessResponse? _plan;
  FitnessPrompt? _savedPrompt;
  bool _loading = false;
  String? _error;

  FitnessResponse? get plan => _plan;
  FitnessPrompt? get savedPrompt => _savedPrompt;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasPlan => _plan != null;
  bool get hasProfile => _savedPrompt != null;

  // ── Derived helpers ──────────────────────────────────────────────────────

  /// Today's daily plan, or null if no plan loaded.
  DailyPlan? get todayPlan {
    if (_plan == null) return null;
    final today = DateTime.now();
    try {
      return _plan!.daily.firstWhere(
        (d) =>
            d.date.year == today.year &&
            d.date.month == today.month &&
            d.date.day == today.day,
      );
    } catch (_) {
      return _plan!.daily.isNotEmpty ? _plan!.daily.first : null;
    }
  }

  /// Returns daily plans for the current calendar week (Mon–Sun).
  List<DailyPlan?> get thisWeekDays {
    if (_plan == null) return List.filled(7, null);
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) {
      final target = monday.add(Duration(days: i));
      try {
        return _plan!.daily.firstWhere(
          (d) =>
              d.date.year == target.year &&
              d.date.month == target.month &&
              d.date.day == target.day,
        );
      } catch (_) {
        return null;
      }
    });
  }

  /// The WeeklyPlan that covers today (by week number, 1-indexed).
  WeeklyPlan? get currentWeekPlan {
    if (_plan == null || _plan!.weekly.isEmpty) return null;
    final now = DateTime.now();
    final planStart = _plan!.daily.isNotEmpty ? _plan!.daily.first.date : now;
    final weekIndex = now.difference(planStart).inDays ~/ 7;
    if (weekIndex < _plan!.weekly.length) return _plan!.weekly[weekIndex];
    return _plan!.weekly.last;
  }

  // ── Public actions ───────────────────────────────────────────────────────

  /// Signal that a plan is being loaded (call before navigating to HomePage).
  void startLoading() {
    _loading = true;
    _error = null;
    notifyListeners();
  }

  /// Load mock data instantly — no network required.
  void loadMock() {
    _plan = MockFitness.response();
    _savedPrompt = MockFitness.prompt;
    _loading = false;
    notifyListeners();
  }

  /// Load persisted plan + prompt from SharedPreferences (call on app start).
  Future<void> loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final planJson = prefs.getString(_kPlanKey);
    final promptJson = prefs.getString(_kPromptKey);
    bool changed = false;

    if (planJson != null) {
      try {
        _plan = FitnessResponse.fromJson(
          jsonDecode(planJson) as Map<String, dynamic>,
        );
        changed = true;
      } catch (_) {}
    }
    if (promptJson != null) {
      try {
        _savedPrompt = FitnessPrompt.fromJson(
          jsonDecode(promptJson) as Map<String, dynamic>,
        );
        changed = true;
      } catch (_) {}
    }

    if (changed) notifyListeners();
  }

  /// Call POST /test with the given prompt, persist result, and notify.
  Future<void> generatePlan(FitnessPrompt prompt) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _plan = await FitnessApi.instance.generatePlan(prompt);
      _savedPrompt = prompt;
      await _persist();
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Wipe cached plan + prompt so the app restarts onboarding on next launch.
  Future<void> clearPlan() async {
    _plan = null;
    _savedPrompt = null;
    _loading = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPlanKey);
    await prefs.remove(_kPromptKey);
    notifyListeners();
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  Future<void> _persist() async {
    if (_plan == null || _savedPrompt == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPlanKey, jsonEncode(_plan!.toJson()));
    await prefs.setString(_kPromptKey, jsonEncode(_savedPrompt!.toJson()));
  }
}
