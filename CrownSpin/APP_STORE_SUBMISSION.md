# Endless Crown App Store Submission

## Current status

Endless Crown is now structured as a watch-only App Store package:

- `CrownSpin` is the iOS watch-only container target.
- `CrownSpin Watch App` is embedded in `CrownSpin.app/Watch`.
- `CrownSpin Complication` is embedded in the watch app's `PlugIns` folder.
- The watch app declares `WKWatchOnly = true`.
- The iOS container declares `ITSWatchOnlyContainer = true` and `LSApplicationLaunchProhibited = true`.
- The watch app and complication include `PrivacyInfo.xcprivacy` files for UserDefaults usage.

Verification completed:

```sh
xcodebuild -project 'CrownSpin/CrownSpin.xcodeproj' -target CrownSpin -configuration Release CODE_SIGNING_ALLOWED=NO build
xcodebuild -project 'CrownSpin/CrownSpin.xcodeproj' -scheme CrownSpin -configuration Release -archivePath /tmp/CrownSpin-verify.xcarchive CODE_SIGNING_ALLOWED=NO archive
xcodebuild test -project 'CrownSpin/CrownSpin.xcodeproj' -scheme 'CrownSpin Watch App' -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm),OS=26.5'
xcodebuild -project 'CrownSpin/CrownSpin.xcodeproj' -scheme CrownSpin -configuration Release -archivePath /tmp/CrownSpin-resumed.xcarchive -allowProvisioningUpdates archive
xcodebuild -exportArchive -archivePath /tmp/CrownSpin-resumed.xcarchive -exportPath /tmp/CrownSpin-resumed-export -exportOptionsPlist 'CrownSpin/AppStoreExportOptions.plist' -allowProvisioningUpdates
```

All commands succeeded. The watchOS test run executed 93 tests with 0 failures.

The exported App Store Connect IPA is available at:

```text
CrownSpin/AppStoreBuilds/CrownSpin-1.0-1.ipa
```

The export summary confirms Apple Distribution signing, App Store provisioning profiles, `get-task-allow = false`, and `beta-reports-active = true` for the iOS container, watch app, and complication.

To regenerate the IPA:

```sh
CrownSpin/scripts/app-store-package.sh export
```

After the App Store Connect app record exists, direct upload can be retried with:

```sh
CrownSpin/scripts/app-store-package.sh upload
```

## Screenshots

Apple Watch screenshot candidates are prepared in:

```text
CrownSpin/AppStoreAssets/Screenshots/
```

Files:

- `apple-watch-46mm-main.jpg`
- `apple-watch-46mm-effect-soft.jpg`
- `apple-watch-46mm-effects.jpg`

Each file is a flattened RGB JPEG at `416 x 496`, which matches Apple's accepted Series 11 / Series 10 Apple Watch screenshot size. App Store Connect requires one to ten Apple Watch screenshots; upload these under the Apple Watch screenshot section.

## Remaining App Store Connect work

Signing/export now works. Upload is currently blocked because App Store Connect has no app record for the container bundle ID.

The upload-style export returned:

```text
IDEDistributionFetchAppRecordStep: missingApp(bundleId: "media.jenny.crownspin")
```

Create the app record in App Store Connect before uploading:

1. App Store Connect > Apps > New App.
2. Platform: iOS.
3. Name: `Endless Crown`.
4. Bundle ID: `media.jenny.crownspin`.
5. SKU: any unique internal value, for example `endless-crown-watch-1`.
6. User Access: Full Access unless you need to restrict it.

Copy/paste fields and final metadata are collected in:

```text
CrownSpin/AppStoreAssets/Metadata/app-record-fields.md
```

After the app record exists, upload the already-exported IPA with Transporter/Xcode Organizer, or retry upload-style export.

## Archive, export, and upload

```sh
xcodebuild -project 'CrownSpin/CrownSpin.xcodeproj' -scheme CrownSpin -configuration Release -archivePath /tmp/CrownSpin.xcarchive -allowProvisioningUpdates archive
xcodebuild -exportArchive -archivePath /tmp/CrownSpin.xcarchive -exportPath /tmp/CrownSpin-export -exportOptionsPlist 'CrownSpin/AppStoreExportOptions.plist' -allowProvisioningUpdates
```

The checked-in export plist uses `destination = export` so it creates an IPA. The script above switches the destination to `upload` automatically for direct App Store Connect upload mode.

You can also use Xcode Organizer:

1. Select the `CrownSpin` scheme.
2. Select Any iOS Device.
3. Product > Archive.
4. Distribute App > App Store Connect.

## App Store Connect setup

For a watch-only app, create an iOS app record in App Store Connect using the container bundle ID:

- Bundle ID: `media.jenny.crownspin`
- Name: `Endless Crown`
- Platform: iOS

Then fill the Apple Watch metadata:

- Add Apple Watch screenshots. iOS screenshots are not required for watch-only apps.
- The description should clearly describe the Apple Watch functionality.
- App privacy can be answered as no data collected, assuming no analytics, ads, or network data collection is added.
- A privacy policy URL is still required for the App Store product page.

Suggested review note:

```text
Endless Crown is a watch-only Digital Crown haptic fidget app. Use the Digital Crown to scroll through numbered items and feel selectable haptic patterns. The app includes pattern selection, local usage statistics, ambient mode, and a WidgetKit complication that shows the current item and haptic count. It has no login, backend, ads, or analytics.
```

Apple references:

- https://help.apple.com/xcode/mac/current/en.lproj/devaba4602fd.html
- https://developer.apple.com/help/app-store-connect/create-an-app-record/add-watchos-app-information/
- https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
- https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitypereasons
