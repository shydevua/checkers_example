/// Route paths and names shared between features. Features navigate with
/// these constants and never import each other. Names double as analytics
/// screen names.
abstract final class AppPaths {
  static const home = '/';
  static const homeName = 'home';

  static const stats = '/stats';
  static const statsName = 'statistics';

  /// Route pattern of the game screen; `difficulty` is a path parameter,
  /// `color` (the human's side, `white` by default) a query parameter.
  static const game = '/game/:$difficultyParam';
  static const gameName = 'game';
  static const difficultyParam = 'difficulty';
  static const colorParam = 'color';

  /// Concrete location of the game screen.
  static String gameFor(String difficulty, {String? color}) => color == null
      ? '/game/$difficulty'
      : '/game/$difficulty?$colorParam=$color';
}
