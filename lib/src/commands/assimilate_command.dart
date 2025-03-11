import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nanoprobe/src/utils/command_helpers.dart';
import 'package:nanoprobe/src/utils/constants.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:path/path.dart' as p;

class Assimilate extends Command {
  @override
  String get description =>
      'Install pubspec_override files as necessary assimilate packages into the workspace';

  @override
  String get name => 'assimilate';

  @override
  FutureOr? run() async {
    final logger = getLogger();
    logger.progress('Installing pubspec_overrides');
    final workspace =
        Pubspec.parse(await File(pubspecPath).readAsString()).workspace ??
        const [];
    for (final project in workspace) {
      final pubspecFile = File(p.join(project, pubspecPath));
      final pubspec = Pubspec.parse(await pubspecFile.readAsString());
      if (pubspec.resolution == 'workspace') {
        logger.trace('$project already has resolution: workspace, skipping');
        continue;
      }
      final pubspecOverrideFile = File(
        p.join(project, pubspecOverridesPath),
      );
      logger.trace('Installing ${pubspecOverrideFile.path}');
      await pubspecOverrideFile.writeAsString(
        'resolution: workspace\ndependency_overrides: {}\n',
      );
    }

    logger.stdout('All sub-projects assimilated');
  }
}
