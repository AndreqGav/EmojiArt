//
//  WelcomeView.swift
//  EmojiArt
//
//  Created by  andreq on 19.01.2023.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var store: EmojiArtDocumentStore
    @Binding var selectedDocId: UUID?
    
    var body: some View {
        VStack {
            Text("Create or select document")
                .font(.largeTitle)
            Spacer()
            Grid (self.documentsInfo(), id: \.self.0) { documentInfo in
                Group {
                    if documentInfo.idx == 0 {
                        VStack {
                            Text("Create New")
                            Image(systemName: "plus").imageScale(.large)
                        }
                    } else {
                        Text(store.name(for: documentInfo.document!))
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .stroke(.gray, lineWidth: 4)
                        .frame(width: 200, height: 200)
                }
                .gesture(TapGesture()
                    .onEnded {
                        if documentInfo.document != nil {
                            selectedDocId = documentInfo.document?.id
                        } else {
                            selectedDocId = self.store.addDocument().id
                        }
                    })
            }
        }
    }
    
    private func documentsInfo() -> [(idx: Int, document: EmojiArtDocument?)] {
        var info: [(idx: Int, document: EmojiArtDocument?)] = store.documents.indices.map {($0 + 1, store.documents[safe: $0])}
        info.insert((0, nil), at: 0)
        return info
    }
}

extension Collection where Indices.Iterator.Element == Index {
    public subscript(safe index: Index) -> Iterator.Element? {
        return (startIndex <= index && index < endIndex) ? self[index] : nil
    }
}
