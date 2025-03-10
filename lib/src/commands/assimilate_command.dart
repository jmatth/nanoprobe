import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:path/path.dart' as p;

class Assimilate extends Command {
  @override
  String get description => 'TODO';

  @override
  String get name => 'assimilate';

  @override
  FutureOr? run() async {
    final workspace =
        Pubspec.parse(await File('pubspec.yaml').readAsString()).workspace ??
            const [];
    for (final project in workspace) {
      final pubspecFile = File(p.join(project, 'pubspec.yaml'));
      final pubspec = Pubspec.parse(await pubspecFile.readAsString());
      if (pubspec.resolution == 'workspace') continue;
      final pubspecOverrideFile =
          File(p.join(project, 'pubspec_overrides.yaml'));
      await pubspecOverrideFile
          .writeAsString('resolution: workspace\ndependency_overrides: {}\n');
    }
  }
}
