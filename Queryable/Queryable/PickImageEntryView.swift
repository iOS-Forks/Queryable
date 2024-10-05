//
//  PickImageEntryView.swift
//  Queryable
//
//  Created by Dy Wang on 2024/10/5.
//

import SwiftUI
import PhotosUI

struct PickImageEntryView: View {
    @StateObject private var viewModel = CloudViewModel.shared
    @State private var isImagePickerPresented = false
    @State private var isCameraPresented = false
    @State private var showClassificationView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    Text("相册")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    isCameraPresented = true
                }) {
                    Text("拍照")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                if let image = viewModel.imagePickFromGallery {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $viewModel.imagePickFromGallery, onImagePicked: {
                    showClassificationView = true
                })
            }
            .fullScreenCover(isPresented: $isCameraPresented) {
                CameraPicker(image: $viewModel.imagePickFromGallery, onImagePicked: {
                    showClassificationView = true
                })
            }
            .background(
                NavigationLink(destination: CloudClassificationView(), isActive: $showClassificationView) {
                    EmptyView()
                }
            )
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onImagePicked: () -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                        self.parent.onImagePicked()
                    }
                }
            }
        }
    }
}

class PortraitOnlyImagePickerController: UIImagePickerController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onImagePicked: () -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraPicker>) -> PortraitOnlyImagePickerController {
        let picker = PortraitOnlyImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.navigationController?.navigationBar.tintColor = .black
        picker.cameraDevice = .rear
        picker.cameraCaptureMode = .photo
        picker.modalPresentationStyle = .fullScreen
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PortraitOnlyImagePickerController, context: UIViewControllerRepresentableContext<CameraPicker>) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
                parent.onImagePicked()
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    PickImageEntryView()
}
