import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/quiz_provider.dart';
import '../utils/app_theme.dart';

/// Écran de quiz interactif avec design premium.
///
/// Affiche une question à la fois avec 4 options de réponse,
/// une barre de progression animée, et un bouton "Suivant".
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkBgGradient
              : AppTheme.lightBgGradient,
        ),
        child: SafeArea(
          child: Consumer<QuizProvider>(
            builder: (context, quizProvider, _) {
              final question = quizProvider.currentQuestion;
              if (question == null) return const SizedBox.shrink();

              return Column(
                children: [
                  // ─── Header bar ───
                  _buildHeader(context, quizProvider, isDark),

                  // ─── Contenu de la question ───
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Texte de la question
                          FadeInDown(
                            key: ValueKey(quizProvider.currentQuestionIndex),
                            duration: const Duration(milliseconds: 400),
                            child: _buildQuestionCard(
                                context, question, quizProvider, isDark),
                          ),

                          const SizedBox(height: 20),

                          // ─── Options de réponse ───
                          ...List.generate(question.options.length, (index) {
                            return FadeInUp(
                              key: ValueKey(
                                  '${quizProvider.currentQuestionIndex}_$index'),
                              delay: Duration(milliseconds: 100 + index * 80),
                              duration: const Duration(milliseconds: 400),
                              child: _buildOptionTile(
                                context,
                                question,
                                index,
                                quizProvider,
                                isDark,
                              ),
                            );
                          }),

                          // ─── Explication ───
                          if (question.isAnswered)
                            FadeInUp(
                              duration: const Duration(milliseconds: 500),
                              child:
                                  _buildExplanation(context, question, isDark),
                            ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),

                  // ─── Bouton Suivant ───
                  _buildBottomButton(context, question, quizProvider, isDark),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, QuizProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              // Bouton quitter
              GestureDetector(
                onTap: () => _showQuitDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 22,
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                  ),
                ),
              ),
              const Spacer(),

              // Compteur de question
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${provider.currentQuestionIndex + 1} / ${provider.totalQuestions}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),

              const Spacer(),

              // Score
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF00E676).withValues(alpha: 0.1)
                      : const Color(0xFF00E676).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00E676).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFF00E676), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.score}',
                      style: const TextStyle(
                        color: Color(0xFF00E676),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Barre de progression
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: provider.progress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6C63FF),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, dynamic question,
      QuizProvider provider, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.premiumCardDecoration(
        brightness: Theme.of(context).brightness,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.help_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            question.question,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  letterSpacing: -0.2,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, dynamic question, int index,
      QuizProvider provider, bool isDark) {
    final isSelected = question.selectedIndex == index;
    final isAnswered = question.isAnswered;
    final isCorrectOption = index == question.correctIndex;

    // Déterminer le style selon l'état
    LinearGradient? gradient;
    Color? borderColor;
    IconData? trailingIcon;
    Color? iconColor;

    if (isAnswered) {
      if (isCorrectOption) {
        gradient = LinearGradient(
          colors: [
            const Color(0xFF00E676).withValues(alpha: 0.12),
            const Color(0xFF00C853).withValues(alpha: 0.08),
          ],
        );
        borderColor = const Color(0xFF00E676).withValues(alpha: 0.5);
        trailingIcon = Icons.check_circle_rounded;
        iconColor = const Color(0xFF00E676);
      } else if (isSelected) {
        gradient = LinearGradient(
          colors: [
            const Color(0xFFFF5252).withValues(alpha: 0.12),
            const Color(0xFFD50000).withValues(alpha: 0.08),
          ],
        );
        borderColor = const Color(0xFFFF5252).withValues(alpha: 0.5);
        trailingIcon = Icons.cancel_rounded;
        iconColor = const Color(0xFFFF5252);
      }
    } else if (isSelected) {
      gradient = LinearGradient(
        colors: [
          const Color(0xFF6C63FF).withValues(alpha: 0.12),
          const Color(0xFF4158D0).withValues(alpha: 0.08),
        ],
      );
      borderColor = const Color(0xFF6C63FF).withValues(alpha: 0.5);
    }

    final letters = ['A', 'B', 'C', 'D'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: isAnswered ? null : () => provider.selectAnswer(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null
                ? (isDark ? const Color(0xFF1E1E36) : Colors.white)
                : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor ??
                  (isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.grey.shade200),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (borderColor ?? const Color(0xFF6C63FF))
                          .withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Lettre de l'option
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: isSelected && !isAnswered
                      ? AppTheme.primaryGradient
                      : null,
                  color: isSelected && !isAnswered
                      ? null
                      : (isAnswered && isCorrectOption
                          ? const Color(0xFF00E676).withValues(alpha: 0.15)
                          : (isAnswered && isSelected
                              ? const Color(0xFFFF5252)
                                  .withValues(alpha: 0.15)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.grey.shade100))),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    letters[index],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isSelected && !isAnswered
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.grey.shade700),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Texte de l'option
              Expanded(
                child: Text(
                  question.options[index],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        height: 1.4,
                      ),
                ),
              ),

              // Icône résultat
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, color: iconColor, size: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplanation(
      BuildContext context, dynamic question, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF00D9FF).withValues(alpha: 0.06)
              : const Color(0xFF6C63FF).withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? const Color(0xFF00D9FF).withValues(alpha: 0.15)
                : const Color(0xFF6C63FF).withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lightbulb_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Explication',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFF00D9FF)
                        : const Color(0xFF6C63FF),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.explanation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, dynamic question,
      QuizProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: question.isAnswered ? AppTheme.primaryGradient : null,
          color: question.isAnswered
              ? null
              : (isDark ? const Color(0xFF2A2A45) : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
          boxShadow: question.isAnswered
              ? [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: question.isAnswered ? provider.nextQuestion : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            provider.isLastQuestion
                ? 'Voir les résultats 🎉'
                : 'Question suivante →',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: question.isAnswered
                  ? Colors.white
                  : (isDark ? Colors.white24 : Colors.grey.shade400),
            ),
          ),
        ),
      ),
    );
  }

  void _showQuitDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E36) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Quitter le quiz ?'),
        content: const Text(
          'Votre progression sera perdue et ce quiz ne sera pas sauvegardé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.grey.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<QuizProvider>().resetQuiz();
            },
            child: const Text(
              'Quitter',
              style: TextStyle(
                color: Color(0xFFFF5252),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
