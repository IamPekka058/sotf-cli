import 'dart:io';

class PlatformHandler {
  String getSavesPathForWindows() {
    final env = Platform.environment;
    if (!env.containsKey('USERPROFILE')) {
      throw Exception('USERPROFILE not found in environment variables.');
    }

    final userProfile = env['USERPROFILE'];

    return '$userProfile\\AppData\\LocalLow\\Endnight\\SonsOfTheForest\\Saves';
  }
}
