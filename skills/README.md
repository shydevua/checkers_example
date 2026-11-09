# Project skills

Instructions for the AI assistant (Claude Code) that this project was built
and is maintained with.

| Skill | What it covers |
|---|---|
| [`flutter-clean-feature-first`](flutter-clean-feature-first/SKILL.md) | Feature-first Clean Architecture: layers, bloc, DI, typed errors, UI performance, accessibility (section 10A), testing and mutation testing |

To have Claude Code pick a skill up automatically, put its folder into
`.claude/skills/` (per project) or `~/.claude/skills/` (for all projects).

## Where this project deliberately departs from the skill

The skill describes a strict multi-package layout. By the author's decision
this project uses:

- **a single Flutter package** instead of a pub workspace; layer boundaries
  are checked by `test/architecture_test.dart`, not by pubspecs;
- **`core/` split by topic** (`analytics`, `storage`, `l10n`, …), without
  domain/data/ui layers inside;
- **business concepts shared by features** in `lib/features/shared/`, not in
  `core`;
- **all DI registrations** in `lib/app/di/modules/`; feature classes carry no
  `injectable` annotations;
- **a single entry point** `lib/main.dart`, the environment via
  `--dart-define=ENV`;
- **strings** with `flutter gen-l10n` (ARB).
