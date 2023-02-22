import XCTest

final class NetworkConnectivityTests: XCTestCase {
    private let faultProxyExpectationTimeout: TimeInterval = 10

    // This test is just a temporary one to demonstrate that the SDK test proxy client is working.
    func testSDKTestProxyClient() {
        let client = SDKTestProxyClient()

        // Get names of all faults

        let getAllFaultsExpectation = expectation(description: "get all faults")
        var faultNames: [String]!

        client.getAllFaults { result in
            do {
                faultNames = try result.get()
            } catch {
                XCTFail("Failed to getAllFaults (\(error))")
            }

            getAllFaultsExpectation.fulfill()
        }

        wait(for: [getAllFaultsExpectation], timeout: faultProxyExpectationTimeout)

        // Create a fault simulation

        let faultName = faultNames[0]

        let createFaultSimulationExpectation = expectation(description: "create fault simulation")
        var faultSimulationDto: FaultSimulationDTO!

        client.createFaultSimulation(withName: faultName) { result in
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
