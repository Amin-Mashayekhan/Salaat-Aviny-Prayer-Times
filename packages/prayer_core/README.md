# prayer_core

Pure Dart code behind *Salaat | Aviny Prayer Times*: the prayer-time calculator (Tehran, Jafari and
international methods), qibla bearing and distance, the great-circle path to the Kaaba, and the schedule
builder with its catch-up policy. It has no Flutter, no I/O and no clock, so everything in it is easy to
test.

```
dart test
```

The reference data in `seed/golden` is produced by `tools/reference/prayer_times_reference.py`; the Dart
calculator must reproduce it to within one second. How the algorithm works is described in
[docs/prayer-times.md](../../docs/prayer-times.md).
