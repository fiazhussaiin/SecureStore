


import SwiftUI
import UIKit

struct ImageVaultView: View {
    @State private var images: [ImageEntry] = []
    @State private var showAddImage = false
    @State private var showActionSheet = false
    @State private var showImageEditor = false
    @State private var selectedImage: ImageEntry?
    @State private var showAlert = false
    @State private var alertMessage: String?
    @State private var showToast = false

    var body: some View {
        NavigationView {
            VStack {
                // Gorgeous Header
                Text("My Secured Images")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 80)

                Spacer()

                // Image List
                if images.isEmpty {
                    Text("No Images Stored")
                        .foregroundColor(.gray)
                        .font(.headline)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(images) { image in
                                if let uiImage = UIImage(data: image.imageData) {
                                    ZStack {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .cornerRadius(15)
                                            .shadow(radius: 10)
                                            .frame(height: 300)
                                            .padding()
                                            .onTapGesture {
                                                self.selectedImage = image
                                                self.showActionSheet = true
                                            }
                                    }
                                }
                            }
                        }
                    }
                }

                Spacer()

                // Add Button with Stylish Design
                Button(action: {
                    self.showAddImage = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                        Text("Add Image")
                            .font(.title2)
                            .bold()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Capsule().fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing)))
                    .shadow(radius: 10)
                }
                .padding(.bottom, 40)
            }
            .background(LinearGradient(gradient: Gradient(colors: [.yellow, .black]), startPoint: .top, endPoint: .bottom))
            .edgesIgnoringSafeArea(.all)
            .sheet(isPresented: $showAddImage) {
                AddImageView(images: $images)
            }
            .sheet(isPresented: $showImageEditor) {
                if let selectedImage = selectedImage {
                    ImageEditorView(imageData: selectedImage.imageData, onSave: { editedData in
                        if let index = images.firstIndex(where: { $0.id == selectedImage.id }) {
                            images[index].imageData = editedData
                            saveImagesToUserDefaults() // Save updated images
                        }
                        alertMessage = "Image saved!"
                        showAlert = true
                    })
                    .onAppear {
                        // Show toast message when ImageEditorView appears
                        showToast = true
                    }
                }
            }
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(
                    title: Text("Image Options"),
                    message: Text("What would you like to do with this image?"),
                    buttons: [
                        .default(Text("Edit"), action: {
                            if let selectedImage = selectedImage {
                                self.showImageEditor = true
                            }
                        }),
                        .default(Text("Share"), action: {
                            if let selectedImage = selectedImage, let image = UIImage(data: selectedImage.imageData) {
                                shareImage(image: image)
                            }
                        }),
                        .default(Text("Copy"), action: {
                            copyImage()
                        }),
                        .destructive(Text("Delete"), action: {
                            deleteImage()
                        }),
                        .cancel(Text("Cancel"))
                    ]
                )
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Image Alert"), message: Text(alertMessage ?? "Unknown Error"), dismissButton: .default(Text("OK")))
            }
            .toast(isPresented: $showToast, message: "Tap on the buttons in Image Editor")
            .onAppear(perform: loadImagesFromUserDefaults)
        }
    }

    // Function to copy the image to clipboard
    func copyImage() {
        if let selectedImage = selectedImage, let image = UIImage(data: selectedImage.imageData) {
            UIPasteboard.general.image = image
            alertMessage = "Image copied to clipboard!"
            showAlert = true
        }
    }

    // Function to delete the selected image
    func deleteImage() {
        if let selectedImage = selectedImage, let index = images.firstIndex(where: { $0.id == selectedImage.id }) {
            images.remove(at: index)
            saveImagesToUserDefaults() // Save updated images
        }
    }

    func shareImage(image: UIImage) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let window = UIApplication.shared.windows.first {
            window.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }

    // Save images to UserDefaults
    func saveImagesToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(images)
            UserDefaults.standard.set(data, forKey: "savedImages")
        } catch {
            print("Failed to save images to UserDefaults: \(error)")
        }
    }

    // Load images from UserDefaults
    func loadImagesFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "savedImages") {
            do {
                let decoder = JSONDecoder()
                images = try decoder.decode([ImageEntry].self, from: data)
            } catch {
                print("Failed to load images from UserDefaults: \(error)")
            }
        }
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    var message: String

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                VStack {
                    Spacer()
                    Text(message)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 10)
                        .transition(.slide)
                        .animation(.easeInOut)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isPresented = false
                                }
                            }
                        }
                }
                .padding()
            }
        }
    }
}

extension View {
    func toast(isPresented: Binding<Bool>, message: String) -> some View {
        self.modifier(ToastModifier(isPresented: isPresented, message: message))
    }
}










struct AddImageView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var images: [ImageEntry]
    @State private var imageData: Data?
    @State private var showImagePicker = false

    var body: some View {
        VStack {
            if let data = imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .padding()
            } else {
                Text("No Image Selected")
                    .foregroundColor(.gray)
                    .padding()
            }

            Button("Select Image") {
                showImagePicker.toggle()
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(imageData: $imageData)
            }

            Button("Save Image") {
                saveImage()
            }
            .disabled(imageData == nil)
            .padding()
        }
    }

    func saveImage() {
        if let data = imageData {
            let newImage = ImageEntry(imageData: data, category: "Personal", dateAdded: Date())
            images.append(newImage)
            saveImagesToUserDefaults()
            presentationMode.wrappedValue.dismiss()
        }
    }

    // Save images to UserDefaults
    func saveImagesToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(images)
            UserDefaults.standard.set(data, forKey: "savedImages")
        } catch {
            print("Failed to save images to UserDefaults: \(error)")
        }
    }
}















// Image Editing View with basic tools
import SwiftUI
import UIKit

struct ImageEditorView: View {
    @State var imageData: Data
    @State private var brightness: Double = 0
    @State private var contrast: Double = 1
    @State private var saturation: Double = 1
    @State private var showToast = false
    @State private var toastMessage: String?
    let onSave: (Data) -> Void

    var body: some View {
        VStack {
            if let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .padding()
                    .brightness(brightness)
                    .contrast(contrast)
                    .saturation(saturation)
            }
            
            VStack(spacing: 20) {
                // Brightness Slider
                HStack {
                    Text("Brightness")
                    Slider(value: $brightness, in: -1...1, step: 0.1)
                }
                .padding()
                
                // Contrast Slider
                HStack {
                    Text("Contrast")
                    Slider(value: $contrast, in: 0.5...2, step: 0.1)
                }
                .padding()

                // Saturation Slider
                HStack {
                    Text("Saturation")
                    Slider(value: $saturation, in: 0...2, step: 0.1)
                }
                .padding()
                
                // Save and Download Buttons
                HStack(spacing: 20) {
                    Button("Save") {
                        // Call save action with the edited image
                        if let editedData = UIImage(data: imageData)?
                            .applyFilters(brightness: brightness, contrast: contrast, saturation: saturation)
                            .jpegData(compressionQuality: 1.0) {
                            onSave(editedData)
                            toastMessage = "Image saved successfully!"
                            showToast = true
                        }
                    }
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    
                    Button("Download") {
                        // Add download functionality here
                        if let uiImage = UIImage(data: imageData) {
                            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                            toastMessage = "Image downloaded successfully!"
                            showToast = true
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                }
            }
        }
        .padding()
        .toast1(isPresented: $showToast, message: toastMessage ?? "")
    }
}

extension UIImage {
    func applyFilters(brightness: Double, contrast: Double, saturation: Double) -> UIImage {
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        filter?.setValue(brightness, forKey: kCIInputBrightnessKey)
        filter?.setValue(contrast, forKey: kCIInputContrastKey)
        filter?.setValue(saturation, forKey: kCIInputSaturationKey)

        guard let outputImage = filter?.outputImage else { return self }

        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return self }

        return UIImage(cgImage: cgImage)
    }
}

struct ToastModifier1: ViewModifier {
    @Binding var isPresented: Bool
    var message: String

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                VStack {
                    Spacer()
                    Text(message)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 10)
                        .transition(.slide)
                        .animation(.easeInOut)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isPresented = false
                                }
                            }
                        }
                }
                .padding()
            }
        }
    }
}

extension View {
    func toast1(isPresented: Binding<Bool>, message: String) -> some View {
        self.modifier(ToastModifier1(isPresented: isPresented, message: message))
    }
}




struct ImagePicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 1.0) {
                parent.imageData = data
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
