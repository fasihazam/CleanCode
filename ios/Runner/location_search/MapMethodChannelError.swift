//
//  MapMethodChannelError.swift
//  Runner
//
//  Created by Hammad Tariq on 02/12/2024.
//

/// An enumeration representing custom errors for map-related operations.
/// Conforms to the `Error` protocol for compatibility with Swift's error handling.
enum MapMethodChannelError: String, Error {
    
    /// Error indicating an invalid or missing argument.
    case invalidArgument = "INVALID_ARGUMENT"
    
    /// Error indicating an issue occurred during a search operation.
    case searchError = "SEARCH_ERROR"
    
    /// Error indicating a method is not implemented.
    case methodNotImplemented = "METHOD_NOT_IMPLEMENTED"

    /// Converts the error into a `FlutterError` to communicate with Flutter via a method channel.
    ///
    /// - Returns: A `FlutterError` with a corresponding code, message, and optional details.
    var flutterError: FlutterError {
        switch self {
        case .invalidArgument:
            return FlutterError(code: self.rawValue, message: "Query is missing or invalid", details: nil)
        case .searchError:
            return FlutterError(code: self.rawValue, message: "An error occurred while searching for locations", details: nil)
        case .methodNotImplemented:
            return FlutterError(code: self.rawValue, message: "Method not implemented", details: nil)
        }
    }

    /// Creates a custom search error with a specific message.
    ///
    /// - Parameter message: A detailed error message describing the issue.
    /// - Returns: A `.searchError` case, optionally extendable for more specific errors.
    ///
    /// - Note: Currently, this method always returns `.searchError`.
    ///         Consider adding a new case for more detailed custom error handling.
    static func customSearchError(message: String) -> MapMethodChannelError {
        return .searchError
    }
}
