//
//  ContentView.swift
//  IsItSpam
//
//  Created by Jackie Zarrilli on 7/8/25.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedImage: UIImage? = nil
    @State private var isPickerPresented = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var recognizedText: String = ""
    @State private var isProcessing: Bool = false
    @State private var aiResult: String = ""
    @State private var isAIProcessing: Bool = false
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
            } else {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
            }
            HStack {
                Button("Take Photo") {
                    pickerSource = .camera
                    isPickerPresented = true
                }
                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                Button("Add Photo/Screenshot") {
                    pickerSource = .photoLibrary
                    isPickerPresented = true
                }
            }
            .padding(.bottom)
            TextEditor(text: $recognizedText)
                .frame(height: 120)
                .border(Color.gray)
                .padding(.horizontal)
                .scrollContentBackground(.visible) // Ensures scroll is always available
            if isProcessing {
                ProgressView("Extracting text...")
            } else if selectedImage != nil {
                Button("Extract Text from Image") {
                    if let image = selectedImage {
                        isProcessing = true
                        TextRecognizer.recognizeText(in: image) { text in
                            DispatchQueue.main.async {
                                recognizedText = text
                                isProcessing = false
                            }
                        }
                    }
                }
                .padding(.top)
            }
            if !recognizedText.isEmpty {
                if isAIProcessing {
                    ProgressView("Analyzing with Apple Intelligence...")
                } else {
                    Button("Ask Apple Intelligence: Is this spam?") {
                        isAIProcessing = true
                        aiResult = ""
                        Task {
                            if let result = try? await analyzeSpamWithAppleIntelligence(text: recognizedText) {
                                aiResult = result
                            } else {
                                aiResult = "Could not analyze text."
                            }
                            isAIProcessing = false
                        }
                    }
                    .padding(.top, 4)
                    if !aiResult.isEmpty {
                        Text("Apple Intelligence: \(aiResult)")
                            .padding(.top, 2)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $isPickerPresented) {
            ImagePicker(sourceType: pickerSource, selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { _ in
            recognizedText = ""
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    ContentView()
}

@MainActor
func analyzeSpamWithAppleIntelligence(text: String) async throws -> String {
    // let session = LanguageModelSession()
    // Replace with the actual FoundationModels API call when available
    // Example using NLLanguageModel (pseudo-code):
    /*
    let model = try await NLLanguageModel(named: "foundation-mistral-7b-instruct")
    let prompt = "Is the following text spam? Answer Yes or No.\n\(text)"
    let result = try await model.generate(prompt: prompt)
    return result.text
    */
    // Placeholder for demonstration:
    return "[Apple Intelligence response here]"let session = LanguageModelSession()
}
