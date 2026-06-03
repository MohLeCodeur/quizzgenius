import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/quiz_provider.dart';
import '../utils/app_theme.dart';

/// Écran de statistiques avec graphiques.
///
/// Affiche les stats globales de l'utilisateur :
/// total de quiz, score moyen, meilleur score, streak,
/// et un graphique de l'évolution des scores.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

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
            builder: (context, provider, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Header ───
                    FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: _buildHeader(context, isDark),
                    ),

                    const SizedBox(height: 24),

                    // ─── Stats Cards ───
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 500),
                      child: _buildStatsGrid(context, provider, isDark),
                    ),

                    const SizedBox(height: 24),

                    // ─── Graphique d'évolution ───
                    if (provider.history.length >= 2)
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        duration: const Duration(milliseconds: 500),
                        child: _buildChart(context, provider, isDark),
                      ),

                    const SizedBox(height: 24),

                    // ─── Répartition des scores ───
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      duration: const Duration(milliseconds: 500),
                      child: _buildScoreDistribution(
                          context, provider, isDark),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: AppTheme.warmGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.insights_rounded,
              color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            ),
            Text(
              'Votre progression',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey.shade500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
      BuildContext context, QuizProvider provider, bool isDark) {
    final stats = provider.globalStats;
    final totalQuizzes = stats['totalQuizzes'] ?? 0;
    final totalCorrect = stats['totalCorrect'] ?? 0;
    final totalQuestions = stats['totalQuestions'] ?? 0;
    final streak = stats['currentStreak'] ?? 0;
    final bestScore = (stats['bestScore'] ?? 0).toDouble();

    final avgScore = totalQuestions > 0
        ? (totalCorrect / totalQuestions * 100).round()
        : 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _BigStatCard(
                icon: Icons.quiz_outlined,
                label: 'Quiz complétés',
                value: '$totalQuizzes',
                gradient: AppTheme.primaryGradient,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BigStatCard(
                icon: Icons.trending_up_rounded,
                label: 'Score moyen',
                value: '$avgScore%',
                gradient: AppTheme.accentGradient,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _BigStatCard(
                icon: Icons.emoji_events_outlined,
                label: 'Meilleur score',
                value: '${bestScore.round()}%',
                gradient: AppTheme.successGradient,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BigStatCard(
                icon: Icons.local_fire_department,
                label: 'Streak actuel',
                value: '$streak jours',
                gradient: AppTheme.warmGradient,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _BigStatCard(
                icon: Icons.check_circle_outline,
                label: 'Bonnes réponses',
                value: '$totalCorrect',
                gradient: AppTheme.successGradient,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BigStatCard(
                icon: Icons.help_outline_rounded,
                label: 'Questions totales',
                value: '$totalQuestions',
                gradient: AppTheme.primaryGradient,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChart(
      BuildContext context, QuizProvider provider, bool isDark) {
    // Prendre les 10 derniers quiz pour le graphique
    final history = provider.history.reversed.toList();
    final recentHistory = history.length > 10
        ? history.sublist(history.length - 10)
        : history;

    final spots = recentHistory.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.percentage);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(
        brightness: Theme.of(context).brightness,
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
                child: const Icon(Icons.show_chart_rounded,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                'Évolution des scores',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}%',
                        style: TextStyle(
                          color: isDark ? Colors.white24 : Colors.grey.shade400,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: AppTheme.accentGradient,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF6C63FF),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF6C63FF).withValues(alpha: 0.2),
                          const Color(0xFF6C63FF).withValues(alpha: 0.0),
                        ],
                      ),
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

  Widget _buildScoreDistribution(
      BuildContext context, QuizProvider provider, bool isDark) {
    if (provider.history.isEmpty) {
      return const SizedBox.shrink();
    }

    // Compter la distribution des notes
    int excellent = 0, good = 0, average = 0, poor = 0;
    for (final entry in provider.history) {
      final p = entry.percentage;
      if (p >= 80) {
        excellent++;
      } else if (p >= 60) {
        good++;
      } else if (p >= 40) {
        average++;
      } else {
        poor++;
      }
    }

    final total = provider.history.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCardDecoration(
        brightness: Theme.of(context).brightness,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppTheme.successGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.pie_chart_rounded,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                'Répartition des scores',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DistributionBar(
            label: 'Excellent (80-100%)',
            count: excellent,
            total: total,
            gradient: AppTheme.successGradient,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _DistributionBar(
            label: 'Bien (60-79%)',
            count: good,
            total: total,
            gradient: AppTheme.accentGradient,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _DistributionBar(
            label: 'Moyen (40-59%)',
            count: average,
            total: total,
            gradient: AppTheme.warmGradient,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _DistributionBar(
            label: 'À revoir (0-39%)',
            count: poor,
            total: total,
            gradient: AppTheme.errorGradient,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

/// Carte de statistique grande
class _BigStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final LinearGradient gradient;
  final bool isDark;

  const _BigStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          ShaderMask(
            shaderCallback: (bounds) => gradient.createShader(bounds),
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Barre de distribution des scores
class _DistributionBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final LinearGradient gradient;
  final bool isDark;

  const _DistributionBar({
    required this.label,
    required this.count,
    required this.total,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? count / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.grey.shade400,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.grey.shade100,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                height: 8,
                width: MediaQuery.of(context).size.width * percent * 0.7,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
