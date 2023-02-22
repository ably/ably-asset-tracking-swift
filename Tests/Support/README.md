# Ably Asset Tracking SDKs Test Support Libraries

This directory contains libraries to help with testing the Ably Asset Tracking SDKs.

## General test support library

The `AblyAssetTrackingTesting` library contains functionality that is generally useful for testing the Ably Asset Tracking SDKs, and which isn’t related to any specific library.

## Library-specific test support libraries

Given a library `SomeLib`, the `SomeLibTesting` library contains types that are useful for testing `SomeLib` or libraries that use `SomeLib` as a dependency. For example, it might contain mocks of the types contained in `SomeLib`.
