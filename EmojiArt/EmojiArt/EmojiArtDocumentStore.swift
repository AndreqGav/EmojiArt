//
//  EmojiArtDocumentStore.swift
//  EmojiArt
//
//  Created by  andreq on 18.01.2023.
//

import SwiftUI
import Combine

class EmojiArtDocumentStore: ObservableObject
{
    let name: String
    
    func name(for document: EmojiArtDocument) -> String {
        if documentNames[document] == nil {
            documentNames[document] = "Untitled"
        }
        return documentNames[document]!
    }
    
    func setName(_ name: String, for document: EmojiArtDocument) {
        documentNames[document] = name
    }
    
    func getById(_ id: UUID?) -> EmojiArtDocument? {
        documentNames.first(where: {$0.key.id == id})?.key
    }
    
    var documents: [EmojiArtDocument] {
        documentNames.keys.sorted { documentNames[$0]! < documentNames[$1]! }
    }
    
    @discardableResult
    func addDocument(named name: String = "Untitled") -> EmojiArtDocument {
        let newDocument = EmojiArtDocument()
        documentNames[newDocument] = name
        return newDocument
        
    }

    func removeDocument(_ document: EmojiArtDocument) {
        documentNames[document] = nil
    }
    
    @Published private var documentNames = [EmojiArtDocument:String]()
    
    private var autosave: AnyCancellable?
    
    init(named name: String = "Emoji Art") {
        self.name = name
        let defaultsKey = "EmojiArtDocumentStore.\(name)"
        documentNames = Dictionary(fromPropertyList: UserDefaults.standard.object(forKey: defaultsKey))
        autosave = $documentNames.sink { names in
            UserDefaults.standard.set(names.asPropertyList, forKey: defaultsKey)
        }
    }
}

extension Dictionary where Key == EmojiArtDocument, Value == String {
    var asPropertyList: [String:String] {
        var uuidToName = [String:String]()
        for (key, value) in self {
            uuidToName[key.id.uuidString] = value
        }
        return uuidToName
    }
    
    init(fromPropertyList plist: Any?) {
        self.init()
        let uuidToName = plist as? [String:String] ?? [:]
        for uuid in uuidToName.keys {
            self[EmojiArtDocument(id: UUID(uuidString: uuid))] = uuidToName[uuid]
        }
    }
}
