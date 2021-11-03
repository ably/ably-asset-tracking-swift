# Ably SDK Contributing

## Contributing to the Ably Asset Tracking SDKs for Swift & Objective-C

_This repository supports iOS only. It doesn't support macOS. Any tries to build or test for macOS will cause an error._

### Project structure

This repository is structured as [Swift Package Manager][1] (SPM).

Project source code is located in the **Sources** directory.

Project tests are located in the **Tests** directory.

Project examples are located in the **Examples** directory.

The product of this project are two libraries:

- `AblyAssetTrackingSubscriber`
- `AblyAssetTrackingPublisher`

defined in the `Package.swift` file

### API Keys and Access Tokens

The Mapbox and the Ably SDK keys and tokens are required to run the **SystemTests**.

Configuration of download token for Mapbox SDK is described [here][2].

### Development

The SPM command doesn't support testing on a specified destination, like "iOS, iOS, tvOS Simulator or macOS" when creating this document. The recommended way is to use the "xcodebuild" command when used from the command line.

### Running tests from the command line

To run tests, you have to configure the download token for the Mapbox described [here][3] and then set environment variables:

- `ABLY_API_KEY` - you can find this key in **your account -> {app name} -> API keys** on https://ably.com
- `MAPBOX_ACCESS_TOKEN` - you can find this key in **your account -> tokens** on https://mapbox.com

`ABLY_API_KEY` and `MAPBOX_ACCESS_TOKEN` are required to generate the `Secrets.swift` file.

Run `Scripts/test.sh` to start the tests.

### Running tests from Xcode IDE

The recommended IDE for working on this project is the [Xcode][4].

To open the project in the Xcode IDE, double click on the `Package.swift` file.

To run tests from Xcode IDE, select the `ably-asset-tracking-swift-Package` scheme, select **_Product_** **_\-> Test_** _or use the keyboard shortcut_ **⌘U**

### Running examples

To run examples, you have set up the Mapbox and Ably tokens in the `Examples/Secrets.xcconfig` file.

### Release Process

Releases should always be made through a release pull request (PR), which must bump the version number and add to the [changelog][5].

The release process must include the following steps:

1.  Ensure that all work intended for this release has landed on to `main` branch
2.  Create a release branch named like release/1.2.3
3.  Add a commit to bump the version number
4.  Add a commit to update the changelog
5.  Push the release branch to GitHub
6.  Open a PR for the release against the release branch you just pushed
7.  Gain approval(s) for the release PR from maintainer(s)
8.  Land the release PR to the `main` branch
9.  Create a tag named like v1.2.3 and push it to GitHub

[1]: https://github.com/apple/swift-package-manager
[2]: https://docs.mapbox.com/ios/search/guides/install/#configure-credentials
[3]: https://docs.mapbox.com/ios/search/guides/install/#configure-credentials
[4]: https://developer.apple.com/xcode/
[5]: https://github.com/ably/ably-asset-tracking-swift/blob/main/CHANGELOG.md