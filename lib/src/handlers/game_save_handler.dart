import 'dart:convert';
import 'dart:io';

import 'package:sotf_cli/src/handlers/game_state_handler.dart';
import 'package:sotf_cli/src/handlers/zip_handler.dart';
import 'package:sotf_cli/src/models/game_save.dart';
import 'package:sotf_cli/src/models/game_state.dart';

import 'file_handler.dart';
import 'platform_handler.dart';

class GameSaveHandler {
  final FileHandler _fileHandler;
  final PlatformHandler _platformHandler;

  GameSaveHandler(this._fileHandler, this._platformHandler);

  /// Find a GameSave by its numeric id. Returns null if not found.
  GameSave? findGameSaveById(int id) {
    final saves = listGameSaves();
    for (final list in saves.values) {
      for (final s in list) {
        if (s.id == id) return s;
      }
    }
    return null;
  }

  /// Set the GameDays value inside the GameStateSave.json which is stored
  /// inside the save's ZIP file. Throws an Exception on failure.
  void setGameDays(int id, int days) {
    final save = findGameSaveById(id);
    if (save == null) {
      throw Exception('Game save with ID $id not found.');
    }

    final dir = Directory(save.path);
    if (!dir.existsSync()) {
      throw Exception('Save directory not found: ${save.path}');
    }

    final zipFiles = dir
        .listSync(recursive: false, followLinks: false)
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.zip'))
        .toList();

    if (zipFiles.isEmpty) {
      throw Exception('No zip file found in save directory: ${save.path}');
    }

    final zipFile = zipFiles.first;

    // Use ZipHandler to decode the archive
    final archive = ZipHandler.decodeZipFile(zipFile);

    // Extract original GameStateSaveData.json content
    final originalBytes = ZipHandler.extractFileBytes(
      archive,
      'gamestatesavedata.json',
    );
    final originalContent = utf8.decode(originalBytes);

    // Parse, update and rebuild
    final gsSave = GameStateSave.parse(originalContent);
    final gameState = GameState.fromJson(gsSave.gameStateMap);
    gameState.gameDays = days;

    // Update the parsed save root and serialize it back. This preserves the
    // original outer structure (Version, additional keys) and whether
    // GameState was stored as string or map.
    gsSave.updateGameState(gameState.toJson());
    final updatedBytes = utf8.encode(gsSave.toJsonString());

    // Replace file inside archive and write back
    final newArchive = ZipHandler.replaceFileBytes(
      archive,
      'gamestatesavedata.json',
      updatedBytes,
    );
    ZipHandler.writeArchiveToZip(zipFile, newArchive);
  }

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
        RegExp(r'\\.name$', caseSensitive: false),
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
