import 'competition.dart';
import 'team.dart';

class MatchItem {
  final int id;
  final int competitionId;
  final String competitionName;
  final String roundName;
  final String stageName;
  final DateTime? startTime;
  final int statusGroup;
  final String statusText;
  final String shortStatusText;
  final int gameTime;
  final String gameTimeDisplay;
  final Team home;
  final Team away;
  final String venueName;
  final bool hasLineups;
  final bool hasStats;
  final bool hasStandings;
  final bool hasTvNetworks;
  final bool hasLiveStreaming;

  const MatchItem({
    required this.id,
    required this.competitionId,
    required this.competitionName,
    required this.roundName,
    required this.stageName,
    required this.startTime,
    required this.statusGroup,
    required this.statusText,
    required this.shortStatusText,
    required this.gameTime,
    required this.gameTimeDisplay,
    required this.home,
    required this.away,
    required this.venueName,
    required this.hasLineups,
    required this.hasStats,
    required this.hasStandings,
    required this.hasTvNetworks,
    required this.hasLiveStreaming,
  });

  factory MatchItem.fromJson(Map<String, dynamic> json) {
    final venue = json['venue'] is Map<String, dynamic> ? json['venue'] as Map<String, dynamic> : const <String, dynamic>{};
    return MatchItem(
      id: _toInt(json['id']),
      competitionId: _toInt(json['competitionId']),
      competitionName: (json['competitionDisplayName'] ?? 'بطولة').toString(),
      roundName: (json['roundName'] ?? '').toString(),
      stageName: (json['stageName'] ?? '').toString(),
      startTime: DateTime.tryParse((json['startTime'] ?? '').toString())?.toLocal(),
      statusGroup: _toInt(json['statusGroup']),
      statusText: (json['statusText'] ?? '').toString(),
      shortStatusText: (json['shortStatusText'] ?? '').toString(),
      gameTime: _toInt(json['gameTime'], fallback: -1),
      gameTimeDisplay: (json['gameTimeDisplay'] ?? '').toString(),
      home: Team.fromJson(_map(json['homeCompetitor'])),
      away: Team.fromJson(_map(json['awayCompetitor'])),
      venueName: (venue['name'] ?? '').toString(),
      hasLineups: json['hasLineups'] == true,
      hasStats: json['hasStats'] == true,
      hasStandings: json['hasStandings'] == true,
      hasTvNetworks: json['hasTVNetworks'] == true,
      hasLiveStreaming: json['hasLiveStreaming'] == true,
    );
  }

  bool get isLive => statusGroup == 3 || (gameTime >= 0 && statusText.contains('الشوط'));
  bool get isFinished => statusGroup == 4 || statusText.contains('انتهت');

  String get kickoffLabel {
    if (isLive && gameTimeDisplay.isNotEmpty) return gameTimeDisplay;
    final d = startTime;
    if (d == null) return statusText.isEmpty ? '—' : statusText;
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
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
