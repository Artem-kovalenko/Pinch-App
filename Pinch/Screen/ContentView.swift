//
//  ContentView.swift
//  Pinch
//
//  Created by Артём Коваленко on 26.07.2023.
//

import SwiftUI

struct ContentView: View {
    // MARK: - PROPERTY
    @State private var isAnimating: Bool = false
    @State private var imageScale: CGFloat = 1
    //CGSize value can be positive or negative ()
    @State private var imageOffset: CGSize = CGSize(width: 0, height: 0) // .zero
    // drawer offset state
    @State private var isDrawerOpen: Bool = false
    
    let pages: [Page] = pagesData
    @State private var pageIndex: Int = 0
    
    // MARK: - FUNCTION
    func resetImageState() -> Void {
        return withAnimation(.spring()) {
            imageScale = 1
            // .zero = CGSize(width: 0, height: 0)
            imageOffset = .zero
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // to fill in all the ZStack space
                // for overlay to put icon on the top of ZStack
                // without it, icon will be on the top of image
                Color.clear
                
                // MARK: - PAGE IMAGE
                Image(pages[pageIndex].imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                    .padding()
                    .shadow(color: .black.opacity(0.2), radius: 12, x: 2, y: 2)
                    .opacity(isAnimating ? 1 : 0.1)
                    .offset(imageOffset)
                    .animation(.linear(duration: 1), value: isAnimating)
                    .scaleEffect(imageScale)
                // MARK: - 1. TAP GESTURE
                    .onTapGesture(count: 2) {
                        if imageScale == 1 {
                            withAnimation(.spring()) {
                                imageScale = 5
                            }
                        } else {
                            // CASE large image
                            // scale to original
                            // place image to original position
                            resetImageState()
                        }
                    }
                // MARK: - 2. DRAG GESTURE
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                withAnimation(.linear(duration: 1)) {
                                    imageOffset = gesture.translation
                                }
                                // SAME AS BELOW
                                //imageOffset = CGSize(width: gesture.translation.width, height: gesture.translation.height)
                            }
                            .onEnded({ _ in
                                if imageScale <= 1 {
                                    resetImageState()
                                }
                            })
                    )
                // MARK: - 3. MAGNIFICATION GESTURE
                    .gesture(
                        MagnificationGesture()
                                    // gesture contains scale value
                            .onChanged({ gesture in
                                withAnimation (.linear(duration: 1)) {
                                    if imageScale >= 1 && imageScale <= 5 {
                                        imageScale = gesture
                                    }
                                }
                            })
                            .onEnded({ _ in
                                if imageScale > 5 {
                                    imageScale = 5
                                } else if imageScale < 1 {
                                    resetImageState()
                                }
                            })
                            
                    )
            } //: ZSTACK
            .navigationTitle("Pinch & Zoom")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: {
                isAnimating = true
            })
            // MARK: - Info Panel
            .overlay (alignment: .top) {
                InfoPanelView(scale: imageScale, offset: imageOffset)
                    .padding(.horizontal)
                    .padding(.top, 30)
            }
            // MARK: - CONTROLS
            .overlay (alignment: .bottom) {
                HStack {
                    // SCALE DOWN
                    Button {
                        withAnimation {
                            // scale down only if scale > 1
                            if imageScale > 1 {
                                imageScale -= 1
                                
                                // reset position when scale is 1
                                if imageScale == 1 {
                                    resetImageState()
                                }
                            }
                        }
                    } label: {
                        ControlImageView(icon: "minus.magnifyingglass")
                    }
                    
                    // RESET
                    Button {
                        resetImageState()
                    } label: {
                        ControlImageView(icon: "arrow.up.left.and.down.right.magnifyingglass")
                    }
                    
                    // SCALE UP
                    Button {
                        withAnimation {
                            if imageScale < 5 {
                                imageScale += 1
                            }
                        }
                    } label: {
                        ControlImageView(icon: "plus.magnifyingglass")
                    }
                } //: CONTROLS
                .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .opacity(isAnimating ? 1 : 0)
            }
            .padding(.bottom, 30)
            // MARK: - DRAWER
            .overlay (alignment: .topTrailing) {
                HStack {
                    // MARK: - DRAWER HANDLE
                    Image(systemName: isDrawerOpen ? "chevron.compact.right" : "chevron.compact.left")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .padding(8)
                        .foregroundStyle(.secondary)
                        .onTapGesture {
                            withAnimation (.easeOut(duration: 0.5)) {
                                isDrawerOpen.toggle()
                            }
                        }
                    
                    // MARK: - THUMBNAILS
                    ForEach(pages) { item in
                        Image(item.thumbnailName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                            .opacity(isDrawerOpen ? 1 : 0)
                            .animation(.easeOut(duration: 0.5), value: isDrawerOpen)
                            .onTapGesture {
                                withAnimation {
                                    pageIndex = item.id
                                }
                            }
                    }
                    Spacer()
                } //: DRAWER
                .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .opacity(isAnimating ? 1 : 0)
                .frame(width: 260)
                .padding(.top, UIScreen.main.bounds.height / 12)
                .offset(x: isDrawerOpen ? 20 : 220)
            }
        } //: NAVIGATION
        .navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
