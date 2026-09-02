import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/pro/presentation/paywall_screen.dart';
import '../features/settings/presentation/privacy_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/share/presentation/share_screen.dart';
import '../features/templates/presentation/templates_screen.dart';
import '../features/trips/presentation/home_screen.dart';
import '../features/trips/presentation/packing_list_screen.dart';
import '../features/trips/presentation/trip_wizard_screen.dart';

/// Named routes, so no screen builds a path by hand.
abstract final class AppRoute {
  const AppRoute._();

  static const String home = 'home';
  static const String newTrip = 'newTrip';
  static const String trip = 'trip';
  static const String editTrip = 'editTrip';
  static const String share = 'share';
  static const String templates = 'templates';
  static const String settings = 'settings';
  static const String privacy = 'privacy';
  static const String paywall = 'paywall';
}

/// Path parameter name for a trip id.
const String tripIdParam = 'tripId';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: AppRoute.home,
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'trip/new',
            name: AppRoute.newTrip,
            builder: (BuildContext context, GoRouterState state) =>
                const TripWizardScreen(),
          ),
          GoRoute(
            path: 'trip/:$tripIdParam',
            name: AppRoute.trip,
            builder: (BuildContext context, GoRouterState state) =>
                PackingListScreen(
              tripId: state.pathParameters[tripIdParam]!,
            ),
            routes: <RouteBase>[
              GoRoute(
                path: 'edit',
                name: AppRoute.editTrip,
                builder: (BuildContext context, GoRouterState state) =>
                    TripWizardScreen(
                  tripId: state.pathParameters[tripIdParam]!,
                ),
              ),
              GoRoute(
                path: 'share',
                name: AppRoute.share,
                builder: (BuildContext context, GoRouterState state) =>
                    ShareScreen(
                  tripId: state.pathParameters[tripIdParam]!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'templates',
            name: AppRoute.templates,
            builder: (BuildContext context, GoRouterState state) =>
                const TemplatesScreen(),
          ),
          GoRoute(
            path: 'settings',
            name: AppRoute.settings,
            builder: (BuildContext context, GoRouterState state) =>
                const SettingsScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: 'privacy',
                name: AppRoute.privacy,
                builder: (BuildContext context, GoRouterState state) =>
                    const PrivacyScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'pro',
            name: AppRoute.paywall,
            builder: (BuildContext context, GoRouterState state) =>
                const PaywallScreen(),
          ),
        ],
      ),
    ],
    // A bad deep link must land somewhere usable, never on a red screen.
    errorBuilder: (BuildContext context, GoRouterState state) =>
        const HomeScreen(),
  );
}
