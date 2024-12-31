//
//  MapMethodChannel.swift
//  Runner
//
//  Created by Hammad Tariq on 27/11/2024.
//

import Flutter
import MapKit

/// A class to handle Flutter method channel communication for map-related functionality.
class MapMethodChannel {

    /// Sets up the Flutter method channel for handling map-related method calls.
    ///
    /// - Parameter controller: The `FlutterViewController` used to bind the method channel to Flutter.
    static func setup(controller: FlutterViewController) {
        // Define the method channel name
        let channel = FlutterMethodChannel(name: "info.lieferking.mapleharvest/mkmapkit", binaryMessenger: controller.binaryMessenger)
        let mapSearchService = MapSearchService()
        
        // Set up the method call handler
        channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "searchLocation":
                // Extract query parameter from the method call arguments
                guard let args = call.arguments as? [String: Any],
                      let query = args["query"] as? String else {
                    result(MapMethodChannelError.invalidArgument.flutterError)
                    return
                }
                
                // Perform the search using MapSearchService
                mapSearchService.searchLocation(query: query) { response in
                    switch response {
                    case .success(let locations):
                        do {
                            // Encode the locations into JSON and return the result as a string
                            let jsonData = try JSONEncoder().encode(locations)
                            if let jsonString = String(data: jsonData, encoding: .utf8) {
                                result(jsonString)
                            } else {
                                result(MapMethodChannelError.searchError.flutterError)
                            }
                        } catch {
                            result(MapMethodChannelError.customSearchError(message: "Failed to encode locations."))
                        }
                    case .failure(let error):
                        // Return any errors that occurred during the search
                        result(error.flutterError)
                    }
                }

            default:
                // Handle unimplemented method calls
                result(MapMethodChannelError.methodNotImplemented.flutterError)
            }
        }
    }
}
