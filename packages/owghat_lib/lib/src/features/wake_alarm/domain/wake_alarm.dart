import 'package:owghat_lib/src/core/utils/json_value.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
import 'package:prayer_core/prayer_core.dart';

/// How a wake-up alarm decides when to fire.
enum AlarmTriggerKind {
  /// At a fixed local clock time.
  fixedTime,

  /// A number of minutes before a prayer.
  relativeToPrayer,
}

/// When a wake-up alarm repeats.
enum AlarmRepeat {
  /// Once, then it disables itself.
  once,

  /// Every day.
  daily,

  /// On the chosen weekdays.
  weekdays,
}

/// What to do after the alarm sound has finished.
enum AfterSound {
  /// Nothing.
  nothing,

  /// Put the PC to sleep.
  sleep,

  /// Hibernate the PC.
  hibernate,
}

/// A wake-up alarm.
class WakeAlarm extends JsonValue {
  /// Creates an alarm.
  const WakeAlarm({
    required this.id,
    this.label = '',
    this.enabled = true,
    this.trigger = AlarmTriggerKind.fixedTime,
    this.hour = 4,
    this.minute = 0,
    this.prayer = Prayer.fajr,
    this.minutesBefore = 40,
    this.repeat = AlarmRepeat.daily,
    this.weekdays = const {},
    this.playSound = true,
    this.sound = SoundRef.defaultAzan,
    this.volume = 1,
    this.afterSound = AfterSound.nothing,
  });

  /// Reads the JSON form; returns null if the entry is unusable.
  static WakeAlarm? fromJson(Object? raw) {
    final map = Json.map(raw);
    final id = Json.string(map['id'], '');
    if (id.isEmpty) return null;
    final weekdays = <int>{
      for (final day in Json.list(map['weekdays']))
        if (day is int && day >= DateTime.monday && day <= DateTime.sunday) day,
    };
    return WakeAlarm(
      id: id,
      label: Json.string(map['label'], ''),
      enabled: Json.boolean(map['enabled'], fallback: true),
      trigger: Json.enumValue(
        AlarmTriggerKind.values,
        map['trigger'],
        AlarmTriggerKind.fixedTime,
      ),
      hour: Json.integer(map['hour'], 4).clamp(0, 23),
      minute: Json.integer(map['minute'], 0).clamp(0, 59),
      prayer: Json.enumValue(Prayer.values, map['prayer'], Prayer.fajr),
      minutesBefore: Json.integer(map['minutesBefore'], 40).clamp(0, 720),
      repeat: Json.enumValue(
        AlarmRepeat.values,
        map['repeat'],
        AlarmRepeat.daily,
      ),
      weekdays: weekdays,
      playSound: Json.boolean(map['playSound'], fallback: true),
      sound: SoundRef.parse(map['sound'] as String?),
      volume: Json.number(map['volume'], 1).clamp(0, 1),
      afterSound: Json.enumValue(
        AfterSound.values,
        map['afterSound'],
        AfterSound.nothing,
      ),
    );
  }

  /// Unique id.
  final String id;

  /// Optional user label.
  final String label;

  /// Whether the alarm is active.
  final bool enabled;

  /// Fixed time or relative to a prayer.
  final AlarmTriggerKind trigger;

  /// Hour (0-23) for [AlarmTriggerKind.fixedTime].
  final int hour;

  /// Minute (0-59) for [AlarmTriggerKind.fixedTime].
  final int minute;

  /// Prayer for [AlarmTriggerKind.relativeToPrayer].
  final Prayer prayer;

  /// Minutes before [prayer] for [AlarmTriggerKind.relativeToPrayer].
  final int minutesBefore;

  /// Repeat rule.
  final AlarmRepeat repeat;

  /// ISO weekdays (Monday = 1) for [AlarmRepeat.weekdays].
  final Set<int> weekdays;

  /// Whether to play a sound when the alarm fires.
  final bool playSound;

  /// The sound to play.
  final SoundRef sound;

  /// Volume, 0 to 1.
  final double volume;

  /// What to do when the sound has ended.
  final AfterSound afterSound;

  /// Copy with changes.
  WakeAlarm copyWith({
    String? label,
    bool? enabled,
    AlarmTriggerKind? trigger,
    int? hour,
    int? minute,
    Prayer? prayer,
    int? minutesBefore,
    AlarmRepeat? repeat,
    Set<int>? weekdays,
    bool? playSound,
    SoundRef? sound,
    double? volume,
    AfterSound? afterSound,
  }) => WakeAlarm(
    id: id,
    label: label ?? this.label,
    enabled: enabled ?? this.enabled,
    trigger: trigger ?? this.trigger,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    prayer: prayer ?? this.prayer,
    minutesBefore: minutesBefore ?? this.minutesBefore,
    repeat: repeat ?? this.repeat,
    weekdays: weekdays ?? this.weekdays,
    playSound: playSound ?? this.playSound,
    sound: sound ?? this.sound,
    volume: volume ?? this.volume,
    afterSound: afterSound ?? this.afterSound,
  );

  @override
  Map<String, Object?> toJson() => {
    'id': id,
    'label': label,
    'enabled': enabled,
    'trigger': trigger.name,
    'hour': hour,
    'minute': minute,
    'prayer': prayer.name,
    'minutesBefore': minutesBefore,
    'repeat': repeat.name,
    'weekdays': (weekdays.toList()..sort()),
    'playSound': playSound,
    'sound': sound.encoded,
    'volume': volume,
    'afterSound': afterSound.name,
  };
}
