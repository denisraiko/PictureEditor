//
//  MainViewModel.swift
//  PictureEditor
//
//  Created by Denis Raiko on 28.08.24.
//

import UIKit
import CoreImage

class MainViewModel {
    private var photo = PhotoModel()
    
    var currentImage: UIImage? {
        return applyFilter(to: photo.originalImage)
    }
    
    func setOriginalImage(_ image: UIImage) {
        photo.originalImage = image
    }
    
    func toggleFilter(_ isOn: Bool) {
        photo.isBlackAndWhite = isOn
    }
    
    private func applyFilter(to image: UIImage?) -> UIImage? {
        guard let image = image else { return nil }
        if photo.isBlackAndWhite {
            let context = CIContext()
            let ciImage = CIImage(image: image)
            let filter = CIFilter(name: "CIPhotoEffectNoir")
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            if let outputImage = filter?.outputImage {
                if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        return image
    }
}
