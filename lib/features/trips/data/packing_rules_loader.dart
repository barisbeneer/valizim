import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../domain/packing_rules.dart';

/// Loads and caches the bundled rules asset.
///
/// The asset ships inside the binary, so the load is fast and can never fail
/// for network reasons. It is read once per app launch and held for the
/// process lifetime; generation itself is pure and synchronous, which is what
/// makes "generated list appears instantly offline" hold.
class PackingRulesLoader {
  PackingRulesLoader({AssetBundle? bundle})
      // A named parameter cannot bind to a private field.
      // ignore: prefer_initializing_formals
      : _bundle = bundle;

  static const String assetPath = 'assets/rules/packing_rules.json';

  final AssetBundle? _bundle;
  PackingRules? _cached;
  Future<PackingRules>? _inFlight;

  PackingRules? get cached => _cached;

  Future<PackingRules> load() {
    final cached = _cached;
    if (cached != null) return Future<PackingRules>.value(cached);
    // Collapse concurrent callers onto one asset read.
    return _inFlight ??= _read();
  }

  Future<PackingRules> _read() async {
    try {
      final source = await (_bundle ?? rootBundle).loadString(assetPath);
      final rules = PackingRules.parse(source);
      _cached = rules;
      return rules;
    } finally {
      _inFlight = null;
    }
  }
}
