import AblyAssetTrackingTestingObjC

/// A type by which a ``ParameterizedTestCase`` subclass is parameterized.
public protocol ParameterizedTestCaseParam {
    /// The string that this parameter should contribute to name of the test method that ``ParameterizedTestCase`` will generate for this parameter.
    ///
    /// If it contains characters that are not allowed in a method name, they will be escaped.
    ///
    /// If there are multiple parameters with the same ``methodNameComponent`` in a single test case, the behaviour is currently undefined.
    var methodNameComponent: String { get }
}

/// An `XCTestCase` subclass that is capable of running parameterized tests.
///
/// A _parameterized test_ is an instance method with the same signature as a normal test method, but whose name starts with `parameterizedTest` instead of `test`. Like a normal test method, this method can also be specified as `throws`. However, `async` parameterized tests are not currently supported.
///
/// `ParameterizedTestCase` begins its execution by fetching all of the parameters that it will use. It does this by calling its ``fetchParams(_:)`` class method, which subclasses must override.
///
/// It then generates a test method corresponding to each combination of parameterized test and parameter. This method calls the corresponding parameterized test method.
///
/// Before running a test method corresponding to a given parameter value, it sets the test case’s ``currentParam`` value. The ``currentParam`` value is also available within the test case’s ``setUp...`` methods.
///
/// In order to use the Xcode GUI to run an individual test, you must first run the whole test file so that Xcode can become aware of the test’s existence. You can then re-run the test using Xcode’s Test navigator.
open class ParameterizedTestCase<Param: ParameterizedTestCaseParam>: AATParameterizedTestCaseObjC {
    // Constant for the lifetime of the test case instance
    private var _currentParam: Param?

    /// The parameter value that the currently-executing test case should use.
    public var currentParam: Param {
        guard let _currentParam else {
            fatalError("Attempted to fetch currentParam before it was populated. Did you try to fetch it before setUp?")
        }
        return _currentParam
    }

    /// Asynchronously fetch the parameters that this test case will use. Subclasses must implement this method.
    ///
    /// The test case imposes a timeout of 10 seconds on this operation.
    ///
    /// - Parameters:
    ///     - completion: A handler that you must call with the fetched results or an error.
    open class func fetchParams(_ completion: @escaping (Result<[Param], Error>) -> Void) {
        fatalError("fetchParams: must be implemented by subclasses")
    }

    /// Override of `NSObject` method, needed for running a single test.
    ///
    /// When `xctest` runs a test for a single test method (e.g. when triggered via the gutter play button in Xcode), it does not call `defaultTestSuite` on the test class but rather calls
    /// `instancesRespondToSelector:`. So, our usual strategy of relying on `defaultTestSuite` to create the test methods will not work in this situation, and we instead use `instancesRespondToSelector:` as our opportunity to do so.
    override open class func instancesRespond(to aSelector: Selector!) -> Bool {
        self.aat_createTestMethods()

        return super.instancesRespond(to: aSelector)
    }

    /// `xctest` calls this method before calling any of the `setUp...` methods, so we can use it to set ``currentParam`` such that it’s accessible by those methods.
    override open func invokeTest() {
        guard let fetchedParam = ParameterizedTestCaseParamStorage.shared.param(forTestMethodNamed: aat_invocationSelector, inClass: Self.self) else {
            fatalError("Could not find stored param for method \(aat_invocationSelector) in \(Self.self)")
        }
        _currentParam = fetchedParam

        super.invokeTest()
    }

    /// This implementation is required by our superclass `AATParameterizedTestCaseObjC`.
    @discardableResult
    override open class func aat_createTestMethods() -> [String] {
        let logHandler = TestLogging.sharedInternalLogHandler.addingSubsystem(.typed(self))

        let params: [Param]
        do {
            params = try Blocking.run(label: "Fetch params for running parameterized test cases", timeout: 10, logHandler: logHandler) { handler in
                fetchParams(handler)
            }
        } catch {
            // I can’t really think of much we can do here other than blow up the test process to bring this failure to people’s attention
            fatalError("Failed to fetch params in \(self): \(error)")
        }

        return parameterizedTestMethodSelectors.flatMap { selector in
            params.map { param in
                let selector = aliasParameterizedTestMethod(named: selector, forParam: param)
                ParameterizedTestCaseParamStorage.shared.setParam(param, forTestMethodNamed: selector, inClass: self)
                return NSStringFromSelector(selector)
            }
        }
    }

    /// Returns a list of selectors for all of this class’s instance methods whose name starts with `parameterizedTest`.
    private class var parameterizedTestMethodSelectors: [Selector] {
        var count: UInt32 = 0
        let list = class_copyMethodList(self, &count)!

        let allInstanceMethodSelectors = (0..<Int32(count)).map { i in
            let method = list[Int(i)]
            return method_getName(method)
        }

        free(list)

        return allInstanceMethodSelectors.filter { selector in
            NSStringFromSelector(selector).hasPrefix("parameterizedTest")
        }
    }

    /// Aliases a parameterized test method to a normal test method by creating a new instance method with the same implementation but a different name.
    private static func aliasParameterizedTestMethod(named name: Selector, forParam param: Param) -> Selector {
        let method = class_getInstanceMethod(self, name)!
        let implementation = method_getImplementation(method)
        let typeEncoding = method_getTypeEncoding(method)

        let testMethodName = testMethodName(forParameterizedTestMethodNamed: name, param: param)
        class_addMethod(self, testMethodName, implementation, typeEncoding)

        return testMethodName
    }

    /// Creates a test method name for a parameterized test method and a parameter value.
    ///
    /// Given a method name of the form `parameterizedTestFooBar` and a parameter whose `methodNameComponent` is `someParamValue`, returns `testFooBar_someParamValue`.
    ///
    /// It also supports method names of the form `parameterizedTestFooBarAndReturnError:`, which are how `throw`-ing test cases are exposed to Objective-C. In this case, it will return `testFooBar_someParamValueAndReturnError:`
    private static func testMethodName(forParameterizedTestMethodNamed name: Selector, param: Param) -> Selector {
        let nameWithParamInserted = insertingParam(param, intoParameterizedTestMethodNamed: name)
        return changingParameterizedTestToTest(nameWithParamInserted)
    }

    /// Inserts the `methodNameComponent` of a parameter value into a parameterized test method name method name.
    ///
    /// Given a method name of the form `parameterizedTestFooBar` and a parameter whose `methodNameComponent` is `someParamValue`, returns `parameterizedTestFooBar_someParamValue`.
    ///
    /// It also supports method names of the form `parameterizedTestFooBarAndReturnError:`, which are how `throw`-ing test cases are exposed to Objective-C. In this case, it will return `parameterizedTestFooBar_someParamValueAndReturnError:`
    ///
    /// - Parameters:
    ///     - param: A parameter value.
    ///     - name: The selector of the parameterized test method.
    private static func insertingParam(_ param: Param, intoParameterizedTestMethodNamed name: Selector) -> Selector {
        var result = NSStringFromSelector(name)

        let insertionIndex: String.Index

        let andReturnError = "AndReturnError:"
        if result.hasSuffix(andReturnError) {
            let range = result.range(of: andReturnError, options: [.backwards])!

            insertionIndex = range.lowerBound
        } else if result.contains(":") {
            // I think we’ll hit this case if we specify an `async` parameterized test, which is presumably exposed to Objective-C as a method that takes a completion handler. We can address this later if we need to, but for now I’ve stated in the class description that async parameterized tests are not supported.
            fatalError("Don’t know how to rename method \(name)")
        } else {
            insertionIndex = result.endIndex
        }

        result.insert(contentsOf: "_\(param.methodNameComponent.c99ExtendedIdentifier)", at: insertionIndex)

        return Selector(result)
    }

    /// Replaces a `"parameterizedTest"` prefix with `"test"`.
    ///
    /// - Parameters:
    ///     - name: A selector which begins with `"parameterizedTest"`.
    private static func changingParameterizedTestToTest(_ name: Selector) -> Selector {
        var result = NSStringFromSelector(name)
        let parameterizedTestRange = result.range(of: "parameterizedTest")!
        result.removeSubrange(parameterizedTestRange)
        result.insert(contentsOf: "test", at: result.startIndex)

        return Selector(result)
    }
}

// This code for escaping strings for insertion into a method name is copied from the Quick testing framework: https://github.com/Quick/Quick/blob/43c1d3dc9e18c02065dc8a9c75ec586ab46e7be9/Sources/Quick/String%2BC99ExtendedIdentifier.swift#L4-L30
private extension String {
    private static var invalidCharacters: CharacterSet = {
        var invalidCharacters = CharacterSet()

        let invalidCharacterSets: [CharacterSet] = [
            .whitespacesAndNewlines,
            .illegalCharacters,
            .controlCharacters,
            .punctuationCharacters,
            .nonBaseCharacters,
            .symbols
        ]

        for invalidSet in invalidCharacterSets {
            invalidCharacters.formUnion(invalidSet)
        }

        return invalidCharacters
    }()

    var c99ExtendedIdentifier: String {
        let validComponents = components(separatedBy: String.invalidCharacters)
        let result = validComponents.joined(separator: "_")

        return result.isEmpty ? "_" : result
    }
}
