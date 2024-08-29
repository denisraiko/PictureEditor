//
//  AboutViewModel.swift
//  PictureEditor
//
//  Created by Denis Raiko on 28.08.24.
//

import Foundation

class AboutViewModel {
    private let model: AboutModel
    
    var displayName: String {
        return model.name
    }
    
    init(model: AboutModel) {
        self.model = model
    }
}
