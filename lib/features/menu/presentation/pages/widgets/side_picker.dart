import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// The human's side. The menu only passes its name to the game route, so it
/// does not depend on the game feature.
enum Side { white, black }

class SidePicker extends StatelessWidget {
  const SidePicker({required this.side, super.key});

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
