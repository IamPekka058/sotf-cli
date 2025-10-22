import 'dart:io';

import 'package:sotf_cli/src/models/game_save.dart';

import 'file_handler.dart';
import 'platform_handler.dart';

class GameSaveHandler {
  final FileHandler _fileHandler;
  final PlatformHandler _platformHandler;

  GameSaveHandler(this._fileHandler, this._platformHandler);

  Map<String, List<GameSave>> listGameSaves() {
    final savesPath = _platformHandler.getSavesPathForWindows();
    final steamIdDirs = _fileHandler.listDirectories(savesPath);

    if (steamIdDirs.isEmpty) {
      return {};
    }

    final steamIdDir = steamIdDirs.first;

    final multiplayerSavesPath = '$steamIdDir\\Multiplayer';
    final singleplayerSavesPath = '$steamIdDir\\Singleplayer';

    final multiplayerDirs = _fileHandler.listDirectories(multiplayerSavesPath);
    final singleplayerDirs = _fileHandler.listDirectories(
      singleplayerSavesPath,
    );

    List<GameSave> multiplayerSaves = _buildGameSavesFromDirs(multiplayerDirs);
    List<GameSave> singleplayerSaves = _buildGameSavesFromDirs(
      singleplayerDirs,
    );

    return {'Multiplayer': multiplayerSaves, 'Singleplayer': singleplayerSaves};
  }

  List<GameSave> _buildGameSavesFromDirs(List<String> dirs) {
    final List<GameSave> result = [];

    for (final dir in dirs) {
      final files = _fileHandler.listFiles(dir);
      final nameFile = files.firstWhere(
        (f) => f.toLowerCase().endsWith('.name'),
        orElse: () => '',
      );

      if (nameFile.isEmpty) {
        continue;
      }

      DateTime lastModified;
      try {
        lastModified = File(nameFile).lastModifiedSync();
      } catch (_) {
        lastModified = DateTime.now();
      }

      final fileName = nameFile.split(RegExp(r'\\|/')).last;
      final withoutExt = fileName.replaceAll(
        RegExp(r'\.name$', caseSensitive: false),
        '',
      );

      final parsed = _parseNameFileName(withoutExt, lastModified, dir);
      result.add(parsed);
    }

    return result;
  }

  GameSave _parseNameFileName(
    String nameWithoutExt,
    DateTime lastModified,
    String path,
  ) {
    final parts = nameWithoutExt.split('_');
    if (parts.length < 2) {
      throw FormatException(
        'Invalid format of the .name file: $nameWithoutExt',
      );
    }

    final difficulty = parts[0];

    String days = parts[1];

    days = days.replaceAll(RegExp(r'Day', caseSensitive: false), '');

    return GameSave(
      id: int.parse(path.split(RegExp(r'\\|/')).last),
      days: days,
      difficulty: difficulty,
      lastModifiedDate: lastModified,
      path: path,
    );
  }
}
