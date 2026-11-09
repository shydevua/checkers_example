import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/navigation/app_paths.dart';
import 'package:checkers_app/core/theme/app_spacing.dart';
import 'package:checkers_app/core/widgets/app_button.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The human's side. The menu only passes its name to the game route, so it
/// does not depend on the game feature.
enum Side { white, black }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Transient choice of this screen: local state, not a bloc.
  final ValueNotifier<Side> _side = ValueNotifier(Side.white);

  @override
  void dispose() {
    _side.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.chooseSide,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  _SidePicker(side: _side),
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    l10n.chooseLevel,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  for (final difficulty in Difficulty.values) ...[
                    _LevelButton(difficulty: difficulty, side: _side),
                    const SizedBox(height: AppSpacing.m),
                  ],
                  const SizedBox(height: AppSpacing.m),
                  OutlinedButton.icon(
                    key: const ValueKey('home-stats'),
                    onPressed: () => context.push(AppPaths.stats),
                    icon: const Icon(Icons.bar_chart),
                    label: Text(l10n.statistics),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidePicker extends StatelessWidget {
  const _SidePicker({required this.side});

  final ValueNotifier<Side> side;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Side>(
    valueListenable: side,
    builder: (context, selected, _) => SegmentedButton<Side>(
      key: const ValueKey('home-side'),
      segments: [
        for (final value in Side.values)
          ButtonSegment(
            value: value,
            label: Text(context.l10n.sideLabel(value.name)),
          ),
      ],
      selected: {selected},
      onSelectionChanged: (values) => side.value = values.single,
    ),
  );
}

class _LevelButton extends StatelessWidget {
  const _LevelButton({required this.difficulty, required this.side});

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
