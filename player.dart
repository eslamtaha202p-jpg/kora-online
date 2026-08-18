import '../core/api_config.dart';

class PlayerItem {
  final int id;
  final String name;
  final String shortName;
  final String clubName;
  final String nationalityName;
  final String positionName;
  final int age;
  final int imageVersion;

  const PlayerItem({
    required this.id,
    required this.name,
    required this.shortName,
    required this.clubName,
    required this.nationalityName,
    required this.positionName,
    required this.age,
    required this.imageVersion,
  });

  factory PlayerItem.fromJson(Map<String, dynamic> json) {
    final position = json['position'] is Map ? Map<String, dynamic>.from(json['position']) : const <String, dynamic>{};
    return PlayerItem(
      id: _toInt(json['id']),
      name: (json['name'] ?? 'لاعب').toString(),
      shortName: (json['shortName'] ?? json['name'] ?? 'لاعب').toString(),
      clubName: (json['clubName'] ?? '').toString(),
      nationalityName: (json['nationalityName'] ?? '').toString(),
      positionName: (position['name'] ?? '').toString(),
      age: _toInt(json['age']),
      imageVersion: _toInt(json['imageVersion'], fallback: 1),
    );
  }

  String get imageUrl => '${ApiConfig.imageBaseUrl}/f_png,w_96,h_96,c_limit,q_auto:eco,dpr_2,d_Athletes:default.png/v$imageVersion/Athletes/$id';

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }
}
