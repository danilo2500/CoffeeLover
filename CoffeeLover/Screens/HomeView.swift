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
    @State var textVisibility = Double.zero
    @State var reachThresshold = false
    
    var body: some View {
        VStack {
            Text("Discover ☕")
                .font(.largeTitle.bold())
            Spacer()
            
            if let imageURL = viewModel.coffeeImageURL {
                Image("frame")
                    .resizable()
                    .background {
                        AsyncFetchImageView(imageURL: imageURL)
                    }
                    .background(.ultraThinMaterial)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(.rect(cornerRadius: 20))
                    .shadow(radius: 20)
                    .offset(offset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                offset = gesture.translation
                                angle = gesture.translation.width / 15
                                textVisibility = gesture.translation.width / 200
                                withAnimation(.bouncy) {
                                    reachThresshold = abs(textVisibility) > 1
                                }
                            }
                            .onEnded { gesture in
                                if reachThresshold {
                                    let liked = textVisibility > 0
                                    offset = CGSize(width: 600 * textVisibility, height: gesture.translation.height)
                                    
                                    Task { @MainActor in
                                        try await Task.sleep(for: .seconds(1))
                                        offset = .zero
                                        angle = .zero
                                        textVisibility = .zero
                                    }
                                    
                                    viewModel.handleSwipe(liked: liked, modelContext: modelContext)
                                } else {
                                    offset = .zero
                                    angle = .zero
                                    textVisibility = .zero
                                }
                            }
                    )
                    .rotationEffect(.init(degrees: angle))
                    .animation(.spring, value: offset)
                    .animation(.spring, value: angle)
                    .transition(.blurReplace)
                    .padding()
            } else {
                ProgressView()
                    .controlSize(.extraLarge)
            }
            
            Spacer()
            
            Divider()
            Text("Swipe left to dislike, right to like!")
        }
        .animation(.bouncy, value: viewModel.coffeeImageURL)
        .overlay {
            let like = textVisibility > 0
            let color: Color = like ? .green : .red
            Text(like ? "Like" : "Dislike")
                .font(.largeTitle.bold())
                .padding()
                .background(color.gradient, in: .capsule)
                .opacity(min(1, abs(textVisibility)))
                .scaleEffect(min(2, abs(textVisibility)))
                .shadow(color:reachThresshold ? color : .clear, radius: 30)
                .scaleEffect(reachThresshold ? 1.5 : 1)
                .rotationEffect(.degrees(reachThresshold ? 20 : .zero))
                
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
