import Foundation

extension DefaultPublisher {
    /// Represents a callback to be executed by ``DefaultPublisher``. Provides an opaque wrapper that allows ``DefaultPublisher`` to treat all callbacks the same regardless of where they came from, whilst respecting any specific threading requirements (such as the requirement that callbacks passed to the public API of ``DefaultPublisher`` must be called on the main thread).
    struct Callback<T> {
        private var resultHandler: ResultHandler<T>
        private var source: Source
        
        /// Describes where the result handler passed to ``init(source:resultHandler:)`` came from.
        enum Source {
            /// The result handler is an argument of a public method of ``DefaultPublisher``, and hence must be called on the main thread.
            case publicAPI
            /// The result handler was created for use as an internal callback in ``DefaultPublisher``, and does not carry any threading requirements.
            case publisherInternal
        }

        /// Creates a ``Callback`` instance.
        /// - Parameters:
        ///   - source: A description of where ``resultHandler`` came from.
        ///   - resultHandler: The action to be stored for later execution.
        init(source: Source, resultHandler: @escaping ResultHandler<T>) {
            self.source = source
            self.resultHandler = resultHandler
        }
        
        /// Calls the result handler with the given result, respecting the source’s threading requirements.
        func handle(_ result: Result<T, ErrorInformation>) {
            switch source {
            case .publicAPI:
                DispatchQueue.main.async { resultHandler(result) }
            case .publisherInternal:
                resultHandler(result)
            }
        }
        
        /// Calls the result handler with a ``Result.success`` result with the given value, respecting the source’s threading requirements.
        func handleValue(_ value: T) {
            handle(.success(value))
        }

        /// Calls the result handler with a ``Result.failure`` result with the given error, respecting the source’s threading requirements.
        func handleError(_ error: ErrorInformation) {
            handle(.failure(error))
        }
    }

}

extension DefaultPublisher.Callback where T == Void {
    /// Calls the result handler with a ``Result.success`` result, respecting the source’s threading requirements.
    func handleSuccess() {
        handleValue(Void())
    }
}

extension DefaultPublisher.Callback {
    /// Calls the result handler with a ``ErrorInformationType.publisherStopped`` error, respecting the source’s threading requirements.
    func handlePublisherStopped() {
        let error = ErrorInformation(type: .publisherStoppedException)
        handle(.failure(error))
    }
}
