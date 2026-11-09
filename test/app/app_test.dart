import 'package:checkers_app/app/app.dart';
import 'package:checkers_app/core/analytics/noop_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens on the level choice', (tester) async {
    await tester.pumpWidget(const App(analytics: NoopAnalytics()));
    await tester.pumpAndSettle();
    expect(find.text('Choose a level'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
  });
}
