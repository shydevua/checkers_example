import 'package:flutter/material.dart';

/// Frame of every screen: app bar with [title] and [actions], [body] inside
/// the safe area. With [maxContentWidth] the body is centred and never wider
/// than that, so tablets and landscape phones keep readable lines.
class AppPageLayout extends StatelessWidget {
  const AppPageLayout({
    required this.title,
    required this.body,
    this.actions = const [],
    this.maxContentWidth,
    super.key,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final double? maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final maxWidth = maxContentWidth;
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(
        child: maxWidth == null
            ? body
            : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: body,
                ),
              ),
      ),
    );
  }
}
