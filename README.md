# Stride

Personal Strava-style fitness app for iPhone. Your account is the **owner** — every premium feature is unlocked (no paywall).

## Features in this MVP

- Record run / ride / walk / hike with GPS (falls back to simulation if permission denied)
- Activity feed with map polylines
- Activity detail: distance, pace/speed, elevation, relative effort, km splits
- Training: fitness & freshness, race predictions, best efforts, weekly plan, monthly report
- Routes: personal heatmap, route ideas, live segments & beacon placeholders
- Profile: owner entitlements list

## Run on your iPhone (Mac + cable)

```bash
cd /path/to/this/repo
flutter pub get
flutter run -d <your-iphone-id>
# or open ios/Runner.xcworkspace in Xcode, select your team, Run
```

1. Install Flutter on the Mac: https://docs.flutter.dev/get-started/install/macos  
2. Open **Xcode → Settings → Accounts** and add your Apple ID.  
3. In `ios/Runner.xcworkspace`, set **Signing Team** for the Runner target.  
4. On the iPhone: Settings → Privacy → Location → allow **Stride** → **Always** (for background recording).  
5. Plug in the cable, trust the computer, then `flutter devices` and `flutter run`.

## Web / quick UI check

```bash
flutter run -d chrome
```

Recording on web/desktop uses a simulated GPS path when real location is unavailable.

## Owner premium

`Entitlements.owner` in `lib/models/entitlements.dart` enables training plans, relative effort, fitness/freshness, race predictions, heatmap, route builder, live segments, best efforts, beacon, advanced analysis, and monthly reports for your account.
