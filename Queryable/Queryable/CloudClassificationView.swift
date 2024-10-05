//
//  CloudClassificationView.swift
//  Queryable
//
//  Created by Dy Wang on 2024/10/5.
//

import SwiftUI

struct CloudClassificationView: View {
    @StateObject private var viewModel = CloudViewModel.shared
    
    var body: some View {
        VStack {
            if let image = viewModel.imagePickFromGallery {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                
                Text("云的种类: \(viewModel.cloudSpecies)")
                    .padding()
                
                Button("开始分类") {
                    viewModel.checkCloudSpecie(image: image)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else {
                Text("没有选择图片")
            }
        }
        .navigationTitle("云分类")
    }
}

#Preview {
    CloudClassificationView()
}
