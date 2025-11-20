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
        .overlay {
            SwipeFeedbackOverlay(textVisibility: swipeIntensity, reachThreshold: reachThresshold)
        }
        
        .fontDesign(.serif)
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

import Combine
import SwiftUI
import SwiftData

@Observable class FeedViewModel: ObservableObject {
    
    var coffeeImageURL: URL?
    var nextCoffeeImageURL: URL?
    
    private let restService = RESTService<CoffeeAPI>()
    
    func fetchRandomCoffee() {
        restService.request(.getRandom) { [weak self] (result: Result<CoffeeResponse, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.coffeeImageURL = response.file
                self.fetchNextCoffee()
            case .failure:
                break
            }
        }
    }
    
    func fetchNextCoffee() {
        restService.request(.getRandom) { [weak self] (result: Result<CoffeeResponse, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.nextCoffeeImageURL = response.file
            case .failure:
                break
            }
        }
    }
    
    func handleSwipe(liked: Bool, modelContext: ModelContext) {
        if liked, let imageURL = coffeeImageURL {
            let favorite = FavoriteCoffee(imageURL: imageURL)
            modelContext.insert(favorite)
        }
        moveToNext()
    }
    
    private func moveToNext() {
        coffeeImageURL = nextCoffeeImageURL
        nextCoffeeImageURL = nil
        fetchNextCoffee()
    }
}
