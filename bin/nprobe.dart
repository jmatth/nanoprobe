import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:nanoprobe/src/commands/assimilate_command.dart';
import 'package:nanoprobe/src/commands/clean_command.dart';
import 'package:nanoprobe/src/commands/scan_command.dart';

const String version = '0.0.1';

void printUsage(ArgParser argParser) {
  print('Usage: dart nprobe.dart <flags> [arguments]');
  print(argParser.usage);
}

void main(List<String> arguments) async {
  final app = CommandRunner('nprobe', 'TODO');
  app.argParser.addFlag(
    'verbose',
    abbr: 'v',
    defaultsTo: false,
    help: 'Enable verbose logging',
  );
  app.addCommand(Scan());
  app.addCommand(Assimilate());
  app.addCommand(Clean());

  try {
    await app.run(arguments);
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(app.argParser);
  }
}
