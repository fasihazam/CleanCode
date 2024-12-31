//
//  MapSearchService.swift
//  Runner
//
//  Created by Hammad Tariq on 27/11/2024.
//

import MapKit

/// A service class responsible for searching locations using `MKLocalSearch`.
class MapSearchService {
    
    /// Searches for locations based on a query string.
    ///
    /// - Parameters:
    ///   - query: A string representing the location query to search for.
    ///   - completion: A closure that is called with the search results.
    ///     It returns either a success with an array of `LocationnModel` or a failure with a `MapMethodChannelError`.
    ///
    /// - Example:
    ///   ```
    ///   let service = MapSearchService()
    ///   service.searchLocation(query: "New York") { result in
    ///       switch result {
    ///       case .success(let locations):
    ///           print("Found locations: \(locations)")
    ///       case .failure(let error):
    ///           print("Error: \(error)")
    ///       }
    ///   }
    ///   ```
    func searchLocation(query: String, completion: @escaping (Result<[LocationnModel], MapMethodChannelError>) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        let search = MKLocalSearch(request: request)
        
        // Starts the location search
        search.start { response, error in
            if let error = error {
                // Handles the error and calls completion with a custom error message
                completion(.failure(MapMethodChannelError.customSearchError(message: error.localizedDescription)))
                return
            }

            // Ensures that mapItems exist and are not empty
            guard let mapItems = response?.mapItems, !mapItems.isEmpty else {
                completion(.failure(.searchError)) // No results found
                return
            }

            // Maps the results to `LocationnModel` and calls the completion handler
            let locations = mapItems.map { LocationnModel(from: $0) }
            completion(.success(locations))
        }
    }
}
