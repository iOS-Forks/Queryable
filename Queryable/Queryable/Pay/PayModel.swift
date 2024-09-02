//
//  PayModel.swift
//  VoiceChat
//
//  Created by andforce on 2023/6/16.
//  Copyright © 2023 andforce. All rights reserved.
//

import Foundation
import PayLibs
import CommonLibs

public class PayModel: ObservableObject {
    public static let shared = PayModel()
    
    private init() {}
    
    private let payManager = PayManager.shared
    
    @Published var isProgressShowing: Bool = false
    
    @Published var isStatueViewShowing: Bool = false
    @Published var isSuccess: Bool = false
    @Published var statusMessage: String = ""
    
    @Published var buttonText : String = "点击解锁"
    
    // 控制PayUI是否弹出来
    @Published var isPayUIPresented = false
    @Published var payProductId = PAY_ONE_YEAR_VIP
    
    func changeSelectProductId(_ newId: String) {
        payProductId = newId
    }
    
    func pay(_ productId: String) {
        isProgressShowing = true
        
        let product = self.payProducts(productId)
        guard let product = product else {
            isProgressShowing = false
            return
        }
        
        let password: String = product.password
        let needCheckTime: Bool = product.needCheckTime
        let isSubscription: Bool = product.isSubscription
        let dayCount: Int = product.needCheckTimeDayCount
        
        payManager.pay(productId, password: password, needCheckTime: needCheckTime) { info in
            self.handleResult(productId: productId, isSubscription: isSubscription, isRestore: false, checkTime: needCheckTime, checkDayCount: dayCount, info: info)
        }
    }
    
    private func handleResult(productId: String, isSubscription:Bool, isRestore: Bool, checkTime: Bool, checkDayCount: Int, info: PayInfo) {
        DispatchQueue.main.async {
            self.isProgressShowing = false
            
            self.isStatueViewShowing = true
            self.isSuccess = self.payManager.hasPayed(productId, isSubscription: isSubscription, checkTime: checkTime, checkDayCount: checkDayCount)
            
            if self.isSuccess {
                self.statusMessage = isRestore ? "恢复成功":"解锁成功"
            } else {
                self.statusMessage = isRestore ? "恢复失败":"解锁失败"
            }
            self.buttonText = self.payManager.hasPayed(productId, isSubscription: isSubscription, checkTime: checkTime, checkDayCount: checkDayCount) ? "已解锁" : "点击解锁"
        }
    }
    
    func startPay(payProductId: String) {
        self.isPayUIPresented = true
        self.payProductId = payProductId
    }
    
    func restore(_ productId: String) {
        isProgressShowing = true
        
        let product = self.payProducts(productId)
        guard let product = product else {
            isProgressShowing = false
            return
        }
        
        let password: String = product.password
        let needCheckTime: Bool = product.needCheckTime
        let isSubscription: Bool = product.isSubscription
        let dayCount: Int = product.needCheckTimeDayCount
        
        payManager.restore(productId, password: password, needCheckTime: needCheckTime) { info in
            self.handleResult(productId: productId, isSubscription: isSubscription, isRestore: true, checkTime: needCheckTime, checkDayCount: dayCount, info: info)
        }
    }
    
    func payProducts() -> [PayProduct] {
        return PayProductHelper.shared.parsePayProducts()
    }
    
    func payProducts(_ productId: String) -> PayProduct? {
        for product in self.payProducts() {
            if product.productId == productId {
                return product
            }
        }
        return nil
    }
    
    
    @Published var isShowPayUI = false
    func showPayUI() {
        isShowPayUI = true
    }
    func hidePayUI() {
        isShowPayUI = false
    }
}
