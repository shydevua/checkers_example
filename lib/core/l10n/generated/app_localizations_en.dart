// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Checkers';

  @override
  String get chooseLevel => 'Choose a level';

  @override
  String difficulty(String level) {
    String _temp0 = intl.Intl.selectLogic(
      level,
      {
        'easy': 'Easy',
        'medium': 'Medium',
        'hard': 'Hard',
        'other': '$level',
      },
    );
    return '$_temp0';
  }

  @override
  String level(String name) {
    return 'Level: $name';
  }

  @override
  String get statistics => 'Statistics';

  @override
  String get wins => 'Wins';

  @override
  String get losses => 'Losses';

  @override
  String get draws => 'Draws';

  @override
  String gamesPlayed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games',
      one: '$count game',
      zero: 'No games',
    );
    return '$_temp0';
  }

  @override
  String get resetStatistics => 'Reset statistics';

  @override
  String get yourTurn => 'Your move';

  @override
  String get aiThinking => 'Computer is thinking…';

  @override
  String get mustCapture => 'Capture is mandatory';

  @override
  String computerMoved(String move) {
    return 'Computer: $move';
  }

  @override
  String outcome(String outcome) {
    String _temp0 = intl.Intl.selectLogic(
      outcome,
      {
        'win': 'You won!',
        'loss': 'You lost',
        'draw': 'Draw',
        'other': '$outcome',
      },
    );
    return '$_temp0';
  }

  @override
  String get playAgain => 'Play again';

  @override
  String get backToMenu => 'Menu';

  @override
  String get retry => 'Retry';

  @override
  String get undoMove => 'Undo move';

  @override
  String get illegalMove => 'Illegal move';

  @override
  String get gameAlreadyOver => 'The game is already over';

  @override
  String get invalidPosition => 'Invalid square';

  @override
  String get statsStorageFailed => 'Could not read or save statistics';

  @override
  String get statsCorrupted => 'Statistics are corrupted';

  @override
  String boardLabel(String color) {
    return 'Board, you play $color';
  }

  @override
  String colorName(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'white': 'white',
        'black': 'black',
        'other': '$color',
      },
    );
    return '$_temp0';
  }

  @override
  String piece(String piece) {
    String _temp0 = intl.Intl.selectLogic(
      piece,
      {
        'whiteMan': 'white man',
        'blackMan': 'black man',
        'whiteKing': 'white king',
        'blackKing': 'black king',
        'other': 'empty',
      },
    );
    return '$_temp0';
  }

  @override
  String squareLabel(String square, String content) {
    return '$square, $content';
  }

  @override
  String get squareSelected => 'selected';

  @override
  String get squareCanMove => 'can move';

  @override
  String get squareTarget => 'you can move here';

  @override
  String get squareLastMove => 'last move';

  @override
  String get selectPieceHint => 'select the piece';

  @override
  String get moveHereHint => 'move here';

  @override
  String get chooseSide => 'Your side';

  @override
  String sideLabel(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'white': 'White',
        'black': 'Black',
        'other': '$color',
      },
    );
    return '$_temp0';
  }
}
