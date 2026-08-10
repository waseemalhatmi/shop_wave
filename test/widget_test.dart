import 'package:flutter_test/flutter_test.dart';
import 'package:shop_wave/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Smoke test: verifies the app class exists.
    // Full widget tests are added in Phase 8.
    expect(ShopWaveApp, isNotNull);
  });
}
