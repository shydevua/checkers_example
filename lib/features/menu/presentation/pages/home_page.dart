import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/navigation/app_paths.dart';
import 'package:checkers_app/core/theme/app_spacing.dart';
import 'package:checkers_app/core/widgets/app_page_layout.dart';
import 'package:checkers_app/features/menu/presentation/pages/widgets/level_button.dart';
import 'package:checkers_app/features/menu/presentation/pages/widgets/side_picker.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    return AppPageLayout(
      title: l10n.appTitle,
      maxContentWidth: 420,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.chooseSide,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.s),
            SidePicker(side: _side),
            const SizedBox(height: AppSpacing.l),
            Text(
              l10n.chooseLevel,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.l),
            for (final difficulty in Difficulty.values) ...[
              LevelButton(difficulty: difficulty, side: _side),
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
    );
  }
}
