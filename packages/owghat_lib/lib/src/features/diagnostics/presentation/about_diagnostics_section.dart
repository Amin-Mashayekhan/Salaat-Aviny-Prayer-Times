import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/core/time/clock_warning.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/clock/application/clock_warning_provider.dart';
import 'package:owghat_lib/src/features/clock/application/local_offset_provider.dart';
import 'package:owghat_lib/src/features/diagnostics/application/app_version.dart';
import 'package:owghat_lib/src/features/diagnostics/application/diagnostics_providers.dart';
import 'package:owghat_lib/src/features/diagnostics/application/diagnostics_report.dart';
import 'package:owghat_lib/src/features/diagnostics/presentation/about_project_cards.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_labels.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_alarm_controller.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_labels.dart';
import 'package:prayer_core/prayer_core.dart';

/// "About and diagnostics" (the last settings section): the version, the
/// licences, and a diagnostics block with the next scheduled events (UTC and
/// local), the clock status, an audio test, the wake-up capability and a
/// button that copies a report without personal data.
///
/// The Settings screen shows it through `aboutSectionBuilderProvider`. It
/// works inside a scrolling parent (it then just sizes to its content) and
/// scrolls by itself when given a bounded height.
class AboutDiagnosticsSection extends ConsumerStatefulWidget {
  /// Creates the section.
  const AboutDiagnosticsSection({super.key});

  @override
  ConsumerState<AboutDiagnosticsSection> createState() =>
      _AboutDiagnosticsSectionState();
}

class _AboutDiagnosticsSectionState
    extends ConsumerState<AboutDiagnosticsSection> {
  AzanPlayResult? _audioResult;
  bool? _copied;

  Future<void> _toggleAudio() async {
    final playback = ref.read(azanPlaybackProvider.notifier);
    if (ref.read(azanPlaybackProvider).playing) {
      await playback.stop();
      return;
    }
    setState(() => _audioResult = null);
    final result = await playback.preview(SoundRef.chime);
    if (mounted) setState(() => _audioResult = result);
  }

  Future<void> _copy() async {
    final report = ref.read(diagnosticsReportProvider);
    try {
      await Clipboard.setData(ClipboardData(text: report));
      if (mounted) setState(() => _copied = true);
      // The clipboard channel may be missing in a preview.
    } on Object {
      if (mounted) setState(() => _copied = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _AboutCard(),
        const SizedBox(height: Gaps.l),
        const AuthorCard(),
        const SizedBox(height: Gaps.l),
        const ContributeCard(),
        const SizedBox(height: Gaps.l),
        const SupportCard(),
        const SizedBox(height: Gaps.l),
        Card(
          key: const Key('diag-card'),
          child: Padding(
            padding: const EdgeInsets.all(Gaps.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Heading(AppLocalizations.of(context).diagTitle),
                const SizedBox(height: Gaps.m),
                const _EventsBlock(),
                const Divider(height: Gaps.xl),
                const _ClockBlock(),
                const Divider(height: Gaps.xl),
                _AudioBlock(result: _audioResult, onPressed: _toggleAudio),
                const Divider(height: Gaps.xl),
                const _WakeBlock(),
                const Divider(height: Gaps.xl),
                const _LogBlock(),
                const Divider(height: Gaps.xl),
                _CopyBlock(copied: _copied, onPressed: _copy),
              ],
            ),
          ),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) => constraints.hasBoundedHeight
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(Gaps.l),
              child: content,
            )
          : content,
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
  );
}

class _AboutCard extends ConsumerWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final version = ref.watch(appVersionProvider);
    return Card(
      key: const Key('about-card'),
      child: Padding(
        padding: const EdgeInsets.all(Gaps.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Heading(l10n.aboutTitle),
            const SizedBox(height: Gaps.s),
            Text(l10n.appName, style: theme.textTheme.headlineMedium),
            Text(
              l10n.aboutVersion(Formatter.isolate(version)),
              key: const Key('about-version'),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: Gaps.s),
            Text(l10n.aboutTagline, style: theme.textTheme.bodyMedium),
            const SizedBox(height: Gaps.m),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton.icon(
                key: const Key('about-licences'),
                icon: const Icon(Icons.description_outlined),
                label: Text(l10n.aboutLicences),
                onPressed: () => showLicensePage(
                  context: context,
                  applicationName: l10n.appName,
                  applicationVersion: version,
                ),
              ),
            ),
            const SizedBox(height: Gaps.m),
            Text(
              l10n.aboutFontNote,
              key: const Key('about-font-note'),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Gaps.s),
            Text(
              l10n.aboutSoundNote,
              key: const Key('about-sound-note'),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventsBlock extends ConsumerWidget {
  const _EventsBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = ref.watch(formatterProvider);
    final offsetAt = ref.watch(localOffsetAtProvider);
    final events = ref.watch(diagnosticEventsProvider).value;

    String name(ScheduledEvent event) => switch (event.kind) {
      EventKind.azan => l10n.diagEventAzan(event.prayer!.label(l10n)),
      EventKind.reminder => l10n.diagEventReminder(event.prayer!.label(l10n)),
      EventKind.wakeAlarm => l10n.diagEventWake,
      EventKind.dayRollover => '',
    };

    String times(ScheduledEvent event) {
      final offset = offsetAt(event.instantUtc);
      final local = event.instantUtc.add(offset);
      // Date and time stay left-to-right inside right-to-left text.
      return l10n.diagEventTimes(
        Formatter.isolate(
          fmt.digits('${formatTimestamp(event.instantUtc)} UTC'),
        ),
        Formatter.isolate(
          fmt.digits('${formatTimestamp(local)} (${formatUtcOffset(offset)})'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(l10n.diagEventsTitle),
        const SizedBox(height: Gaps.s),
        if (events == null || events.isEmpty)
          Text(
            l10n.diagEventsEmpty,
            key: const Key('diag-events-empty'),
            style: theme.textTheme.bodyMedium,
          )
        else
          for (var i = 0; i < events.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: Gaps.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${fmt.formatNumber(i + 1)}. ${name(events[i])}',
                    key: Key('diag-event-$i'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    times(events[i]),
                    key: Key('diag-event-times-$i'),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

class _ClockBlock extends ConsumerWidget {
  const _ClockBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final fmt = ref.watch(formatterProvider);
    final warning = ref.watch(clockWarningProvider);
    final networkOn = ref.watch(
      settingsProvider.select((s) => s.networkTime.enabled),
    );

    final String text;
    var ok = false;
    switch (warning) {
      case ClockSkewWarning(:final skew):
        text = l10n.homeBannerClockSkew(fmt.formatDuration(skew.abs()));
      case StaleZoneRulesWarning():
        text = l10n.homeBannerStaleZone;
      case null:
        ok = networkOn;
        text = networkOn ? l10n.diagClockOk : l10n.diagClockUnchecked;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(l10n.diagClockTitle),
        const SizedBox(height: Gaps.s),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              warning != null
                  ? Icons.warning_amber_rounded
                  : ok
                  ? Icons.check_circle_outline
                  : Icons.info_outline,
              size: 20,
              color: warning != null
                  ? colors.warning
                  : ok
                  ? colors.success
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: Gaps.s),
            Expanded(
              child: Text(
                text,
                key: const Key('diag-clock'),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AudioBlock extends ConsumerWidget {
  const _AudioBlock({required this.result, required this.onPressed});

  final AzanPlayResult? result;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final playing = ref.watch(azanPlaybackProvider.select((s) => s.playing));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(l10n.diagAudioTitle),
        const SizedBox(height: Gaps.s),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton.tonalIcon(
            key: const Key('diag-audio'),
            icon: Icon(playing ? Icons.stop : Icons.volume_up_outlined),
            label: Text(playing ? l10n.diagAudioStop : l10n.diagAudioPlay),
            onPressed: onPressed,
          ),
        ),
        if (result != null)
          Padding(
            padding: const EdgeInsets.only(top: Gaps.s),
            child: Text(
              result == AzanPlayResult.failed
                  ? l10n.diagAudioFailed
                  : l10n.diagAudioOk,
              key: const Key('diag-audio-result'),
              style: theme.textTheme.labelLarge?.copyWith(
                color: result == AzanPlayResult.failed
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

class _WakeBlock extends ConsumerWidget {
  const _WakeBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final capability = ref.watch(wakeCapabilityProvider);
    final probing = ref.watch(
      wakeAlarmControllerProvider.select((s) => s.probing),
    );

    String tri({required bool? value}) => l10n.diagValue(
      value == null
          ? 'unknown'
          : value
          ? 'yes'
          : 'no',
    );
    String works({required bool? value}) => l10n.diagValue(
      value == null
          ? 'unknown'
          : value
          ? 'ok'
          : 'failed',
    );

    Widget line(String text, Key key) => Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(text, key: key, style: theme.textTheme.bodyMedium),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(l10n.diagWakeTitle),
        const SizedBox(height: Gaps.s),
        if (capability == null)
          line(l10n.diagWakeNotChecked, const Key('diag-wake-none'))
        else ...[
          line(
            l10n.diagWakeTask(works(value: capability.taskCreationOk)),
            const Key('diag-wake-task'),
          ),
          line(
            l10n.diagWakeAc(l10n.diagValue(capability.wakeTimersOnAc.name)),
            const Key('diag-wake-ac'),
          ),
          line(
            l10n.diagWakeBattery(
              l10n.diagValue(capability.wakeTimersOnBattery.name),
            ),
            const Key('diag-wake-battery'),
          ),
          line(
            l10n.diagWakeInProcess(works(value: capability.inProcessTimerOk)),
            const Key('diag-wake-inprocess'),
          ),
          line(
            l10n.diagWakeModern(tri(value: capability.modernStandby)),
            const Key('diag-wake-modern'),
          ),
          for (final issue in capability.issues)
            Padding(
              padding: const EdgeInsets.only(top: Gaps.s),
              child: Text(
                issue.text(l10n),
                key: Key('diag-wake-issue-${issue.name}'),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
        const SizedBox(height: Gaps.s),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton.tonalIcon(
            key: const Key('diag-wake-check'),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.diagWakeCheck),
            onPressed: probing
                ? null
                : () => unawaited(
                    ref.read(wakeAlarmControllerProvider.notifier).probe(),
                  ),
          ),
        ),
      ],
    );
  }
}

class _LogBlock extends ConsumerWidget {
  const _LogBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final path = ref.watch(logDirectoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(l10n.diagLogTitle),
        const SizedBox(height: Gaps.s),
        // A path is always left to right.
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: path == null
                ? Text(
                    l10n.diagLogNone,
                    key: const Key('diag-log'),
                    style: theme.textTheme.bodyMedium,
                  )
                : SelectableText(
                    path,
                    key: const Key('diag-log'),
                    style: theme.textTheme.bodyMedium,
                  ),
          ),
        ),
      ],
    );
  }
}

class _CopyBlock extends StatelessWidget {
  const _CopyBlock({required this.copied, required this.onPressed});

  final bool? copied;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton.icon(
            key: const Key('diag-copy'),
            icon: const Icon(Icons.copy_outlined),
            label: Text(l10n.diagCopy),
            onPressed: onPressed,
          ),
        ),
        if (copied != null)
          Padding(
            padding: const EdgeInsets.only(top: Gaps.s),
            child: Semantics(
              liveRegion: true,
              child: Text(
                copied! ? l10n.diagCopied : l10n.diagCopyFailed,
                key: const Key('diag-copy-result'),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: copied!
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.error,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
