//
//  EmojiArtDocuments.swift
//  EmojiArt
//
//  Created by andreq on 16.01.2023.
//

import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject, Hashable, Identifiable, Equatable {
    
    @Published var steadyStateZoomScale: CGFloat = 1.0
    @Published var steadyStatePanOffset: CGSize = .zero
    
    var id: UUID
    
    static func == (lhs: EmojiArtDocument, rhs: EmojiArtDocument) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static let pallete: String="😃😘😊😅😙😚😇😊🥹😜🥸🥰😄😜🥸😞☹️"
    
    var autoSaveCancellable: AnyCancellable?
    
    @Published private var emojiArt: EmojiArt
    
    init(id: UUID? = nil) {
        self.id = id ?? UUID()
        let defaultKey = "EmojiArtDocument.\(self.id.uuidString)"
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: defaultKey)) ?? EmojiArt()
        autoSaveCancellable = $emojiArt.sink { (emojiArt) in
            UserDefaults.standard.set(emojiArt.json, forKey: defaultKey)
        }
        fetchBackgroundImageData()
        fetchEmojiImages()
    }
    
    
    @Published private(set) var backgroundImage: UIImage?
    @Published private(set) var images: [String:UIImage] = [:]
    
    
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    
    // MARK - Intent(S)
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func addImage(_ url: URL?) {
        if url != nil {
            emojiArt.addImage(url!)
            fetchEmojiImages()
        }
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, to location: CGPoint) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x = Int(location.x)
            emojiArt.emojis[index].y = Int(location.y)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int(CGFloat(emojiArt.emojis[index].size) * scale
                .rounded(.toNearestOrEven))
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, at scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int(scale.rounded(.toNearestOrEven))
        }
    }
    
    var backgroundUrl: URL? {
        get {
            emojiArt.backgroundURL
        }
        set {
            emojiArt.backgroundURL = newValue?.imageURL
            fetchBackgroundImageData()
        }
    }
    
    private var fetchImageCancellable: AnyCancellable?
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        
        if let url = self.emojiArt.backgroundURL {
            fetchImageCancellable?.cancel()
            fetchImageCancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { data, urlError in UIImage(data: data) }
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)
                .assign(to: \.backgroundImage, on: self)
        }
    }
    
    private var fetchImagesCancellable: AnyCancellable?
    
    private func fetchEmojiImages() {
        fetchImagesCancellable?.cancel()
        
        for emoji in emojis.filter({$0.url != nil}) {
            if !images.contains(where: {$0.key == emoji.text}) {
                let url = emoji.url!.imageURL
                
                fetchImagesCancellable = URLSession.shared.dataTaskPublisher(for: url)
                    .map { data, urlError in UIImage(data: data) }
                    .receive(on: DispatchQueue.main)
                    .replaceError(with: nil)
                    .sink {(image) in
                        self.images[emoji.text] = image
                    }
            }
        }
    }
}
