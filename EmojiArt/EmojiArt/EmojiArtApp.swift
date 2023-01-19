//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by andreq on 16.01.2023.
//

import SwiftUI

@main
struct EmojiArtApp: App {

    var store:EmojiArtDocumentStore
    
    init() {
        store = EmojiArtDocumentStore(named: "Emoji Art")
    }
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDOcumentChooser( )
                .environmentObject(store)
        }
    }
}
