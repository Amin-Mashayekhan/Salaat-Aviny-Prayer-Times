import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/features/calendar/application/calendar_names.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/domain/coordinates.dart';
import 'package:owghat_lib/src/features/locations/domain/custom_location_input.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/application/location_draft.dart';
import 'package:owghat_lib/src/features/settings/application/zone_info.dart';
import 'package:owghat_lib/src/features/settings/presentation/setting_widgets.dart';
import 'package:prayer_core/prayer_core.dart';

/// The live "offset in effect today" lines of a time zone: the offset, and
/// the next change in the database if there is one. There is no daylight
/// saving switch anywhere; this is only a read-out.
class OffsetInEffectLines extends ConsumerWidget {
  /// Creates the lines for [info]; [keyId] makes the keys unique.
  const OffsetInEffectLines({
    required this.info,
    required this.keyId,
    super.key,
  });

  /// What to show.
  final OffsetInEffect info;

  /// Suffix of the widget keys.
  final String keyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fmt = ref.watch(formatterProvider);
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    final String second;
    final next = info.nextChangeAt;
    if (info.fixed) {
      second = l10n.settingsZoneFixedAllYear;
    } else if (next != null && info.nextOffset != null) {
      final local = next.add(info.current);
      final header = ref.watch(
        dateHeaderProvider(CivilDate.fromDateTime(local)),
      );
      second = l10n.settingsZoneNext(
        header.primary,
        fmt.formatInstant(next, info.current),
        formatUtcOffset(fmt, info.nextOffset!),
      );
    } else {
      second = l10n.settingsZoneNoChange;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsZoneNow(formatUtcOffset(fmt, info.current)),
          key: Key('set-zone-now-$keyId'),
          style: theme.textTheme.bodyMedium,
        ),
        Text(second, key: Key('set-zone-next-$keyId'), style: style),
      ],
    );
  }
}

/// Minus and plus buttons for a fixed UTC offset, by one hour and by a
/// quarter of an hour, between -12:00 and +14:00.
class FixedOffsetStepper extends ConsumerWidget {
  /// Creates the stepper.
  const FixedOffsetStepper({
    required this.minutes,
    required this.onChanged,
    required this.keyPrefix,
    super.key,
  });

  /// The offset in minutes east of UTC.
  final int minutes;

  /// Called with the new offset.
  final ValueChanged<int> onChanged;

  /// Keys are `<keyPrefix>-hour-dec`, `-quarter-dec`, `-quarter-inc`,
  /// `-hour-inc` and `-value`.
  final String keyPrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fmt = ref.watch(formatterProvider);

    Widget button(String name, IconData icon, String tooltip, int delta) {
      final target = minutes + delta;
      final allowed =
          target >= LocationOffset.minFixedMinutes &&
          target <= LocationOffset.maxFixedMinutes;
      return IconButton(
        key: Key('$keyPrefix-$name'),
        tooltip: tooltip,
        icon: Icon(icon),
        onPressed: allowed ? () => onChanged(target) : null,
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        button(
          'hour-dec',
          Icons.keyboard_double_arrow_down,
          l10n.settingsZoneHourLess,
          -60,
        ),
        button(
          'quarter-dec',
          Icons.keyboard_arrow_down,
          l10n.settingsZoneQuarterLess,
          -15,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gaps.s),
          child: Text(
            formatUtcOffset(fmt, Duration(minutes: minutes)),
            key: Key('$keyPrefix-value'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        button(
          'quarter-inc',
          Icons.keyboard_arrow_up,
          l10n.settingsZoneQuarterMore,
          15,
        ),
        button(
          'hour-inc',
          Icons.keyboard_double_arrow_up,
          l10n.settingsZoneHourMore,
          60,
        ),
      ],
    );
  }
}

/// Automatic or fixed offset for one location (rule T-3): two choices, the
/// zone used when automatic, the stepper when fixed.
class OffsetModeEditor extends ConsumerWidget {
  /// Creates the editor.
  const OffsetModeEditor({
    required this.value,
    required this.zoneId,
    required this.onChanged,
    required this.keyPrefix,
    super.key,
  });

  /// The current rule.
  final LocationOffset value;

  /// The zone used by the automatic rule.
  final String zoneId;

  /// Called with the new rule.
  final ValueChanged<LocationOffset> onChanged;

  /// Prefix of the widget keys.
  final String keyPrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fmt = ref.watch(formatterProvider);

    void choose(OffsetMode mode) {
      if (mode == value.mode) return;
      if (mode == OffsetMode.automatic) {
        onChanged(const LocationOffset.automatic());
        return;
      }
      // Start from the offset the zone has now, rounded to a quarter hour.
      final info = describeOffset(
        resolver: ref.read(zoneOffsetResolverProvider),
        rule: const LocationOffset.automatic(),
        zoneId: zoneId,
        now: ref.read(settingsNowMinuteProvider),
      );
      onChanged(
        LocationOffset.fixed(roundToQuarterHour(info.current.inMinutes)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChoiceChips<OffsetMode>(
          keyPrefix: '$keyPrefix-mode',
          semanticsLabel: l10n.settingsZoneTitle,
          value: value.mode,
          options: [
            (OffsetMode.automatic, l10n.settingsZoneAuto),
            (OffsetMode.fixed, l10n.settingsZoneFixed),
          ],
          onChanged: choose,
        ),
        const SizedBox(height: Gaps.s),
        if (value.mode == OffsetMode.automatic)
          Text(
            l10n.settingsZoneAutoHelp(Formatter.isolate(zoneId)),
            style: Theme.of(context).textTheme.bodySmall,
          )
        else ...[
          Text(
            l10n.settingsZoneFixedHelp,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          FixedOffsetStepper(
            keyPrefix: '$keyPrefix-fixed',
            minutes: value.fixedMinutes ?? 0,
            onChanged: (minutes) => onChanged(LocationOffset.fixed(minutes)),
          ),
          Text(
            l10n.settingsZoneFixedValue(
              formatUtcOffset(fmt, Duration(minutes: value.fixedMinutes ?? 0)),
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

/// The form for a custom location: name, latitude and longitude (decimal or
/// degrees-minutes-seconds), elevation, and the time zone (searchable list or
/// a fixed offset). Validation is `validateCustomLocation`; nothing is saved
/// until [onSubmit] is called with a valid draft.
class CustomLocationForm extends ConsumerStatefulWidget {
  /// Creates the form. With [initial] it edits that location.
  const CustomLocationForm({
    required this.onSubmit,
    required this.submitLabel,
    this.initial,
    this.showOffset = true,
    this.keyPrefix = 'set-loc',
    super.key,
  });

  /// Prefix of the widget keys (two forms can be open at once).
  final String keyPrefix;

  /// The location being edited, or null for a new one.
  final SavedLocation? initial;

  /// Whether the form also edits the offset rule (off when the caller shows
  /// its own editor).
  final bool showOffset;

  /// Label of the submit button.
  final String submitLabel;

  /// Called with a draft that passed validation.
  final void Function(CustomLocationDraft draft) onSubmit;

  @override
  ConsumerState<CustomLocationForm> createState() => _CustomLocationFormState();
}

class _CustomLocationFormState extends ConsumerState<CustomLocationForm> {
  final _name = TextEditingController();
  final _elevation = TextEditingController();
  final _latText = TextEditingController();
  final _lonText = TextEditingController();
  final _latDeg = TextEditingController();
  final _latMin = TextEditingController();
  final _latSec = TextEditingController();
  final _lonDeg = TextEditingController();
  final _lonMin = TextEditingController();
  final _lonSec = TextEditingController();
  final _zoneSearch = TextEditingController();

  CoordinateFormat _format = CoordinateFormat.decimal;
  bool _latSouth = false;
  bool _lonWest = false;
  String _zoneId = 'Asia/Tehran';
  LocationOffset _offset = const LocationOffset.automatic();
  LocationInputError? _error;
  late final List<String> _allZones;

  @override
  void initState() {
    super.initState();
    _allZones = ref.read(zoneOffsetResolverProvider).zoneIds;
    final initial = widget.initial;
    if (initial != null && initial.kind == LocationKind.custom) {
      _name.text = initial.name!;
      _latText.text = _plain(initial.latitude!);
      _lonText.text = _plain(initial.longitude!);
      _elevation.text = initial.elevationMeters == 0
          ? ''
          : _plain(initial.elevationMeters);
      _zoneId = initial.zoneId;
      _offset = initial.offset;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _elevation,
      _latText,
      _lonText,
      _latDeg,
      _latMin,
      _latSec,
      _lonDeg,
      _lonMin,
      _lonSec,
      _zoneSearch,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _plain(double value) {
    final text = value.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '');
    return text.isEmpty ? '0' : text;
  }

  CoordinateInput get _lat => _format == CoordinateFormat.decimal
      ? CoordinateInput.decimal(_latText.text)
      : CoordinateInput.dms(
          degrees: _latDeg.text,
          minutes: _latMin.text,
          seconds: _latSec.text,
          negative: _latSouth,
        );

  CoordinateInput get _lon => _format == CoordinateFormat.decimal
      ? CoordinateInput.decimal(_lonText.text)
      : CoordinateInput.dms(
          degrees: _lonDeg.text,
          minutes: _lonMin.text,
          seconds: _lonSec.text,
          negative: _lonWest,
        );

  /// Carries the typed coordinates over when the format changes.
  void _switchFormat(CoordinateFormat next) {
    if (next == _format) return;
    final lat = _lat.parse();
    final lon = _lon.parse();
    setState(() {
      if (next == CoordinateFormat.dms) {
        if (lat != null) {
          final d = Dms.fromDecimal(lat);
          _latDeg.text = d.degrees.toString();
          _latMin.text = d.minutes.toString();
          _latSec.text = _plain(d.seconds);
          _latSouth = d.negative;
        }
        if (lon != null) {
          final d = Dms.fromDecimal(lon);
          _lonDeg.text = d.degrees.toString();
          _lonMin.text = d.minutes.toString();
          _lonSec.text = _plain(d.seconds);
          _lonWest = d.negative;
        }
      } else {
        if (lat != null) _latText.text = _plain(lat);
        if (lon != null) _lonText.text = _plain(lon);
      }
      _format = next;
    });
  }

  CustomLocationDraft get _draft => CustomLocationDraft(
    name: _name.text,
    latitude: _lat,
    longitude: _lon,
    elevationText: _elevation.text,
    zoneId: _zoneId,
    offset: _offset,
  );

  void _submit() {
    final error = _draft.validate(ref.read(zoneOffsetResolverProvider));
    setState(() => _error = error);
    if (error == null) widget.onSubmit(_draft);
  }

  String _errorText(AppLocalizations l10n, LocationInputError error) {
    final fmt = ref.read(formatterProvider);
    return switch (error) {
      LocationInputError.nameEmpty => l10n.settingsLocErrName,
      LocationInputError.latitudeRange => l10n.settingsLocErrLatitude(
        fmt.formatNumber(-SavedLocation.maxLatitude, fractionDigits: 1),
        fmt.formatNumber(SavedLocation.maxLatitude, fractionDigits: 1),
      ),
      LocationInputError.longitudeRange => l10n.settingsLocErrLongitude(
        fmt.formatNumber(-180),
        fmt.formatNumber(180),
      ),
      LocationInputError.elevationRange => l10n.settingsLocErrElevation(
        fmt.formatNumber(0),
        fmt.formatNumber(9000),
      ),
      LocationInputError.unknownZone => l10n.settingsLocErrZone,
      LocationInputError.offsetRange => l10n.settingsLocErrOffset(
        formatUtcOffset(
          fmt,
          const Duration(minutes: LocationOffset.minFixedMinutes),
        ),
        formatUtcOffset(
          fmt,
          const Duration(minutes: LocationOffset.maxFixedMinutes),
        ),
      ),
    };
  }

  Widget _numberField({
    required Key key,
    required TextEditingController controller,
    required String label,
    String? error,
    double? width,
  }) {
    final field = TextField(
      key: key,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        errorText: error,
        errorMaxLines: 4,
      ),
    );
    return width == null ? field : SizedBox(width: width, child: field);
  }

  Widget _coordinate({
    required String label,
    required String keyId,
    required TextEditingController decimal,
    required TextEditingController deg,
    required TextEditingController min,
    required TextEditingController sec,
    required bool negative,
    required ValueChanged<bool> onHemisphere,
    required String positiveLabel,
    required String negativeLabel,
    required String? error,
  }) {
    final l10n = AppLocalizations.of(context);
    if (_format == CoordinateFormat.decimal) {
      return _numberField(
        key: Key('${widget.keyPrefix}-$keyId'),
        controller: decimal,
        label: label,
        error: error,
      );
    }
    final danger = context.appColors.danger;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: Gaps.s),
        Wrap(
          spacing: Gaps.s,
          runSpacing: Gaps.s,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _numberField(
              key: Key('${widget.keyPrefix}-$keyId-deg'),
              controller: deg,
              label: l10n.settingsLocDegrees,
              width: 96,
            ),
            _numberField(
              key: Key('${widget.keyPrefix}-$keyId-min'),
              controller: min,
              label: l10n.settingsLocMinutes,
              width: 96,
            ),
            _numberField(
              key: Key('${widget.keyPrefix}-$keyId-sec'),
              controller: sec,
              label: l10n.settingsLocSeconds,
              width: 112,
            ),
            ChoiceChips<bool>(
              keyPrefix: '${widget.keyPrefix}-$keyId-hemisphere',
              semanticsLabel: label,
              value: negative,
              options: [(false, positiveLabel), (true, negativeLabel)],
              onChanged: (value) => setState(() => onHemisphere(value)),
            ),
          ],
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: Gaps.s / 2),
            child: Text(
              error,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: danger),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final error = _error;
    String? errorFor(LocationInputError which) =>
        error == which ? _errorText(l10n, which) : null;
    final zones = filterZoneIds(_allZones, _zoneSearch.text, limit: 30);
    final fixed = _offset.mode == OffsetMode.fixed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: Key('${widget.keyPrefix}-name'),
          controller: _name,
          decoration: InputDecoration(
            isDense: true,
            labelText: l10n.settingsLocName,
            errorText: errorFor(LocationInputError.nameEmpty),
          ),
        ),
        const SizedBox(height: Gaps.m),
        ChoiceChips<CoordinateFormat>(
          keyPrefix: '${widget.keyPrefix}-format',
          semanticsLabel: l10n.settingsLocFormatDecimal,
          value: _format,
          options: [
            (CoordinateFormat.decimal, l10n.settingsLocFormatDecimal),
            (CoordinateFormat.dms, l10n.settingsLocFormatDms),
          ],
          onChanged: _switchFormat,
        ),
        const SizedBox(height: Gaps.m),
        _coordinate(
          label: l10n.settingsLocLatitude,
          keyId: 'lat',
          decimal: _latText,
          deg: _latDeg,
          min: _latMin,
          sec: _latSec,
          negative: _latSouth,
          onHemisphere: (v) => _latSouth = v,
          positiveLabel: l10n.settingsLocNorth,
          negativeLabel: l10n.settingsLocSouth,
          error: errorFor(LocationInputError.latitudeRange),
        ),
        const SizedBox(height: Gaps.m),
        _coordinate(
          label: l10n.settingsLocLongitude,
          keyId: 'lon',
          decimal: _lonText,
          deg: _lonDeg,
          min: _lonMin,
          sec: _lonSec,
          negative: _lonWest,
          onHemisphere: (v) => _lonWest = v,
          positiveLabel: l10n.settingsLocEast,
          negativeLabel: l10n.settingsLocWest,
          error: errorFor(LocationInputError.longitudeRange),
        ),
        const SizedBox(height: Gaps.m),
        _numberField(
          key: Key('${widget.keyPrefix}-elevation'),
          controller: _elevation,
          label: l10n.settingsLocElevation,
          error: errorFor(LocationInputError.elevationRange),
        ),
        if (widget.showOffset) ...[
          const SizedBox(height: Gaps.l),
          Text(l10n.settingsZoneTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: Gaps.s),
          OffsetModeEditor(
            keyPrefix: '${widget.keyPrefix}-offset',
            value: _offset,
            zoneId: _zoneId,
            onChanged: (value) => setState(() => _offset = value),
          ),
          if (errorFor(LocationInputError.offsetRange) != null)
            Text(
              errorFor(LocationInputError.offsetRange)!,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.danger),
            ),
        ],
        if (!fixed || !widget.showOffset) ...[
          const SizedBox(height: Gaps.m),
          TextField(
            key: Key('${widget.keyPrefix}-zone-search'),
            controller: _zoneSearch,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.search),
              labelText: l10n.settingsLocZoneSearch,
              errorText: errorFor(LocationInputError.unknownZone),
            ),
          ),
          const SizedBox(height: Gaps.s),
          Text(
            l10n.settingsLocZoneSelected(Formatter.isolate(_zoneId)),
            key: Key('${widget.keyPrefix}-zone-selected'),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: Gaps.s),
          SizedBox(
            height: 168,
            child: zones.isEmpty
                ? Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(l10n.settingsLocZoneNone),
                  )
                : ListView.builder(
                    key: Key('${widget.keyPrefix}-zone-list'),
                    itemCount: zones.length,
                    itemExtent: 40,
                    itemBuilder: (context, index) {
                      final id = zones[index];
                      return InkWell(
                        key: Key('${widget.keyPrefix}-zone-$id'),
                        onTap: () => setState(() => _zoneId = id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Gaps.s,
                          ),
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              id,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: id == _zoneId
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: id == _zoneId
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
        if (widget.showOffset) ...[
          const SizedBox(height: Gaps.s),
          Consumer(
            builder: (context, ref, _) {
              final info = describeOffset(
                resolver: ref.watch(zoneOffsetResolverProvider),
                rule: _offset,
                zoneId: _zoneId,
                now: ref.watch(settingsNowMinuteProvider),
              );
              return OffsetInEffectLines(info: info, keyId: widget.keyPrefix);
            },
          ),
        ],
        const SizedBox(height: Gaps.l),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton(
            key: Key('${widget.keyPrefix}-submit'),
            onPressed: _submit,
            child: Text(widget.submitLabel),
          ),
        ),
      ],
    );
  }
}
