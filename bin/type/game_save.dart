class GameSave {
  final String days;
  final String difficulty;
  final DateTime lastModifiedDate;
  final String path;
  final int id;

  GameSave({
    required this.id,
    required this.days,
    required this.difficulty,
    required this.lastModifiedDate,
    required this.path,
  });

  @override
  String toString() {
    final dt = lastModifiedDate.toLocal();
    String p(int n) => n.toString().padLeft(2, '0');
    final formatted =
        '${p(dt.day)}.${p(dt.month)}.${dt.year} ${p(dt.hour)}:${p(dt.minute)}:${p(dt.second)}';
    return 'ID: $id Difficulty: $difficulty, Days Survived: $days, Last Modified: $formatted';
  }
}
