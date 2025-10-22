import 'dart:io';

import 'package:args/args.dart';

import 'file_handler.dart';
import 'game_save_handler.dart';
import 'platform_handler.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addCommand("list")
    ..addCommand("update")
    ..addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Print the tool version.',
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: dart sotf_cli.dart <flags> [arguments]');
  print(argParser.usage);
}

void main(List<String> arguments) {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);

    if (results.flag('help')) {
      printUsage(argParser);
      return;
    }
    if (results.flag('version')) {
      print('sotf_cli version: $version');
      return;
    }

    if (results.command?.name == 'list') {
      printList();
    } else {
      print('No valid command provided.');
      printUsage(argParser);
    }
  } on FormatException catch (e) {
    print(e.message);
    print('');
    printUsage(argParser);
  } catch (e) {
    print('An error occurred: $e');
  }
}

void printList() {
  final fileHandler = FileHandler();
  final platformHandler = PlatformHandler();
  final gameSaveHandler = GameSaveHandler(fileHandler, platformHandler);

  final gameSaves = gameSaveHandler.listGameSaves();

  if (gameSaves.isEmpty) {
    print('No game saves found.');
    return;
  }

  stdout.writeln('Sons of the Forest Game Saves:');
  gameSaves.forEach((type, saves) {
    stdout.writeln('  $type:');
    if (saves.isEmpty) {
      stdout.writeln('    No saves found for this type.');
    } else {
      for (var savePath in saves) {
        stdout.writeln('    - $savePath');
      }
    }
  });
}
