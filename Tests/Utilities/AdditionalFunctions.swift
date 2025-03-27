//
//  AdditionalFunctions.swift
//  Japx_Example
//
//  Created by Vlaho Poluta on 24/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import Japx

public typealias ParsingPipelineCallback = (_ json: Data) -> (Any)

@objc public class AdditionalFunctions: NSObject {

    @objc public static func does(jsonFromFileNamed: String, containsEverythingFrom otherJsonFromFile: String, afterParsingBlock block: ParsingPipelineCallback) -> Bool {
        let data = jsonData(from: jsonFromFileNamed)
        let dataOther = jsonData(from: otherJsonFromFile)

        let json = block(data)
        let jsonOther = try! JSONSerialization.jsonObject(with: dataOther)

        if let json = json as? Japx.Parameters, let jsonOther = jsonOther as? Japx.Parameters {
            return does(jsonParameter: json, containsEverythingFrom: jsonOther)
        }

        if let json = json as? Japx.Parameters, let jsonOther = jsonOther as? [Japx.Parameters] {
            return does(jsonParameter: json, containsEverythingFrom: ["data": jsonOther])
        }

        if let json = json as? [Japx.Parameters], let jsonOther = jsonOther as? Japx.Parameters {
            return does(jsonParameter: ["data": json], containsEverythingFrom: jsonOther)
        }

        if let json = json as? [Japx.Parameters], let jsonOther = jsonOther as? [Japx.Parameters] {
            return does(jsonParameters: json, containsEverythingFrom: jsonOther)
        }

        assert(false, "You should not end up here")
    }
    
    @objc public static func jsonData(from jsonFromFileNamed: String) -> Data {
        let path = Bundle(for: self).path(forResource: jsonFromFileNamed, ofType: "json")!
        return try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
    }

    @objc public static func does(jsonParameters: [Japx.Parameters], containsEverythingFrom otherJson: [Japx.Parameters]) -> Bool {
        guard otherJson.count == jsonParameters.count else { return false }
        return zip(jsonParameters, otherJson).reduce(true) { (value, jsons) -> Bool in
            return value && does(jsonParameter: jsons.0, containsEverythingFrom: jsons.1)
        }
    }

    @objc public static func does(jsonParameter: Japx.Parameters, containsEverythingFrom otherJson: Japx.Parameters) -> Bool {
        return otherJson.reduce(true) { (boolCollectedSoFar, entry) -> Bool in

            if !boolCollectedSoFar { return false }

            if let arrayOther = entry.value as? [Japx.Parameters] {
                guard let array = jsonParameter[entry.key] as? [Japx.Parameters] else { return false }
                return does(jsonParameters: array, containsEverythingFrom: arrayOther)
            }

            if let innerJsonOther = entry.value as? Japx.Parameters {
                guard let innerJson = jsonParameter[entry.key] as? Japx.Parameters else { return false }
                return does(jsonParameter: innerJson, containsEverythingFrom: innerJsonOther)
            }

            if let stringOther = entry.value as? String {
                guard let string = jsonParameter[entry.key] as? String else { return false }
                return string == stringOther
            }

            if let numberOther = entry.value as? NSNumber {
                guard let number = jsonParameter[entry.key] as? NSNumber else { return false }
                return number == numberOther
            }

            if entry.value is NSNull {
                return (jsonParameter[entry.key] == nil || jsonParameter[entry.key] is NSNull)
            }

            assert(false, "You should not end up here")
        }
    }
}

