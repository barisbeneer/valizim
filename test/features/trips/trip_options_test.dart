import 'package:flutter_test/flutter_test.dart';
import 'package:valizim/core/config/app_config.dart';
import 'package:valizim/features/trips/domain/trip_options.dart';

/// `optionsJson` is a free-form blob in the database, so it is the most likely
/// place for corrupt data to appear. Decoding must always yield a usable value.
void main() {
  group('round-trip', () {
    test('preserves every field', () {
      const settings = TripSettings(
        packing: PackingOptions(swimming: true, work: true),
        reminders: ReminderSettings(
          dayBefore: true,
          departureHour: 6,
          departureMinute: 45,
        ),
      );
      final decoded = TripSettings.decode(settings.encode());

      expect(decoded.packing.swimming, isTrue);
      expect(decoded.packing.work, isTrue);
      expect(decoded.packing.formalEvent, isFalse);
      expect(decoded.reminders.dayBefore, isTrue);
      expect(decoded.reminders.hoursBefore, isFalse);
      expect(decoded.reminders.departureHour, 6);
      expect(decoded.reminders.departureMinute, 45);
      expect(decoded, settings);
    });

    test('defaults survive an empty encode', () {
      const settings = TripSettings();
      final decoded = TripSettings.decode(settings.encode());
      expect(decoded.reminders.departureHour, AppConfig.defaultDepartureHour);
      expect(decoded.packing.enabledIds, isEmpty);
    });
  });

  group('option ordering', () {
    test('enabled ids come back in a fixed order regardless of construction', () {
      const a = PackingOptions(
        laundry: true,
        swimming: true,
        work: true,
        formalEvent: true,
      );
      expect(a.enabledIds, <String>['swimming', 'formalEvent', 'work', 'laundry']);
    });
  });

  group('corrupt blobs degrade to defaults', () {
    test('null and empty', () {
      expect(TripSettings.decode(null), const TripSettings());
      expect(TripSettings.decode(''), const TripSettings());
    });

    test('invalid JSON', () {
      expect(TripSettings.decode('{oops'), const TripSettings());
      expect(TripSettings.decode('[]'), const TripSettings());
      expect(TripSettings.decode('42'), const TripSettings());
    });

    test('partial objects keep what they can', () {
      final decoded = TripSettings.decode('{"packing":{"swimming":true}}');
      expect(decoded.packing.swimming, isTrue);
      expect(decoded.reminders, const ReminderSettings());
    });

    test('wrong value types fall back rather than throwing', () {
      final decoded = TripSettings.decode(
        '{"packing":"nope","reminders":{"departureHour":"eight"}}',
      );
      expect(decoded.packing, const PackingOptions());
      expect(decoded.reminders.departureHour, AppConfig.defaultDepartureHour);
    });

    test('out-of-range times are clamped into a valid clock', () {
      final decoded = TripSettings.decode(
        '{"reminders":{"departureHour":99,"departureMinute":-5}}',
      );
      expect(decoded.reminders.departureHour, 23);
      expect(decoded.reminders.departureMinute, 0);
    });

    test('a numeric string hour is accepted', () {
      final decoded =
          TripSettings.decode('{"reminders":{"departureHour":"7"}}');
      expect(decoded.reminders.departureHour, 7);
    });
  });
}
