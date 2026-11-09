import 'dart:convert';
import 'dart:io';

import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:checkers_app/features/shared/game_results/game_outcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Set<String> _keys(String language) => {
  for (final key
      in (jsonDecode(
                File('lib/core/l10n/arb/app_$language.arb').readAsStringSync(),
              )
              as Map<String, dynamic>)
          .keys)
    if (!key.startsWith('@')) key,
};

void main() {
  final ru = lookupAppLocalizations(const Locale('ru'));
  final en = lookupAppLocalizations(const Locale('en'));

  test('ru and en define exactly the same strings', () {
    expect(_keys('en'), _keys('ru'));
  });

  test('Russian is preferred and listed first', () {
    expect(AppLocalizations.supportedLocales.first, const Locale('ru'));
    expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
  });

  for (final l10n in [ru, en]) {
    test('${l10n.localeName}: every level has its own label', () {
      final labels = [
        for (final d in Difficulty.values) l10n.difficulty(d.name),
      ];
      expect(labels.toSet(), hasLength(Difficulty.values.length));
      expect(labels, isNot(contains(anyOf('easy', 'medium', 'hard'))));
    });

    test('${l10n.localeName}: every outcome has its own text', () {
      final texts = [for (final o in GameOutcome.values) l10n.outcome(o.name)];
      expect(texts.toSet(), hasLength(GameOutcome.values.length));
      expect(texts, isNot(contains(anyOf('win', 'loss', 'draw'))));
    });

    test('${l10n.localeName}: every piece kind has its own name', () {
      final names = [
        for (final piece in ['whiteMan', 'blackMan', 'whiteKing', 'blackKing'])
          l10n.piece(piece),
      ];
      expect(names.toSet(), hasLength(4));
      expect(names, isNot(contains(l10n.piece('none'))));
    });
  }

  test('Russian plural forms of games played', () {
    expect(ru.gamesPlayed(0), 'Партий нет');
    expect(ru.gamesPlayed(1), '1 партия');
    expect(ru.gamesPlayed(3), '3 партии');
    expect(ru.gamesPlayed(5), '5 партий');
    expect(ru.gamesPlayed(21), '21 партия');
  });

  test('English plural forms of games played', () {
    expect(en.gamesPlayed(0), 'No games');
    expect(en.gamesPlayed(1), '1 game');
    expect(en.gamesPlayed(2), '2 games');
  });

  test('placeholders are filled in', () {
    expect(ru.level('Сложный'), 'Уровень: Сложный');
    expect(en.computerMoved('c3-d4'), 'Computer: c3-d4');
    expect(ru.squareLabel('a1', ru.piece('whiteMan')), 'a1, белая шашка');
  });

  testWidgets('unsupported device language -> Russian', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = context.l10n;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(l10n.appTitle, 'Шашки');
  });
}
