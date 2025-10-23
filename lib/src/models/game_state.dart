import 'dart:convert';

class GameState {
  String version;
  String gameName;
  DateTime saveTime;
  String gameType;
  String gameId;
  int gameDays;
  int gameHours;
  int gameMinutes;
  int gameSeconds;
  int gameMilliseconds;
  String crashSite;
  List<NamedIntData> namedIntDatas;

  GameState.fromJson(dynamic json)
    : assert(json != null),
      version = _asString(_ensureMap(json)['Version']),
      gameName = _asString(_ensureMap(json)['GameName']),
      saveTime = _parseDateTime(_ensureMap(json)['SaveTime']),
      gameType = _asString(_ensureMap(json)['GameType']),
      gameId = _asString(_ensureMap(json)['GameId']),
      gameDays = _toInt(_ensureMap(json)['GameDays']),
      gameHours = _toInt(_ensureMap(json)['GameHours']),
      gameMinutes = _toInt(_ensureMap(json)['GameMinutes']),
      gameSeconds = _toInt(_ensureMap(json)['GameSeconds']),
      gameMilliseconds = _toInt(_ensureMap(json)['GameMilliseconds']),
      crashSite = _asString(_ensureMap(json)['CrashSite']),
      namedIntDatas = _parseNamedIntDatas(_ensureMap(json)['NamedIntDatas']);

  Map<String, dynamic> toJson() {
    return {
      'Version': version,
      'GameName': gameName,
      'SaveTime': saveTime.toIso8601String(),
      'GameType': gameType,
      'GameId': gameId,
      'GameDays': gameDays,
      'GameHours': gameHours,
      'GameMinutes': gameMinutes,
      'GameSeconds': gameSeconds,
      'GameMilliseconds': gameMilliseconds,
      'CrashSite': crashSite,
      'NamedIntDatas': namedIntDatas.map((e) {
        final m = <String, dynamic>{'SaveObjectNameId': e.saveObjectNameId};
        if (e.saveValue != null) {
          m['SaveValue'] = e.saveValue;
        }
        return m;
      }).toList(),
    };
  }

  String toJsonString() => jsonEncode(toJson());
}

class NamedIntData {
  final String saveObjectNameId;
  final int? saveValue;

  NamedIntData({required this.saveObjectNameId, this.saveValue});

  factory NamedIntData.fromJson(dynamic json) {
    final map = _ensureMap(json);
    return NamedIntData(
      saveObjectNameId: _asString(map['SaveObjectNameId']),
      saveValue: map.containsKey('SaveValue') && map['SaveValue'] != null
          ? _toInt(map['SaveValue'])
          : null,
    );
  }
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is num) return v.toInt();
  if (v is String) {
    return int.tryParse(v) ?? (double.tryParse(v)?.toInt() ?? 0);
  }
  return 0;
}

String _asString(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  try {
    return jsonEncode(v);
  } catch (_) {
    return v.toString();
  }
}

Map<String, dynamic> _ensureMap(dynamic v) {
  if (v == null) return <String, dynamic>{};
  if (v is Map<String, dynamic>) return Map<String, dynamic>.from(v);
  if (v is String) {
    try {
      final decoded = jsonDecode(v);
      if (decoded is Map<String, dynamic>) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      // Fallthrough
    }
  }
  throw ArgumentError(
    'Expected Map or JSON-String that decodes to Map, got: ${v.runtimeType}',
  );
}

List<NamedIntData> _parseNamedIntDatas(dynamic v) {
  if (v == null) return const [];
  List<dynamic> list;
  if (v is List) {
    list = v;
  } else if (v is String) {
    try {
      final decoded = jsonDecode(v);
      if (decoded is List<dynamic>) {
        list = decoded;
      } else {
        return const [];
      }
    } catch (_) {
      return const [];
    }
  } else {
    return const [];
  }

  return list.map((e) {
    if (e is Map<String, dynamic>) return NamedIntData.fromJson(e);
    if (e is String) {
      try {
        final decoded = jsonDecode(e);
        if (decoded is Map<String, dynamic>) {
          return NamedIntData.fromJson(decoded);
        }
      } catch (_) {}
      // Fallback: treat as object with only SaveObjectNameId set to the string
      return NamedIntData(saveObjectNameId: e);
    }
    // Unknown element type: return empty entry
    return NamedIntData(saveObjectNameId: '');
  }).toList();
}

DateTime _parseDateTime(dynamic v) {
  if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
  if (v is DateTime) return v;
  final s = _asString(v);
  try {
    return DateTime.parse(s);
  } catch (_) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
