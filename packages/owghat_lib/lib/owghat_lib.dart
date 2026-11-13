/// Owghat application library.
library;

export 'src/app/app.dart';
export 'src/app/bootstrap.dart';
export 'src/app/startup_info.dart';
export 'src/core/platform/app_notifier.dart';
export 'src/core/platform/audio_output.dart';
export 'src/core/platform/autostart_service.dart';
export 'src/core/platform/device_location.dart';
export 'src/core/platform/file_dialogs.dart';
export 'src/core/platform/launch_args.dart';
export 'src/core/platform/link_opener.dart';
export 'src/core/platform/notice_scheduler.dart';
export 'src/core/platform/place_search.dart';
export 'src/core/platform/platform_capabilities.dart';
export 'src/core/platform/platform_paths.dart';
export 'src/core/platform/platform_services.dart';
export 'src/core/platform/power_events.dart';
export 'src/core/platform/single_instance.dart';
export 'src/core/platform/tray_host.dart';
export 'src/core/platform/tray_menu.dart';
export 'src/core/platform/window_host.dart';
export 'src/core/storage/json_file_store.dart'
    show JsonStore, MemoryJsonStore, StoreReadResult;
export 'src/core/time/fade_ramp.dart';
export 'src/features/diagnostics/application/app_version.dart';
export 'src/features/locations/data/location_repository.dart'
    show AssetTextLoader;
export 'src/features/places/data/online_place_search.dart';
export 'src/features/settings/domain/sound_ref.dart';
