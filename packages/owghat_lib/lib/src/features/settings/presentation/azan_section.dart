import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/azan/application/mute_providers.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_labels.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/application/settings_actions.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
import 'package:owghat_lib/src/features/settings/presentation/setting_widgets.dart';
import 'package:prayer_core/prayer_core.dart';

/// Section 3: master switch and volume, fade-in, quick mute and one card per
/// prayer with its own switch, sound, volume and preview.
class AzanSection extends ConsumerWidget {
  /// Creates the section.
  const AzanSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final azan = ref.watch(settingsProvider.select((s) => s.azan));
    final controller = ref.read(settingsProvider.notifier);
    final fmt = ref.watch(formatterProvider);
    final muted = ref.watch(muteActiveProvider);
    final location = ref.watch(activeLocationProvider);
    final resolver = ref.watch(zoneOffsetResolverProvider);
    final mute = ref.read(muteActionsProvider);

    String muteState() {
      if (!muted) return l10n.settingsAzanNotMuted;
      final until = azan.mute.until;
      if (azan.mute.indefinite || until == null) {
        return l10n.homeAzanMutedIndefinite;
      }
      final offset = resolver.currentOffset(
        rule: location.offset,
        zoneId: location.zoneId,
        instant: until,
      );
      return l10n.homeAzanMutedUntil(fmt.formatInstant(until, offset));
    }

    final osNotices = ref
        .watch(platformCapabilitiesProvider)
        .osScheduledNotices;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (osNotices)
          Padding(
            padding: const EdgeInsets.only(bottom: Gaps.m),
            child: InfoNote(
              l10n.settingsAzanPhoneNote,
              key: const Key('set-azan-phone-note'),
            ),
          ),
        SettingsGroup(
          children: [
            SwitchRow(
              key: const Key('set-azan-master'),
              title: l10n.settingsAzanEnabled,
              description: l10n.settingsAzanEnabledHelp,
              value: azan.enabled,
              onChanged: (value) => controller.setAzanEnabled(enabled: value),
            ),
            SettingRow(
              title: l10n.settingsAzanVolume,
              description: l10n.settingsAzanVolumeHelp,
              controlWidth: 280,
              control: PercentSlider(
                key: const Key('set-azan-volume'),
                value: azan.masterVolume,
                label: l10n.settingsPercent(
                  fmt.formatNumber((azan.masterVolume * 100).round()),
                ),
                semanticsLabel: l10n.settingsAzanVolume,
                onChanged: controller.setMasterVolume,
              ),
            ),
            SwitchRow(
              key: const Key('set-azan-fade'),
              title: l10n.settingsAzanFade,
              description: l10n.settingsAzanFadeHelp,
              value: azan.fadeIn,
              onChanged: (value) => controller.setFadeIn(enabled: value),
            ),
            SettingRow(
              title: l10n.settingsAzanMute,
              description: '${l10n.settingsAzanMuteHelp} ${muteState()}',
              control: PopupMenuButton<VoidCallback>(
                key: const Key('set-azan-mute'),
                tooltip: l10n.settingsAzanMute,
                onSelected: (action) => action(),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: mute.untilNextAzan,
                    child: Text(l10n.homeMuteUntilNext),
                  ),
                  PopupMenuItem(
                    value: () => mute.forDuration(const Duration(hours: 1)),
                    child: Text(
                      l10n.homeMuteForDuration(
                        fmt.formatDuration(const Duration(hours: 1)),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: () => mute.forDuration(const Duration(hours: 24)),
                    child: Text(
                      l10n.homeMuteForDuration(
                        fmt.formatDuration(const Duration(hours: 24)),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: mute.indefinitely,
                    child: Text(l10n.homeMuteIndefinite),
                  ),
                  PopupMenuItem(
                    value: mute.cancel,
                    enabled: muted,
                    child: Text(l10n.homeMuteCancel),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(Gaps.s),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(muted ? Icons.volume_off : Icons.volume_up),
                      const SizedBox(width: Gaps.s),
                      Text(l10n.homeMute),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        for (final prayer in AzanSettings.azanPrayers)
          _PrayerAzanCard(prayer: prayer),
      ],
    );
  }
}

class _PrayerAzanCard extends ConsumerStatefulWidget {
  const _PrayerAzanCard({required this.prayer});

  final Prayer prayer;

  @override
  ConsumerState<_PrayerAzanCard> createState() => _PrayerAzanCardState();
}

enum _PreviewNote { none, fallback, failed }

class _PrayerAzanCardState extends ConsumerState<_PrayerAzanCard> {
  _PreviewNote _note = _PreviewNote.none;

  Prayer get prayer => widget.prayer;

  /// The last path segment, for either kind of separator.
  static String _fileName(String path) => path.split(RegExp(r'[\\/]')).last;

  Future<void> _preview() async {
    setState(() => _note = _PreviewNote.none);
    final result = await ref.read(settingsActionsProvider).previewAzan(prayer);
    if (!mounted) return;
    setState(() {
      _note = switch (result) {
        AzanPlayResult.played => _PreviewNote.none,
        AzanPlayResult.playedFallback => _PreviewNote.fallback,
        AzanPlayResult.failed => _PreviewNote.failed,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final fmt = ref.watch(formatterProvider);
    final entry = ref.watch(
      settingsProvider.select(
        (s) => s.azan.perPrayer[prayer] ?? const PrayerAzan(),
      ),
    );
    final controller = ref.read(settingsProvider.notifier);
    final actions = ref.read(settingsActionsProvider);
    final playing = ref.watch(azanPlaybackProvider.select((s) => s.playing));
    final name = prayer.label(l10n);
    final title = l10n.settingsAzanPrayerSwitch(name);
    final isFile = entry.sound.kind == SoundKind.file;

    return SettingsGroup(
      key: Key('set-azan-card-${prayer.name}'),
      title: name,
      children: [
        SwitchRow(
          key: Key('set-azan-enabled-${prayer.name}'),
          title: title,
          value: entry.enabled,
          onChanged: (value) =>
              controller.setPrayerAzan(prayer, entry.copyWith(enabled: value)),
        ),
        SettingRow(
          title: l10n.settingsAzanSound,
          description: isFile
              ? l10n.settingsAzanSoundFile(
                  Formatter.isolate(_fileName(entry.sound.value)),
                )
              : l10n.settingsAzanSoundDefault,
          stacked: true,
          control: Wrap(
            spacing: Gaps.s,
            runSpacing: Gaps.s,
            children: [
              if (ref.watch(platformCapabilitiesProvider).fileAccess)
                OutlinedButton.icon(
                  key: Key('set-azan-pick-${prayer.name}'),
                  icon: const Icon(Icons.folder_open_outlined),
                  label: Text(l10n.settingsAzanChoose),
                  onPressed: () => actions.pickSound(prayer),
                ),
              if (isFile)
                TextButton(
                  key: Key('set-azan-default-${prayer.name}'),
                  onPressed: () => actions.useDefaultSound(prayer),
                  child: Text(l10n.settingsAzanUseDefault),
                ),
            ],
          ),
        ),
        SettingRow(
          title: l10n.settingsAzanPrayerVolume,
          controlWidth: 280,
          control: PercentSlider(
            key: Key('set-azan-prayer-volume-${prayer.name}'),
            value: entry.volume,
            label: l10n.settingsPercent(
              fmt.formatNumber((entry.volume * 100).round()),
            ),
            semanticsLabel: l10n.settingsAzanPrayerVolume,
            onChanged: (value) =>
                controller.setPrayerAzan(prayer, entry.copyWith(volume: value)),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: Gaps.s,
              runSpacing: Gaps.s,
              children: [
                FilledButton.tonalIcon(
                  key: Key('set-azan-preview-${prayer.name}'),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.settingsAzanPreview),
                  onPressed: _preview,
                ),
                OutlinedButton.icon(
                  key: Key('set-azan-stop-${prayer.name}'),
                  icon: const Icon(Icons.stop),
                  label: Text(l10n.homeStop),
                  onPressed: playing ? actions.stopPreview : null,
                ),
              ],
            ),
            if (_note != _PreviewNote.none)
              Padding(
                padding: const EdgeInsets.only(top: Gaps.s),
                child: StatusLine(
                  key: Key('set-azan-note-${prayer.name}'),
                  text: _note == _PreviewNote.fallback
                      ? l10n.notifSoundFallback
                      : l10n.notifAzanFailed,
                  icon: Icons.error_outline,
                  color: _note == _PreviewNote.failed
                      ? colors.danger
                      : colors.warning,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
