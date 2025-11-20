//
//  HomeView.swift
//  CoffeeLover
//
//  Created by Danilo Henrique on 19/11/25.
//

import SwiftUI

struct FeedView: View {
    @StateObject var viewModel = FeedViewModel()
    
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
                Color.black
                    .overlay {
                        CoffeeImageView(imageURL: imageURL)
                    }
                    .aspectRatio(contentMode: .fit)
                    .border(.brown.mix(with: .black, by: 0.7), width: 20)
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
                    .padding()
            } else {
                ProgressView()
                    .controlSize(.extraLarge)
            }
            
            Spacer()
        }
        .overlay {
            let like = textVisibility > 0
            let color: Color = like ? .green : .red
            Text(like ? "Like" : "Dislike")
                .font(.largeTitle.bold())
                .padding()
                .background(color, in: .capsule)
                .opacity(min(1, abs(textVisibility)))
                .scaleEffect(min(1, abs(textVisibility)))
                .shadow(color:reachThresshold ? color : .clear, radius: 30)
                .scaleEffect(reachThresshold ? 1.5 : 1)
                .rotationEffect(.degrees(reachThresshold ? 20 : .zero))
                
        }
        .background {
            BackgroundView()
        }
        .task {
            viewModel.fetchRandomCoffee()
        }
    }
}

import Combine

struct CoffeeImageView: View {
    let imageURL: URL
    
    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .controlSize(.extraLarge)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                Image(systemName: "photo.badge.exclamationmark.fill")
            @unknown default:
                EmptyView()
            }
        }
    }
}

#Preview {
    FeedView()
}

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
    
    func moveToNext() {
        coffeeImageURL = nextCoffeeImageURL
        nextCoffeeImageURL = nil
        fetchNextCoffee()
    }
}
