import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:sotf_cli/game_save_handler.dart';

class ListCommand extends Command<void> {
  final GameSaveHandler gameSaveHandler;

  @override
  final String name = 'list';

  @override
  final String description = 'List all game saves.';

  ListCommand(this.gameSaveHandler) {
    argParser
      ..addFlag(
        "multiplayer",
        abbr: 'm',
        help: 'List only multiplayer saves.',
        negatable: false,
      )
      ..addFlag(
        "singleplayer",
        abbr: 's',
        help: 'List only singleplayer saves.',
        negatable: false,
      );
  }

  @override
  void run() {
    final bool onlyMultiplayer = argResults?['multiplayer'] ?? false;
    final bool onlySingleplayer = argResults?['singleplayer'] ?? false;

    final gameSaves = gameSaveHandler.listGameSaves();

    if (gameSaves.isEmpty) {
      print('No game saves found.');
      return;
    }

    stdout.writeln('Sons of the Forest Game Saves:');
    gameSaves.forEach((type, saves) {
      if (onlyMultiplayer && type.toLowerCase() != 'multiplayer') return;
      if (onlySingleplayer && type.toLowerCase() != 'singleplayer') return;

      stdout.writeln('  $type:');
      if (saves.isEmpty) {
        stdout.writeln('    No saves found for this models.');
      } else {
        for (var savePath in saves) {
          stdout.writeln('    - $savePath');
        }
      }
    });
  }
}
