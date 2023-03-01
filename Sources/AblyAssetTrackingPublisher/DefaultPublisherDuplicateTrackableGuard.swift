extension DefaultPublisher {
    /// Used by ``DefaultPublisher`` to keep track of which trackables it is currently in the process of adding, to ensure that for a given trackable ID the process of entering Ably presence is only performed once.
    struct DuplicateTrackableGuard {
        private var trackableIDsCurrentlyBeingAdded: Set<String> = []
        private var duplicateAddTrackableCompletionHandlersById: [String : [Callback<Void>]] = [:]
        
        /// Records that the process of adding a trackable with the given ID has begun.
        /// - Parameter id: The ID of the trackable that is being added.
        mutating func startAddingTrackableWithId(_ id: String) {
            trackableIDsCurrentlyBeingAdded.insert(id)
        }
        
        /// Records that the process of adding a trackable with the given ID has ended, and calls all stored duplicate completion handlers for that ID.
        /// - Parameters:
        ///   - id: The ID of the trackable.
        ///   - result: The result of the add process.
        mutating func finishAddingTrackableWithId(_ id: String, result: Result<Void, ErrorInformation>) {
            trackableIDsCurrentlyBeingAdded.remove(id)
            duplicateAddTrackableCompletionHandlersById[id]?.forEach { $0.handle(result) }
            duplicateAddTrackableCompletionHandlersById[id]?.removeAll()
        }
        
        /// Stores a completion handler that should be called when ``finishAddingTrackableWithId(_:,result:)`` is called.
        /// - Parameters:
        ///   - completion: The completion handler.
        ///   - id: The ID of the trackable.
        mutating func saveDuplicateAddCompletionHandler(_ completion: Callback<Void>, forTrackableWithId id: String) {
            var handlers = duplicateAddTrackableCompletionHandlersById[id] ?? []
            handlers.append(completion)
            duplicateAddTrackableCompletionHandlersById[id] = handlers
        }
    
        /// Returns whether a trackable with the given ID is currently being added – that is, whether there has been a call to ``startAddingTrackableWithId(_:)`` without a subsequent call to ``finishAddingTrackableWithId(_:,result:)``.
        func isCurrentlyAddingTrackableWithId(_ id: String) -> Bool {
            return trackableIDsCurrentlyBeingAdded.contains(id)
        }
    }
}
