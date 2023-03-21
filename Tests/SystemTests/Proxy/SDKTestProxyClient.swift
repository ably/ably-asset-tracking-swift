import AblyAssetTrackingInternal
import Foundation

/// A client for communicating with an instance of the SDK test proxy server. Provides methods for creating and managing proxies which are able to simulate connectivity faults that might occur during use of the Ably Asset Tracking SDKs.
class SDKTestProxyClient {
    private let baseURL: URL
    private let logHandler: InternalLogHandler
    private let urlSession = URLSession(configuration: .default)

    init(baseURL: URL = URL(string: "http://localhost:8080")!, logHandler: InternalLogHandler) {
        self.baseURL = baseURL
        self.logHandler = logHandler.addingSubsystem(.typed(Self.self))
    }

    private func url(forPathComponents pathComponents: String...) -> URL {
        pathComponents.reduce(baseURL) { url, pathComponent in
            url.appendingPathComponent(pathComponent)
        }
    }

    private enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }

    enum RequestError: Swift.Error {
        case unexpectedStatus(Int)
    }

    private func makeRequest(for url: URL, method: HTTPMethod, _ completionHandler: @escaping (Result<Data, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error {
                completionHandler(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                fatalError("Expected an HTTPURLResponse but got \(type(of: response))")
            }

            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                completionHandler(.failure(RequestError.unexpectedStatus(httpResponse.statusCode)))
                return
            }

            completionHandler(.success(data!))
        }

        task.resume()
    }

    private func makeVoidPostRequest(for url: URL, loggingLabel: String, _ completionHandler: @escaping (Result<Void, Error>) -> Void) {
        logHandler.info(message: "Performing operation: \(loggingLabel)", error: nil)

        makeRequest(for: url, method: .post) { [weak self] result in
            guard let self else {
                return
            }

            switch result {
            case .success:
                self.logHandler.info(message: "SUCCESS: \(loggingLabel)", error: nil)
                completionHandler(.success)
            case .failure(let error):
                self.logHandler.error(message: "FAILURE: \(loggingLabel)", error: error)
            }
        }
    }

    /// Lists all of the faults that the server is capable of simulating.
    func getAllFaults(_ completionHandler: @escaping (Result<[String], Error>) -> Void) {
        logHandler.info(message: "Fetching all faults", error: nil)

        let url = url(forPathComponents: "faults")

        makeRequest(for: url, method: .get) { [weak self] result in
            guard let self else {
                return
            }

            do {
                let decoder = JSONDecoder()
                let data = try result.get()
                let faultNames = try decoder.decode([String].self, from: data)
                self.logHandler.info(message: "Fetched fault names \(faultNames)", error: nil)

                completionHandler(.success(faultNames))
            } catch {
                self.logHandler.error(message: "Failed to fetch fault names", error: error)
                completionHandler(.failure(error))
            }
        }
    }

    /// Creates a fault simulation and starts its proxy.
    func createFaultSimulation(withName name: String, _ completionHandler: @escaping (Result<FaultSimulationDTO, Error>) -> Void) {
        logHandler.info(message: "Creating fault simulation for fault named \(name)", error: nil)

        let url = url(forPathComponents: "faults", name, "simulation")

        makeRequest(for: url, method: .post) { [weak self] result in
            guard let self else {
                return
            }

            do {
                let decoder = JSONDecoder()
                let data = try result.get()
                let dto = try decoder.decode(FaultSimulationDTO.self, from: data)
                self.logHandler.info(message: "Created fault simulation \(dto)", error: nil)

                completionHandler(.success(dto))
            } catch {
                self.logHandler.error(message: "Failed to create fault simulation", error: error)
                completionHandler(.failure(error))
            }
        }
    }

    /// Breaks the proxy using the fault-specific failure conditions.
    func enableFaultSimulation(withID id: String, _ completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let url = url(forPathComponents: "fault-simulations", id, "enable")
        makeVoidPostRequest(for: url, loggingLabel: "Enable fault simulation with ID \(id)", completionHandler)
    }

    /// Restores the proxy to normal functionality.
    func resolveFaultSimulation(withID id: String, _ completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let url = url(forPathComponents: "fault-simulations", id, "resolve")
        makeVoidPostRequest(for: url, loggingLabel: "Resolve fault simulation with ID \(id)", completionHandler)
    }

    /// Stops the proxy. This should be called at the end of each test case that creates a fault simulation.
    func cleanUpFaultSimulation(withID id: String, _ completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let url = url(forPathComponents: "fault-simulations", id, "clean-up")
        makeVoidPostRequest(for: url, loggingLabel: "Resolve fault simulation with ID \(id)", completionHandler)
    }
}
