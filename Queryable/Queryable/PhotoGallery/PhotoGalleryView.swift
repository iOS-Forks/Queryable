//
//  PhotoGalleryView.swift
//  AIPoem
//
//  Created by andforce on 2023/6/26.
//

import SwiftUI

import Photos
import CommonLibs
import PayLibs

struct PhotoGalleryView: View {
    
    @ObservedObject var viewModel = PhotoGalleryViewModel.shared
    
    @ObservedObject var payViewModel = PayModel.shared
    
    @EnvironmentObject var rotationState: RotationState
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack {
            if viewModel.assetImageDic.isEmpty {
                VStack(spacing: 10) {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    Text("正在加载")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: self.columes(), spacing: 2) {
                        ForEach(viewModel.phAssets, id: \.self) { asset in
//                            if viewModel.isLinkActive {
//                                NavigationLink {
//                                    TableViewControllerView(data: asset)
//                                        .navigationTitle("诗句")
//                                        .edgesIgnoringSafeArea(.all)
//                                } label: {
//                                    imageView(for: asset)
//                                }
//                                .simultaneousGesture(
//                                    TapGesture().onEnded {
//                                        if viewModel.isLimit() {
//                                            viewModel.showPayAlert()
//                                        } else {
//                                            viewModel.goLink()
//                                        }
//                                        //CountChecker.shared.updateTodayCount()
//                                    }
//                                )
//                            } else {
//                                Button {
//                                    viewModel.showPayAlert()
//                                } label: {
//                                    imageView(for: asset)
//                                }
//                            }
                            Button {
                                Task {
                                    do {
                                        let imgEncoder = try ImgEncoder()
                                        let image = viewModel.assetImageDic[asset] ?? UIImage()
                                        let embedding = try await imgEncoder.computeImgEmbedding(img: image)
                                        print("Image embedding: \(embedding)")
                                    } catch {
                                        print("Error encoding image: \(error)")
                                    }
                                }
                                viewModel.showPayAlert()
                            } label: {
                                imageView(for: asset)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("相册")
        .environmentObject(rotationState)
        .onAppear {
            self.viewModel.fetchPhotos()
        }
        .onAppear {
            self.viewModel.isLinkActive = !viewModel.isLimit()
        }
        .onAppear {
            self.rotationState.isRotated = UIDevice.current.orientation.isLandscape
            NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
                self.rotationState.isRotated = UIDevice.current.orientation.isLandscape
            }
        }
        .alert(isPresented: $viewModel.isShowPayAlert) {
            Alert(title: Text("限制"), message: Text("您今天的5次免费次数已经用完，请明天再尝试或者成为会员获取无限次数。"),primaryButton: .default(Text("解锁"), action: {
                viewModel.hidePayAlert()
                payViewModel.showPayUI()
            }), secondaryButton: .default(Text("关闭"), action: {
                viewModel.hidePayAlert()
            }))
        }
        .fullScreenCover(isPresented: $payViewModel.isShowPayUI) {
            PayUI(payModel: payViewModel).onDisappear {
                self.viewModel.isLinkActive = !viewModel.isLimit()
                viewModel.refreshGallery()
            }
        }
    }
    
    struct CustomBackButton: View {
        @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        
        var body: some View {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    if #available(iOS 16.0, *) {
                        Image(systemName: "chevron.backward")
                            .bold()
                    } else {
                        Image(systemName: "chevron.backward")
                    }
                    
                    Text("返回")
                }.offset(x: -8)
                
            }
        }
    }
    
    @ViewBuilder func imageView(for asset: PHAsset) -> some View {
        if let image = viewModel.assetImageDic[asset] {
            let size = imageSize()
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipped()
                .overlay(
                    RoundedRectangle(cornerRadius: 0).stroke(Color.gray, lineWidth: 0.1)
                )
        } else {
            // Placeholder view or default image
            Color.gray
        }
    }
    
    private func imageSize() -> CGFloat {
        DeviceUtils.screenSizeWithSafeArea().width / (rotationState.isRotated ? 5 : 3)
    }
    
    private func columes() -> [GridItem] {
        if rotationState.isRotated {
            // 横屏
            return [GridItem(.flexible()), GridItem(.flexible()) , GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        } else {
            // 竖屏
            return [GridItem(.flexible()), GridItem(.flexible()) , GridItem(.flexible())]
        }
    }
    
}
