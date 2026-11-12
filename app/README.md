# Salaat (Windows runner)

The thin Windows application of *Salaat | Aviny Prayer Times*. All logic and screens live in
`packages/owghat_lib`; this package only starts the app and provides the Windows implementations of the
platform interfaces (sound, toasts, tray, window, autostart, location, links, wake-up timers) in
`lib/src/platform`.

```
flutter run -d windows
flutter build windows --release
```

The installer script is `windows/installer/salaat.iss` (Inno Setup).
