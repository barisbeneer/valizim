import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/trip_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/adaptive_field_row.dart';
import '../../../shared/widgets/count_stepper.dart';
import '../../../shared/widgets/dialogs.dart';
import '../domain/trip.dart';
import '../domain/trip_options.dart';
import '../domain/trip_type.dart';
import 'trip_display.dart';

/// Creates a trip, or edits an existing one.
///
/// Deliberately a single scrolling form rather than a multi-step wizard: the
/// whole thing is five decisions, four of which have sensible defaults, and a
/// stepper would put taps between the user and the payoff. The 30-second
/// success principle in spec section 1 is easier to hit with one screen and one
/// dominant button.
class TripWizardScreen extends ConsumerStatefulWidget {
  const TripWizardScreen({super.key, this.tripId});

  /// Null when creating.
  final String? tripId;

  @override
  ConsumerState<TripWizardScreen> createState() => _TripWizardScreenState();
}

class _TripWizardScreenState extends ConsumerState<TripWizardScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  TripType _tripType = TripType.general;
  int _durationDays = 3;
  int _travelerCount = 1;
  DateTime? _startDate;
  PackingOptions _options = const PackingOptions();

  Trip? _existing;
  bool _loaded = false;
  bool _saving = false;

  bool get _isEditing => widget.tripId != null;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(appPreferencesProvider);
    _durationDays = prefs.defaultDurationDays;
    _travelerCount = prefs.defaultTravelerCount;
    if (_isEditing) {
      unawaited(_loadExisting());
    } else {
      _loaded = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final result =
        await ref.read(tripRepositoryProvider).getTripWithItems(widget.tripId!);
    if (!mounted) return;
    final trip = result?.trip;
    setState(() {
      _loaded = true;
      _existing = trip;
      if (trip != null) {
        _nameController.text = trip.name;
        _tripType = trip.tripType;
        _durationDays = trip.durationDays;
        _travelerCount = trip.travelerCount;
        _startDate = trip.startDate;
        _options = trip.options;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_isEditing && _existing == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.listNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.wizardEditTitle : l10n.wizardTitle),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageGutter,
              AppSpacing.sm,
              AppSpacing.pageGutter,
              AppSpacing.xxl,
            ),
            children: <Widget>[
              _Heading(
                title: l10n.wizardStepTypeTitle,
                body: l10n.wizardStepTypeBody,
              ),
              _TripTypeGrid(
                selected: _tripType,
                onChanged: (TripType type) => setState(() => _tripType = type),
              ),
              const SizedBox(height: AppSpacing.xl),
              _Heading(title: l10n.wizardStepDetailsTitle),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                maxLength: AppConfig.maxTripNameLength,
                decoration: InputDecoration(
                  labelText: l10n.wizardNameLabel,
                  hintText: l10n.wizardNameHint,
                  prefixIcon: const Icon(Icons.edit_outlined),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.wizardNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              AdaptiveFieldRow(
                label: l10n.wizardDurationLabel,
                child: CountStepper(
                  value: _durationDays,
                  min: AppConfig.minDurationDays,
                  max: AppConfig.maxDurationDays,
                  semanticLabel: l10n.wizardDurationLabel,
                  valueLabel: l10n.wizardDurationValue(_durationDays),
                  onChanged: (int value) =>
                      setState(() => _durationDays = value),
                ),
              ),
              const Divider(height: AppSpacing.lg),
              AdaptiveFieldRow(
                label: l10n.wizardTravelersLabel,
                child: CountStepper(
                  value: _travelerCount,
                  min: AppConfig.minTravelerCount,
                  max: AppConfig.maxTravelerCount,
                  semanticLabel: l10n.wizardTravelersLabel,
                  onChanged: (int value) =>
                      setState(() => _travelerCount = value),
                ),
              ),
              const Divider(height: AppSpacing.lg),
              _StartDateField(
                value: _startDate,
                onChanged: (DateTime? value) =>
                    setState(() => _startDate = value),
              ),
              const SizedBox(height: AppSpacing.xl),
              _Heading(
                title: l10n.wizardStepExtrasTitle,
                body: l10n.wizardStepExtrasBody,
              ),
              _OptionSwitch(
                title: l10n.wizardOptionSwimming,
                subtitle: l10n.wizardOptionSwimmingHint,
                icon: Icons.pool_rounded,
                value: _options.swimming,
                onChanged: (bool v) =>
                    setState(() => _options = _options.copyWith(swimming: v)),
              ),
              _OptionSwitch(
                title: l10n.wizardOptionFormal,
                subtitle: l10n.wizardOptionFormalHint,
                icon: Icons.local_bar_rounded,
                value: _options.formalEvent,
                onChanged: (bool v) =>
                    setState(() => _options = _options.copyWith(formalEvent: v)),
              ),
              _OptionSwitch(
                title: l10n.wizardOptionWork,
                subtitle: l10n.wizardOptionWorkHint,
                icon: Icons.laptop_mac_rounded,
                value: _options.work,
                onChanged: (bool v) =>
                    setState(() => _options = _options.copyWith(work: v)),
              ),
              _OptionSwitch(
                title: l10n.wizardOptionLaundry,
                subtitle: l10n.wizardOptionLaundryHint,
                icon: Icons.local_laundry_service_rounded,
                value: _options.laundry,
                onChanged: (bool v) =>
                    setState(() => _options = _options.copyWith(laundry: v)),
              ),
              const SizedBox(height: AppSpacing.lg),
              _PreviewCount(
                tripType: _tripType,
                durationDays: _durationDays,
                travelerCount: _travelerCount,
                options: _options,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.pageGutter,
          AppSpacing.sm,
          AppSpacing.pageGutter,
          AppSpacing.md,
        ),
        child: FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? l10n.wizardSubmitEdit : l10n.wizardSubmit),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final l10n = AppL10n.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    try {
      final repository = ref.read(tripRepositoryProvider);
      final generator = ref.read(packingGeneratorProvider);
      final name = _nameController.text.trim();

      if (!_isEditing) {
        // Authoritative check, straight from the database. The provider-backed
        // gate on Home reads a stream that reports "unknown" as "allowed" so
        // the button is never wrongly disabled; this is the point where being
        // wrong would actually matter, so it asks the database directly.
        if (!ref.read(isProProvider) &&
            await repository.countTrips() >= AppConfig.freeTripLimit) {
          if (!mounted) return;
          setState(() => _saving = false);
          Haptics.warning();
          await context.pushNamed(AppRoute.paywall);
          return;
        }

        final items = generator.generate(
          tripType: _tripType,
          durationDays: _durationDays,
          travelerCount: _travelerCount,
          options: _options,
        );
        final id = await repository.createTrip(
          name: name,
          tripType: _tripType,
          durationDays: _durationDays,
          travelerCount: _travelerCount,
          settings: TripSettings(packing: _options),
          items: items,
          startDate: _startDate,
        );
        if (!mounted) return;
        Haptics.success();
        // Replace so Back from the new list returns home, not to the form.
        context.pushReplacementNamed(
          AppRoute.trip,
          pathParameters: <String, String>{tripIdParam: id},
        );
        return;
      }

      final existing = _existing!;
      // Regenerating throws away the user's ticks and their own items, so it is
      // only ever done with explicit consent.
      final affectsGeneration = existing.tripType != _tripType ||
          existing.durationDays != _durationDays ||
          existing.travelerCount != _travelerCount ||
          existing.options != _options;

      var regenerate = false;
      if (affectsGeneration) {
        regenerate = await AppDialogs.confirm(
          context,
          title: l10n.listRegenerateTitle,
          message: l10n.listRegenerateBody,
          confirmLabel: l10n.listRegenerateAction,
          destructive: true,
        );
      }

      final updated = existing.copyWith(
        name: name,
        tripType: _tripType,
        durationDays: _durationDays,
        travelerCount: _travelerCount,
        startDate: _startDate,
        settings: existing.settings.copyWith(packing: _options),
      );

      await repository.updateTrip(
        updated,
        regeneratedItems: regenerate
            ? ref.read(packingGeneratorProvider).generate(
                  tripType: _tripType,
                  durationDays: _durationDays,
                  travelerCount: _travelerCount,
                  options: _options,
                )
            : null,
      );

      // The start date may have moved or been cleared, so the OS schedule has
      // to follow it.
      await ref.read(reminderSchedulerProvider).sync(
            updated,
            (_) => (
              title: l10n.notificationTitle(updated.name),
              body: l10n.notificationBodyReady,
            ),
          );

      if (!mounted) return;
      context.pop();
    } on Object {
      if (!mounted) return;
      setState(() => _saving = false);
      context.showMessage(l10n.errorSaveFailed);
    }
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.title, this.body});

  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: theme.textTheme.titleLarge),
          if (body != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              body!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TripTypeGrid extends StatelessWidget {
  const _TripTypeGrid({required this.selected, required this.onChanged});

  final TripType selected;
  final ValueChanged<TripType> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: <Widget>[
        for (final type in TripType.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Semantics(
              selected: type == selected,
              button: true,
              child: Material(
                color: type == selected
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  onTap: () {
                    Haptics.selection();
                    onChanged(type);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm + AppSpacing.xs,
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          type.icon,
                          color: type == selected
                              ? scheme.onPrimaryContainer
                              : scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                type.label(l10n),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: type == selected
                                          ? scheme.onPrimaryContainer
                                          : null,
                                    ),
                              ),
                              Text(
                                type.hint(l10n),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: type == selected
                                          ? scheme.onPrimaryContainer
                                          : scheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (type == selected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: scheme.onPrimaryContainer,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StartDateField extends StatelessWidget {
  const _StartDateField({required this.value, required this.onChanged});

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final current = value;
    final formatted = current == null
        ? l10n.wizardStartDateNone
        : DateFormat.yMMMEd(Localizations.localeOf(context).toLanguageTag())
            .format(TripDate.toLocalDayStart(current));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AdaptiveFieldRow(
          label: l10n.wizardStartDateLabel,
          subtitle: l10n.wizardStartDateHelp,
          child: OutlinedButton.icon(
            onPressed: () => _pick(context),
            icon: const Icon(Icons.calendar_today_rounded, size: 18),
            label: Text(formatted),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, AppSpacing.minTapTarget),
            ),
          ),
        ),
        if (current != null)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => onChanged(null),
              child: Text(l10n.wizardStartDateClear),
            ),
          ),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    final today = TripDate.toLocalDayStart(TripDate.today());
    final initial =
        value == null ? today : TripDate.toLocalDayStart(value!);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(today) ? today : initial,
      // Past dates are allowed a short way back so a trip started yesterday can
      // still be recorded; the far bound keeps the picker usable.
      firstDate: today.subtract(const Duration(days: 30)),
      lastDate: DateTime(today.year + 3, today.month, today.day),
    );
    if (picked == null) return;
    onChanged(TripDate.toStorage(picked));
  }
}

class _OptionSwitch extends StatelessWidget {
  const _OptionSwitch({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: (bool next) {
        Haptics.selection();
        onChanged(next);
      },
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Icon(icon),
      contentPadding: EdgeInsets.zero,
    );
  }
}

/// Live count of what the current settings would produce, so the user sees the
/// effect of a toggle before committing.
class _PreviewCount extends ConsumerWidget {
  const _PreviewCount({
    required this.tripType,
    required this.durationDays,
    required this.travelerCount,
    required this.options,
  });

  final TripType tripType;
  final int durationDays;
  final int travelerCount;
  final PackingOptions options;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final rules = ref.watch(packingRulesProvider);
    final count = rules.whenOrNull(
      data: (_) => ref
          .read(packingGeneratorProvider)
          .generate(
            tripType: tripType,
            durationDays: durationDays,
            travelerCount: travelerCount,
            options: options,
          )
          .length,
    );
    if (count == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.checklist_rounded,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          l10n.wizardPreview(count),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
