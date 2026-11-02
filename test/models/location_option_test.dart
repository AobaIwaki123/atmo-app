import 'package:flutter_test/flutter_test.dart';
import 'package:atmo_app/models/location_option.dart';

void main() {
  test('都道府県の代表地点を47件収録する', () {
    expect(LocationCatalog.all, hasLength(47));
    expect(LocationCatalog.byPrefecture('東京都'), LocationCatalog.tokyo);
  });

  test('都道府県名・代表地点名で簡易検索できる', () {
    expect(LocationCatalog.search('札幌').single.prefecture, '北海道');
    expect(LocationCatalog.search('かなざわ').single.prefecture, '石川県');
  });

  test('都道府県フィルターと検索語を組み合わせられる', () {
    final results = LocationCatalog.search('京都', prefecture: '京都府');

    expect(results, hasLength(1));
    expect(results.single.representative, '京都');
  });
}
