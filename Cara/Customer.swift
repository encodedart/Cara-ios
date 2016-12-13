//
//  Customer.swift
//  Cara
//
//  Created by Kim Nguyen on 2016-12-12.
//  Copyright © 2016 NexttApps. All rights reserved.
//

import Foundation
import UIKit
import Moya
import CoreLocation

class Cusotmer: BaseController, CLLocationManagerDelegate {
    
    @IBOutlet weak var placeOrderBtn: UIButton!
    
    @IBOutlet weak var orderNumTxt: UILabel!
    @IBOutlet weak var orderDateTxt: UILabel!
    @IBOutlet weak var newOrderBtn: UIButton!
    
    @IBOutlet weak var orderInfo: UIView!
    @IBOutlet weak var frontErrorTxt: UILabel!
    @IBOutlet weak var backError: UILabel!
    @IBOutlet weak var trackingBtn: UIButton!
    @IBOutlet weak var trackingNumberInput: UITextField!
    
    var placingOrder = false
    var isCust = true
    var timer: Timer?
    let provider = MoyaProvider<APIService>()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        frontErrorTxt.isHidden = true
        backError.isHidden = true
        trackingNumberInput.isHidden = true
        trackingBtn.isHidden = true
//        map = mapView!
        
        newOrderBtn.addTarget(self, action: #selector(self.onNewOrder(sender:)), for: .touchUpInside)
        
        if isCust {
            renderCust()
        } else {
            renderDriver()
        }
    }
    
    func onNewOrder(sender: UIButton) {
        stopTimer()
        self.orderID = ""
        locationManager.stopUpdatingLocation()
        
        if isCust {
            showGetOrder()
        } else {
            showGetTracking()
        }
    }
    
    func setViewType(isCust: Bool) {
        self.isCust = isCust
    }
    
    func renderCust() {
        
        if orderID.isEmpty {
            placeOrderBtn.isHidden = false
            showGetOrder()
        } else {
            showMap()
        }
        
        placeOrderBtn.addTarget(self, action: #selector(self.onPlaceOrderClicked(sender:)), for: .touchUpInside)
    }
    
    func renderDriver() {
        placeOrderBtn.isHidden = true
        self.view.backgroundColor = UIColorFromHex(rgbValue: 0xb0d458)
        
        trackingNumberInput.isHidden = false
        trackingBtn.isHidden = false
        if orderID.isEmpty {
            showGetTracking()
        }
        trackingBtn.addTarget(self, action: #selector(self.onProvideTrackingClicked(sender:)), for: .touchUpInside)
        
//        self.locationManager.requestAlwaysAuthorization() 
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            noGPSAllowError()
            return
        }
        if CLLocationManager.locationServicesEnabled() {
            print("Location service enable")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        } else {
            noGPSAllowError()
            return
        }
    }
    
    func noGPSAllowError() {
//        trackingNumberInput.isHidden = true
//        trackingBtn.isHidden = true
        frontErrorTxt.isHidden = false
        frontErrorTxt.text = "Cara Driver app require access to device loction to update driver's location. Please go to Setting and allow Cara app to access device location while in use."
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.lat = locValue.latitude as Double
        self.lon = locValue.longitude
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func showGetOrder() {
        placingOrder = false
        backError.isHidden = true
        mapView?.isHidden = true
        orderInfo.isHidden = true
        placeOrderBtn.isHidden = false
    }
    
    func showGetTracking() {
        trackingNumberInput.isHidden = false
        trackingBtn.isHidden = false
        backError.isHidden = true
        mapView?.isHidden = true
        orderInfo.isHidden = true
    
    }
    
    func showMap() {
        if orderID.isEmpty {
            showGetOrder()
            return
        }
        
        loadViewMap()
        placeOrderBtn.isHidden = true
        mapView?.isHidden = false
        orderInfo.isHidden = false
        orderNumTxt.text = "Order: #\(orderID)"
        orderDateTxt.text = Date().toString()
    }
    
    func showDriverMap() {
        if orderID.isEmpty {
            showGetTracking()
            return
        }
        
        loadViewMap()
        trackingNumberInput.isHidden = true
        trackingBtn.isHidden = true
        orderInfo.isHidden = false
        newOrderBtn.setTitle("New Order", for: .normal)
        newOrderBtn.backgroundColor = UIColorFromHex(rgbValue: 0xb0d458)
    }
    
    func onProvideTrackingClicked(sender: UIButton) {
        if (trackingNumberInput.text?.isEmpty)! {
            return
        }
        
        self.view.endEditing(true)
        self.orderID = trackingNumberInput.text!
        trackingNumberInput.text = ""
        showDriverMap()
        postTracking()
        startTimer()
    }
    
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { t in
                if self.isCust {
                    self.getTracking()
                } else {
                    self.postTracking()
                }
            }
        }
    }
    
    func showTrackingOnMap(lat: Double, lon: Double) {
        if lat == 0.0 || lon == 0.0 {
            if isCust {
                backError.isHidden = false
            }
            return
        }
        backError.isHidden = true
        placeMaker(lat: lat, lon: lon)
    }
    
    func stopTimer() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    func getTracking() {
        if orderID.isEmpty {
            stopTimer()
            showGetOrder()
            return
        }
        
        provider.request(.trackingOrder(id: orderID)) { result in
            switch result {
            case let .success(response):
//                let data = String(data: response.data, encoding: .utf8)
//                print(data)
                let json = try? JSONSerialization.jsonObject(with: response.data, options: [])
                if let dic = json as? [String: Any] {
                    var lat2: Double = 0.0
                    var lon2: Double = 0.0
//                    latitude\": null,\n    \"longitude
                    if let lat1 = dic["latitude"] as? String {
                        lat2 = Double(lat1)!
                    }
                    if let lon1 = dic["longitude"] as? String {
                        lon2 = Double(lon1)!
                    }
                    print("Locate: \(lat2),\(lon2)")
                    self.showTrackingOnMap(lat: lat2, lon: lon2)
                }
//
//                self.placingOrder = false
            case let .failure(error):
                print(error.localizedDescription)
                self.placingOrder = false
            }
        }
    }
    
    func postTracking() {
        if orderID.isEmpty {
            stopTimer()
            showGetTracking()
            return
        }
        
        orderNumTxt.text = String(format: "%.6f", self.lat) + "," + String(format: "%.6f", self.lon)
        orderDateTxt.text = Date().toString()
        
        provider.request(.submitLocation(id: self.orderID, lat: self.lat, lon: self.lon)) { result in
            self.showTrackingOnMap(lat: self.lat, lon: self.lon)
        }
        
    }
    
    func onPlaceOrderClicked(sender: UIButton) {
        if placingOrder {
            return
        }
        placingOrder = true
        
        provider.request(.generateOrder) { result in
            switch result {
            case let .success(response):
//                let data = String(data: response.data, encoding: .utf8)
                let json = try? JSONSerialization.jsonObject(with: response.data, options: [])
                if let dic = json as? [String: Any] {
                    if let oid = dic["orderId"] as? String {
                        self.orderID = oid
                        print("get order id: \(oid)")
                        self.showMap()
                        self.getTracking()
                        self.startTimer()
                    }
                }
            
                self.placingOrder = false
            case let .failure(error):
                print(error.localizedDescription)
                self.placingOrder = false
            }
        }
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}
