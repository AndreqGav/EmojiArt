//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by andreq on 16.01.2023.
//

import Foundation

struct EmojiArt : Codable {
    
    var backgroundURL: URL?
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable, Codable, Hashable {
        var id: Int
        
        let text: String
        var x: Int
        var y: Int
        var size: Int
        
        var isImage = false
        var url: URL?
        
        fileprivate init(id: Int, text: String, x: Int, y: Int, size: Int, url: URL?) {
            self.id = id
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.isImage = url != nil
            self.url = url
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data?) {
        if json != nil, let newEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json!) {
            self = newEmojiArt
        } else {
            return nil
        }
    }
    
    init() {}
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(id: uniqueEmojiId, text: text, x: x, y: y, size: size, url: nil))
    }
    
    mutating func addImage(_ url: URL) {
        uniqueEmojiId += 1
        emojis.append(Emoji(id: uniqueEmojiId, text: url.absoluteString, x: 0, y: 0, size: 10, url: url))
    }
}
