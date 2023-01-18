//
//  PalletteChooser.swift
//  EmojiArt
//
//  Created by  andreq on 17.01.2023.
//

import SwiftUI

struct PaletteChooser: View {
    @ObservedObject var document: EmojiArtDocument
    @State private var showPaletteEditor = false
    
    @Binding var choosenPalette: String
    
    var body: some View {
        HStack {
            Stepper(onIncrement: {self.choosenPalette = self.document.palette(after: self.choosenPalette) },
                    onDecrement: {self.choosenPalette = self.document.palette(before: self.choosenPalette) }, label: {EmptyView()})
            Text(self.document.paletteNames[self.choosenPalette] ?? "")
            Image(systemName: "keyboard").imageScale(.large)
                .onTapGesture {
                    self.showPaletteEditor = true
                }
                .sheet(isPresented: $showPaletteEditor) {
                    PaletteEditor(choosenPalette: self.$choosenPalette, isShowing: self.$showPaletteEditor)
                        .environmentObject(self.document)
                        .frame(minWidth: 300, minHeight: 500)
                }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PaletteEditor: View {
    @EnvironmentObject var document: EmojiArtDocument
    
    @Binding var choosenPalette: String
    @Binding var isShowing: Bool
    @State private var paletteName: String = ""
    @State private var emojiToAdd: String = ""
    
    var height: CGFloat {
        CGFloat((choosenPalette.count - 1) / 6) * 70 + 70
    }
    
    let fontSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Palette Editor").font(.headline).padding()
                HStack {
                    Spacer()
                    Button(action: {
                        self.isShowing = false
                    }, label: {
                        Text("Done")
                    }).padding()
                }
            }
            Divider()
            Form {
                Section {
                    TextField("Palette name", text: $paletteName) { began in
                        self.document.renamePalette(self.choosenPalette, to: self.paletteName)
                    }
                    TextField("Add emoji", text: $emojiToAdd) { began in
                        self.choosenPalette = self.document.addEmoji(self.emojiToAdd, toPalette: self.choosenPalette)
                        self.emojiToAdd = ""
                    }
                }
                Section(header: Text("Remove emoji")) {
                    Grid (choosenPalette.map{String($0)}, id: \.self) { emoji in
                        Text(emoji).font(Font.system(size: self.fontSize))
                            .onTapGesture {
                                self.choosenPalette = self.document.removeEmoji(emoji, fromPalette: self.choosenPalette)
                            }
                    }
                    .frame(height: self.height)
                }
            }
        }
        .onAppear {self.paletteName = self.document.paletteNames[self.choosenPalette] ?? ""}
    }
}

struct PalleteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser(document: EmojiArtDocument(), choosenPalette: Binding.constant(""))
    }
}
