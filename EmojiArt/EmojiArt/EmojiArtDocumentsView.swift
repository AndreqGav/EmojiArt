//
//  ContentView.swift
//  EmojiArt
//
//  Created by Виолетточка on 16.01.2023.
//

import SwiftUI

struct EmojiArtDocumentsView: View {
    @ObservedObject var document: EmojiArtDocument
    
    @State private var chooserPalette: String = ""
    @State private var explainBackgroundPaste = false
    @State private var confirmBAckgroundPaste = false
    
    var backgroundImage: UIImage?
    
    init(document: EmojiArtDocument) {
        self.document = document
        _chooserPalette = State(wrappedValue: self.document.defaultPalette)
    }
    
    var body: some View {
        VStack {
            HStack {
                PaletteChooser(document: document, choosenPalette: $chooserPalette)
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(chooserPalette.map{String($0)}, id: \.self) { emoji in
                            Text(emoji)
                                .font(Font.system(size: self.defaultEmojiSize))
                                .onDrag {
                                    NSItemProvider(object: emoji as NSString)
                                }
                        }
                    }
                }
            }
            
            GeometryReader { geometry in
                ZStack {
                    Color.white.overlay(
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(self.zoomScale)
                            .offset(self.panOffset)
                    )
                    .gesture(doubleTapToZoom(in: geometry.size))
                    
                    if self.isLoading {
                        Image(systemName: "hourglass").imageScale(.large).spinning()
                    } else {
                        ForEach(self.document.emojis) { emoji in
                            Text(emoji.text)
                                .font(animatableWithSize: emoji.fontSize * zoomScale)
                                .position(self.position(for: emoji, in: geometry.size))
                                .gesture(dragEmojiGesture(emoji: emoji, geometry: geometry))
                                .gesture(zoomEmojiGesture(emoji: emoji))
                        }
                    }
                }
                
                .clipped()
                .gesture(panGesture())
                .gesture(zoomGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onReceive(self.document.$backgroundImage) { (image) in
                    zoomToFit(image, in: geometry.size)
                }
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = geometry.convert(location, from: .local)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - panOffset.width, y: location.y - panOffset.height)
                    location = CGPoint(x: location.x / zoomScale, y: location.y / zoomScale)
                    return drop(providers: providers, at: location)
                }
                .navigationBarItems(trailing: Button(action: {
                    if let url = UIPasteboard.general.url, url != self.document.backgroundUrl {
                            self.confirmBAckgroundPaste = true
                        } else {
                            self.explainBackgroundPaste = true
                        }
                    }, label: {
                        Image(systemName: "doc.on.clipboard").imageScale(.large)
                            .alert(isPresented: $explainBackgroundPaste) { () -> Alert in
                                return Alert(title: Text("Paste Background"), message: Text("Copy the URL of an image to the clip board and touch this button to make it the background of your document."),
                                             dismissButton: .default(Text("Ok")))
                            }
                    })
                )
            }
            .alert(isPresented: $confirmBAckgroundPaste) {
                Alert(title: Text("Paste Background"), message: Text("Replace your background with \(UIPasteboard.general.url?.absoluteString ?? "nothing")?.*"), primaryButton: .default(Text("Ok")) {
                    self.document.backgroundUrl = UIPasteboard.general.url
                }, secondaryButton: .cancel())
            }
        }
    }
    
    
    var isLoading: Bool {
        document.backgroundUrl != nil && document.backgroundImage == nil
    }
    
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    @State private var isEmojiGesture = false
    
    private var zoomScale: CGFloat {
        self.document.steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                if !isEmojiGesture {
                    gestureZoomScale = latestGestureScale
                }
            }
            .onEnded { finalGestureScale in
                self.document.steadyStateZoomScale *= finalGestureScale
            }
    }
    
    @State private var startScaleValue: Int = 0
    private func zoomEmojiGesture(emoji: EmojiArt.Emoji) -> some Gesture {
        MagnificationGesture()
            .onChanged { magnificationGestureValue in
                if !isEmojiGesture {
                    startScaleValue = emoji.size
                }
                isEmojiGesture = true
                let scaleFactor = CGFloat(startScaleValue) * magnificationGestureValue
                print(magnificationGestureValue)
                print(magnificationGestureValue.magnitude)
                print("      ")
  
                document.scaleEmoji(emoji, at: scaleFactor)
            }
            .onEnded { finalGestureScale in
                isEmojiGesture = false
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image,
           image.size.width > 0,
           image.size.height > 0,
           size.height > 0,
           size.width > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.document.steadyStatePanOffset = .zero
            self.document.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (self.document.steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { (latestDragGestureValue, gesturePanOffset, transaction) in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragState in
                self.document.steadyStatePanOffset = self.document.steadyStatePanOffset + (finalDragState.translation / zoomScale)
            }
    }
    
    private func dragEmojiGesture(emoji: EmojiArt.Emoji, geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { dragValue in
                let dragLocation = dragValue.startLocation
                var location = geometry.convert(dragLocation, from: .local)
                location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                location = CGPoint(x: location.x - panOffset.width, y: location.y - panOffset.height)
                location = CGPoint(x: location.x / zoomScale, y: location.y / zoomScale)
                document.moveEmoji(emoji, to: location + dragValue.translation / zoomScale)
            }
    }
    
    private func font(for emoji: EmojiArt.Emoji) -> Font {
        Font.system(size: emoji.fontSize)
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        location = CGPoint(x: location.x + size.width / 2, y: location.y + size.height / 2 )
        return location
    }
    
    private let defaultEmojiSize: CGFloat = 40
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.document.backgroundUrl = url
        }
        
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        
        return found
    }

}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
