//
//  PayManager+Poem.swift
//  AIPoem
//
//  Created by andforce on 2023/6/28.
//

import Foundation
import PayLibs

extension PayManager {
    public func hasPayed() -> Bool {
        let productIds = PayProductHelper.shared.parsePayProducts()
        var hasPayed = false
        for product in productIds {
            let payed = PayManager.shared.hasPayed(product.productId, isSubscription: product.isSubscription, checkTime: product.needCheckTime, checkDayCount: product.needCheckTimeDayCount)
            if payed {
                hasPayed = true
                break
            }
        }
        
        return hasPayed
    }
}
