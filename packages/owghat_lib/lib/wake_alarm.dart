/// Public API of the wake-up alarm feature, for the Windows runner and the
/// UI: the interfaces to implement, the controller and its providers.
library;

export 'src/features/wake_alarm/application/wake_alarm_controller.dart';
export 'src/features/wake_alarm/application/wake_alarm_providers.dart';
export 'src/features/wake_alarm/application/wake_plan_providers.dart'
    show
        nextWakeOccurrenceProvider,
        wakeAlarmOccurrencesProvider,
        wakeAlarmPlanProvider;
export 'src/features/wake_alarm/data/audio_alarm_sound_player.dart';
export 'src/features/wake_alarm/data/composite_wake_timer_service.dart';
export 'src/features/wake_alarm/data/fake_wake_services.dart';
export 'src/features/wake_alarm/data/powercfg_parser.dart';
export 'src/features/wake_alarm/data/schtasks.dart';
export 'src/features/wake_alarm/data/wake_task_xml.dart';
export 'src/features/wake_alarm/domain/next_occurrence.dart';
export 'src/features/wake_alarm/domain/wake_alarm.dart';
export 'src/features/wake_alarm/domain/wake_capability.dart';
export 'src/features/wake_alarm/domain/wake_countdown_state.dart';
export 'src/features/wake_alarm/domain/wake_plan.dart';
export 'src/features/wake_alarm/domain/wake_services.dart';
