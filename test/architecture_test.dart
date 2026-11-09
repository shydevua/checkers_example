// Layers live in folders of one package, so the compiler no longer keeps
// them apart. This test is the Dependency Rule: it fails the build when a
// file imports something its layer must not see.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _app = 'package:checkers_app/';

/// Every `lib/**.dart` file except generated code, with its directives.
final Map<String, List<String>> _imports = {
  for (final file in Directory('lib').listSync(recursive: true))
    if (file is File &&
        file.path.endsWith('.dart') &&
        !file.path.endsWith('.g.dart') &&
        !file.path.endsWith('.config.dart'))
      file.path: [
        for (final match in RegExp(
          "^(?:import|export) '([^']+)'",
          multiLine: true,
        ).allMatches(file.readAsStringSync()))
          match.group(1)!,
      ],
};

final List<String> _features = [
  for (final dir in Directory('lib/features').listSync())
    if (dir is Directory && _name(dir) != _sharedKernel) _name(dir),
];

/// `features/shared/` holds business concepts of several features; it is
/// not a feature itself.
const _sharedKernel = 'shared';

String _name(Directory dir) =>
    dir.uri.pathSegments.lastWhere((segment) => segment.isNotEmpty);

/// Imports of files under [folder] that [allowed] rejects.
List<String> _violations(String folder, bool Function(String uri) allowed) => [
  for (final MapEntry(key: path, value: uris) in _imports.entries)
    if (path.startsWith(folder))
      for (final uri in uris)
        if (!allowed(uri)) '$path -> $uri',
];

/// Core folders of plain Dart: business concepts and ports.
const _pureCore = ['analytics', 'exceptions', 'monitoring', 'usecases'];

/// The part of [_pureCore] that a feature's domain may use.
const _businessCore = ['exceptions', 'usecases'];

/// Core folders that talk to the platform (plugins, files, network).
const _infraCore = ['storage'];

/// Core folders of shared Flutter UI.
const _uiCore = ['l10n', 'navigation', 'theme', 'widgets'];

/// Ports and repository contracts: only `abstract interface class`
/// declarations, nothing to execute.
bool _isInterfaceOnly(String path) {
  final source = File(path).readAsStringSync();
  return source.contains('abstract interface class') &&
      !RegExp(r'=>|\breturn\b|\bclass (?!\w+ \{)').hasMatch(
        source.replaceAll(RegExp('abstract interface class'), ''),
      );
}

bool _inShared(String uri) => uri.startsWith('${_app}features/$_sharedKernel/');

bool _inCore(String uri, List<String> folders) =>
    folders.any((folder) => uri.startsWith('${_app}core/$folder/'));

bool _isSdkOr(String uri, List<String> packages) =>
    uri.startsWith('dart:') ||
    packages.any((p) => uri.startsWith('package:$p/'));

void main() {
  test('features are menu, game and statistics', () {
    expect(_features..sort(), ['game', 'menu', 'statistics']);
  });

  test('every core folder is classified', () {
    expect(
      [
        for (final dir in Directory('lib/core').listSync())
          if (dir is Directory)
            dir.uri.pathSegments.lastWhere((s) => s.isNotEmpty),
      ]..sort(),
      ([..._pureCore, ..._infraCore, ..._uiCore])..sort(),
    );
  });

  test('pure core folders: plain Dart, only other pure core folders', () {
    for (final folder in _pureCore) {
      expect(
        _violations(
          'lib/core/$folder/',
          (uri) =>
              _isSdkOr(uri, ['equatable', 'meta']) || _inCore(uri, _pureCore),
        ),
        isEmpty,
        reason: folder,
      );
    }
  });

  test('infrastructure core folders: no UI, no other infrastructure', () {
    for (final folder in _infraCore) {
      expect(
        _violations(
          'lib/core/$folder/',
          (uri) =>
              !uri.startsWith('package:flutter/widgets') &&
              !uri.startsWith('package:flutter/material') &&
              (!uri.startsWith('${_app}core/') ||
                  _inCore(uri, [..._pureCore, folder])),
        ),
        isEmpty,
        reason: folder,
      );
    }
  });

  test('UI core folders: never infrastructure', () {
    for (final folder in _uiCore) {
      expect(
        _violations(
          'lib/core/$folder/',
          (uri) =>
              !uri.startsWith('${_app}core/') ||
              _inCore(uri, [..._pureCore, ..._uiCore]),
        ),
        isEmpty,
        reason: folder,
      );
    }
  });

  test('core never imports features or the shared kernel', () {
    expect(
      _violations('lib/core/', (uri) => !uri.startsWith('${_app}features/')),
      isEmpty,
    );
  });

  test('shared kernel: plain Dart business concepts, no features', () {
    expect(
      _violations(
        'lib/features/$_sharedKernel/',
        (uri) =>
            _isSdkOr(uri, ['equatable', 'meta']) ||
            _inCore(uri, _businessCore) ||
            _inShared(uri),
      ),
      isEmpty,
    );
  });

  for (final feature in _features) {
    final own = '${_app}features/$feature/';

    test('$feature/domain: pure Dart, only business core and own domain', () {
      expect(
        _violations(
          'lib/features/$feature/domain/',
          (uri) =>
              _isSdkOr(uri, ['equatable', 'meta']) ||
              _inCore(uri, _businessCore) ||
              _inShared(uri) ||
              uri.startsWith('${own}domain/'),
        ),
        isEmpty,
      );
    });

    test('$feature/data: no Flutter, no presentation, no other features', () {
      expect(
        _violations(
          'lib/features/$feature/data/',
          (uri) =>
              !uri.startsWith('package:flutter/') &&
              (!uri.startsWith(_app) ||
                  _inCore(uri, [..._businessCore, ..._infraCore]) ||
                  _inShared(uri) ||
                  uri.startsWith('${own}domain/') ||
                  uri.startsWith('${own}data/')),
        ),
        isEmpty,
      );
    });

    test('$feature/presentation: no infrastructure, no other features', () {
      expect(
        _violations(
          'lib/features/$feature/presentation/',
          (uri) =>
              !uri.startsWith('package:dio') &&
              (!uri.startsWith(_app) ||
                  _inCore(uri, [..._pureCore, ..._uiCore]) ||
                  _inShared(uri) ||
                  uri.startsWith('${own}domain/') ||
                  uri.startsWith('${own}presentation/')),
        ),
        isEmpty,
      );
    });
  }

  test('GetIt only in routes and the composition root', () {
    final usesGetIt = _violations(
      'lib/',
      (uri) => !uri.startsWith('package:get_it/'),
    );
    expect(
      usesGetIt.where(
        (v) => !v.startsWith('lib/app/di/') && !v.contains('/routes/'),
      ),
      isEmpty,
    );
  });

  test('all DI registrations live in app/di (no annotations elsewhere)', () {
    final usesInjectable = _violations(
      'lib/',
      (uri) => !uri.startsWith('package:injectable/'),
    );
    expect(
      usesInjectable.where(
        (v) => !v.startsWith('lib/app/di/'),
      ),
      isEmpty,
    );
  });

  test('app/ is the top: core and features never import it', () {
    expect(
      [
        ..._violations('lib/core/', (uri) => !uri.startsWith('${_app}app/')),
        ..._violations(
          'lib/features/',
          (uri) => !uri.startsWith('${_app}app/'),
        ),
      ],
      isEmpty,
    );
  });

  test('lib/ root holds only the entry point', () {
    expect(
      [
        for (final entity in Directory('lib').listSync())
          if (entity is File) entity.uri.pathSegments.last,
      ]..sort(),
      ['main.dart'],
    );
  });

  test('every file with logic has a mirrored test (needed by dart_mutant)', () {
    final logic = RegExp(
      '/(usecases|value_objects|entities|services|mappers|repositories|'
      r'datasources|game_results)/.*\.dart$|_bloc\.dart$',
    );
    final missing = [
      for (final path in _imports.keys)
        if (logic.hasMatch(path) &&
            !_isInterfaceOnly(path) &&
            !File(
              path
                  .replaceFirst('lib/', 'test/')
                  .replaceFirst(RegExp(r'\.dart$'), '_test.dart'),
            ).existsSync())
          path,
    ];
    expect(missing, isEmpty);
  });
}
