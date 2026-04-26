import Foundation

// MARK: - Error Logger Protocol
protocol ErrorLogger {
    func log(_ error: Error, context: String)
}

// MARK: - Print Logger
struct PrintErrorLogger: ErrorLogger {
    func log(_ error: Error, context: String) {
        print("[\(context)] \(error)")
    }
}

// MARK: - Silent Logger
struct SilentErrorLogger: ErrorLogger {
    func log(_ error: Error, context: String) {}
}
