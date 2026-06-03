import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_model.dart';

/// Service de stockage local pour l'historique et les préférences.
///
/// Utilise SharedPreferences pour persister les données
/// entre les sessions de l'application.
class StorageService {
  static const String _historyKey = 'quiz_history';
  static const String _themeKey = 'theme_mode';
  static const String _totalQuizzesKey = 'total_quizzes';
  static const String _totalCorrectKey = 'total_correct';
  static const String _totalQuestionsKey = 'total_questions_answered';
  static const String _streakKey = 'current_streak';
  static const String _lastQuizDateKey = 'last_quiz_date';
  static const String _bestScoreKey = 'best_score_percent';

  // ─── Historique ───

  /// Sauvegarde une entrée d'historique
  static Future<void> saveQuizHistory(QuizHistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();

    // Charger l'historique existant
    final history = await getQuizHistory();
    history.insert(0, entry); // Ajouter en premier (plus récent)

    // Limiter à 50 entrées
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    // Sauvegarder
    final jsonList = history.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);

    // Mettre à jour les stats globales
    await _updateGlobalStats(entry, prefs);
  }

  /// Charge tout l'historique des quiz
  static Future<List<QuizHistoryEntry>> getQuizHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];

    return jsonList.map((jsonStr) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return QuizHistoryEntry.fromJson(map);
    }).toList();
  }

  /// Supprime une entrée d'historique par ID
  static Future<void> deleteHistoryEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getQuizHistory();
    history.removeWhere((e) => e.id == id);
    final jsonList = history.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }

  /// Efface tout l'historique
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await prefs.remove(_totalQuizzesKey);
    await prefs.remove(_totalCorrectKey);
    await prefs.remove(_totalQuestionsKey);
    await prefs.remove(_streakKey);
    await prefs.remove(_lastQuizDateKey);
    await prefs.remove(_bestScoreKey);
  }

  // ─── Statistiques globales ───

  static Future<void> _updateGlobalStats(
    QuizHistoryEntry entry,
    SharedPreferences prefs,
  ) async {
    // Total de quiz
    final totalQuizzes = (prefs.getInt(_totalQuizzesKey) ?? 0) + 1;
    await prefs.setInt(_totalQuizzesKey, totalQuizzes);

    // Total bonnes réponses
    final totalCorrect = (prefs.getInt(_totalCorrectKey) ?? 0) + entry.score;
    await prefs.setInt(_totalCorrectKey, totalCorrect);

    // Total questions répondues
    final totalQuestions =
        (prefs.getInt(_totalQuestionsKey) ?? 0) + entry.totalQuestions;
    await prefs.setInt(_totalQuestionsKey, totalQuestions);

    // Meilleur score
    final bestScore = prefs.getDouble(_bestScoreKey) ?? 0;
    if (entry.percentage > bestScore) {
      await prefs.setDouble(_bestScoreKey, entry.percentage);
    }

    // Streak (jours consécutifs)
    final lastQuizDateStr = prefs.getString(_lastQuizDateKey);
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (lastQuizDateStr != null) {
      final lastDate = DateTime.parse(lastQuizDateStr);
      final difference = today.difference(lastDate).inDays;
      if (difference == 1) {
        // Jour consécutif
        final streak = (prefs.getInt(_streakKey) ?? 0) + 1;
        await prefs.setInt(_streakKey, streak);
      } else if (difference > 1) {
        // Streak cassé
        await prefs.setInt(_streakKey, 1);
      }
      // Si même jour, on ne change pas le streak
    } else {
      await prefs.setInt(_streakKey, 1);
    }
    await prefs.setString(_lastQuizDateKey, todayStr);
  }

  /// Récupère les statistiques globales
  static Future<Map<String, dynamic>> getGlobalStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'totalQuizzes': prefs.getInt(_totalQuizzesKey) ?? 0,
      'totalCorrect': prefs.getInt(_totalCorrectKey) ?? 0,
      'totalQuestions': prefs.getInt(_totalQuestionsKey) ?? 0,
      'currentStreak': prefs.getInt(_streakKey) ?? 0,
      'bestScore': prefs.getDouble(_bestScoreKey) ?? 0,
    };
  }

  // ─── Thème ───

  /// Sauvegarde le mode thème (0 = système, 1 = clair, 2 = sombre)
  static Future<void> saveThemeMode(int mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode);
  }

  /// Charge le mode thème
  static Future<int> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_themeKey) ?? 0; // 0 = système par défaut
  }
}
