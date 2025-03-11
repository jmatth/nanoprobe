import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart';

extension CommandHelpers on Command {
  bool get verbose => globalResults?.flag('verbose') ?? false;

  Logger getLogger() => verbose ? Logger.verbose() : Logger.standard();
}
