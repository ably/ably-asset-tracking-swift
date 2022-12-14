import XCTest
@testable import AblyAssetTrackingPublisher

class DuplicateTrackableGuardTests: XCTestCase {
    func test_isCurrentlyAddingTrackableWithId_when_startAddingTrackableHasBeenCalled_returnsTrue() {
        var duplicateTrackableGuard = DefaultPublisher.DuplicateTrackableGuard()
        duplicateTrackableGuard.startAddingTrackableWithId("abc")
        
        XCTAssertTrue(duplicateTrackableGuard.isCurrentlyAddingTrackableWithId("abc"))
    }
    
    func test_isCurrentlyAddingTrackableWithId_when_startAddingTrackableHasBeenCalled_andThenFinishAddingTrackableHasBeenCalled_returnsFalse () {
        var duplicateTrackableGuard = DefaultPublisher.DuplicateTrackableGuard()
        duplicateTrackableGuard.startAddingTrackableWithId("abc")
        duplicateTrackableGuard.finishAddingTrackableWithId("abc", result: .success)
        
        XCTAssertFalse(duplicateTrackableGuard.isCurrentlyAddingTrackableWithId("abc"))
    }
    
    func test_finishAddingTrackableWithId_whenSaveDuplicateAddCompletionHandlerHasBeenCalled_callsDuplicateCompletionHandlers() {
        var duplicateTrackableGuard = DefaultPublisher.DuplicateTrackableGuard()
        
        let indices = (0..<3)
        
        let expectations = indices.map { index in
            expectation(description: "Duplicate completion handler \(index) called")
        }
        
        func createCompletionHandler(index: Int) -> DefaultPublisher.Callback<Void> {
            return .init(source: .publicAPI) { result in
                switch result {
                case .success:
                    expectations[index].fulfill()
                case .failure:
                    XCTFail("Expected success")
                }
            }
        }
        
        indices.forEach { index in
            duplicateTrackableGuard.saveDuplicateAddCompletionHandler(createCompletionHandler(index: index), forTrackableWithId: "abc")
        }
        
        duplicateTrackableGuard.finishAddingTrackableWithId("abc", result: .success)
        
        waitForExpectations(timeout: 1)
    }
    
    func test_finishAddingTrackableWithId_removesSavedDuplicateAddCompletionHandlers() {
        var duplicateTrackableGuard = DefaultPublisher.DuplicateTrackableGuard()
        
        let firstTimeExpectation = expectation(description: "Completion handler called")
        var calledFirstTime = false
        let secondTimeExpectation = expectation(description: "Completion handler called again")
        secondTimeExpectation.isInverted = true
        let completionHandler = DefaultPublisher.Callback<Void>(source: .publicAPI) { result in
            if !calledFirstTime {
                calledFirstTime = true
                firstTimeExpectation.fulfill()
            } else {
                secondTimeExpectation.fulfill()
            }
        }
        
        duplicateTrackableGuard.saveDuplicateAddCompletionHandler(completionHandler, forTrackableWithId: "abc")
        
        duplicateTrackableGuard.finishAddingTrackableWithId("abc", result: .success)
        wait(for: [firstTimeExpectation], timeout: 1)
        duplicateTrackableGuard.finishAddingTrackableWithId("abc", result: .success)
        wait(for: [secondTimeExpectation], timeout: 1)
    }
}