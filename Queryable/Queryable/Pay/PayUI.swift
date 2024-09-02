//
//  File.swift
//  
//
//  Created by andforce on 2023/5/27.
//

import Foundation
import SwiftUI
import PayLibs
import CommonLibs
import SwiftUIViews

public struct PayUI : View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @ObservedObject var payModel: PayModel
    
    public var body : some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                VStack {
                    CustomPayContentView(payModel: payModel)
                    
                    PayRestoreBtnView(buttonText: $payModel.buttonText) {
                        payModel.pay($payModel.payProductId.wrappedValue)
                    } restoreAction: {
                        payModel.restore($payModel.payProductId.wrappedValue)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: CloseButton(dismiss: {
                    payModel.hidePayUI()
                }))
                
                // Loading
                if payModel.isProgressShowing {
                    LoadingDialogView(isPresented: $payModel.isProgressShowing)
                        .animation(.easeInOut, value: payModel.isProgressShowing)
                }
                
                if payModel.isStatueViewShowing {
                    DialogStatusView(isPresented: $payModel.isStatueViewShowing, isSuccess: $payModel.isSuccess, message: $payModel.statusMessage)
                        .animation(.easeInOut, value: payModel.isStatueViewShowing)
                }
            }
        }
        
    }
}


struct CustomPayContentView: View {
    
    @ObservedObject var payModel: PayModel
    
    public var body : some View {
        ScrollView{
            VStack {
                Text("👑").font(.system(size: 66))
                
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color("AccentColor"))
                        Text("干净无广告").font(.system(size: 18))
                        Spacer()
                    }
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color("AccentColor"))
                        Text("解除次数限制").font(.system(size: 18))
                        Spacer()
                    }
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color("AccentColor"))
                        Text("使用所有功能").font(.system(size: 18))
                        Spacer()
                    }
                }
                .padding(.top, 15)
                .padding(.leading, 18)
                
                ForEach(payModel.payProducts(), id: \.productId) { product in
                    PayItemButtonView(product: product, selectProductId: $payModel.payProductId) {
                        payModel.changeSelectProductId(product.productId)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                }
                Spacer()
            }
        }
    }
}
