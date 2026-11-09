# Скилы проекта

Инструкции для ИИ-ассистента (Claude Code), по которым написан и меняется
этот проект.

| Скил | О чём |
|---|---|
| [`flutter-clean-feature-first`](flutter-clean-feature-first/SKILL.md) | Feature-first Clean Architecture: слои, bloc, DI, типизированные ошибки, производительность UI, доступность (раздел 10A), тесты и мутационное тестирование |

Чтобы Claude Code подхватывал скил автоматически, положите папку скила в
`.claude/skills/` (в проекте) или в `~/.claude/skills/` (для всех проектов).

## Где проект сознательно отходит от скила

Скил описывает строгую схему из нескольких пакетов. В этом проекте по
решению автора:

- **один Flutter-пакет** вместо pub workspace; границы слоёв проверяет
  `test/architecture_test.dart`, а не pubspec;
- **`core/` разбит по темам** (`analytics`, `storage`, `l10n`…), без слоёв
  domain/data/ui внутри;
- **общие бизнес-понятия фич** — в `lib/features/shared/`, а не в `core`;
- **все регистрации DI** — в `lib/app/di/modules/`, классы фич без
  аннотаций `injectable`;
- **одна точка входа** `lib/main.dart`, окружение через `--dart-define=ENV`;
- **строки** — `flutter gen-l10n` (ARB).
