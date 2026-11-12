# Decision records

Short records of design decisions that shaped the code, with the reason and the consequences. Add a new
one when you take a decision that is hard to reverse or that a newcomer would otherwise reverse by
accident (for example a new network use or a new platform service). Number records in order; never reuse
a number.

| Record | Decision |
|---|---|
| [0001](0001-split-app-into-library-and-runner.md) | Split the app into a testable library and a thin Windows runner |
| [0002](0002-hand-written-models.md) | Hand-written immutable models instead of `freezed` |
| [0003](0003-platform-services-bundle-and-window-close-contract.md) | Platform services bundle, window-close contract, toast and tray details |
| [0005](0005-wake-timers.md) | Wake-up alarms: two wake mechanisms, one awake hold, explicit suspend |
| [0006](0006-place-search-and-offline-use.md) | Place search on public servers, with offline use afterwards |

There is no 0004: that number was reserved and never used. It is not a missing file.

Record format: title, status and date, context, decision, consequences (and alternatives where they
matter).
