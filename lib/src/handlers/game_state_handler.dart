import 'dart:convert';

/// Utility to parse and rebuild the GameStateSaveData.json content which has
/// the structure { "Version": ..., "Data": { "GameState": &lt;string-or-map> } }
class GameStateHandler {
  Map<String, dynamic> root;
  Map<String, dynamic> gameStateMap;
  bool gameStateWasString;

  GameStateHandler._(this.root, this.gameStateMap, this.gameStateWasString);

  /// Parse full file content (JSON string) and extract the inner GameState as Map.
  static GameStateHandler parse(String content) {
    final dynamic parsed = jsonDecode(content);
    if (parsed is! Map<String, dynamic>) {
      throw Exception('Unexpected JSON structure in GameStateSaveData.json');
    }

    if (!parsed.containsKey('Data') ||
        parsed['Data'] is! Map<String, dynamic>) {
      throw Exception('Missing "Data" key in GameStateSaveData.json');
    }

    final data = parsed['Data'] as Map<String, dynamic>;
    if (!data.containsKey('GameState')) {
      throw Exception('Missing "GameState" key in GameStateSaveData.json');
    }

    final gsRaw = data['GameState'];
    if (gsRaw is String) {
      final decoded = jsonDecode(gsRaw);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('GameState string does not decode to a Map');
      }
      return GameStateHandler._(
        Map<String, dynamic>.from(parsed),
        Map<String, dynamic>.from(decoded),
        true,
      );
    } else if (gsRaw is Map<String, dynamic>) {
      return GameStateHandler._(
        Map<String, dynamic>.from(parsed),
        Map<String, dynamic>.from(gsRaw),
        false,
      );
    } else {
      throw Exception('Unsupported GameState type: ${gsRaw.runtimeType}');
    }
  }

  /// Replace the inner GameState with [newGameState] (as Map). Keeps the original
  /// representation (string vs map) consistent.
  void updateGameState(Map<String, dynamic> newGameState) {
    if (!root.containsKey('Data') || root['Data'] is! Map<String, dynamic>) {
      root['Data'] = <String, dynamic>{};
    }
    final data = root['Data'] as Map<String, dynamic>;
    data['GameState'] = gameStateWasString
        ? jsonEncode(newGameState)
        : newGameState;
    gameStateMap = Map<String, dynamic>.from(newGameState);
  }

  /// Serializes the whole file back to a JSON string (no pretty print).
  String toJsonString() => jsonEncode(root);
}
