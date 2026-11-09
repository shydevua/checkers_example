import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/navigation/app_paths.dart';
import 'package:checkers_app/core/widgets/app_button.dart';
import 'package:checkers_app/features/menu/presentation/pages/widgets/side_picker.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LevelButton extends StatelessWidget {
  const LevelButton({required this.difficulty, required this.side, super.key});

  final Difficulty difficulty;
  final ValueNotifier<Side> side;

  @override
  Widget build(BuildContext context) => AppButton(
    key: ValueKey('level-${difficulty.name}'),
    label: context.l10n.difficulty(difficulty.name),
    onPressed: () => context.push(
      AppPaths.gameFor(
        difficulty.name,
        color: side.value == Side.white ? null : side.value.name,
      ),
    ),
  );
}
