//
//  AnimatableSystemFontModifier.swift
//  EmojiArt
//
//  Created by Виолетточка on 17.01.2023.
//

import SwiftUI

struct AnimatableSystemFontModifier: AnimatableModifier {
    var size: CGFloat
    var weigth: Font.Weight = .regular
    var design: Font.Design = .default
    
    func body(content: Content) -> some View {
        content.font(Font.system(size: size, weight: weigth, design: design))
    }
    
    var animatableData: CGFloat {
        get { size }
        set {
            size = newValue
        }
    }
}

extension View {
    func font(
        animatableWithSize size: CGFloat,
        weigth: Font.Weight = .regular,
        design: Font.Design = .default
    ) -> some View {
        self.modifier(
            AnimatableSystemFontModifier(
                size: size,
                weigth: weigth,
                design: design
            )
        )
    }
}
