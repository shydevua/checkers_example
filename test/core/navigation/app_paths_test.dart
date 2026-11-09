import 'package:checkers_app/core/navigation/app_paths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('paths', () {
    expect(AppPaths.home, '/');
    expect(AppPaths.stats, '/stats');
    expect(AppPaths.game, '/game/:difficulty');
    expect(AppPaths.difficultyParam, 'difficulty');
  });

  test('route names (also analytics screen names)', () {
    expect(AppPaths.homeName, 'home');
    expect(AppPaths.gameName, 'game');
    expect(AppPaths.statsName, 'statistics');
  });

  test('gameFor -> concrete game location', () {
    expect(AppPaths.gameFor('hard'), '/game/hard');
    expect(AppPaths.gameFor('hard', color: 'black'), '/game/hard?color=black');
    expect(AppPaths.colorParam, 'color');
  });
}
