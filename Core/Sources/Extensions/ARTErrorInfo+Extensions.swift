import Ably

extension ARTErrorInfo {
    func toErrorInformation() -> ErrorInformation {
        return ErrorInformation(code: self.code,
                                statusCode: self.statusCode,
                                message: self.message,
                                cause: nil)
    }
}
