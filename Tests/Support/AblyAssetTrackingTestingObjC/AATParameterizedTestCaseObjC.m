#import "AATParameterizedTestCaseObjC.h"

@implementation AATParameterizedTestCaseObjC

/// An override of the corresponding `XCTestCase` method, which allows us to specify the test methods that should be executed. This is where we can dynamically create test methods.
+ (NSArray<NSInvocation *> *)testInvocations {
    if (self == [AATParameterizedTestCaseObjC class]) {
        // The XCTest runtime will call +[AATParameterizedTestCaseObjC testInvocations] when
        // enumerating all of the XCTestCase subclasses. We don’t want to call through to
        // +aat_createTestMethods as that will trigger an unimplemented method exception.
        return [super testInvocations];
    }

    NSArray<NSString *> *testMethodSelectorStrings = [self aat_createTestMethods];
    NSMutableArray<NSInvocation *> *invocations = [NSMutableArray array];

    // Copied from https://github.com/Quick/Quick/blob/43c1d3d/Sources/QuickObjCRuntime/QuickSpecBase.m#L20-L29
    for (NSString *selectorString in testMethodSelectorStrings) {
        SEL selector = NSSelectorFromString(selectorString);
        NSMethodSignature *signature = [self instanceMethodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.selector = selector;

        [invocations addObject:invocation];
    }

    return invocations;
}

+ (NSArray<NSString *> *)aat_createTestMethods {
    [NSException raise:@"AATParameterizedTestCaseException" format:@"aat_createTestMethods must be implemented by subclasses"];
}

- (SEL)aat_invocationSelector {
    return self.invocation.selector;
}

@end
