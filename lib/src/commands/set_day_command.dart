import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:sotf_cli/src/handlers/game_save_handler.dart';

class SetDayCommand extends Command<void> {
  final GameSaveHandler gameSaveHandler;

  @override
  final String name = 'set-day';

  @override
  final String description = 'Set the GameDays value for a save by GameId.';

  SetDayCommand(this.gameSaveHandler) {
    argParser.addOption(
      'days',
      abbr: 'd',
      help: 'Number of days to set (defaults to 1 if omitted).',
      valueHelp: 'NUMBER',
    );
  }

  @override
  void run() {
    final rest = argResults?.rest ?? [];
    if (rest.isEmpty) {
      stderr.writeln('Please provide the GameId as positional argument.');
      return;
    }

    final idStr = rest.first;
    final int? id = int.tryParse(idStr);
    if (id == null) {
      stderr.writeln('Invalid GameId: $idStr');
      return;
    }

    final daysArg = argResults?['days'];
    final int days = daysArg == null ? 1 : int.tryParse(daysArg) ?? 1;

    try {
      gameSaveHandler.setGameDays(id, days);
      stdout.writeln('Successfully set GameDays to $days for save ID $id.');
    } catch (e) {
      stderr.writeln(e.toString());
    }
  }
}
