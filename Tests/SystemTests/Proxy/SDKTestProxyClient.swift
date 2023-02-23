import Foundation

/// A client for communicating with an instance of the SDK test proxy server. Provides methods for creating and managing proxies which are able to simulate connectivity faults that might occur during use of the Ably Asset Tracking SDKs.
class SDKTestProxyClient {
    private let baseURL: URL
    private let urlSession = URLSession(configuration: .default)

    init(baseURL: URL = URL(string: "http://localhost:8080")!) {
        self.baseURL = baseURL
    }

    private func url(forPathComponents pathComponents: String...) -> URL {
        return pathComponents.reduce(baseURL) { (url, pathComponent) in
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
            if let error = error {
                completionHandler(.failure(error))
                return
            }

            let httpResponse = response as! HTTPURLResponse

            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                completionHandler(.failure(RequestError.unexpectedStatus(httpResponse.statusCode)))
                return
            }

            completionHandler(.success(data!))
        }

        task.resume()
    }

    private func makeVoidPostRequest(for url: URL, _ completionHandler: @escaping (Result<Void, Error>) -> Void) {
        makeRequest(for: url, method: .post) { result in
            completionHandler(result.map() { success in })
        }
    }

    /// Lists all of the faults that the server is capable of simulating.
    func getAllFaults(_ completionHandler: @escaping (Result<[String], Error>) -> Void) {
        let url = url(forPathComponents: "faults")

        makeRequest(for: url, method: .get) { result in
            do {
                let decoder = JSONDecoder()
                let data = try result.get()
                let faultNames = try decoder.decode([String].self, from: data)

                completionHandler(.success(faultNames))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }

    /// Creates a fault simulation and starts its proxy.
    func createFaultSimulation(withName name: String, _ completionHandler: @escaping (Result<FaultSimulationDTO, Error>) -> Void) {
        let url = url(forPathComponents: "faults", name, "simulation")

        makeRequest(for: url, method: .post) { result in
            do {
                let decoder = JSONDecoder()
                let data = try result.get()
                let dto = try decoder.decode(FaultSimulationDTO.self, from: data)

                completionHandler(.success(dto))
            } catch {
                completionHandler(.failure(error))
            }
        }
    }

    /// Breaks the proxy using the fault-specific failure conditions.
    func enableFaultSimulation(withID id: String, _ completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let url = url(forPathComponents: "fault-simulations", id, "enable")
        makeVoidPostRequest(for: url, completionHandler)
    }

    /// Restores the proxy to normal functionality.
    func resolveFaultSimulation(withID id: String, _ completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let url = url(forPathComponents: "fault-simulations", id, "resolve")
        makeVoidPostRequest(for: url, completionHandler)
    }

    /// Stops the proxy. This should be called at the end of each test case that creates a fault simulation.
    func cleanUpFaultSimulation(withID id: String, _ completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let url = url(forPathComponents: "fault-simulations", id, "clean-up")
        makeVoidPostRequest(for: url, completionHandler)
    }
}
