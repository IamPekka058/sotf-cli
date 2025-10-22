import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:sotf_cli/file_handler.dart';
import 'package:sotf_cli/game_save_handler.dart';
import 'package:sotf_cli/platform_handler.dart';
import 'package:sotf_cli/src/commands/list_command.dart';

const String version = '0.0.1';

void main(List<String> arguments) {
  final fileHandler = FileHandler();
  final platformHandler = PlatformHandler();
  final gameSaveHandler = GameSaveHandler(fileHandler, platformHandler);

  final runner = CommandRunner<void>(
    'sotf_cli',
    'A CLI tool to manage Sons of the Forest game saves.',
  )..addCommand(ListCommand(gameSaveHandler));

  if (arguments.contains("--version") || arguments.contains("-v")) {
    print('sotf_cli version $version');
    return;
  }

  if (arguments.isEmpty) {
    runner.run(['help']);
    return;
  }

  try {
    runner.run(arguments);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
  } catch (e) {
    stderr.writeln('An error occurred: $e');
  }
}
