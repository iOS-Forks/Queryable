//
//  QueryableApp.swift
//  Queryable
//
//  Created by Mazzystar on 2023/07/09.
//

import SwiftUI

@main
struct QueryableApp: App {
    
    @StateObject var rotationState = RotationState()
    
    var body: some Scene {
        WindowGroup {
            //ContentView()
            //MainView()
//            PhotoGalleryView()
//                .environmentObject(rotationState)
            PickImageEntryView()
        }
    }
}
