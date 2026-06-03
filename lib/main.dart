import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/quiz_provider.dart';
import 'providers/theme_provider.dart';

import 'screens/home_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/results_screen.dart';
import 'screens/history_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const QuizGeniusApp());
}


/// Application principale Quiz-Genius v2.
///
/// Architecture avec MultiProvider (Quiz + Thème),
/// navigation hybride : BottomNavigationBar + states pour quiz flow.
class QuizGeniusApp extends StatelessWidget {
  const QuizGeniusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Quiz-Genius',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(nextScreen: AppShell()),
          );
        },
      ),
    );
  }
}

/// Shell principal de l'application.
///
/// Gère la navigation entre le quiz-flow (HomeScreen → Loading → Quiz → Results)
/// et les onglets (Historique, Stats, Paramètres).
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<QuizProvider>(
      builder: (context, quizProvider, _) {
        // Si le quiz est en cours (loading/playing/finished), cacher la nav bar
        final isInQuizFlow = quizProvider.state == QuizState.loading ||
            quizProvider.state == QuizState.playing ||
            quizProvider.state == QuizState.error;

        if (isInQuizFlow) {
          return _buildQuizFlow(quizProvider, isDark);
        }

        Widget homeOrResults = quizProvider.state == QuizState.finished
            ? const ResultsScreen()
            : const HomeScreen();

        final tabs = [
          homeOrResults,
          const HistoryScreen(),
          const StatsScreen(),
          const SettingsScreen(),
        ];

        return Scaffold(
          body: tabs[_currentTab],
          bottomNavigationBar: _buildBottomNav(context, isDark),
        );
      },
    );
  }

  Widget _buildQuizFlow(QuizProvider quizProvider, bool isDark) {
    switch (quizProvider.state) {
      case QuizState.loading:
        return _LoadingScreen(isDark: isDark);
      case QuizState.playing:
        return const QuizScreen();
      case QuizState.finished:
        return const ResultsScreen();
      case QuizState.error:
        return _ErrorScreen(
            message: quizProvider.errorMessage, isDark: isDark);
      default:
        return const HomeScreen();
    }
  }

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1A2E).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.grey.shade200,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Accueil',
                isSelected: _currentTab == 0,
                onTap: () => setState(() => _currentTab = 0),
                isDark: isDark,
              ),
              _NavItem(
                icon: Icons.history_rounded,
                label: 'Historique',
                isSelected: _currentTab == 1,
                onTap: () {
                  setState(() => _currentTab = 1);
                  context.read<QuizProvider>().refreshData();
                },
                isDark: isDark,
              ),
              _NavItem(
                icon: Icons.insights_rounded,
                label: 'Stats',
                isSelected: _currentTab == 2,
                onTap: () {
                  setState(() => _currentTab = 2);
                  context.read<QuizProvider>().refreshData();
                },
                isDark: isDark,
              ),
              _NavItem(
                icon: Icons.settings_rounded,
                label: 'Réglages',
                isSelected: _currentTab == 3,
                onTap: () => setState(() => _currentTab = 3),
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Item de navigation personnalisé avec animation
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white30 : Colors.grey.shade400),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 📄 Écran de Chargement (Premium)
// ═══════════════════════════════════════════════════════════════

/// Écran affiché pendant que l'IA génère le quiz.
class _LoadingScreen extends StatelessWidget {
  final bool isDark;
  const _LoadingScreen({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkBgGradient
              : AppTheme.lightBgGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône animée
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 36),

            // Spinner
            Pulse(
              infinite: true,
              child: SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6C63FF),
                  ),
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.grey.shade200,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Texte
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.accentGradient.createShader(bounds),
                child: Text(
                  '🧠 L\'IA crée votre quiz...',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: Text(
                'Analyse de votre cours en cours...',
                style: TextStyle(
                  color: isDark ? Colors.white30 : Colors.grey.shade400,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 📄 Écran d'Erreur (Premium)
// ═══════════════════════════════════════════════════════════════

/// Écran affiché en cas d'erreur (API, réseau, parsing...).
class _ErrorScreen extends StatelessWidget {
  final String message;
  final bool isDark;
  const _ErrorScreen({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkBgGradient
              : AppTheme.lightBgGradient,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône d'erreur
                FadeInDown(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.errorGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5252).withValues(alpha: 0.4),
                          blurRadius: 25,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Oups ! Une erreur est survenue',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                // Message d'erreur
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            const Color(0xFFFF5252).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFFF5252),
                            height: 1.4,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Bouton de retour
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF)
                              .withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<QuizProvider>().resetQuiz();
                      },
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                      label: const Text(
                        'Retour à l\'accueil',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
