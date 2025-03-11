import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:nanoprobe/src/utils/constants.dart';

extension CommandHelpers on Command {
  bool get verbose => globalResults?.flag(verboseFlagName) ?? false;

  Logger getLogger() => verbose ? Logger.verbose() : Logger.standard();
}
