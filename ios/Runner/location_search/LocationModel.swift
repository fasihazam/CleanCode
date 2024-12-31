//
//  LocationModel.swift
//  Runner
//
//  Created by Hammad Tariq on 02/12/2024.
//

import MapKit

/// A model representing a location's details.
/// Conforms to `Codable` for easy encoding and decoding to/from JSON.
struct LocationnModel: Codable {
    
    /// The primary text description of the location (e.g., name or title).
    let main_text: String
    
    /// The secondary text description of the location (e.g., full address or additional details).
    let secondary_text: String
    
    /// The latitude of the location.
    let latitude: Double
    
    /// The longitude of the location.
    let longitude: Double
    
    /// A unique identifier for the place.
    /// Defaults to the locality from the placemark, or a UUID if unavailable.
    let placeId: String

    /// Initializes a `LocationnModel` from an `MKMapItem`.
    ///
    /// - Parameter mapItem: The `MKMapItem` object from which to extract location details.
    /// - Note:
    ///   - If `mapItem.name` is `nil`, `"Unknown"` is used as a default value for `main_text`.
    ///   - If `mapItem.placemark.title` is `nil`, `"No address available"` is used for `secondary_text`.
    ///   - If `mapItem.placemark.locality` is `nil`, a random UUID string is used for `placeId`.
    init(from mapItem: MKMapItem) {
        self.main_text = mapItem.name ?? "Unknown"
        self.secondary_text = mapItem.placemark.title ?? "No address available"
        self.latitude = mapItem.placemark.coordinate.latitude
        self.longitude = mapItem.placemark.coordinate.longitude
        self.placeId = mapItem.placemark.locality ?? UUID().uuidString
    }
}
