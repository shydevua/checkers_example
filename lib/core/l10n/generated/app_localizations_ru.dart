// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Шашки';

  @override
  String get chooseLevel => 'Выберите уровень';

  @override
  String difficulty(String level) {
    String _temp0 = intl.Intl.selectLogic(
      level,
      {
        'easy': 'Лёгкий',
        'medium': 'Средний',
        'hard': 'Сложный',
        'other': '$level',
      },
    );
    return '$_temp0';
  }

  @override
  String level(String name) {
    return 'Уровень: $name';
  }

  @override
  String get statistics => 'Статистика';

  @override
  String get wins => 'Победы';

  @override
  String get losses => 'Поражения';

  @override
  String get draws => 'Ничьи';

  @override
  String gamesPlayed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count партии',
      many: '$count партий',
      few: '$count партии',
      one: '$count партия',
      zero: 'Партий нет',
    );
    return '$_temp0';
  }

  @override
  String get resetStatistics => 'Сбросить статистику';

  @override
  String get yourTurn => 'Ваш ход';

  @override
  String get aiThinking => 'Компьютер думает…';

  @override
  String get mustCapture => 'Бить обязательно';

  @override
  String computerMoved(String move) {
    return 'Компьютер: $move';
  }

  @override
  String outcome(String outcome) {
    String _temp0 = intl.Intl.selectLogic(
      outcome,
      {
        'win': 'Вы победили!',
        'loss': 'Вы проиграли',
        'draw': 'Ничья',
        'other': '$outcome',
      },
    );
    return '$_temp0';
  }

  @override
  String get playAgain => 'Играть снова';

  @override
  String get backToMenu => 'В меню';

  @override
  String get retry => 'Повторить';

  @override
  String get undoMove => 'Отменить ход';

  @override
  String get illegalMove => 'Недопустимый ход';

  @override
  String get gameAlreadyOver => 'Партия уже завершена';

  @override
  String get invalidPosition => 'Неверная клетка';

  @override
  String get statsStorageFailed =>
      'Не удалось прочитать или сохранить статистику';

  @override
  String get statsCorrupted => 'Статистика повреждена';

  @override
  String boardLabel(String color) {
    return 'Доска, вы играете $color';
  }

  @override
  String colorName(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'white': 'белыми',
        'black': 'чёрными',
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
        'whiteMan': 'белая шашка',
        'blackMan': 'чёрная шашка',
        'whiteKing': 'белая дамка',
        'blackKing': 'чёрная дамка',
        'other': 'пусто',
      },
    );
    return '$_temp0';
  }

  @override
  String squareLabel(String square, String content) {
    return '$square, $content';
  }

  @override
  String get squareSelected => 'выбрана';

  @override
  String get squareCanMove => 'можно ходить';

  @override
  String get squareTarget => 'можно пойти сюда';

  @override
  String get squareLastMove => 'последний ход';

  @override
  String get selectPieceHint => 'выбрать шашку';

  @override
  String get moveHereHint => 'пойти сюда';

  @override
  String get chooseSide => 'Ваш цвет';

  @override
  String sideLabel(String color) {
    String _temp0 = intl.Intl.selectLogic(
      color,
      {
        'white': 'Белые',
        'black': 'Чёрные',
        'other': '$color',
      },
    );
    return '$_temp0';
  }
}
