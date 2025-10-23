import 'package:sotf_cli/src/models/game_state.dart';

class CapsulationHandler {
  static Map<String, dynamic> capsulateGameState(GameState gameState) {
    return {
      "Version": "0.0.0",
      "Data": {"GameState": gameState.toJsonString()},
    };
  }
}
