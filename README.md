## Asset Tracking

Hi there. This is main repo for Ably Asset Tracking (AAT) project.
Since it's in very early stage of development, this doc will be change heavily.
So far it'll just contain basic concepts and assumptions:

- SDK will be written in Swift, however it still has to be compatible with ObjC
- It should be structured as monorepo with publishing SDK and demo app and subscribing SDK and demo app.
- Both SDK are well tested (I’d love to use Quick/Nimble for that)
- We’re following Protocol Oriented Programming with Dependency Injection for easy testing and stubbing.
- Demo apps are written using MVC pattern as they won't contain any heavy logic
- There should be some static analysis built in (SwiftLint)
- SDK’s should be distributed using CocoaPods (at the begninning), later we’ll add support for Carthage and Swift Package Manager
- At the beginning, we aim only to support iOS, but we need to keep in mind OSX and tvOS
- Project dependencies  (ably SDK and MapBox) are fetched using CocoaPods
- Docs are written for both Swift and ObjC
- SDK instances are created using Builder pattern.
- We’re supporting iOS 12 and higher
