import 'dart:convert';
import 'dart:io';

/// The real bundled rules file, read straight from disk.
///
/// Tests run against the shipping data rather than a hand-written stand-in, so
/// a bad edit to `packing_rules.json` fails the suite instead of reaching a
/// device.
final String fixtureRulesJson =
    File('assets/rules/packing_rules.json').readAsStringSync();

/// Decoded form, for structural assertions.
Map<String, Object?> get fixtureRulesMap =>
    jsonDecode(fixtureRulesJson) as Map<String, Object?>;
