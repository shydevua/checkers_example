import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/game/presentation/pages/widgets/game_error_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('ru'));

  test('every game exception has its own text', () {
    expect(
      gameErrorText(l10n, const InvalidPositionException(9, 9)),
      l10n.invalidPosition,
    );
    expect(gameErrorText(l10n, const IllegalMoveException()), l10n.illegalMove);
    expect(
      gameErrorText(l10n, const GameAlreadyOverException()),
      l10n.gameAlreadyOver,
    );
  });
}
