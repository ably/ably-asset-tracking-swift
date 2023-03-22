import Foundation

/// Provides storage for the parameter values corresponding to each generated test method of ``ParameterizedTestCase`` subclasses.
struct ParameterizedTestCaseParamStorage {
    static var shared = ParameterizedTestCaseParamStorage()
    private init() {}

    /// Provides a "unique" identifier for a type such that it can be used as a hash key.
    ///
    /// I’m not sure under exactly what circumstances the return value of `String(describing: type)` uniquely describes the type, but I think it’s good enough for our immediate needs.
    ///
    /// I tried various ways of implementing the `ParameterizedTestCaseParamStorage` class in the hopes that I could avoid this `TypeID` and have a type-safe, generic `MethodNameKeyedParamStorage`, but I didn’t get anywhere (it always ended up involving a cast somewhere, and the cast always failed for reasons I couldn’t get my head around).
    private struct TypeID: Hashable {
        private let id: String

        init(type: Any.Type) {
            self.id = String(describing: type)
        }
    }

    private var perTypeStorages: [TypeID: MethodNameKeyedParamStorage] = [:]

    private struct MethodNameKeyedParamStorage {
        private var paramsByTestMethodName: [Selector: Any] = [:]

        mutating func setParam(_ param: Any, forTestMethodNamed name: Selector) {
            paramsByTestMethodName[name] = param
        }

        func param(forTestMethodNamed name: Selector) -> Any? {
            paramsByTestMethodName[name]
        }
    }

    /// Stores the parameter corresponding to the test method names `name` in class `containingClass`.
    mutating func setParam<TestClass, Param>(_ param: Param, forTestMethodNamed name: Selector, inClass containingClass: TestClass.Type) where TestClass: ParameterizedTestCase<Param> {
        let typeID = TypeID(type: containingClass)

        if let storage = perTypeStorages[typeID] {
            var newStorage = storage
            newStorage.setParam(param, forTestMethodNamed: name)
            perTypeStorages[typeID] = newStorage
        } else {
            var storage = MethodNameKeyedParamStorage()
            storage.setParam(param, forTestMethodNamed: name)
            perTypeStorages[typeID] = storage
        }
    }

    /// Retrieves the parameter corresponding to the test method named `name` in class `containingClass`.
    func param<TestClass, Param>(forTestMethodNamed name: Selector, inClass containingClass: TestClass.Type) -> Param? where TestClass: ParameterizedTestCase<Param> {
        let typeID = TypeID(type: containingClass)
        return perTypeStorages[typeID]?.param(forTestMethodNamed: name) as? Param
    }
}
