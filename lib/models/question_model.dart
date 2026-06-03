import 'dart:convert';

/// Modèle de données représentant une question de quiz.
///
/// Chaque question contient le texte de la question, 4 options de réponse,
/// l'index de la bonne réponse, et une explication détaillée.
class QuestionModel {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  /// Réponse sélectionnée par l'utilisateur (-1 = pas encore répondu)
  int selectedIndex;

  QuestionModel({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.selectedIndex = -1,
  });

  /// Crée une instance de [QuestionModel] à partir d'un objet JSON
  /// retourné par l'API OpenRouter.
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String,
      selectedIndex: json['selectedIndex'] as int? ?? -1,
    );
  }

  /// Convertit en JSON pour la sauvegarde locale
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
      'selectedIndex': selectedIndex,
    };
  }

  /// Vérifie si la réponse de l'utilisateur est correcte.
  bool get isCorrect => selectedIndex == correctIndex;

  /// Vérifie si l'utilisateur a déjà répondu à cette question.
  bool get isAnswered => selectedIndex != -1;
}

/// Modèle pour l'historique d'un quiz complété
class QuizHistoryEntry {
  final String id;
  final DateTime date;
  final int score;
  final int totalQuestions;
  final String coursePreview;
  final List<QuestionModel> questions;
  final Duration duration;

  QuizHistoryEntry({
    required this.id,
    required this.date,
    required this.score,
    required this.totalQuestions,
    required this.coursePreview,
    required this.questions,
    required this.duration,
  });

  double get percentage => totalQuestions > 0 ? score / totalQuestions * 100 : 0;

  String get grade {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  factory QuizHistoryEntry.fromJson(Map<String, dynamic> json) {
    return QuizHistoryEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      score: json['score'] as int,
      totalQuestions: json['totalQuestions'] as int,
      coursePreview: json['coursePreview'] as String,
      questions: (jsonDecode(json['questions'] as String) as List)
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
      duration: Duration(seconds: json['durationSeconds'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'score': score,
      'totalQuestions': totalQuestions,
      'coursePreview': coursePreview,
      'questions': jsonEncode(questions.map((q) => q.toJson()).toList()),
      'durationSeconds': duration.inSeconds,
    };
  }
}
