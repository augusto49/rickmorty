import 'package:flutter_test/flutter_test.dart';
import 'package:rickmorty/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app bar shows Rick and Morty title
    expect(find.text('Rick and Morty'), findsOneWidget);

    // Verify that the loading indicator shows initially
    expect(find.text('Carregando personagens...'), findsOneWidget);
  });
}
