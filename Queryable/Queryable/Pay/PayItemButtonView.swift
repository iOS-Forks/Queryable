//
//  PayItemButtonView.swift
//  FoldingCell-Demo
//
//  Created by andforce on 2023/6/28.
//  Copyright © 2023 Alex K. All rights reserved.
//

import SwiftUI
import PayLibs

struct PayItemButtonView: View {
    private typealias Action = () -> Void
    
    private var action: Action
    private var product: PayProduct
    
    @Binding var selectProductId: String
    
    public init(product: PayProduct, selectProductId: Binding<String>, action: @escaping () -> Void) {
        self.action = action
        self.product = product
        self._selectProductId = selectProductId
    }
    
    var body: some View {
        
        VStack {
            Button {
                self.action()
            } label: {
                VStack(spacing: 16) {
                    HStack {
                        Text(product.name).foregroundColor(.primary).bold().font(.system(size: 20))
                        Spacer()
                        if LocalePriceHelper.shared.localePrice(productId: product.productId) == "" {
                            Text("¥\(product.originPriceFormat())").strikethrough(true, color: .red).foregroundColor(.secondary).font(.system(size: 15))
                            Text("¥\(product.priceFormat())").foregroundColor(.primary).bold().font(.system(size: 20))
                        } else {
                            Text("\(LocalePriceHelper.shared.localePriceOrg(productId: product.productId))").strikethrough(true, color: .red).foregroundColor(.secondary).font(.system(size: 15))
                            Text("\(LocalePriceHelper.shared.localePrice(productId: product.productId))").foregroundColor(.primary).bold().font(.system(size: 20))
                        }
                    }
                    
                    HStack {
                        Text(product.des)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding(16)
                .background(Color(UIColor.tertiarySystemFill))
                .overlay(
                    RoundedRectangle(cornerRadius: 8).stroke(selectProductId == product.productId ? Color.yellow : Color.clear, lineWidth: 6)
                )
                .cornerRadius(8)
            }
            
            Text(product.notice)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
}
