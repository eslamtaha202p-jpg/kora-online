class ScorerItem {
  final int athleteId;
  final String name;
  final String shortName;
  final String teamName;
  final int imageVersion;
  final num value;
  final String valueName;
  final String secondary;

  const ScorerItem({
    required this.athleteId,
    required this.name,
    required this.shortName,
    required this.teamName,
    required this.imageVersion,
    required this.value,
    required this.valueName,
    required this.secondary,
  });

  factory ScorerItem.fromRow(Map<String, dynamic> row) {
    final entity = _map(row['entity']);
    final mainStat = _map(row['mainStat']);
    return ScorerItem(
      athleteId: _toInt(entity['id']),
      name: (entity['name'] ?? 'لاعب').toString(),
      shortName: (entity['shortName'] ?? entity['name'] ?? 'لاعب').toString(),
      teamName: (entity['competitorName'] ?? entity['clubName'] ?? '').toString(),
      imageVersion: _toInt(entity['imageVersion'], fallback: 1),
      value: mainStat['value'] is num ? mainStat['value'] as num : num.tryParse('${mainStat['value']}') ?? 0,
      valueName: (mainStat['name'] ?? '').toString(),
      secondary: (row['secondaryStatName'] ?? '').toString(),
    );
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry('$k', v));
    return const <String, dynamic>{};
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }
}
