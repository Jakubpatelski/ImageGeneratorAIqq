//
//  ViewModel.swift
//  ImageGeneratorAI
//
//  Created by Jakub Patelski on 12/06/2023.
//

import Foundation
import OpenAIKit
import SwiftUI


class ViewModel: ObservableObject {
    
    private var openAI: OpenAI
    
    init() {
        // Load the configuration from the property list file
        guard let path = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
              let configDictionary = NSDictionary(contentsOfFile: path) as? [String: Any],
              let organizationId = configDictionary["organizationId"] as? String,
              let apiKey = configDictionary["apiKey"] as? String
        else {
            fatalError("Invalid configuration file or missing values.")
        }
        
        // Use the configuration to initialize the OpenAI class
        openAI = OpenAI(Configuration(organizationId: organizationId, apiKey: apiKey))
    }
      
    
    func generateImage(prompt: String) async -> UIImage? {
        
        do {
            
            //create an instance of ImageParameters with the prompt, resolution, and response format
            let params = ImageParameters(
                prompt: prompt,
                resolution: .medium,
                responseFormat: .base64Json)
            
            let result = try await openAI.createImage(parameters: params)
            let data = result.data[0].image
            //decode the base64 image data into a UIImage.
            let image = try openAI.decodeBase64Image(data)
            return image
                
            
        } catch {
            
            print(String(describing: error))
            return nil
            
        }
    }
}
