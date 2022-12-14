# Contributing to the Ably Asset Tracking SDKs for Swift

_This repository supports iOS only. It doesn't support macOS. Any tries to build or test for macOS will cause an error._

## Project structure

This repository is structured as [Swift Package Manager](https://github.com/apple/swift-package-manager) (SPM).

Project source code is located in the **Sources** directory.

Project tests are located in the **Tests** directory.

Project examples are located in the **Examples** directory.

The product of this project are two libraries:

- `AblyAssetTrackingSubscriber`
- `AblyAssetTrackingPublisher`

defined in the `Package.swift` file

## API Keys and Access Tokens

The Mapbox and the Ably SDK keys and tokens are required to run the **SystemTests**.

Configuration of download token for Mapbox SDK is described [here](https://docs.mapbox.com/ios/search/guides/install/#configure-credentials).

## Development

The SPM command doesn't support testing on a specified destination, like "iOS, iOS, tvOS Simulator or macOS" when creating this document. The recommended way is to use the "xcodebuild" command when used from the command line.

## Initializing Git submodules

After checking out the repository you must first initialize the Git submodules:

```bash
git submodule update --init --recursive
```

## Running tests from the command line

To run tests, you have to configure the download token for the Mapbox described [here](https://docs.mapbox.com/ios/search/guides/install/#configure-credentials) and then set environment variables:

- `ABLY_API_KEY` - you can find this key in **your account -> {app name} -> API keys** on https://ably.com
- `MAPBOX_ACCESS_TOKEN` - you can find this key in **your account -> tokens** on https://mapbox.com

`ABLY_API_KEY` and `MAPBOX_ACCESS_TOKEN` are required to generate the `Secrets.swift` file.

Run `Scripts/test.sh` to start the tests.

## Running tests from Xcode IDE

The recommended IDE for working on this project is the [Xcode](https://developer.apple.com/xcode/).

To open the project in the Xcode IDE, double click on the `Package.swift` file.

To run tests from Xcode IDE, select the `ably-asset-tracking-swift-Package` scheme, select **_Product_** **_\-> Test_** _or use the keyboard shortcut_ **⌘U**

## Building Platform-Specific Documentation

_This repo uses_ [_jazzy_](https://github.com/realm/jazzy) _to build documentation._

Run `bundle install` to install the required tools.

Run `jazzy/build.sh` to build the documentation.

The above command will generate HTML files that are located in the `docs` directory.

## Release Process

Releases should always be made through a release pull request (PR), which must bump the version number and add to the [changelog](https://github.com/ably/ably-asset-tracking-swift/blob/main/CHANGELOG.md).

The release process must include the following steps:

1.  Ensure that all work intended for this release has landed on to `main` branch
2.  Create a release branch named like release/1.2.3
3.  Add a commit to bump the version number
	- use the script to update version, e.g.: `Scripts/update-version.sh 1.2.3`
4.  Add a commit to update the changelog
5.  Push the release branch to GitHub
6.  Open a PR for the release against the release branch you just pushed
7.  Gain approval(s) for the release PR from maintainer(s)
8.  Land the release PR to the `main` branch
9.  Create a tag named like v1.2.3 and push it to GitHub

We tend to use [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator) to collate the information required for a change log update.
Your mileage may vary, but it seems the most reliable method to invoke the generator is something like:
`github_changelog_generator -u ably -p ably-asset-tracking-swift --since-tag v1.0.0 --output delta.md`
and then manually merge the delta contents in to the main change log (where `v1.0.0` in this case is the tag for the previous release).

## Coding Conventions and Style Guide

- Favor Protocol Oriented Programming with Dependency Injection when writing any code. We're unable to create automatic mocks in Swift, so it'll be helpful for writing unit tests.
- Please remove default Xcode header comments (with author, license and creation date) as they're not necessary.
- If you're adding or modifying any part of the public interface of SDK, please also update [QuickHelp](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/SymbolDocumentation.html#//apple_ref/doc/uid/TP40016497-CH51-SW1) documentation.

### Logging

Inside the SDK we pass around a logger that conforms to the [`InternalLogHandler` protocol](Sources/AblyAssetTrackingInternal/Logging/InternalLogHandler.swift). This logger stores information about which subsystem the logged messages come from. When you create a new subsystem (e.g. adding a new type, or introducing a dependency on an external SDK) you should create a new log handler instance to store this subsystem information, using the logger’s `addingSubsystem(_:)` method.

## Generating mocks

We use [Sourcery](https://github.com/krzysztofzablocki/Sourcery) to generate mocks for the protocols that are marked with a `//sourcery: AutoMockable` comment.

At the time of writing, there is no way to automatically generate these mocks as part of the SPM build process, so when you update these protocols you’ll need to manually run the command `Scripts/generate-mocks.sh`.

When [Swift package plugins](https://developer.apple.com/videos/play/wwdc2022/110359/) get introduced in Swift 5.6, we might be able to generate these mocks automatically.

## Example apps distribution to TestFlight

We have a `testflight.yml` workflow that builds and uploads both the Publisher and Subscriber example apps to testflight for internal testing whenever code is pushed to the `main` branch.

`testflight.yml` workflow uses [fastlane](https://docs.fastlane.tools/) for creating and uploading builds, along with [match](https://docs.fastlane.tools/actions/match/) for handling code signing. The match secrets repo is available under git organization level secrets - `secrets.APPLE_APPS_MATCH_GIT_URL`, with it's `secrets.APPLE_APPS_MATCH_ENCRYPTION_PASSPHRASE`.
There are two separate `Fastfile`s that fastlane uses in this workflow - one for the publisher, and one for the example apps: `Examples/PublisherExampleSwiftUI/fastlane/Fastfile` and `Examples/SubscriberExample/fastlane/Fastfile`.

`testflight.yml` workflow will need some manual maintenance, since the distribution signing certificate used for signing the example apps builds expires a year after it's creation date. 
Whenever that happens, we will need to recreate it, and the corresponding provisioning profiles (currently named `match dist com.ably.tracking.example.subscriber` and `match appstore com.ably.tracking.example.publisher`) and upload them to the `Match secrets repo`.

This can be done automatically by `match` using `bundle exec fastlane match appstore` command from `Examples/SubsriberExample` and `Examples/PublisherExampleSwiftUI`, however this command creates both a new distribution cert and an appstore provisioning profile each time it is run - so it will create two distribution certs. 

Since the ammount of distribution certificates linked to an App Store Connect organization is limited, it's preferable to create a new distribution certificate manually in Xcode, and then [export it](https://sarunw.com/posts/how-to-share-ios-distribution-certificate/#exporting-a-certificate) from your keychain - both the .p12 and .cer files.

Then create new `App Store` type provisioning profiles for both example apps in [Apple dev center](https://developer.apple.com/account/resources/profiles/list), and download them.

Finally, run the command `bundle exec fastlane match import --readonly true --type appstore` to import the created distribution cert and provisioning profiles into the match secrets repo.

If provisioning profiles' names were changed in the process, make sure to update the corresponing values in both fastfiles: 
```
update_code_signing_settings(
    ...
    profile_name: "new name")
```
