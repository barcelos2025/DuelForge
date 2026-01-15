
import 'package:flutter_test/flutter_test.dart';
import '../lib/battle/domain/services/power_service.dart';

void main() {
  group('PowerService Tests', () {
    late PowerService service;

    setUp(() {
      service = PowerService(initialPower: 5.0);
    });

    tearDown(() {
      service.dispose();
    });

    test('Initial power should be 5.0', () {
      expect(service.currentPower, 5.0);
    });

    test('Consume should reduce power and return true if enough', () {
      final success = service.consume(3);
      expect(success, true);
      expect(service.currentPower, 2.0);
    });

    test('Consume should return false and not reduce if not enough', () {
      final success = service.consume(6);
      expect(success, false);
      expect(service.currentPower, 5.0);
    });

    test('Tick should regenerate power', () {
      // 1.2s to regen 1 point
      // Tick 1.2s
      service.tick(1.2);
      // Should be 5.0 + 1.0 = 6.0 (approx due to float)
      expect(service.currentPower, closeTo(6.0, 0.001));
    });

    test('Power should not exceed max', () {
      service = PowerService(initialPower: 9.5);
      service.tick(2.0); // Should add > 1.5
      expect(service.currentPower, 10.0);
    });

    test('Overtime should increase regen rate', () {
      service.setOvertime(true);
      // Base is 0.833/s. Overtime x1.5 = 1.25/s.
      service.tick(1.0);
      expect(service.currentPower, closeTo(5.0 + (1.0/1.2 * 1.5), 0.001));
    });
  });
}
