//
//  PrettyPrint.swift
//  Japx_Example
//
//  Created by Vlaho Poluta on 24/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Japx

struct PrettyPrint {
    
    static func prettyPrintJson(data: Japx.Parameters) -> String {
        let dataData = try! JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        
        return String(data: dataData, encoding: .utf8)!
    }
    
    static func prettyPrintJson(data: NSDictionary) -> String {
        let dataData = try! JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        return String(data: dataData, encoding: .utf8)!
    }
    
    static func prettyPrintJson(data: Data) -> String {
        return String(data: data, encoding: .utf8)!
    }
}
