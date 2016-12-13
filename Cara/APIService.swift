//
//  APIService.swift
//  Cara
//
//  Created by Kim Nguyen on 2016-12-12.
//  Copyright © 2016 NexttApps. All rights reserved.
//

import Foundation
import Moya

enum APIService {
    case generateOrder
    case submitLocation(id: String, lat: Double, lon: Double)
    case trackingOrder(id: String)
}

extension APIService: TargetType {
    var baseURL: URL {
        return URL(string: "http://159.203.1.45")!
    }
    
    var path: String {
        switch self {
        case .generateOrder:
            return "/createOrder"
        case .submitLocation(_, _, _):
            return "/submitLocation"
        case .trackingOrder(_):
            return "/trackOrder"
        }
    }
    
    var sampleData: Data {
        return "{}".utf8EncodedData
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .generateOrder:
            return nil
        case .trackingOrder(let id):
            return ["orderId": id]
        case .submitLocation(let id, let lat, let lon):
            return ["orderId": id, "longitude": lon, "latitude": lat]
        }
        
    }
    
    var method: Moya.Method {
        return .GET
    }
    
    var task: Task {
        return .request
    }
    
}


private extension String {
    var urlEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8EncodedData: Data {
        return self.data(using: .utf8)!
    }
}
