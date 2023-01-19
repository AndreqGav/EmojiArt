//
//  EmojiArtDocumentChooser.swift
//  EmojiArt
//
//  Created by  andreq on 18.01.2023.
//

import SwiftUI

struct EmojiArtDOcumentChooser: View {
    @EnvironmentObject var store: EmojiArtDocumentStore
    @State private var editMode: EditMode = .inactive
    @State private var selectedDocId: UUID? = nil
    
    var body: some View {
        NavigationView {
            List() {
                ForEach(store.documents) { document in
                    NavigationLink(destination: EmojiArtDocumentsView(document: document)
                        .navigationBarTitle(self.store.name(for: document))
                        .toolbar {
                            Button(action: {
                                selectedDocId = self.store.addDocument().id
                            }, label: {
                                Image(systemName: "plus")
                            })
                        }, tag: document.id,selection: $selectedDocId) {
                            EditableText(self.store.name(for: document), isEditing: self.editMode.isEditing) { name in
                                store.setName(name, for: document)
                            }
                        }
                }
                .onDelete { indexSet in
                    indexSet.map {self.store.documents[$0]}
                        .forEach {document in
                            self.store.removeDocument(document)
                            if selectedDocId == document.id {
                                selectedDocId = nil
                            }
                        }

                }
            }
            .navigationBarTitle(self.store.name)
            .navigationBarItems(leading:
                                    Button(action: {
                self.store.addDocument()
            }, label: {
                Image(systemName: "plus").imageScale(.large)
            }), trailing: EditButton()
            )
            .environment(\.editMode, $editMode)
            
            if selectedDocId == nil {
                WelcomeView(selectedDocId: $selectedDocId)
            }
        }
    }
}
