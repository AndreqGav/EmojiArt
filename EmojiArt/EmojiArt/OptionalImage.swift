//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by andreq on 17.01.2023.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        return Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
