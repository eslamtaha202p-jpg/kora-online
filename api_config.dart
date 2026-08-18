abstract final class ApiConfig {
  static const baseUrl = 'https://webws.365scores.com';
  static const imageBaseUrl = 'https://imagecache.365scores.com/image/upload';

  static Map<String, String> baseParams() => {
        'appTypeId': '5',
        'langId': '27',
        'timezoneName': 'Africa/Cairo',
        'userCountryId': '131',
      };

  static Uri uri(String path, [Map<String, String> extra = const {}]) {
    return Uri.parse('$baseUrl$path').replace(
      queryParameters: {...baseParams(), ...extra},
    );
  }

  static String competitorLogo({required int id, required int imageVersion, int size = 96}) {
    return '$imageBaseUrl/f_png,w_$size,h_$size,c_limit,q_auto:eco,dpr_2,d_Competitors:default1.png/v$imageVersion/Competitors/$id';
  }

  static String competitionLogo({required int id, required int imageVersion, int size = 72}) {
    return '$imageBaseUrl/f_png,w_$size,h_$size,c_limit,q_auto:eco,dpr_2,d_Countries:Round:19.png/v$imageVersion/Competitions/light/$id';
  }
}
