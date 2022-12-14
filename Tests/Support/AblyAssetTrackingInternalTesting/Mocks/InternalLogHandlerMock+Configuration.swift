extension InternalLogHandlerMock {
    /// Returns a mock whose ``addingSubsystem(_:)`` method is configured to return another mock.
    public static var configured: InternalLogHandlerMock {
        let handler = InternalLogHandlerMock()
        handler.addingSubsystemClosure = { _ in
            return InternalLogHandlerMock.configured
        }
        
        return handler
    }
}
