//
//  PayRestoreBtnView.swift
//  FoldingCell-Demo
//
//  Created by andforce on 2023/6/28.
//  Copyright © 2023 Alex K. All rights reserved.
//

import SwiftUI

public struct PayRestoreBtnView : View {
    private var payAction: () -> Void
    private var restoreAction: () -> Void
    @Binding var buttonText: String
    
    init(buttonText: Binding<String>, payAction: @escaping () -> Void, restoreAction: @escaping () -> Void) {
        self.payAction = payAction
        self.restoreAction = restoreAction
        self._buttonText = buttonText
    }
    
    public var body: some View {
        VStack {
            
            HStack {
                Link(destination: URL(string: "https://andforce.com/privacy_app.html")!) {
                    Text("隐私协议")
                }
                
                Divider()
                
                Link(destination: URL(string: "https://andforce.com/terms_of_use_app.html")!) {
                    Text("使用条款")
                }
            }
            .frame(height: 20)
            .padding(.vertical, 4)
            
            // 点击解锁
            Button {
                payAction()
            } label: {
                Text("\(buttonText)").bold().foregroundColor(Color(UIColor.white))
                    .frame(maxWidth: .infinity) // 将Text的宽度设置为Button的最大宽度
                    .frame(height: 50)
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(UIColor.systemYellow))
            .cornerRadius(8)
            .padding(.horizontal, 18)
            
            // 恢复订阅
            Button {
                restoreAction()
            } label: {
                Text("恢复购买")
            }
            .frame(maxWidth: .infinity)
            .frame(height: 30)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
    
}
