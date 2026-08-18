import '../core/api_config.dart';

class Competition {
  final int id;
  final String name;
  final String nameForUrl;
  final int imageVersion;
  final int currentSeasonNum;
  final bool hasStandings;
  final bool hasBrackets;

  const Competition({
    required this.id,
    required this.name,
    required this.nameForUrl,
    required this.imageVersion,
    this.currentSeasonNum = 0,
    this.hasStandings = false,
    this.hasBrackets = false,
  });

  factory Competition.fromJson(Map<String, dynamic> json) => Competition(
        id: _toInt(json['id']),
        name: (json['name'] ?? 'بطولة').toString(),
        nameForUrl: (json['nameForURL'] ?? '').toString(),
        imageVersion: _toInt(json['imageVersion'], fallback: 1),
        currentSeasonNum: _toInt(json['currentSeasonNum']),
        hasStandings: json['hasStandings'] == true,
        hasBrackets: json['hasBrackets'] == true,
      );

  String get logoUrl => ApiConfig.competitionLogo(id: id, imageVersion: imageVersion);

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }
}
