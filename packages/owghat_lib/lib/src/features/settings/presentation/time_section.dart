import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/core/time/clock_warning.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/clock/application/clock_warning_provider.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/application/zone_info.dart';
import 'package:owghat_lib/src/features/settings/presentation/setting_widgets.dart';
import 'package:prayer_core/prayer_core.dart';

/// Section 5: the optional network time check, its last result, and the
/// clock diagnostics (D-1 skew, D-2 stale Windows rules).
class TimeSection extends ConsumerWidget {
  /// Creates the section.
  const TimeSection({super.key});

  /// Whether [host] looks like a server name or address.
  static bool isValidHost(String host) =>
      host.isNotEmpty &&
      host.length <= 253 &&
      RegExp(r'^[A-Za-z0-9]([A-Za-z0-9.\-]*[A-Za-z0-9])?$').hasMatch(host);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final fmt = ref.watch(formatterProvider);
    final network = ref.watch(settingsProvider.select((s) => s.networkTime));
    final controller = ref.read(settingsProvider.notifier);
    final correction = ref.watch(clockCorrectionProvider);
    final warning = ref.watch(clockWarningProvider);
    final location = ref.watch(activeLocationProvider);
    final resolver = ref.watch(zoneOffsetResolverProvider);
    final now = ref.watch(settingsNowMinuteProvider);

    // Status of the last network check.
    final String status;
    final bool statusIsError;
    final offset = correction.offset;
    if (correction.checking) {
      status = l10n.settingsTimeChecking;
      statusIsError = false;
    } else if (correction.error != null) {
      status = l10n.settingsTimeError;
      statusIsError = true;
    } else if (offset != null) {
      final amount = fmt.formatDuration(offset.abs());
      final skew = offset.abs() < const Duration(seconds: 1)
          ? l10n.settingsTimeSkewZero
          : (offset.isNegative
                ? l10n.settingsTimeSkewAhead(amount)
                : l10n.settingsTimeSkewBehind(amount));
      final at = correction.checkedAt;
      final time = at == null
          ? null
          : fmt.formatInstant(
              at,
              resolver.currentOffset(
                rule: location.offset,
                zoneId: location.zoneId,
                instant: at,
              ),
            );
      status = time == null
          ? skew
          : '$skew ${l10n.settingsTimeCheckedAt(time)}';
      statusIsError = false;
    } else {
      status = l10n.settingsTimeNever;
      statusIsError = false;
    }

    // Clock diagnostics.
    final String diagnosis;
    final IconData diagnosisIcon;
    final Color? diagnosisColor;
    switch (warning) {
      case ClockSkewWarning(:final skew):
        diagnosis = l10n.homeBannerClockSkew(fmt.formatDuration(skew.abs()));
        diagnosisIcon = Icons.warning_amber_outlined;
        diagnosisColor = colors.warning;
      case StaleZoneRulesWarning():
        diagnosis = l10n.homeBannerStaleZone;
        diagnosisIcon = Icons.warning_amber_outlined;
        diagnosisColor = colors.warning;
      case null:
        diagnosis = l10n.settingsTimeDiagOk;
        diagnosisIcon = Icons.check_circle_outline;
        diagnosisColor = colors.success;
    }
    final windowsOffset = ref.watch(systemZoneProvider).localOffsetAt(now);
    final databaseOffset = resolver.offsetFor(
      rule: location.offset,
      zoneId: location.zoneId,
      date: CivilDate.fromDateTime(now),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          children: [
            SwitchRow(
              key: const Key('set-time-enabled'),
              title: l10n.settingsTimeCheck,
              description: l10n.settingsTimeCheckHelp,
              value: network.enabled,
              onChanged: (value) =>
                  controller.setNetworkTime(network.copyWith(enabled: value)),
            ),
            SwitchRow(
              key: const Key('set-time-correct'),
              title: l10n.settingsTimeCorrect,
              description: l10n.settingsTimeCorrectHelp,
              value: network.applyCorrection,
              onChanged: network.enabled
                  ? (value) => controller.setNetworkTime(
                      network.copyWith(applyCorrection: value),
                    )
                  : null,
            ),
            SettingRow(
              title: l10n.settingsTimeServer,
              description: l10n.settingsTimeServerHelp,
              controlWidth: 260,
              control: CommitField(
                key: const Key('set-time-server'),
                value: network.host,
                semanticsLabel: l10n.settingsTimeServer,
                keyboardType: TextInputType.url,
                onCommit: (text) {
                  final host = text.trim();
                  if (!isValidHost(host)) return l10n.settingsTimeServerInvalid;
                  controller.setNetworkTime(network.copyWith(host: host));
                  return null;
                },
              ),
            ),
          ],
        ),
        SettingsGroup(
          title: l10n.settingsTimeStatusTitle,
          children: [
            StatusLine(
              key: const Key('set-time-status'),
              text: status,
              icon: statusIsError
                  ? Icons.error_outline
                  : Icons.access_time_outlined,
              color: statusIsError ? colors.danger : null,
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton.icon(
                key: const Key('set-time-check-now'),
                icon: const Icon(Icons.sync),
                label: Text(l10n.settingsTimeCheckNow),
                onPressed: network.enabled && !correction.checking
                    ? () => ref.read(clockCorrectionProvider.notifier).check()
                    : null,
              ),
            ),
          ],
        ),
        SettingsGroup(
          title: l10n.settingsTimeDiagTitle,
          children: [
            StatusLine(
              key: const Key('set-time-diagnosis'),
              text: diagnosis,
              icon: diagnosisIcon,
              color: diagnosisColor,
            ),
            Text(
              l10n.settingsTimeDiagWindows(formatUtcOffset(fmt, windowsOffset)),
              key: const Key('set-time-windows-offset'),
            ),
            Text(
              l10n.settingsTimeDiagLocation(
                formatUtcOffset(fmt, databaseOffset),
              ),
              key: const Key('set-time-database-offset'),
            ),
          ],
        ),
      ],
    );
  }
}
