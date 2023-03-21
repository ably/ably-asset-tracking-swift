import XCTest
import AblyAssetTrackingTesting

struct NetworkConnectivityTestsParam: ParameterizedTestCaseParam {
    var faultName: String

    var methodNameComponent: String {
        faultName
    }
}

final class NetworkConnectivityTests: ParameterizedTestCase<NetworkConnectivityTestsParam> {
    private let faultProxyExpectationTimeout: TimeInterval = 10

    static let client = SDKTestProxyClient(logHandler: TestLogging.sharedInternalLogHandler)

    override class func fetchParams(_ completion: @escaping (Result<[NetworkConnectivityTestsParam], Error>) -> Void) {
        // Get names of all faults
        client.getAllFaults { result in
            let paramsResult = result.map { faultNames in
                faultNames.map(NetworkConnectivityTestsParam.init(faultName:))
            }
            completion(paramsResult)
        }
    }

    override func setUp() {
        NSLog("In setUp, fault name is \(currentParam.faultName)")
    }

    // This test is just a temporary one to demonstrate that the SDK test proxy client is working.
    func parameterizedTest_SDKTestProxyClient() {
        let client = NetworkConnectivityTests.client

        // Create a fault simulation

        let createFaultSimulationExpectation = expectation(description: "create fault simulation")
        var faultSimulationDto: FaultSimulationDTO!

        client.createFaultSimulation(withName: currentParam.faultName) { result in
            do {
                faultSimulationDto = try result.get()
            } catch {
                XCTFail("Failed to create fault simulation (\(error))")
            }

            createFaultSimulationExpectation.fulfill()
        }

        wait(for: [createFaultSimulationExpectation], timeout: faultProxyExpectationTimeout)

        // Enable the fault simulation

        let enableFaultSimulationExpectation = expectation(description: "enable fault simulation")

        client.enableFaultSimulation(withID: faultSimulationDto.id) { result in
            do {
                try result.get()
            } catch {
                XCTFail("Failed to enable fault simulation (\(error))")
            }

            enableFaultSimulationExpectation.fulfill()
        }

        wait(for: [enableFaultSimulationExpectation], timeout: faultProxyExpectationTimeout)

        // Resolve the fault simulation

        let resolveFaultSimulationExpectation = expectation(description: "resolve fault simulation")

        client.resolveFaultSimulation(withID: faultSimulationDto.id) { result in
            do {
                try result.get()
            } catch {
                XCTFail("Failed to resolve fault simulation (\(error))")
            }

            resolveFaultSimulationExpectation.fulfill()
        }

        wait(for: [resolveFaultSimulationExpectation], timeout: faultProxyExpectationTimeout)

        // Clean up the fault simulation

        let cleanUpFaultSimulationExpectation = expectation(description: "clean up fault simulation")

        client.cleanUpFaultSimulation(withID: faultSimulationDto.id) { result in
            do {
                try result.get()
            } catch {
                XCTFail("Failed to clean up fault simulation (\(error))")
            }

            cleanUpFaultSimulationExpectation.fulfill()
        }

        wait(for: [cleanUpFaultSimulationExpectation], timeout: faultProxyExpectationTimeout)
    }
}
