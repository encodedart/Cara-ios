//
//  BaseController.swift
//  Cara
//
//  Created by Kim Nguyen on 2016-12-12.
//  Copyright © 2016 NexttApps. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class BaseController : UIViewController {
    
    var lat = 43.849869;
    var lon = -79.510986;
    
    var mapView: GMSMapView?
    let marker = GMSMarker()
    var orderID = ""
    
    func loadViewMap() {
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 14.0)
        mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
        self.view.insertSubview(mapView!, at: 0)
        marker.map = mapView!
        marker.icon = UIImage(named: "selected_bp_pin_smaller")
    }
    
    func placeMaker(lat: Double, lon: Double) {
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 14.0)
        mapView!.camera = camera
    }
}

extension Date {
    func toString() -> String {
        let df = DateFormatter()
        df.dateFormat = "dd MMM, yyyy hh:mm:ss a"
        return df.string(from: self)
    }
}
