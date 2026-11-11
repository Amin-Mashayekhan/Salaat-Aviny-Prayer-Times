import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/calendar/application/calendar_names.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_labels.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_alarm_controller.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_labels.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_alarm.dart';
import 'package:prayer_core/prayer_core.dart';

/// Opens the alarm editor: a new alarm when [alarm] is null, else that one.
/// Saving goes through `WakeAlarmController.addAlarm` / `updateAlarm`.
Future<void> showAlarmEditor(BuildContext context, {WakeAlarm? alarm}) {
  return showDialog<void>(
    context: context,
    // The preview sound must stop whichever way the dialog closes, so it can
    // only be closed through its own buttons.
    barrierDismissible: false,
    builder: (context) => AlarmEditorDialog(initial: alarm),
  );
}

/// The add / edit dialog of a wake-up alarm: trigger (fixed time or minutes
/// before a prayer), repeat, sound with volume and preview, and what to do
/// after the sound.
class AlarmEditorDialog extends ConsumerStatefulWidget {
  /// Creates the dialog; [initial] is null for a new alarm.
  const AlarmEditorDialog({this.initial, super.key});

  /// The alarm being edited.
  final WakeAlarm? initial;

  @override
  ConsumerState<AlarmEditorDialog> createState() => _AlarmEditorDialogState();
}

class _AlarmEditorDialogState extends ConsumerState<AlarmEditorDialog> {
  late final TextEditingController _label;
  late final TextEditingController _minutesBefore;
  late AlarmTriggerKind _trigger;
  late int _hour;
  late int _minute;
  late Prayer _prayer;
  late AlarmRepeat _repeat;
  late Set<int> _weekdays;
  late bool _playSound;
  late SoundRef _sound;
  late double _volume;
  late AfterSound _after;
  bool _saveFailed = false;

  @override
  void initState() {
    super.initState();
    final a = widget.initial ?? const WakeAlarm(id: 'new');
    _label = TextEditingController(text: a.label);
    _minutesBefore = TextEditingController(text: '${a.minutesBefore}');
    _trigger = a.trigger;
    _hour = a.hour;
    _minute = a.minute;
    _prayer = a.prayer;
    _repeat = a.repeat;
    _weekdays = {...a.weekdays};
    _playSound = a.playSound;
    _sound = a.sound;
    _volume = a.volume;
    _after = a.afterSound;
  }

  @override
  void dispose() {
    _label.dispose();
    _minutesBefore.dispose();
    super.dispose();
  }

  /// The typed minutes, or null when they are not a whole number in range.
  int? get _minutesValue {
    final value = int.tryParse(_normalized(_minutesBefore.text));
    if (value == null || value < 0 || value > 720) return null;
    return value;
  }

  static String _normalized(String text) {
    final out = StringBuffer();
    for (final rune in text.trim().runes) {
      if (rune >= 0x06f0 && rune <= 0x06f9) {
        out.writeCharCode(0x30 + rune - 0x06f0);
      } else if (rune >= 0x0660 && rune <= 0x0669) {
        out.writeCharCode(0x30 + rune - 0x0660);
      } else {
        out.writeCharCode(rune);
      }
    }
    return out.toString();
  }

  bool get _valid =>
      (_trigger == AlarmTriggerKind.fixedTime || _minutesValue != null) &&
      (_repeat != AlarmRepeat.weekdays || _weekdays.isNotEmpty);

  Future<void> _stopPreview() async {
    if (ref.read(azanPlaybackProvider).playing) {
      await ref.read(azanPlaybackProvider.notifier).stop();
    }
  }

  Future<void> _close() async {
    await _stopPreview();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _save() async {
    if (!_valid) {
      setState(() {});
      return;
    }
    final controller = ref.read(wakeAlarmControllerProvider.notifier);
    final base = widget.initial ?? WakeAlarm(id: controller.newAlarmId());
    final alarm = base.copyWith(
      label: _label.text.trim(),
      trigger: _trigger,
      hour: _hour,
      minute: _minute,
      prayer: _prayer,
      minutesBefore: _minutesValue ?? base.minutesBefore,
      repeat: _repeat,
      weekdays: _weekdays,
      playSound: _playSound,
      sound: _sound,
      volume: _volume,
      afterSound: _after,
    );
    final failure = widget.initial == null
        ? controller.addAlarm(alarm)
        : controller.updateAlarm(alarm);
    if (failure != null) {
      setState(() => _saveFailed = true);
      return;
    }
    await _close();
  }

  Future<void> _pickFile() async {
    final path = await ref.read(fileDialogsProvider).pickSoundFile();
    if (path != null && mounted) setState(() => _sound = SoundRef.file(path));
  }

  Future<void> _togglePreview() async {
    final playing = ref.read(azanPlaybackProvider).playing;
    final playback = ref.read(azanPlaybackProvider.notifier);
    if (playing) {
      await playback.stop();
    } else {
      await playback.preview(_sound, volume: _volume);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = ref.watch(formatterProvider);
    final names = ref.watch(calendarNamesProvider);
    final previewing = ref.watch(azanPlaybackProvider.select((s) => s.playing));
    final scaler = MediaQuery.textScalerOf(context);

    Widget section(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.only(top: Gaps.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: Gaps.s),
          ...children,
        ],
      ),
    );

    Widget choices<T>({
      required List<(T, String, Key)> items,
      required T selected,
      required ValueChanged<T> onSelected,
    }) => Wrap(
      spacing: Gaps.s,
      runSpacing: Gaps.s,
      children: [
        for (final (value, label, key) in items)
          ChoiceChip(
            key: key,
            label: Text(label),
            selected: value == selected,
            onSelected: (_) => setState(() => onSelected(value)),
          ),
      ],
    );

    final minutesError =
        _trigger == AlarmTriggerKind.relativeToPrayer && _minutesValue == null
        ? l10n.wakeErrorMinutes(fmt.formatNumber(0), fmt.formatNumber(720))
        : null;
    final soundName = _sound.kind == SoundKind.file
        ? l10n.wakeSoundFile(_sound.value.split(RegExp(r'[\\/]')).last)
        : l10n.wakeSoundDefault;

    return AlertDialog(
      title: Text(
        widget.initial == null
            ? l10n.wakeEditorTitleAdd
            : l10n.wakeEditorTitleEdit,
      ),
      scrollable: true,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SizedBox(
          width: 480,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('wake-ed-label'),
                controller: _label,
                decoration: InputDecoration(labelText: l10n.wakeFieldLabel),
              ),
              section(l10n.wakeTriggerTypeTitle, [
                choices<AlarmTriggerKind>(
                  items: [
                    (
                      AlarmTriggerKind.fixedTime,
                      l10n.wakeChoiceFixed,
                      const Key('wake-ed-trigger-fixed'),
                    ),
                    (
                      AlarmTriggerKind.relativeToPrayer,
                      l10n.wakeChoiceRelative,
                      const Key('wake-ed-trigger-relative'),
                    ),
                  ],
                  selected: _trigger,
                  onSelected: (v) => _trigger = v,
                ),
                const SizedBox(height: Gaps.m),
                if (_trigger == AlarmTriggerKind.fixedTime)
                  Wrap(
                    spacing: Gaps.m,
                    runSpacing: Gaps.m,
                    children: [
                      SizedBox(
                        width: scaler.scale(120),
                        child: DropdownButtonFormField<int>(
                          key: const Key('wake-ed-hour'),
                          initialValue: _hour,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: l10n.wakeFieldHour,
                          ),
                          items: [
                            for (var h = 0; h < 24; h++)
                              DropdownMenuItem(
                                value: h,
                                child: Text(fmt.formatPadded(h)),
                              ),
                          ],
                          onChanged: (v) => setState(() => _hour = v ?? _hour),
                        ),
                      ),
                      SizedBox(
                        width: scaler.scale(120),
                        child: DropdownButtonFormField<int>(
                          key: const Key('wake-ed-minute'),
                          initialValue: _minute,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: l10n.wakeFieldMinute,
                          ),
                          items: [
                            for (var m = 0; m < 60; m++)
                              DropdownMenuItem(
                                value: m,
                                child: Text(fmt.formatPadded(m)),
                              ),
                          ],
                          onChanged: (v) =>
                              setState(() => _minute = v ?? _minute),
                        ),
                      ),
                    ],
                  )
                else
                  Wrap(
                    spacing: Gaps.m,
                    runSpacing: Gaps.m,
                    children: [
                      SizedBox(
                        width: scaler.scale(180),
                        child: DropdownButtonFormField<Prayer>(
                          key: const Key('wake-ed-prayer'),
                          initialValue: _prayer,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: l10n.wakeFieldPrayer,
                          ),
                          items: [
                            for (final p in Prayer.values)
                              DropdownMenuItem(
                                value: p,
                                child: Text(
                                  p.label(l10n),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (v) =>
                              setState(() => _prayer = v ?? _prayer),
                        ),
                      ),
                      SizedBox(
                        width: scaler.scale(150),
                        child: TextField(
                          key: const Key('wake-ed-minutes'),
                          controller: _minutesBefore,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp('[0-9۰-۹٠-٩]'),
                            ),
                            LengthLimitingTextInputFormatter(3),
                          ],
                          decoration: InputDecoration(
                            labelText: l10n.wakeFieldMinutesBefore,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                if (minutesError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: Gaps.s),
                    child: Text(
                      minutesError,
                      key: const Key('wake-ed-minutes-error'),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
              ]),
              section(l10n.wakeRepeatTitle, [
                choices<AlarmRepeat>(
                  items: [
                    (
                      AlarmRepeat.once,
                      l10n.wakeRepeatOnce,
                      const Key('wake-ed-repeat-once'),
                    ),
                    (
                      AlarmRepeat.daily,
                      l10n.wakeRepeatDaily,
                      const Key('wake-ed-repeat-daily'),
                    ),
                    (
                      AlarmRepeat.weekdays,
                      l10n.wakeRepeatWeekdaysChoice,
                      const Key('wake-ed-repeat-weekdays'),
                    ),
                  ],
                  selected: _repeat,
                  onSelected: (v) => _repeat = v,
                ),
                if (_repeat == AlarmRepeat.weekdays) ...[
                  const SizedBox(height: Gaps.s),
                  Wrap(
                    spacing: Gaps.s,
                    runSpacing: Gaps.s,
                    children: [
                      for (final iso in persianWeekOrder)
                        FilterChip(
                          key: Key('wake-ed-day-$iso'),
                          label: Text(names.weekday(iso)),
                          selected: _weekdays.contains(iso),
                          onSelected: (on) => setState(() {
                            if (on) {
                              _weekdays.add(iso);
                            } else {
                              _weekdays.remove(iso);
                            }
                          }),
                        ),
                    ],
                  ),
                  if (_weekdays.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: Gaps.s),
                      child: Text(
                        l10n.wakeWeekdaysError,
                        key: const Key('wake-ed-days-error'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ]),
              section(l10n.wakeSoundTitle, [
                SwitchListTile(
                  key: const Key('wake-ed-sound-switch'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.wakePlaySound),
                  value: _playSound,
                  onChanged: (v) => setState(() => _playSound = v),
                ),
                if (_playSound) ...[
                  Text(
                    soundName,
                    key: const Key('wake-ed-sound-name'),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: Gaps.s),
                  Wrap(
                    spacing: Gaps.s,
                    runSpacing: Gaps.s,
                    children: [
                      OutlinedButton.icon(
                        key: const Key('wake-ed-pick'),
                        icon: const Icon(Icons.folder_open),
                        label: Text(l10n.wakeChooseFile),
                        onPressed: _pickFile,
                      ),
                      if (_sound != SoundRef.defaultAzan)
                        OutlinedButton(
                          key: const Key('wake-ed-default'),
                          onPressed: () =>
                              setState(() => _sound = SoundRef.defaultAzan),
                          child: Text(l10n.wakeUseDefault),
                        ),
                      FilledButton.tonalIcon(
                        key: const Key('wake-ed-preview'),
                        icon: Icon(previewing ? Icons.stop : Icons.play_arrow),
                        label: Text(
                          previewing ? l10n.wakePreviewStop : l10n.wakePreview,
                        ),
                        onPressed: _togglePreview,
                      ),
                    ],
                  ),
                  const SizedBox(height: Gaps.s),
                  Row(
                    children: [
                      Text(l10n.wakeVolume),
                      Expanded(
                        child: Slider(
                          key: const Key('wake-ed-volume'),
                          value: _volume,
                          semanticFormatterCallback: (v) => l10n.wakePercent(
                            fmt.formatNumber((v * 100).round()),
                          ),
                          onChanged: (v) => setState(() => _volume = v),
                        ),
                      ),
                      Text(
                        l10n.wakePercent(
                          fmt.formatNumber((_volume * 100).round()),
                        ),
                        key: const Key('wake-ed-volume-text'),
                      ),
                    ],
                  ),
                ],
              ]),
              section(l10n.wakeAfterTitle, [
                choices<AfterSound>(
                  items: [
                    (
                      AfterSound.nothing,
                      l10n.wakeAfterNothing,
                      const Key('wake-ed-after-nothing'),
                    ),
                    (
                      AfterSound.sleep,
                      l10n.wakeAfterSleepChoice,
                      const Key('wake-ed-after-sleep'),
                    ),
                    (
                      AfterSound.hibernate,
                      l10n.wakeAfterHibernateChoice,
                      const Key('wake-ed-after-hibernate'),
                    ),
                  ],
                  selected: _after,
                  onSelected: (v) => _after = v,
                ),
                if (_after != AfterSound.nothing)
                  Padding(
                    padding: const EdgeInsets.only(top: Gaps.s),
                    child: Text(
                      l10n.wakeAfterNote,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ]),
              if (_saveFailed)
                Padding(
                  padding: const EdgeInsets.only(top: Gaps.m),
                  child: Text(
                    l10n.wakeSaveFailed,
                    key: const Key('wake-ed-save-failed'),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('wake-ed-cancel'),
          onPressed: () => unawaited(_close()),
          child: Text(l10n.wakeCancel),
        ),
        FilledButton(
          key: const Key('wake-ed-save'),
          onPressed: _valid ? () => unawaited(_save()) : null,
          child: Text(l10n.wakeSave),
        ),
      ],
    );
  }
}
