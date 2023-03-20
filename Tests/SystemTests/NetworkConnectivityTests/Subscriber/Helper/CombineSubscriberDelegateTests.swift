import AblyAssetTrackingSubscriberTesting
import AblyAssetTrackingTesting
import Combine
import XCTest

class CombineSubscriberDelegateTests: XCTestCase {
    // The testing pattern is taken from
    // https://heckj.github.io/swiftui-notes/#patterns-testing-and-debugging

    func testReplaysLastValueToAllNewSubscribers() {
        let combineSubscriberDelegate = SubscriberNetworkConnectivityTests.CombineSubscriberDelegate(
            logHandler: TestLogging.sharedInternalLogHandler
        )

        let subscriber = SubscriberMock()

        // Given...
        // ...that the object under test has received an invocation of `subscriber(sender:,didChangeTrackableState:)`

        combineSubscriberDelegate.subscriber(sender: subscriber, didChangeTrackableState: .online)

        // When...

        var cancellables = Set<AnyCancellable>()
        let firstExpectation = expectation(description: "First subscriber gets value")
        let secondExpectation = expectation(description: "Second subscriber gets value")

        // ...a subscriber is added to the object under test’s `trackableStates`...
        combineSubscriberDelegate.trackableStates.sink { status in
            XCTAssertEqual(status, .online)
            firstExpectation.fulfill()

            // ...and, when that first subscriber receives a value, another subscriber is added to the object under test’s `trackableStates`...
            combineSubscriberDelegate.trackableStates.sink { status in
                XCTAssertEqual(status, .online)
                secondExpectation.fulfill()
            }
            .store(in: &cancellables)
        }
        .store(in: &cancellables)

        // Then...
        // ...both subscribers receive the connection status sent to the object under test’s `subscriber(sender:,didChangeAssetConnectionStatus:)` method.

        waitForExpectations(timeout: 10)
    }
}
