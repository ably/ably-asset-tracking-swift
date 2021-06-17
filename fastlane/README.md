fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios test
```
fastlane ios test
```
Run tests on all targets
### ios test_core
```
fastlane ios test_core
```
Run tests on the Core target
### ios test_internal
```
fastlane ios test_internal
```
Run tests on the Internal target
### ios test_publisher
```
fastlane ios test_publisher
```
Run tests on the Publisher target
### ios test_subscriber
```
fastlane ios test_subscriber
```
Run tests on the Subscriber framework of SDK
### ios build_subscriber
```
fastlane ios build_subscriber
```
Build Subscriber SDK and export is as .framework file
### ios build_publisher
```
fastlane ios build_publisher
```
Build Publisher SDK and export is as .framework file
### ios build_example_apps
```
fastlane ios build_example_apps
```
Build example apps to validate that there are no build errors

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
