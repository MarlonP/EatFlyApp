//
//  MapOverlay.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 21/05/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit
import MapKit

class MapOverlay: NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    
    init(mapSite: MapSite) {
        boundingMapRect = mapSite.overlayBoundingMapRect
        coordinate = mapSite.midCoordinate
    }
}
