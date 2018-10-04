//
//  Flyover.swift
//  FlyoverKit
//
//  Created by Sven Tiigi on 21.02.18.
//  Copyright © 2018 Sven Tiigi. All rights reserved.
//

import MapKit

// MARK: - Flyover Protocol

/// The Flyover Protocol
public protocol Flyover {
    /// The flyover coordinate
    var coordinate: CLLocationCoordinate2D { get }
}

// MARK: - CoreLocation Framework Flyover Extensions

extension CLLocationCoordinate2D: Flyover {
    /// The flyover coordinate
    public var coordinate: CLLocationCoordinate2D {
        return self
    }
}
extension CLCircularRegion: Flyover {
    /// The flyover coordinate
    public var coordinate: CLLocationCoordinate2D {
        return self.center
    }
}
extension CLLocation: Flyover { }
extension CLVisit: Flyover { }

// MARK: - MapKit Framework Flyover Extensions

extension MKMapItem: Flyover {
    /// The flyover coordinate
    public var coordinate: CLLocationCoordinate2D {
        return self.placemark.coordinate
    }
}
extension MKMapView: Flyover {
    /// The flyover coordinate
    public var coordinate: CLLocationCoordinate2D {
        return self.centerCoordinate
    }
}
extension MKMapPoint: Flyover {
    /// The flyover coordinate
    public var coordinate: CLLocationCoordinate2D {
        return self.coordinate
    }
}
extension MKCoordinateRegion: Flyover {
    /// The flyover coordinate
    public var coordinate: CLLocationCoordinate2D {
        return self.center
    }
}
extension MKMapRect: Flyover {
    /// The flyover coordinate
    public var coordinate: CLLocationCoordinate2D {
        return self.origin.coordinate
    }
}
extension MKCoordinateSpan: Flyover {
    /// The flyover coordinate
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitudeDelta, longitude: self.longitudeDelta)
    }
}
extension MKShape: Flyover { }
extension MKPlacemark: Flyover { }
