//
//  EmojiArtDocumentPalette.swift
//  EmojiArt
//
//  Created by  andreq on 17.01.2023.
//

import Foundation

extension EmojiArtDocument {
    private static let PalettesKey = "EmojiArtDocument.PalettesKey"
    
    private(set) var paletteNames: [String: String] {
        get {
            UserDefaults.standard.object(forKey: EmojiArtDocument.PalettesKey) as? [String:String] ?? [
                "😃😘😊😅😙😚😇😊🥹😜🥸🥰😄😜🥸😞":"Faces",
                "😃😘😊😅😙😚😇😊🥹😜🥸🥰😄😜🥸": "Food",
                "😃😘😊😅😙😚😇😊🥹😜🥸🥰😄😜": "Animals",
                "😃😘😊😅😙😚😇😊🥹😜🥸🥰": "Activites"
            ]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: EmojiArtDocument.PalettesKey)
            objectWillChange.send()
        }
    }
    
    var sortedPalettes: [String] {
        paletteNames.keys.sorted(by: {paletteNames[$0]! < paletteNames[$1]!})
    }
    
    var defaultPalette: String {
        sortedPalettes.first ?? ""
    }
    
    func renamePalette(_ palette: String, to name: String) {
        paletteNames[palette] = name
    }
    
    func addPalette(_ palette: String, named name: String) {
        paletteNames[name] = palette
    }
    
    func removePalette(named name: String) {
        paletteNames[name] = nil
    }
    
    @discardableResult
    func addEmoji(_ emoji: String, toPalette palette: String) -> String {
        return changePlatte(palette, to: (emoji + palette).uniqued(withRespectTo: []))
    }
    
    @discardableResult
    func removeEmoji(_ emojisToRemove: String, fromPalette palette: String)->String {
        return changePlatte(palette, to: palette.filter {!emojisToRemove.contains($0)})
    }
    
    private func changePlatte(_ palette: String, to newPalette: String) -> String {
        let name = paletteNames[palette] ?? ""
        paletteNames[palette] = nil
        paletteNames[newPalette] = name
        
        return newPalette
    }
    
    func palette(after otherPalette: String)->String {
        palette(offsetBy: +1, from: otherPalette)
    }
    
    func palette(before otherPalette: String)->String {
        palette(offsetBy: -1, from: otherPalette)
    }
    
    private func palette(offsetBy offset: Int, from otherPalette: String) -> String {
        if let currentIndex = mostLikelyIndex(of: otherPalette) {
            let newIndex = (currentIndex + (offset >= 0 ? offset : sortedPalettes.count - abs(offset) % sortedPalettes.count)) % sortedPalettes.count
            return sortedPalettes[newIndex]
        } else {
            return defaultPalette
        }
    }
    
    private func mostLikelyIndex(of palette: String) -> Int? {
        let paletteSet = Set(palette)
        var best: (index: Int, score: Int)?
        let palettes = sortedPalettes
        for index in palettes.indices {
            let score = paletteSet.intersection(Set(palettes[index])).count
            if score > (best?.score ?? 0) {
                best = (index, score)
            }
        }
        
        return best?.index
    }
    
}
