import 'package:checkers_app/core/usecases/use_case.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRules extends Mock implements CheckersRules {}

void main() {
  late _MockRules rules;
  late StartNewGame sut;
  final game = const CheckersRules().newGame();

  setUp(() {
    rules = _MockRules();
    sut = StartNewGame(rules);
  });

  test('returns the new game from the rules', () async {
    when(() => rules.newGame()).thenReturn(game);
    expect(await sut(const NoParams()), game);
    verify(() => rules.newGame()).called(1);
    verifyNoMoreInteractions(rules);
  });
}
