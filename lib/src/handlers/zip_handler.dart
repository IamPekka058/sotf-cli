import 'dart:io';

import 'package:archive/archive.dart';

/// Handler for ZIP file operations.
class ZipHandler {
  /// Decodes the ZIP file and returns the [Archive].
  static Archive decodeZipFile(File zipFile) {
    final bytes = zipFile.readAsBytesSync();
    return ZipDecoder().decodeBytes(bytes);
  }

  /// Extracts the raw bytes of the first file whose name ends with [endsWith].
  /// Throws a [StateError] if no such file is found.
  static List<int> extractFileBytes(Archive archive, String endsWith) {
    final file = archive.files.firstWhere(
      (e) => e.name.toLowerCase().endsWith(endsWith.toLowerCase()),
      orElse: () => throw Exception('$endsWith not found inside zip.'),
    );

    // ArchiveFile.content is a list of bytes; cast directly and return a copy.
    final content = file.content as List<int>;
    return List<int>.from(content);
  }

  /// Replaces the first file whose name ends with [endsWith] with the
  /// provided [newBytes] and returns a new [Archive].
  static Archive replaceFileBytes(
    Archive archive,
    String endsWith,
    List<int> newBytes,
  ) {
    final oldFile = archive.files.firstWhere(
      (e) => e.name.toLowerCase().endsWith(endsWith.toLowerCase()),
      orElse: () => throw Exception('$endsWith not found inside zip.'),
    );

    final newFile = ArchiveFile(oldFile.name, newBytes.length, newBytes);

    final newArchive = Archive();
    for (final f in archive.files) {
      // Compare by filename to decide which file to replace.
      if (f.name == oldFile.name) {
        newArchive.addFile(newFile);
      } else {
        newArchive.addFile(f);
      }
    }

    return newArchive;
  }

  /// Writes the given [archive] back to the ZIP file (with backup).
  static void writeArchiveToZip(File zipFile, Archive archive) {
    final encoder = ZipEncoder();
    final bytes = encoder.encode(archive);

    final backupPath = '${zipFile.path}.bak';
    try {
      if (File(backupPath).existsSync()) File(backupPath).deleteSync();
      zipFile.copySync(backupPath);
    } catch (_) {
      stderr.writeln('Failed to backup original zip.');
      stderr.writeln('Aborting to prevent data loss.');
      return;
    }

    File(zipFile.path).writeAsBytesSync(bytes);
  }
}
