import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/core/platform/device_location.dart';
import 'package:owghat_lib/src/features/qibla/application/qibla_point.dart';
import 'package:owghat_lib/src/features/qibla/presentation/qibla_map_support.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:prayer_core/prayer_core.dart';

/// The "Map" tab of the Qibla screen: the position to measure from (the
/// prayer-times city, this device, or any point), the qibla angle and
/// distance, and the line to the Kaaba on a map.
class QiblaMapTab extends ConsumerWidget {
  /// Creates the tab.
  const QiblaMapTab({super.key});

  /// Width from which the map and the side panel sit side by side.
  static const double twoColumnWidth = 900;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= twoColumnWidth) {
          return const Padding(
            padding: EdgeInsets.all(Gaps.l),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _MapArea()),
                SizedBox(width: Gaps.l),
                SizedBox(
                  width: 360,
                  child: SingleChildScrollView(child: _SidePanel()),
                ),
              ],
            ),
          );
        }
        final mapHeight = math.max<double>(320, constraints.maxHeight * 0.6);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(Gaps.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: mapHeight, child: const _MapArea()),
              const SizedBox(height: Gaps.l),
              const _SidePanel(),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------- side panel

class _SidePanel extends ConsumerStatefulWidget {
  const _SidePanel() : super(key: const Key('qibla-map-panel'));

  @override
  ConsumerState<_SidePanel> createState() => _SidePanelState();
}

class _SidePanelState extends ConsumerState<_SidePanel> {
  final TextEditingController _coords = TextEditingController();
  bool _coordsInvalid = false;

  @override
  void dispose() {
    _coords.dispose();
    super.dispose();
  }

  void _applyCoordinates() {
    final ok = ref
        .read(qiblaPointProvider.notifier)
        .setCustomFromText(_coords.text);
    setState(() => _coordsInvalid = !ok);
  }

  void _select(QiblaSourceKind kind) {
    final controller = ref.read(qiblaPointProvider.notifier);
    setState(() => _coordsInvalid = false);
    switch (kind) {
      case QiblaSourceKind.city:
        controller.useCity();
      case QiblaSourceKind.device:
        unawaited(controller.useDevice());
      case QiblaSourceKind.custom:
        final choice = ref.read(qiblaPointProvider);
        final point =
            choice.customPoint ??
            (
              latitude: ref.read(qiblaViewProvider).latitude,
              longitude: ref.read(qiblaViewProvider).longitude,
            );
        controller.setCustom(point.latitude, point.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = ref.watch(formatterProvider);
    final choice = ref.watch(qiblaPointProvider);
    final view = ref.watch(qiblaViewProvider);
    final mapEnabled = ref.watch(
      settingsProvider.select((s) => s.qibla.mapEnabled),
    );
    // While the device is being asked it counts as chosen, so a tap on the
    // selected city is a real change and cancels the request.
    final chosen = choice.locating ? QiblaSourceKind.device : choice.kind;
    final muted = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    final String sourceHelp;
    switch (choice.kind) {
      case QiblaSourceKind.city:
        sourceHelp = l10n.qiblaSourceCityHelp(view.placeName ?? '');
      case QiblaSourceKind.device:
        sourceHelp = l10n.qiblaDeviceFixShown;
      case QiblaSourceKind.custom:
        sourceHelp = l10n.qiblaSourceCustomHelp;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Gaps.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.qiblaSourceTitle, style: theme.textTheme.titleLarge),
                const SizedBox(height: Gaps.m),
                Column(
                  key: const Key('qibla-source'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SourceTile(
                      icon: Icons.location_city_outlined,
                      label: l10n.qiblaSourceCity,
                      selected: chosen == QiblaSourceKind.city,
                      onTap: () => _select(QiblaSourceKind.city),
                    ),
                    const SizedBox(height: Gaps.s),
                    _SourceTile(
                      icon: Icons.my_location,
                      label: l10n.qiblaSourceDevice,
                      selected: chosen == QiblaSourceKind.device,
                      onTap: () => _select(QiblaSourceKind.device),
                    ),
                    const SizedBox(height: Gaps.s),
                    _SourceTile(
                      icon: Icons.edit_location_alt_outlined,
                      label: l10n.qiblaSourceCustom,
                      selected: chosen == QiblaSourceKind.custom,
                      onTap: () => _select(QiblaSourceKind.custom),
                    ),
                  ],
                ),
                const SizedBox(height: Gaps.m),
                Text(
                  sourceHelp,
                  key: const Key('qibla-source-help'),
                  style: muted,
                ),
                if (choice.kind == QiblaSourceKind.device ||
                    choice.failure != null ||
                    choice.locating) ...[
                  const SizedBox(height: Gaps.m),
                  _DeviceBlock(muted: muted),
                ],
                if (choice.kind == QiblaSourceKind.custom) ...[
                  const SizedBox(height: Gaps.m),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          key: const Key('qibla-coords-field'),
                          controller: _coords,
                          textDirection: TextDirection.ltr,
                          decoration: InputDecoration(
                            labelText: l10n.qiblaCoordsLabel,
                            hintText: l10n.qiblaCoordsHint,
                            errorText: _coordsInvalid
                                ? l10n.qiblaCoordsInvalid
                                : null,
                            errorMaxLines: 3,
                          ),
                          onSubmitted: (_) => _applyCoordinates(),
                        ),
                      ),
                      const SizedBox(width: Gaps.s),
                      Padding(
                        padding: const EdgeInsets.only(top: Gaps.s),
                        child: FilledButton(
                          key: const Key('qibla-coords-apply'),
                          onPressed: _applyCoordinates,
                          child: Text(l10n.qiblaCoordsApply),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: Gaps.m),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Gaps.l),
            child: Wrap(
              spacing: Gaps.xl,
              runSpacing: Gaps.m,
              children: [
                _Stat(
                  label: l10n.qiblaBearingLabel,
                  value: l10n.qiblaBearingValue(
                    fmt.formatNumber(view.info.bearing, fractionDigits: 1),
                    l10n.homeCompass('p${view.info.compassIndex}'),
                  ),
                  valueKey: const Key('qibla-map-bearing'),
                ),
                _Stat(
                  label: l10n.qiblaDistanceLabel,
                  value: l10n.qiblaDistanceValue(
                    fmt.formatNumber(view.info.distanceKm.round()),
                  ),
                  valueKey: const Key('qibla-map-distance'),
                ),
                _Stat(
                  label: l10n.qiblaStatLatitude,
                  value: fmt.formatNumber(view.latitude, fractionDigits: 4),
                  valueKey: const Key('qibla-map-lat'),
                ),
                _Stat(
                  label: l10n.qiblaStatLongitude,
                  value: fmt.formatNumber(view.longitude, fractionDigits: 4),
                  valueKey: const Key('qibla-map-lon'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Gaps.m),
        Text(
          l10n.qiblaMapLineNote,
          key: const Key('qibla-map-note'),
          style: muted,
        ),
        if (mapEnabled) ...[
          const SizedBox(height: Gaps.s),
          Text(l10n.qiblaMapTapHint, style: muted),
          const SizedBox(height: Gaps.s),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              key: const Key('qibla-map-off'),
              onPressed: () => ref
                  .read(settingsProvider.notifier)
                  .setQiblaMapEnabled(enabled: false),
              child: Text(l10n.qiblaMapTurnOff),
            ),
          ),
        ],
      ],
    );
  }
}

/// One choice of where to measure from: an outlined row that fills with the
/// primary colour when chosen. (A row of three segments did not fit the
/// panel: Persian labels broke in the middle of a word.)
class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: selected ? scheme.primaryContainer : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Gaps.m,
              vertical: Gaps.m,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: Gaps.m),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : null,
                    ),
                  ),
                ),
                if (selected) Icon(Icons.check_circle, color: scheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.valueKey,
  });

  final String label;
  final String value;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(value, key: valueKey, style: theme.textTheme.titleLarge),
      ],
    );
  }
}

/// The "find my position" button, its progress, accuracy and any failure.
class _DeviceBlock extends ConsumerWidget {
  const _DeviceBlock({required this.muted});

  final TextStyle? muted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = ref.watch(formatterProvider);
    final choice = ref.watch(qiblaPointProvider);
    final view = ref.watch(qiblaViewProvider);
    final failure = choice.failure;
    final hasFix = choice.deviceFix != null;

    String? failureText;
    switch (failure) {
      case null:
        break;
      case DeviceLocationFailure.serviceDisabled:
        failureText = l10n.qiblaFailServiceDisabled;
      case DeviceLocationFailure.permissionDenied:
        failureText = l10n.qiblaFailPermissionDenied;
      case DeviceLocationFailure.permissionDeniedForever:
        failureText = l10n.qiblaFailPermissionForever;
      case DeviceLocationFailure.timeout:
        failureText = l10n.qiblaFailTimeout;
      case DeviceLocationFailure.unsupported:
        failureText = l10n.qiblaFailUnsupported;
      case DeviceLocationFailure.failed:
        failureText = l10n.qiblaFailGeneric;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton.tonalIcon(
            key: const Key('qibla-locate'),
            onPressed: choice.locating
                ? null
                : () => unawaited(
                    ref.read(qiblaPointProvider.notifier).locateDevice(),
                  ),
            icon: choice.locating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: Text(
              choice.locating
                  ? l10n.qiblaLocating
                  : (hasFix ? l10n.qiblaLocateAgain : l10n.qiblaLocateButton),
            ),
          ),
        ),
        if (view.kind == QiblaSourceKind.device &&
            view.accuracyMeters != null) ...[
          const SizedBox(height: Gaps.s),
          Text(
            l10n.qiblaAccuracyValue(
              fmt.formatNumber(view.accuracyMeters!.round()),
            ),
            key: const Key('qibla-accuracy'),
            style: muted,
          ),
        ],
        if (failureText != null) ...[
          const SizedBox(height: Gaps.s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: context.appColors.warning,
              ),
              const SizedBox(width: Gaps.s),
              Expanded(
                child: Text(
                  failureText,
                  key: const Key('qibla-locate-failure'),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ----------------------------------------------------------------------- map

enum _Camera { overview, nearby, kaaba }

LatLng _latLng(GeoPoint point) => LatLng(point.latitude, point.longitude);

class _MapArea extends ConsumerStatefulWidget {
  const _MapArea();

  @override
  ConsumerState<_MapArea> createState() => _MapAreaState();
}

class _MapAreaState extends ConsumerState<_MapArea> {
  /// Zoom of the "around me" view: about a kilometre across the window, so
  /// the line can be compared with streets and buildings.
  static const double nearbyZoom = 17;

  /// Zoom of the Kaaba view.
  static const double kaabaZoom = 19;

  /// Tile errors after which the "no internet" banner shows.
  static const int offlineAfterErrors = 4;

  final MapController _controller = MapController();
  _Camera _camera = _Camera.overview;
  bool _ready = false;
  bool _fromMapTap = false;
  int _tileErrors = 0;

  CameraFit _overviewFit(List<GeoPoint> path) => CameraFit.bounds(
    bounds: LatLngBounds.fromPoints([for (final p in path) _latLng(p)]),
    padding: const EdgeInsets.fromLTRB(56, 72, 56, 56),
    maxZoom: 15,
  );

  void _moveCamera(_Camera camera, QiblaView view, List<GeoPoint> path) {
    if (!_ready) return;
    switch (camera) {
      case _Camera.overview:
        _controller.fitCamera(_overviewFit(path));
      case _Camera.nearby:
        _controller.move(LatLng(view.latitude, view.longitude), nearbyZoom);
      case _Camera.kaaba:
        _controller.move(
          const LatLng(kaabaLatitude, kaabaLongitude),
          kaabaZoom,
        );
    }
  }

  void _setCamera(_Camera camera) {
    setState(() {
      _camera = camera;
      _tileErrors = 0;
    });
    _moveCamera(
      camera,
      ref.read(qiblaViewProvider),
      ref.read(qiblaPathProvider),
    );
  }

  void _onTileError() {
    if (!mounted) return;
    // Tile errors arrive during layout; schedule the rebuild for after it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _tileErrors < offlineAfterErrors + 1) {
        setState(() => _tileErrors++);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final fmt = ref.watch(formatterProvider);
    final mapEnabled = ref.watch(
      settingsProvider.select((s) => s.qibla.mapEnabled),
    );

    if (!mapEnabled) return const _ConsentCard();

    final view = ref.watch(qiblaViewProvider);
    final path = ref.watch(qiblaPathProvider);

    // A new start point (another source, a device fix, typed coordinates)
    // moves the camera to the current view mode. A tap on the map keeps the
    // camera where the user has put it.
    ref.listen(qiblaViewProvider, (previous, next) {
      if (previous == next) return;
      if (_fromMapTap) {
        _fromMapTap = false;
        return;
      }
      _moveCamera(_camera, next, ref.read(qiblaPathProvider));
    });

    final placeName = view.placeName ?? l10n.qiblaMapYou;
    final bearing = l10n.qiblaBearingValue(
      fmt.formatNumber(view.info.bearing, fractionDigits: 1),
      l10n.homeCompass('p${view.info.compassIndex}'),
    );
    final distance = l10n.qiblaDistanceValue(
      fmt.formatNumber(view.info.distanceKm.round()),
    );
    final tileProvider = ref.watch(qiblaTileProviderProvider);
    final qiblaColor = theme.colorScheme.primary;
    final accuracy = view.accuracyMeters;
    final arrowAt = path[math.min(2, path.length - 1)];

    return Semantics(
      container: true,
      label: l10n.qiblaMapSemantics(placeName, bearing, distance),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            FlutterMap(
              key: const Key('qibla-map'),
              mapController: _controller,
              options: MapOptions(
                initialCameraFit: _overviewFit(path),
                minZoom: 2,
                maxZoom: 19,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                onMapReady: () => _ready = true,
                onTap: (position, point) {
                  _fromMapTap = true;
                  ref
                      .read(qiblaPointProvider.notifier)
                      .setCustom(point.latitude, point.longitude);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: qiblaTileUrlTemplate,
                  userAgentPackageName: qiblaTileUserAgent,
                  tileProvider: tileProvider,
                  errorTileCallback: (tile, error, stack) => _onTileError(),
                ),
                if (accuracy != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: LatLng(view.latitude, view.longitude),
                        radius: accuracy,
                        useRadiusInMeter: true,
                        color: qiblaColor.withValues(alpha: 0.15),
                        borderColor: qiblaColor,
                        borderStrokeWidth: 1,
                      ),
                    ],
                  ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [for (final p in path) _latLng(p)],
                      strokeWidth: 4,
                      color: qiblaColor,
                      borderStrokeWidth: 2,
                      borderColor: Colors.white,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _latLng(arrowAt),
                      width: 32,
                      height: 32,
                      child: Transform.rotate(
                        angle: view.info.bearing * math.pi / 180,
                        child: Icon(
                          Icons.navigation,
                          key: const Key('qibla-map-arrow'),
                          color: qiblaColor,
                          size: 28,
                        ),
                      ),
                    ),
                    Marker(
                      point: const LatLng(kaabaLatitude, kaabaLongitude),
                      width: 44,
                      height: 44,
                      child: Tooltip(
                        message: l10n.qiblaMapKaaba,
                        child: Container(
                          key: const Key('qibla-map-kaaba'),
                          decoration: BoxDecoration(
                            color: colors.accentWarm,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.mosque,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    Marker(
                      point: LatLng(view.latitude, view.longitude),
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: Tooltip(
                        message: placeName,
                        child: Icon(
                          Icons.location_on,
                          key: const Key('qibla-map-you'),
                          color: colors.danger,
                          size: 44,
                        ),
                      ),
                    ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(l10n.qiblaMapAttribution),
                  ],
                ),
              ],
            ),
            PositionedDirectional(
              top: Gaps.s,
              start: Gaps.s,
              end: Gaps.s,
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(24),
                  color: theme.colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Gaps.s,
                      vertical: 4,
                    ),
                    child: Wrap(
                      spacing: Gaps.s,
                      children: [
                        for (final entry in [
                          (_Camera.overview, l10n.qiblaCamOverview),
                          (_Camera.nearby, l10n.qiblaCamNearby),
                          (_Camera.kaaba, l10n.qiblaCamKaaba),
                        ])
                          ChoiceChip(
                            key: Key('qibla-cam-${entry.$1.name}'),
                            label: Text(entry.$2),
                            selected: _camera == entry.$1,
                            onSelected: (_) => _setCamera(entry.$1),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_tileErrors >= offlineAfterErrors)
              PositionedDirectional(
                start: Gaps.s,
                end: Gaps.s,
                bottom: 28,
                child: Material(
                  key: const Key('qibla-map-offline'),
                  elevation: 2,
                  borderRadius: BorderRadius.circular(8),
                  color: theme.colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(Gaps.s),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off, size: 20, color: colors.warning),
                        const SizedBox(width: Gaps.s),
                        Expanded(
                          child: Text(
                            l10n.qiblaMapOfflineBanner,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConsentCard extends ConsumerWidget {
  const _ConsentCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      key: const Key('qibla-map-consent'),
      child: Padding(
        padding: const EdgeInsets.all(Gaps.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: Gaps.m),
                  Text(
                    l10n.qiblaMapConsentTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: Gaps.s),
                  Text(
                    l10n.qiblaMapConsentBody,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: Gaps.l),
                  Align(
                    child: FilledButton.icon(
                      key: const Key('qibla-map-enable'),
                      onPressed: () => ref
                          .read(settingsProvider.notifier)
                          .setQiblaMapEnabled(enabled: true),
                      icon: const Icon(Icons.public),
                      label: Text(l10n.qiblaMapConsentButton),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
