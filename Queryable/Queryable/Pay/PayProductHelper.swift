//
//  PayProductHelper.swift
//  AIPoem
//
//  Created by andforce on 2023/6/28.
//

import Foundation
import CommonLibs

class PayProductHelper {
    public static let shared = PayProductHelper()
    
    private init() {}
    
    func parsePayProducts() -> [PayProduct] {
        let products:[PayProduct] = JsonUtils.toCodableModel(jsonFile: Bundle.main.path(forResource: "pay_productids", ofType: "json")!)!
        return products
    }
}
