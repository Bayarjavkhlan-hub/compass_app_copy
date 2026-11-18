# Maestro flows

The same flows run unchanged on Android and iOS. Both builds use the app ID `com.example.compassApp`, and every selector uses a Flutter `Semantics` identifier (see `app/lib/ui/core/ui/test_ids.dart`). Flutter exposes those identifiers as `resource-id` on Android and `accessibilityIdentifier` on iOS.

| Flow | Tags | Covers |
|---|---|---|
| `01_home_smoke` | smoke | Home loads with the seeded Alaska booking |
| `02_open_existing_booking` | smoke | Open a booking, return home |
| `03_create_booking` | smoke, booking | Search → results → activities → booking → booking listed on home |
| `04_search_validation` | regression | Search is disabled until the form is complete, guest counter limits |
| `05_delete_booking` | regression | Swipe to delete, snackbar shown |

`subflows/search_trip.yaml` fills in the search form (with the `CONTINENT_ID`, `START_OFFSET`, `LENGTH` and `GUESTS_TAPS` params). `scripts/trip_dates.js` picks trip dates relative to today, so the flows never go stale.

## Running locally (Android)

Run these from the repo root, with an emulator running:

```bash
cd app && flutter build apk --debug -t lib/main_development.dart && cd ..
adb uninstall com.example.compassApp; adb install app/build/app/outputs/flutter-apk/app-debug.apk
maestro test .maestro                                   # all flows
maestro test .maestro --include-tags smoke              # smoke only
maestro test .maestro/flows/03_create_booking.yaml      # one flow
maestro test .maestro --format junit --output report.xml
```

Always build the **development** version of the app (`main_development.dart`): it uses local data and is always logged in.

## Gotchas

- **Enabled state:** the ID sits on a wrapper node, and the enabled/disabled state lives on the button node inside it. Assert it with `enabled: false` plus `childOf: { id: ... }`.
- **Swipe to delete:** `swipe: from: id` starts at the row's center and is too short for `Dismissible`'s 40% threshold. Use explicit `start`/`end` coordinates, and keep them away from the screen edges, because edge swipes trigger the OS back gesture.
- **Emulator storage:** the debug APK is about 190 MB. `adb install -r` can fail with `INSUFFICIENT_STORAGE`, so uninstall first.
- **Images:** they show `HttpException: 403` text because the upstream image bucket is gone. Don't assert on images.
