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
### ios test_all
```
fastlane ios test_all
```
Run tests on all targets
### ios test_core
```
fastlane ios test_core
```
Run Core tests
### ios test_internal
```
fastlane ios test_internal
```
Run Internal tests
### ios test_subscriber
```
fastlane ios test_subscriber
```
Run Subscriber tests
### ios test_publisher
```
fastlane ios test_publisher
```
Run Publisher tests
### ios test_system
```
fastlane ios test_system
```
Run System tests
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
