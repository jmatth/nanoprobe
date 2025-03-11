import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nanoprobe/src/utils/command_helpers.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:path/path.dart' as p;

class Clean extends Command {
  @override
  String get description => 'Remove pubspec_override files from sub-projects';

  @override
  String get name => 'clean';

  @override
  FutureOr? run() async {
    final logger = getLogger();

    logger.progress('Cleaning pubspec_override.yaml files from sub-projects');

    final rootPubspec = Pubspec.parse(
      await File('pubspec.yaml').readAsString(),
    );
    final knownProjects = rootPubspec.workspace ?? const [];

    for (final project in knownProjects) {
      final psOverride = File(p.join(project, 'pubspec_override.yaml'));
      if (!(await psOverride.exists())) continue;
      logger.trace('Removing ${psOverride.path}');
      await psOverride.delete();
    }

    logger.stdout('Done cleaning pubspec_overrides from workspace');
  }
}
