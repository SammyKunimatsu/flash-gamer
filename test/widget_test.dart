import 'package:flutter_test/flutter_test.dart';
import 'package:flashgamer/main.dart';

void main() => testWidgets('Login page smoke test', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  expect(find.text('FlashGamer'), findsOneWidget);
  expect(find.text('Entrar na sua conta'), findsOneWidget);
});
