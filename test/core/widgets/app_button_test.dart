import 'package:checkers_app/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the label and calls onPressed', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: AppButton(label: 'Go', onPressed: () => pressed++),
      ),
    );
    await tester.tap(find.text('Go'));
    expect(pressed, 1);
  });

  testWidgets('null onPressed -> disabled', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AppButton(label: 'Go', onPressed: null)),
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });
}
