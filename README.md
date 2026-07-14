# ReceiptLine

**Share a receipt photo. Get an expense line.**

iOS-first Flutter MVP for a side-income App Store app.

## What it does

1. Scan a receipt (camera or Photos)
2. AI extracts merchant, amount, date, category
3. Review → Save → Copy as `Starbucks · $6.45 · Apr 12 · Food`
4. Free: 5 scans/month · Pro: $3.99/mo or $29.99/yr (demo unlock for now)

## Run on iPhone

```bash
flutter pub get
flutter run -d <your-iphone-id>
```

Or open `ios/Runner.xcworkspace` in Xcode, select your iPhone, Run.

### Real receipt parsing

1. Open the app → Settings
2. Paste an OpenAI API key
3. Scan again — photos are sent only when a key is set

Without a key, the app uses a **demo parse** so you can test the full UI offline.

## Screens

| Screen | Purpose |
|--------|---------|
| Home | Brand, quota, scan CTA, history |
| Processing | Reading receipt… |
| Review | Edit merchant/amount/date/category |
| Done | Saved + copy |
| Paywall | Yearly / monthly Pro |
| Settings | API key, currency, privacy |

## Next (native Share Sheet)

v1 uses in-app camera/Photos. An iOS Share Extension target can be added in Xcode so Photos → Share → ReceiptLine works system-wide.

## Monetization target

$1K–$5K MRR with freemium + yearly subscription after StoreKit/RevenueCat + ASO.

## Stack

Flutter · Provider · image_picker · OpenAI vision JSON parse · SharedPreferences
