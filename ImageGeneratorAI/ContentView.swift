//
//  ContentView.swift
//  ImageGeneratorAI
//
//  Created by Jakub Patelski on 11/06/2023.
//

import SwiftUI
import OpenAIKit

struct ContentView: View {
    
    
    @State private var isLoading = true
    
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var image: UIImage?
    @State private var isGeneratingImage = false
    
    @State private var isImageSaved: Bool = false
    @State private var isImageSavedError: Bool = false
    @State private var isEmpty: Bool = false
    
    private func saveImage() {
         guard let image = image else {
             //run if image is not found
             print("No image to save.")
             isImageSavedError = true
             return
         }
        
        //save the image to the users's camera roll
         UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
         isImageSaved = true
        
     }
    
    private func generateImage(){
        if !text.isEmpty {
            isGeneratingImage = true
            Task {
                let result = await viewModel.generateImage(prompt: text)
                
                if result == nil {
                    print("Failed to get image")
                }
                
                image = result
                
                isGeneratingImage = false
            }
        } else {
            isEmpty = true
        }
    }
    
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer()
                
                if isGeneratingImage {
                    ProgressView()
                        .tint(.blue)
                        .scaleEffect(5)
                    
                } else if let image = image {
                    //run if image is found
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 290, height: 290)
                    
                    Button("Save") {
                        saveImage()
                    }
                    .font(.system(size: 25))

                } else {
                    Image("logoAI")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .cornerRadius(10)
                    
                    Text("Type a prompt to generate an image!")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                }
                
                Spacer()

                
                TextField("Type prompt here...", text: $text)
                    .submitLabel(.search)
                    .onSubmit {
                        generateImage()
                    }
                    .padding()
                    .background(Color(.systemGray6).cornerRadius(10))
                    .foregroundColor(.black)
                    .font(.headline)
                    .bold()
                
                
                Button("Generate") {
                  generateImage()
                }
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .padding()
                .padding(.horizontal, 20)
                .background(Color.blue
                    .cornerRadius(10)
                    .shadow(radius: 10))
                
            }

            
            if isLoading {
                Color.white.opacity(0.9)
                        .ignoresSafeArea()
                
                Image("logoAI")
                    .resizable()
                    .frame(width: 250, height: 250)
                    .cornerRadius(10)
            }

        }
        .padding()
        .onAppear {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                //code to be executed after a delay of 3 seconds
                isLoading = false
            }
        }
        .alert("Image Saved 😎",
          isPresented: $isImageSaved) {
        }
          
          .alert("Error 😥", isPresented: $isImageSavedError) {
          }
        
          .alert("Type something 🤖", isPresented: $isEmpty) {
          }
          
    }

}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
