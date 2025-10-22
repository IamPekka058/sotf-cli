import 'dart:io';

class FileHandler {
  List<String> listDirectories(String path) {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      return [];
    }
    final entries = dir.listSync(recursive: false, followLinks: false);

    return entries.whereType<Directory>().map((d) => d.path).toList();
  }

  List<String> listFiles(String path) {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      return [];
    }
    final entries = dir.listSync(recursive: false, followLinks: false);

    return entries.whereType<File>().map((f) => f.path).toList();
  }
}
