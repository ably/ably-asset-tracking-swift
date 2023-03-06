import Foundation
import AblyAssetTrackingCore

/// Represents a callback to be executed by ``DefaultPublisher`` or ``DefaultSubscriber``. Provides an opaque wrapper that allows these classes to treat all callbacks the same regardless of where they came from, whilst respecting any specific threading requirements (such as the requirement that callbacks passed to the public API of these classes must be called on the main thread).
public struct Callback<T> {
    private var resultHandler: ResultHandler<T>
    private var source: Source

    /// Describes where the result handler passed to ``init(source:resultHandler:)`` came from.
    public enum Source {
        /// The result handler is an argument of a public method of ``DefaultPublisher`` or ``DefaultSubscriber``, and hence must be called on the main thread.
        case publicAPI
        /// The result handler was created for use as an internal callback in ``DefaultPublisher`` or ``DefaultSubscriber``, and does not carry any threading requirements.
        case internallyCreated
    }

    /// Creates a ``Callback`` instance.
    /// - Parameters:
    ///   - source: A description of where ``resultHandler`` came from.
    ///   - resultHandler: The action to be stored for later execution.
    public init(source: Source, resultHandler: @escaping ResultHandler<T>) {
        self.source = source
        self.resultHandler = resultHandler
    }

    /// Calls the result handler with the given result, respecting the source’s threading requirements.
    public func handle(_ result: Result<T, ErrorInformation>) {
        switch source {
        case .publicAPI:
            DispatchQueue.main.async { resultHandler(result) }
        case .internallyCreated:
            resultHandler(result)
        }
    }

    /// Calls the result handler with a ``Result.success`` result with the given value, respecting the source’s threading requirements.
    public func handleValue(_ value: T) {
        handle(.success(value))
    }

    /// Calls the result handler with a ``Result.failure`` result with the given error, respecting the source’s threading requirements.
    public func handleError(_ error: ErrorInformation) {
        handle(.failure(error))
    }
}

public extension Callback where T == Void {
    /// Calls the result handler with a ``Result.success`` result, respecting the source’s threading requirements.
    func handleSuccess() {
        handleValue(Void())
    }
}

public extension Callback {
    /// Calls the result handler with a ``ErrorInformationType.publisherStopped`` error, respecting the source’s threading requirements.
    func handlePublisherStopped() {
        let error = ErrorInformation(type: .publisherStoppedException)
        handle(.failure(error))
    }

    /// Calls the result handler with a ``ErrorInformationType.subscriberStopped`` error, respecting the source’s threading requirements.
    func handleSubscriberStopped() {
        let error = ErrorInformation(type: .subscriberStoppedException)
        handle(.failure(error))
    }
}
