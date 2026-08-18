import '../core/api_config.dart';

class Team {
  final int id;
  final String name;
  final String symbolicName;
  final int imageVersion;
  final int? score;
  final String colorHex;

  const Team({
    required this.id,
    required this.name,
    required this.symbolicName,
    required this.imageVersion,
    this.score,
    this.colorHex = '#14B8FF',
  });

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: _toInt(json['id']),
        name: (json['name'] ?? 'فريق').toString(),
        symbolicName: (json['symbolicName'] ?? '').toString(),
        imageVersion: _toInt(json['imageVersion'], fallback: 1),
        score: json['score'] is num ? (json['score'] as num).toInt() : null,
        colorHex: (json['color'] ?? '#14B8FF').toString(),
      );

  String get logoUrl => ApiConfig.competitorLogo(id: id, imageVersion: imageVersion);

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }
}
