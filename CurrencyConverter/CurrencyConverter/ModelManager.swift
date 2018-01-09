//
//  ModelManager.swift
//  CurrencyConverter
//
//  Created by Benjamin Chris on 1/9/18.
//  Copyright © 2018 EnvisionWorld. All rights reserved.
//

import UIKit
import Alamofire

class ModelManager: NSObject {
    
    static let manager = ModelManager()
    
    var currencies:[String] = [String]()
    
    func loadCurrencies(completion: @escaping ((Bool, Error?)->())) {
        
        Alamofire.request("http://api.fixer.io/latest", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            
            if response.response?.statusCode == 200 {
                if let resp = response.result.value as? [String:Any] {
                    if let base = resp["base"] as? String {
                        self.currencies.append(base)
                    }
                    
                    if let rates = resp["rates"] as? [String:Double] {
                        let keys = Array(rates.keys)
                        for key in keys {
                            self.currencies.append(key)
                        }
                    }
                    
                    self.currencies.sort()
                    completion(true, nil)
                }
            } else {
                completion(false, response.error)
            }
            
        }
    }
    
    func exchange(source: String, target:String, date:Date, completion: @escaping ((Bool, Double, Error?)->())) {
        let url = "http://api.fixer.io/\(date.toString(format: "yyyy-MM-dd"))?symbols=\(target)&base=\(source)"
        print("url:\(url)")
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            
            if response.response?.statusCode == 200 {
                if let resp = response.result.value as? [String:Any] {
                    if let rates = resp["rates"] as? [String:Double] {
                        if let rate = rates[target] {
                            print("rate \(rate)")
                            completion(true, rate, nil)
                            return
                        }
                    }
                }
            }
            
            completion(false, 0, response.error)
        }
    }
    
}
