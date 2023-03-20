#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

/// An `XCTestCase` subclass that serves as a base class for `AblyAssetTrackingTesting.ParameterizedTestCase`. It implements the parts of that class which can’t be implemented in Swift due to the unavailability of `NSInvocation`.
@interface AATParameterizedTestCaseObjC : XCTestCase

/// Creates all of the test methods (that is, instance methods whose name begins with `test_`) that this class wishes `xctest` to run. Subclasses must implement this method.
///
/// - Returns: A list of `NSStringFromSelector`-ified selectors which name all of the created methods.
+ (NSArray<NSString *> *)aat_createTestMethods;

/// Returns `self.invocation.selector`.
@property (readonly) SEL aat_invocationSelector;

@end

NS_ASSUME_NONNULL_END
