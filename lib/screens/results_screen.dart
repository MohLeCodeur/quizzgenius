import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/quiz_provider.dart';
import '../utils/app_theme.dart';

/// Écran des résultats du quiz avec design premium.
///
/// Affiche le score final avec animations, un résumé visuel,
/// et la liste complète des questions avec les réponses.
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quizProvider = context.read<QuizProvider>();
    final score = quizProvider.score;
    final total = quizProvider.totalQuestions;
    final percentage = (score / total * 100).round();
    final duration = quizProvider.quizDuration;

    // Déterminer le style selon le score
    String emoji;
    String message;
    String subtitle;
    LinearGradient gradient;

    if (percentage >= 80) {
      emoji = '🏆';
      message = 'Excellent !';
      subtitle = 'Vous maîtrisez ce sujet !';
      gradient = AppTheme.successGradient;
    } else if (percentage >= 60) {
      emoji = '👏';
      message = 'Bien joué !';
      subtitle = 'Encore un petit effort !';
      gradient = const LinearGradient(
        colors: [Color(0xFF00D9FF), Color(0xFF6C63FF)],
      );
    } else if (percentage >= 40) {
      emoji = '💪';
      message = 'Pas mal !';
      subtitle = 'Continuez à réviser';
      gradient = AppTheme.warmGradient;
    } else {
      emoji = '📚';
      message = 'À réviser';
      subtitle = 'Relisez votre cours et réessayez';
      gradient = AppTheme.errorGradient;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkBgGradient : AppTheme.lightBgGradient,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),

              // ─── Header Score Card ───
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: _buildScoreCard(
                  context,
                  isDark,
                  score,
                  total,
                  percentage,
                  emoji,
                  message,
                  subtitle,
                  gradient,
                  duration,
                ),
              ),

              const SizedBox(height: 24),

              // ─── Actions ───
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 500),
                child: _buildActions(context, isDark),
              ),

              const SizedBox(height: 28),

              // ─── Titre section détails ───
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 500),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.fact_check_rounded,
                        color: Color(0xFF6C63FF),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Détail des réponses',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── Liste des questions ───
              ...List.generate(quizProvider.questions.length, (index) {
                return FadeInUp(
                  delay: Duration(milliseconds: 400 + index * 80),
                  duration: const Duration(milliseconds: 500),
                  child: _buildQuestionResult(
                    context,
                    quizProvider.questions[index],
                    index,
                    isDark,
                  ),
                );
              }),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(
    BuildContext context,
    bool isDark,
    int score,
    int total,
    int percentage,
    String emoji,
    String message,
    String subtitle,
    LinearGradient gradient,
    Duration duration,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradient.colors[0].withValues(alpha: isDark ? 0.2 : 0.12),
            gradient.colors[1].withValues(alpha: isDark ? 0.08 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: gradient.colors[0].withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.colors[0].withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Emoji
          Text(emoji, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 16),

          // Score circulaire
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 8,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.grey.shade200,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(gradient.colors[0]),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          gradient.createShader(bounds),
                      child: Text(
                        '$percentage%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '$score / $total',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white38 : Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Message
          ShaderMask(
            shaderCallback: (bounds) => gradient.createShader(bounds),
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 16),

          // Durée
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => context.read<QuizProvider>().resetQuiz(),
              icon: const Icon(Icons.replay_rounded, color: Colors.white),
              label: const Text(
                'Nouveau Quiz',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionResult(
    BuildContext context,
    dynamic question,
    int index,
    bool isDark,
  ) {
    final isCorrect = question.isCorrect;
    final userAnswer = question.selectedIndex >= 0
        ? question.options[question.selectedIndex]
        : 'Non répondu';
    final correctAnswer = question.options[question.correctIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E36) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isCorrect
                      ? AppTheme.successGradient
                      : AppTheme.errorGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCorrect
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Q${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                isCorrect ? 'Correct ✅' : 'Incorrect ❌',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: isCorrect
                      ? const Color(0xFF00E676)
                      : const Color(0xFFFF5252),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Question
          Text(
            question.question,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 14),

          // Réponse de l'utilisateur
          _buildAnswerRow(
            context,
            'Votre réponse',
            userAnswer,
            isCorrect ? const Color(0xFF00E676) : const Color(0xFFFF5252),
            isDark,
          ),

          // Bonne réponse (si erreur)
          if (!isCorrect) ...[
            const SizedBox(height: 8),
            _buildAnswerRow(
              context,
              'Bonne réponse',
              correctAnswer,
              const Color(0xFF00E676),
              isDark,
            ),
          ],

          const SizedBox(height: 12),

          // Explication
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF00D9FF).withValues(alpha: 0.05)
                  : const Color(0xFF6C63FF).withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF00D9FF).withValues(alpha: 0.1)
                    : const Color(0xFF6C63FF).withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_rounded,
                      size: 14,
                      color: isDark
                          ? const Color(0xFF00D9FF)
                          : const Color(0xFF6C63FF),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Explication',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF00D9FF)
                            : const Color(0xFF6C63FF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  question.explanation,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.5,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerRow(
    BuildContext context,
    String label,
    String answer,
    Color color,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Text(
            '$label : ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
          ),
          Expanded(
            child: Text(
              answer,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}min ${seconds}s';
    }
    return '${seconds}s';
  }
}
