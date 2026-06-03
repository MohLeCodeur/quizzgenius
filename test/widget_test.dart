import 'package:flutter_test/flutter_test.dart';
import 'package:quizzgenius/main.dart';

void main() {
  testWidgets('Quiz-Genius app démarre correctement', (WidgetTester tester) async {
    await tester.pumpWidget(const QuizGeniusApp());

    // Vérifie que l'écran d'accueil s'affiche
    expect(find.text('Quiz-Genius'), findsOneWidget);
  });
}
