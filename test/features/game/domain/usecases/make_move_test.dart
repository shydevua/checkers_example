import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRules extends Mock implements CheckersRules {}

void main() {
  late _MockRules rules;
  late MakeMove sut;
  const real = CheckersRules();
  final game = real.newGame();
  final move = game.legalMoves.first;
  final next = real.play(game, move);
  final params = MakeMoveParams(game: game, move: move);

  setUp(() {
    rules = _MockRules();
    sut = MakeMove(rules);
  });

  test('legal move -> next game from the rules', () async {
    when(() => rules.play(game, move)).thenReturn(next);
    expect(await sut(params), next);
    verify(() => rules.play(game, move)).called(1);
    verifyNoMoreInteractions(rules);
  });

  test('IllegalMoveException from the rules -> propagates', () async {
    when(() => rules.play(game, move)).thenThrow(const IllegalMoveException());
    await expectLater(sut(params), throwsA(const IllegalMoveException()));
  });

  test('GameAlreadyOverException from the rules -> propagates', () async {
    when(
      () => rules.play(game, move),
    ).thenThrow(const GameAlreadyOverException());
    await expectLater(sut(params), throwsA(const GameAlreadyOverException()));
  });

  test('params equality', () {
    expect(params, MakeMoveParams(game: game, move: move));
    expect(params, isNot(MakeMoveParams(game: next, move: move)));
  });
}
