import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:file/local.dart';
import 'package:glob/glob.dart';
import 'package:nanoprobe/src/utils/command_helpers.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

const envKeySdk = 'sdk';

class Scan extends Command {
  @override
  String get description =>
      'Scan a directory for packages to incorporate into the workspace';

  @override
  String get name => 'scan';

  @override
  FutureOr? run() async {
    final logger = getLogger();

    logger.progress('Scanning for new sub-projects');
    await Future.delayed(const Duration(seconds: 3));

    final rootPubspec =
        Pubspec.parse(await File('pubspec.yaml').readAsString());
    final knownProjects = rootPubspec.workspace ?? const [];
    logger.trace('Known projects:\n${knownProjects.join('\n')}');

    final pubspecsGlob = Glob('packages/**/pubspec.yaml');
    final globResults = pubspecsGlob.listFileSystem(const LocalFileSystem());
    final newProjects = await globResults
        .where((e) => e is File)
        .cast<File>()
        .asyncMap((f) async {
          if (f.path.contains(RegExp(r'ephemeral\/\.(plugin_)?symlinks'))) {
            return null;
          }
          logger.trace('Candidate: ${f.path}');
          final pubspec = Pubspec.parse(
            await f.readAsString(), //
            sourceUrl: f.uri,
            lenient: true,
          );
          return ParsedPubspec(file: f, pubspec: pubspec);
        })
        .nonNulls
        .where((p) => !knownProjects.contains(p.localPath))
        .toList();
    if (newProjects.isEmpty) {
      logger.stdout('No new sub-projects found');
      return;
    }

    logger.stdout('Found found new sub-projects:\n'
        '${newProjects.map((e) => e.localPath).join('\n')}');
  }
}

class ParsedPubspec {
  final File file;
  final Pubspec pubspec;

  ParsedPubspec({required this.file, required this.pubspec});

  bool get allowsWorkspace => pubspec.environment[envKeySdk]!
      .allowsAny(VersionConstraint.parse('>=3.6.0'));

  bool get usesWorkspace => pubspec.resolution == 'workspace';

  String get localPath => p.normalize(p.dirname(file.path));
}

extension _NNS<T> on Stream<T?> {
  Stream<T> get nonNulls => where((e) => e != null).cast<T>();
}
