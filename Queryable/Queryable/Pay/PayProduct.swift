//
//  PayProduct.swift
//  FoldingCell-Demo
//
//  Created by andforce on 2023/6/28.
//  Copyright © 2023 Alex K. All rights reserved.
//

import Foundation

public class PayProduct: Codable {
    var productId: String
    var name: String
    var price: Float
    var originPrice: Float
    var des: String
    var notice: String
    var isSubscription: Bool
    var password: String
    var needCheckTime: Bool
    var needCheckTimeDayCount: Int
    
    func priceFormat()->String {
        let formattedNumber = String(format: "%.2f", price)
        return formattedNumber
    }
    
    func originPriceFormat()->String {
        let formattedNumber = String(format: "%.2f", originPrice)
        return formattedNumber
    }
}
