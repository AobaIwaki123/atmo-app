/// 端末の位置情報を使わずに選べる、都道府県の代表観測地点。
class LocationOption {
  const LocationOption({
    required this.prefecture,
    required this.representative,
    required this.latitude,
    required this.longitude,
    this.aliases = const <String>[],
  });

  final String prefecture;
  final String representative;
  final double latitude;
  final double longitude;
  final List<String> aliases;

  String get searchText =>
      <String>[prefecture, representative, ...aliases].join(' ').toLowerCase();

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    return normalized.isEmpty || searchText.contains(normalized);
  }
}

class LocationCatalog {
  LocationCatalog._();

  static const LocationOption tokyo = LocationOption(
    prefecture: '東京都',
    representative: '東京',
    latitude: 35.6895,
    longitude: 139.6917,
    aliases: <String>['とうきょう'],
  );

  static const List<LocationOption> all = <LocationOption>[
    LocationOption(
      prefecture: '北海道',
      representative: '札幌',
      latitude: 43.0642,
      longitude: 141.3469,
      aliases: <String>['さっぽろ'],
    ),
    LocationOption(
      prefecture: '青森県',
      representative: '青森',
      latitude: 40.8244,
      longitude: 140.7400,
      aliases: <String>['あおもり'],
    ),
    LocationOption(
      prefecture: '岩手県',
      representative: '盛岡',
      latitude: 39.7036,
      longitude: 141.1525,
      aliases: <String>['もりおか'],
    ),
    LocationOption(
      prefecture: '宮城県',
      representative: '仙台',
      latitude: 38.2689,
      longitude: 140.8719,
      aliases: <String>['せんだい'],
    ),
    LocationOption(
      prefecture: '秋田県',
      representative: '秋田',
      latitude: 39.7186,
      longitude: 140.1025,
      aliases: <String>['あきた'],
    ),
    LocationOption(
      prefecture: '山形県',
      representative: '山形',
      latitude: 38.2406,
      longitude: 140.3633,
      aliases: <String>['やまがた'],
    ),
    LocationOption(
      prefecture: '福島県',
      representative: '福島',
      latitude: 37.7500,
      longitude: 140.4678,
      aliases: <String>['ふくしま'],
    ),
    LocationOption(
      prefecture: '茨城県',
      representative: '水戸',
      latitude: 36.3414,
      longitude: 140.4467,
      aliases: <String>['みと'],
    ),
    LocationOption(
      prefecture: '栃木県',
      representative: '宇都宮',
      latitude: 36.5658,
      longitude: 139.8836,
      aliases: <String>['うつのみや'],
    ),
    LocationOption(
      prefecture: '群馬県',
      representative: '前橋',
      latitude: 36.3911,
      longitude: 139.0608,
      aliases: <String>['まえばし'],
    ),
    LocationOption(
      prefecture: '埼玉県',
      representative: 'さいたま',
      latitude: 35.8569,
      longitude: 139.6489,
      aliases: <String>['さいたま市'],
    ),
    LocationOption(
      prefecture: '千葉県',
      representative: '千葉',
      latitude: 35.6047,
      longitude: 140.1233,
      aliases: <String>['ちば'],
    ),
    tokyo,
    LocationOption(
      prefecture: '神奈川県',
      representative: '横浜',
      latitude: 35.4478,
      longitude: 139.6425,
      aliases: <String>['よこはま'],
    ),
    LocationOption(
      prefecture: '新潟県',
      representative: '新潟',
      latitude: 37.9022,
      longitude: 139.0236,
      aliases: <String>['にいがた'],
    ),
    LocationOption(
      prefecture: '富山県',
      representative: '富山',
      latitude: 36.6953,
      longitude: 137.2114,
      aliases: <String>['とやま'],
    ),
    LocationOption(
      prefecture: '石川県',
      representative: '金沢',
      latitude: 36.5944,
      longitude: 136.6256,
      aliases: <String>['かなざわ'],
    ),
    LocationOption(
      prefecture: '福井県',
      representative: '福井',
      latitude: 36.0653,
      longitude: 136.2219,
      aliases: <String>['ふくい'],
    ),
    LocationOption(
      prefecture: '山梨県',
      representative: '甲府',
      latitude: 35.6639,
      longitude: 138.5683,
      aliases: <String>['こうふ'],
    ),
    LocationOption(
      prefecture: '長野県',
      representative: '長野',
      latitude: 36.6514,
      longitude: 138.1811,
      aliases: <String>['ながの'],
    ),
    LocationOption(
      prefecture: '岐阜県',
      representative: '岐阜',
      latitude: 35.3911,
      longitude: 136.7222,
      aliases: <String>['ぎふ'],
    ),
    LocationOption(
      prefecture: '静岡県',
      representative: '静岡',
      latitude: 34.9769,
      longitude: 138.3831,
      aliases: <String>['しずおか'],
    ),
    LocationOption(
      prefecture: '愛知県',
      representative: '名古屋',
      latitude: 35.1803,
      longitude: 136.9067,
      aliases: <String>['なごや'],
    ),
    LocationOption(
      prefecture: '三重県',
      representative: '津',
      latitude: 34.7303,
      longitude: 136.5086,
      aliases: <String>['つ'],
    ),
    LocationOption(
      prefecture: '滋賀県',
      representative: '大津',
      latitude: 35.0044,
      longitude: 135.8683,
      aliases: <String>['おおつ'],
    ),
    LocationOption(
      prefecture: '京都府',
      representative: '京都',
      latitude: 35.0214,
      longitude: 135.7556,
      aliases: <String>['きょうと'],
    ),
    LocationOption(
      prefecture: '大阪府',
      representative: '大阪',
      latitude: 34.6864,
      longitude: 135.5200,
      aliases: <String>['おおさか'],
    ),
    LocationOption(
      prefecture: '兵庫県',
      representative: '神戸',
      latitude: 34.6914,
      longitude: 135.1831,
      aliases: <String>['こうべ'],
    ),
    LocationOption(
      prefecture: '奈良県',
      representative: '奈良',
      latitude: 34.6853,
      longitude: 135.8328,
      aliases: <String>['なら'],
    ),
    LocationOption(
      prefecture: '和歌山県',
      representative: '和歌山',
      latitude: 34.2261,
      longitude: 135.1675,
      aliases: <String>['わかやま'],
    ),
    LocationOption(
      prefecture: '鳥取県',
      representative: '鳥取',
      latitude: 35.5036,
      longitude: 134.2383,
      aliases: <String>['とっとり'],
    ),
    LocationOption(
      prefecture: '島根県',
      representative: '松江',
      latitude: 35.4722,
      longitude: 133.0506,
      aliases: <String>['まつえ'],
    ),
    LocationOption(
      prefecture: '岡山県',
      representative: '岡山',
      latitude: 34.6617,
      longitude: 133.9350,
      aliases: <String>['おかやま'],
    ),
    LocationOption(
      prefecture: '広島県',
      representative: '広島',
      latitude: 34.3964,
      longitude: 132.4594,
      aliases: <String>['ひろしま'],
    ),
    LocationOption(
      prefecture: '山口県',
      representative: '山口',
      latitude: 34.1858,
      longitude: 131.4714,
      aliases: <String>['やまぐち'],
    ),
    LocationOption(
      prefecture: '徳島県',
      representative: '徳島',
      latitude: 34.0658,
      longitude: 134.5594,
      aliases: <String>['とくしま'],
    ),
    LocationOption(
      prefecture: '香川県',
      representative: '高松',
      latitude: 34.3403,
      longitude: 134.0433,
      aliases: <String>['たかまつ'],
    ),
    LocationOption(
      prefecture: '愛媛県',
      representative: '松山',
      latitude: 33.8417,
      longitude: 132.7658,
      aliases: <String>['まつやま'],
    ),
    LocationOption(
      prefecture: '高知県',
      representative: '高知',
      latitude: 33.5597,
      longitude: 133.5311,
      aliases: <String>['こうち'],
    ),
    LocationOption(
      prefecture: '福岡県',
      representative: '福岡',
      latitude: 33.6064,
      longitude: 130.4181,
      aliases: <String>['ふくおか'],
    ),
    LocationOption(
      prefecture: '佐賀県',
      representative: '佐賀',
      latitude: 33.2494,
      longitude: 130.2989,
      aliases: <String>['さが'],
    ),
    LocationOption(
      prefecture: '長崎県',
      representative: '長崎',
      latitude: 32.7447,
      longitude: 129.8736,
      aliases: <String>['ながさき'],
    ),
    LocationOption(
      prefecture: '熊本県',
      representative: '熊本',
      latitude: 32.7897,
      longitude: 130.7417,
      aliases: <String>['くまもと'],
    ),
    LocationOption(
      prefecture: '大分県',
      representative: '大分',
      latitude: 33.2381,
      longitude: 131.6125,
      aliases: <String>['おおいた'],
    ),
    LocationOption(
      prefecture: '宮崎県',
      representative: '宮崎',
      latitude: 31.9111,
      longitude: 131.4239,
      aliases: <String>['みやざき'],
    ),
    LocationOption(
      prefecture: '鹿児島県',
      representative: '鹿児島',
      latitude: 31.5603,
      longitude: 130.5581,
      aliases: <String>['かごしま'],
    ),
    LocationOption(
      prefecture: '沖縄県',
      representative: '那覇',
      latitude: 26.2125,
      longitude: 127.6811,
      aliases: <String>['なは'],
    ),
  ];

  static LocationOption? byPrefecture(String? prefecture) {
    if (prefecture == null) return null;
    for (final option in all) {
      if (option.prefecture == prefecture) return option;
    }
    return null;
  }

  static List<LocationOption> search(String query, {String? prefecture}) {
    return all
        .where(
          (option) => prefecture == null || option.prefecture == prefecture,
        )
        .where((option) => option.matches(query))
        .toList(growable: false);
  }
}
