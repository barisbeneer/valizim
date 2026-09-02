import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/haptics.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/pro_badge.dart';
import '../../trips/domain/item_label_resolver.dart';
import '../../trips/domain/trip.dart';
import '../../trips/presentation/trip_display.dart';
import '../domain/share_text_builder.dart';
import 'widgets/share_card.dart';

/// Share as text (free) or as a rendered card (Pro).
class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({required this.tripId, super.key});

  final String tripId;

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final detail = ref.watch(tripDetailProvider(widget.tripId));
    final isPro = ref.watch(isProProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shareTitle)),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) =>
            Center(child: Text(l10n.errorGeneric)),
        data: (TripWithItems? data) {
          if (data == null) return Center(child: Text(l10n.listNotFound));

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.pageGutter),
            children: <Widget>[
              // Rendered off-list at a fixed width so the exported image is the
              // same on every device, then shown scaled to fit.
              Center(
                child: FittedBox(
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: ShareCard(
                      data: data,
                      tagline: l10n.shareCardTagline,
                      typeLabel: data.trip.tripType.label(l10n),
                      metaLabel: _meta(data, l10n),
                      progressLabel:
                          l10n.packedOfTotal(data.packed, data.total),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: _sharing ? null : () => _shareText(data),
                icon: const Icon(Icons.notes_rounded),
                label: Text(l10n.shareAsText),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.shareAsTextHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: _sharing ? null : () => _shareImage(isPro),
                icon: const Icon(Icons.image_outlined),
                label: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: <Widget>[
                    Text(l10n.shareAsImage),
                    if (!isPro) ProBadge(label: l10n.proBadge),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.shareAsImageHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _meta(TripWithItems data, AppL10n l10n) => l10n.shareTextMeta(
        l10n.daysCount(data.trip.durationDays),
        l10n.travelersCount(data.trip.travelerCount),
      );

  Future<void> _shareText(TripWithItems data) async {
    final l10n = AppL10n.of(context);
    final rules = ref.read(packingRulesProvider).valueOrNull;
    final resolver = rules == null
        ? null
        : ItemLabelResolver.forTrip(
            rules: rules,
            trip: data.trip,
            languageCode: Localizations.localeOf(context).languageCode,
          );

    final text = ShareTextBuilder.build(
      data: data,
      labelFor: (TripItem item) => resolver?.labelFor(item) ?? item.label,
      labels: ShareTextLabels(
        header: l10n.shareTextHeader(data.trip.name),
        meta: _meta(data, l10n),
        progress: l10n.packedOfTotal(data.packed, data.total),
        footer: l10n.shareTextFooter,
        categoryLabel: (category) => category.label(l10n),
      ),
    );

    setState(() => _sharing = true);
    try {
      await SharePlus.instance.share(
        ShareParams(text: text, subject: data.trip.name),
      );
    } on Object {
      if (!mounted) return;
      context.showMessage(l10n.shareFailed);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _shareImage(bool isPro) async {
    final l10n = AppL10n.of(context);
    if (!isPro) {
      Haptics.warning();
      context.showMessage(l10n.proLockedShareCard);
      await context.pushNamed(AppRoute.paywall);
      return;
    }

    setState(() => _sharing = true);
    try {
      final boundary = _cardKey.currentContext?.findRenderObject();
      if (boundary is! RenderRepaintBoundary) {
        throw StateError('share card is not attached');
      }
      // 3x keeps the card crisp when the recipient views it full-screen.
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) throw StateError('failed to encode share card');

      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[
            XFile.fromData(
              bytes.buffer.asUint8List(),
              mimeType: 'image/png',
              name: 'valizim.png',
            ),
          ],
        ),
      );
    } on Object {
      if (!mounted) return;
      context.showMessage(l10n.shareFailed);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }
}
