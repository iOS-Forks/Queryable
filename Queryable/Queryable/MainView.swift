//
//  MainView.swift
//  AIPoem
//
//  Created by andforce on 2023/6/27.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var rotationState: RotationState
    @State var title: String = ""
    var body: some View {
        NavigationView {
            VStack {
//                Image(uiImage: UIImage(named: "logo_1024")!)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 156)
//                    .padding(.top, rotationState.isRotated ? 0 : 156)
                
                
                Text("配诗").foregroundColor(Color("mainColor")).font(.system(size: 26)).offset(y: -25)
                
                Text("用 AI 给你的照片配一首古诗").foregroundColor(Color.secondary).font(.system(size: 18)).offset(y: -10)
                
                Spacer()
                
                NavigationLink(destination:PhotoGalleryView()) {
                    Text("开始")
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 18)
                        .background(Color("AccentColor"))
                        .cornerRadius(8)
                }.padding(.bottom, 56)
                
            }.onAppear {
                self.rotationState.isRotated = UIDevice.current.orientation.isLandscape
                NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
                    self.rotationState.isRotated = UIDevice.current.orientation.isLandscape
                }
            }
            
//            .navigationBarItems(trailing: NavigationLink(destination: {
//                SettingsView()
//            }, label: {
//                Image(systemName: "gearshape")
//                    .foregroundColor(Color("AccentColor"))
//            }))
            
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .environmentObject(rotationState)
        .navigationViewStyle(.stack)
        
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
