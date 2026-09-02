# iOS release readiness checklist

Current state of the repository, and the steps that still need a human with an
Apple Developer account. Re-check Apple's policy pages immediately before
submission: the notes below were accurate on 31 August 2026 and policy changes
without notice.

---

## 1. Already done in this repository

| Item | State | Where |
|---|---|---|
| Bundle identifier | `com.valizim.app` | `ios/Runner.xcodeproj/project.pbxproj`, mirrored in `AppConfig.bundleId` |
| Display name | `Valizim` | `CFBundleDisplayName` |
| Bundle name | `Valizim` | `CFBundleName` |
| Version / build | `1.0.0` / `1` | `pubspec.yaml` → `version: 1.0.0+1` |
| App icons | 15 sizes, opaque, no alpha | `ios/Runner/Assets.xcassets/AppIcon.appiconset/` |
| Launch screen | Adaptive light/dark background + glyph | `LaunchScreen.storyboard`, `LaunchBackground.colorset` |
| Orientation | Portrait only on iPhone | `UISupportedInterfaceOrientations` |
| Export compliance | `ITSAppUsesNonExemptEncryption = false` | `Info.plist` |
| Shipped languages | `en`, `tr` | `CFBundleLocalizations` |
| Privacy manifest | No tracking, no collection, 3 required-reason APIs | `ios/Runner/PrivacyInfo.xcprivacy` |
| StoreKit test config | Wired into the Run scheme | `ios/Runner/Valizim.storekit` |
| Permission usage strings | **None needed** | See section 4 |
| Release build | Succeeds, 22.7 MB | `flutter build ios --release --no-codesign` |

---

## 2. Signing — needs a human

Nothing in this repository hard-codes a team, certificate or profile, so a new
developer account can adopt it without edits.

1. Xcode → Runner target → Signing & Capabilities.
2. Set **Team**. Leave "Automatically manage signing" on unless the studio has a
   reason not to.
3. Confirm the bundle identifier `com.valizim.app` is registered to that team in
   the Apple Developer portal.
4. Build once to let Xcode create the provisioning profile.

**Capabilities:** In-App Purchase is the only one required. The app uses no
push, no background modes, no App Groups, no HealthKit, no location. Do not add
capabilities the app does not use — each one widens the review surface.

---

## 3. In-app purchase — needs App Store Connect

The product id must match `AppConfig.proProductId` exactly:

```
com.valizim.app.pro_lifetime
```

1. App Store Connect → your app → Monetization → In-App Purchases.
2. Create a **Non-Consumable** with that exact id.
3. Set a reference name, price tier, and localized display name + description for
   English and Turkish.
4. Attach a review screenshot of the paywall.
5. Submit the IAP for review **with** the first app version, not after.

### Testing before submission

**Locally, no account needed:** the StoreKit configuration file is already wired
into the Run scheme, so purchase, cancel and restore all work on the simulator.
Xcode → Product → Scheme → Edit Scheme → Run → Options → StoreKit Configuration.

**Sandbox, on a real device:** create a Sandbox Apple Account in App Store
Connect → Users and Access → Sandbox, sign into it on the device under Settings
→ Developer, then run a Release-configuration build.

### States to exercise before release

Each has a distinct branch in `PurchaseService` and distinct copy:

- [ ] Purchase succeeds → Pro unlocks, message shown once
- [ ] Purchase cancelled → cancellation message, no entitlement
- [ ] Purchase fails → failure message, transaction still completed so the queue is not blocked
- [ ] Purchase pending (Ask to Buy) → pending message, no entitlement yet
- [ ] Restore with a prior purchase → Pro unlocks
- [ ] Restore with no prior purchase → "no previous purchase" message, not a silent spinner
- [ ] Delete and reinstall → free tier, then Restore → Pro returns
- [ ] Launch in airplane mode as a Pro user → still Pro (cached entitlement)
- [ ] Store unreachable → paywall explains it, app remains fully usable

---

## 4. Permissions

The app requests exactly one permission, notifications, and iOS requires no
usage-description string for it. There is deliberately **no**
`NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`,
`NSLocationWhenInUseUsageDescription` or contacts/calendar key, because the app
touches none of those. Adding an unused key invites a review question.

Notification permission is requested only in the moment a user switches a
reminder on. Verified on device: a clean install shows no prompt at launch.

---

## 5. App privacy declarations

Answer App Store Connect's questionnaire from what actually ships:

| Question | Answer |
|---|---|
| Do you collect data from this app? | **No** |
| Do you track users? | **No** |
| Third-party SDKs that collect data | **None** |

The app has no analytics, advertising or attribution SDK. Its dependencies are
Flutter plugins for local storage, local notifications, sharing, URL opening and
StoreKit — none of which collect data on the developer's behalf.

`PrivacyInfo.xcprivacy` declares required-reason API usage:

| API category | Reason | Why |
|---|---|---|
| UserDefaults | `CA92.1` | The app's own settings: cached entitlement, new-trip defaults |
| File timestamp | `C617.1` | Opening the local database in the app container |
| Disk space | `E174.1` | SQLite checks free space before writing |

**Privacy policy URL is required and is currently a placeholder.** Replace
`AppConfig.privacyPolicyUrl` with a live URL and enter the same URL in App Store
Connect. The in-app Privacy screen already describes the real behaviour; keep
the hosted policy consistent with it.

---

## 6. Build and upload

```bash
flutter build ios --release
```

Then in Xcode: Product → Archive → Distribute App → App Store Connect.

Increment `version:` in `pubspec.yaml` before every upload. App Store Connect
rejects a duplicate build number for the same version.

Pre-upload verification:

- [ ] `flutter analyze` clean
- [ ] `flutter test` green
- [ ] `tool/test_timezones.sh` green
- [ ] Placeholder URLs replaced
- [ ] Final icon artwork in place
- [ ] Version and build number incremented
- [ ] Release build installed and smoke-tested on a real device

---

## 7. Known review considerations

**No account, nothing to demo-login.** App Review needs no credentials; say so
in the review notes.

**Restore Purchases is present and reachable** from the paywall, which Apple
requires for non-consumables.

**The paywall states what stays free**, what Pro adds, the store-supplied price,
and links to Terms and Privacy — the full set Apple expects on a purchase
screen.

**Client-side entitlement verification** is a deliberate trade-off for a
backend-free v1. It is not a review blocker, but it is documented in the README
under "Purchase verification".

---

## 8. Not applicable to v1

Listed so the next person does not go looking:

- Push notifications (local only)
- Background modes (nothing runs in the background)
- Sign in with Apple (no accounts at all)
- App Tracking Transparency (no tracking)
- Universal links / associated domains
- iPad-specific layouts (iPhone target; the app runs scaled on iPad)
