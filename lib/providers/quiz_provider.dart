import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/question_model.dart';
import '../services/storage_service.dart';


/// ============================================================
/// 🔑 CLÉ API OPENROUTER CHARGÉE DEPUIS LE FICHIER .ENV
/// ============================================================
String get _apiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';


/// URL de l'API OpenRouter
const String _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

/// Modèle IA à utiliser (rapide et performant)
const String _model = 'google/gemini-3.1-flash-lite';

/// États possibles du quiz
enum QuizState {
  /// L'utilisateur n'a pas encore lancé de quiz
  initial,

  /// L'IA est en train de générer les questions
  loading,

  /// Le quiz est prêt et l'utilisateur répond aux questions
  playing,

  /// Le quiz est terminé, affichage des résultats
  finished,

  /// Une erreur s'est produite
  error,
}

/// Provider principal gérant toute la logique du quiz.
///
/// Gère l'appel API, le parsing des questions, la navigation
/// entre les questions, le calcul du score, et l'historique.
class QuizProvider extends ChangeNotifier {
  // ─── État ───
  QuizState _state = QuizState.initial;
  QuizState get state => _state;

  List<QuestionModel> _questions = [];
  List<QuestionModel> get questions => _questions;

  int _currentQuestionIndex = 0;
  int get currentQuestionIndex => _currentQuestionIndex;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // ─── Timer ───
  DateTime? _quizStartTime;
  Duration _quizDuration = Duration.zero;
  Duration get quizDuration => _quizDuration;

  // ─── Texte du cours ───
  String _courseText = '';
  String get courseText => _courseText;

  // ─── Historique ───
  List<QuizHistoryEntry> _history = [];
  List<QuizHistoryEntry> get history => _history;

  // ─── Stats globales ───
  Map<String, dynamic> _globalStats = {};
  Map<String, dynamic> get globalStats => _globalStats;

  QuizProvider() {
    _loadHistory();
    _loadStats();
  }

  // ─── Getters utilitaires ───

  /// Question actuellement affichée
  QuestionModel? get currentQuestion =>
      _questions.isNotEmpty ? _questions[_currentQuestionIndex] : null;

  /// Nombre total de questions
  int get totalQuestions => _questions.length;

  /// Progression (entre 0.0 et 1.0)
  double get progress =>
      totalQuestions > 0 ? (_currentQuestionIndex + 1) / totalQuestions : 0;

  /// Score final : nombre de bonnes réponses
  int get score => _questions.where((q) => q.isCorrect).length;

  /// Vérifie si on est à la dernière question
  bool get isLastQuestion => _currentQuestionIndex >= totalQuestions - 1;

  /// Pourcentage du score
  double get scorePercentage =>
      totalQuestions > 0 ? score / totalQuestions * 100 : 0;

  // ─── Actions ───

  /// Charge l'historique depuis le stockage local
  Future<void> _loadHistory() async {
    _history = await StorageService.getQuizHistory();
    notifyListeners();
  }

  /// Charge les statistiques globales
  Future<void> _loadStats() async {
    _globalStats = await StorageService.getGlobalStats();
    notifyListeners();
  }

  /// Rafraîchit l'historique et les stats
  Future<void> refreshData() async {
    await _loadHistory();
    await _loadStats();
  }

  /// Génère un quiz en envoyant le texte du cours à l'API OpenRouter.
  ///
  /// [courseText] : le texte du cours collé par l'utilisateur
  /// [numberOfQuestions] : nombre de questions souhaitées (5, 10, ou 15)
  /// [difficulty] : Niveau de difficulté (Facile, Moyen, Difficile)
  Future<void> generateQuiz(String courseText, int numberOfQuestions, String difficulty) async {
    // Passer en état de chargement
    _state = QuizState.loading;
    _questions = [];
    _currentQuestionIndex = 0;
    _errorMessage = '';
    _courseText = courseText;
    notifyListeners();

    try {
      // Construction du prompt système strict pour forcer le JSON
      final systemPrompt =
          '''
Tu es un expert en pédagogie et en création de quiz éducatifs.
À partir du texte de cours fourni par l'utilisateur, génère exactement $numberOfQuestions questions à choix multiples de niveau "$difficulty".

RÈGLES STRICTES :
- Chaque question doit avoir exactement 4 options de réponse.
- Une seule réponse est correcte par question.
- L'explication doit être claire et concise.
- TRÈS IMPORTANT : La position de la bonne réponse (l'index "correctIndex") DOIT être diversifiée et aléatoire entre 0, 1, 2 et 3. Ne place jamais systématiquement la bonne réponse au même endroit (évite de mettre que des "0" ou que des A). Diversifie équitablement.
- Tu DOIS répondre UNIQUEMENT avec du JSON valide, sans aucun texte supplémentaire, sans markdown, sans backticks.
- Le format JSON est le suivant :
{
  "questions": [
    {
      "question": "Le texte de la question ?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correctIndex": 0,
      "explanation": "Explication de la bonne réponse"
    }
  ]
}
''';

      // Appel à l'API OpenRouter
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://quizgenius.app',
          'X-Title': 'Quiz-Genius',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {
              'role': 'user',
              'content':
                  'Voici mon cours. Génère $numberOfQuestions questions à choix multiples :\n\n$courseText',
            },
          ],
          'temperature': 0.7,
          'max_tokens': 4000,
        }),
      );

      // Vérification du code de réponse HTTP
      if (response.statusCode != 200) {
        throw Exception(
          'Erreur API (${response.statusCode}): ${response.body}',
        );
      }

      // Parsing de la réponse OpenRouter
      final responseData = jsonDecode(response.body);
      final content =
          responseData['choices'][0]['message']['content'] as String;

      // Nettoyage du contenu (suppression des éventuels backticks markdown)
      String cleanedContent = content.trim();
      if (cleanedContent.startsWith('```json')) {
        cleanedContent = cleanedContent.substring(7);
      }
      if (cleanedContent.startsWith('```')) {
        cleanedContent = cleanedContent.substring(3);
      }
      if (cleanedContent.endsWith('```')) {
        cleanedContent = cleanedContent.substring(0, cleanedContent.length - 3);
      }
      cleanedContent = cleanedContent.trim();

      // Parsing du JSON des questions
      final questionsJson = jsonDecode(cleanedContent);
      final List<dynamic> questionsList = questionsJson['questions'];

      _questions = questionsList.map((q) => QuestionModel.fromJson(q)).toList();

      if (_questions.isEmpty) {
        throw Exception("L'IA n'a généré aucune question.");
      }

      // Démarrer le timer
      _quizStartTime = DateTime.now();
      _state = QuizState.playing;
    } catch (e) {
      _state = QuizState.error;
      
      final errorStr = e.toString();
      if (errorStr.contains('SocketException') || errorStr.contains('Failed host lookup')) {
        _errorMessage = 'Problème de connexion. Veuillez vérifier votre accès à Internet.';
      } else if (errorStr.contains('TimeoutException')) {
        _errorMessage = 'Le délai d\'attente est dépassé. Le serveur met trop de temps à répondre. Réessayez.';
      } else if (errorStr.contains('Erreur API (401)') || errorStr.contains('Erreur API (403)')) {
        _errorMessage = 'Erreur d\'autorisation avec l\'API. Veuillez vérifier votre clé API OpenRouter.';
      } else if (errorStr.contains('Erreur API (429)')) {
        _errorMessage = 'Vous avez atteint la limite de requêtes avec l\'API OpenRouter. Veuillez réessayer plus tard.';
      } else if (errorStr.contains('FormatException') || errorStr.contains('JSON') || errorStr.contains('Expected a value') || errorStr.contains('type \'String\' is not a subtype')) {
        _errorMessage = 'L\'IA a généré une réponse incohérente ou qui n\'a pas pu être lue. Veuillez recommencer la génération.';
      } else {
        _errorMessage = 'Une erreur rare est survenue : \$errorStr';
      }

      if (kDebugMode) {
        print('❌ Erreur QuizProvider: \$e');
      }
    }

    notifyListeners();
  }

  /// Sélectionne une réponse pour la question actuelle.
  void selectAnswer(int index) {
    if (currentQuestion != null && !currentQuestion!.isAnswered) {
      currentQuestion!.selectedIndex = index;
      notifyListeners();
    }
  }

  /// Passe à la question suivante, ou termine le quiz.
  void nextQuestion() {
    if (isLastQuestion) {
      _finishQuiz();
    } else {
      _currentQuestionIndex++;
    }
    notifyListeners();
  }

  /// Termine le quiz et sauvegarde dans l'historique
  Future<void> _finishQuiz() async {
    _state = QuizState.finished;

    // Calculer la durée
    if (_quizStartTime != null) {
      _quizDuration = DateTime.now().difference(_quizStartTime!);
    }

    // Créer l'entrée d'historique
    final entry = QuizHistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      score: score,
      totalQuestions: totalQuestions,
      coursePreview: _courseText.length > 100
          ? '${_courseText.substring(0, 100)}...'
          : _courseText,
      questions: _questions,
      duration: _quizDuration,
    );

    // Sauvegarder
    await StorageService.saveQuizHistory(entry);
    await _loadHistory();
    await _loadStats();
  }

  /// Supprime une entrée d'historique
  Future<void> deleteHistoryEntry(String id) async {
    await StorageService.deleteHistoryEntry(id);
    await _loadHistory();
  }

  /// Efface tout l'historique
  Future<void> clearHistory() async {
    await StorageService.clearHistory();
    _history = [];
    _globalStats = {};
    notifyListeners();
  }

  /// Réinitialise complètement le quiz pour revenir à l'écran d'accueil.
  void resetQuiz({bool clearText = false}) {
    _state = QuizState.initial;
    _questions = [];
    _currentQuestionIndex = 0;
    _errorMessage = '';
    _quizStartTime = null;
    _quizDuration = Duration.zero;
    if (clearText) {
      _courseText = '';
    }
    notifyListeners();
  }
}
