//
//  HomeView.swift
//  CoffeeLover
//
//  Created by Danilo Henrique on 19/11/25.
//

import SwiftUI
import SwiftData

struct FeedView: View {
    @StateObject var viewModel = FeedViewModel()
    @Environment(\.modelContext) private var modelContext
    
    @State var offset = CGSize.zero
    @State var angle = Double.zero
    @State var swipeIntensity = Double.zero
    @State var reachThresshold = false
    
    private func resetAnimationState() {
        offset = .zero
        angle = .zero
        swipeIntensity = .zero
    }
    
    var body: some View {
        VStack {
            Text("Discover ☕")
                .font(.largeTitle.bold())
            Spacer()
            
            ZStack {
                if let nextImageURL = viewModel.nextCoffeeImageURL {
                    FramedPortraitView(imageURL: nextImageURL)
                        .scaleEffect(min(1, abs(swipeIntensity)))
                        .opacity(abs(swipeIntensity))
                }
                if let imageURL = viewModel.coffeeImageURL {
                    FramedPortraitView(imageURL: imageURL)
                        .offset(offset)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    offset = gesture.translation
                                    angle = gesture.translation.width / 15
                                    swipeIntensity = gesture.translation.width / 200
                                    withAnimation(.bouncy) {
                                        reachThresshold = abs(swipeIntensity) > 1
                                    }
                                }
                                .onEnded { gesture in
                                    if reachThresshold {
                                        let liked = swipeIntensity > 0
                                        withAnimation {
                                            offset = CGSize(width: 500 * swipeIntensity, height: gesture.translation.height)
                                        }
                                        Task { @MainActor in
                                            try await Task.sleep(for: .seconds(1.5))
                                            viewModel.handleSwipe(liked: liked, modelContext: modelContext)
                                            resetAnimationState()
                                        }
                                    } else {
                                        withAnimation(.bouncy) {
                                            resetAnimationState()
                                        }
                                    }
                                }
                        )
                        .rotationEffect(.init(degrees: angle))
                        
                } else {
                    ProgressView()
                        .controlSize(.extraLarge)
                }
            }
            .padding()
            
            Spacer()
            
            Divider()
            Text("Swipe left to dislike, right to like!")
        }
        .padding()
        .overlay {
            SwipeFeedbackOverlay(textVisibility: swipeIntensity, reachThreshold: reachThresshold)
                .sensoryFeedback(.levelChange, trigger: reachThresshold)
        }
        .alert("Error Loading Coffee", isPresented: $viewModel.showError) {
            Button("Retry") {
                viewModel.fetchRandomCoffee()
            }
        }
        .fontDesign(.serif)
        .foregroundStyle(.white)
        .background {
            BackgroundView()
        }
        .task {
            viewModel.fetchRandomCoffee()
        }
    }
}

#Preview {
    FeedView()
}
