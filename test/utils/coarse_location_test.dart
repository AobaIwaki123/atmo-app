import 'package:flutter_test/flutter_test.dart';
import 'package:atmo_app/utils/coarse_location.dart';

void main() {
  group('CoarseLocation.snap', () {
    test('緯度経度を0.1度(約10km)単位に四捨五入してピンポイント特定を排除すること', () {
      // 渋谷駅周辺: 35.658034, 139.701636 -> 35.7, 139.7
      expect(CoarseLocation.snap(35.658034), 35.7);
      expect(CoarseLocation.snap(139.701636), 139.7);

      // 東京駅周辺: 35.681236, 139.767125 -> 35.7, 139.8
      expect(CoarseLocation.snap(35.681236), 35.7);
      expect(CoarseLocation.snap(139.767125), 139.8);

      // マイナス座標 (南緯・西経) でも適切に機能すること
      expect(CoarseLocation.snap(-33.8688), -33.9);
      expect(CoarseLocation.snap(-151.2093), -151.2);
    });
  });
}
