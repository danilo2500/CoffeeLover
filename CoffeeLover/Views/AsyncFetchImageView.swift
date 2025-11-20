//
//  CoffeeImageView.swift
//  CoffeeLover
//
//  Created by Danilo Henrique on 20/11/25.
//

import SwiftUI
import Kingfisher

struct AsyncFetchImageView: View {
    let imageURL: URL
    
    @State var errorFetch = false
    @State var retryTrigger = 0
    
    var body: some View {
        KFImage(imageURL)
            .placeholder {
                ProgressView()
                    .controlSize(.extraLarge)
            }
            .onSuccess { _ in
                errorFetch = false
            }
            .onFailure { error in
                errorFetch = true
            }
            .aspectRatio(contentMode: .fill)
            .id(retryTrigger)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                if errorFetch {
                    Image("sad-coffee")
                    Button("Retry", systemImage: "photo.badge.exclamationmark.fill") {
                        errorFetch = false
                        retryTrigger += 1
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                }
            }
            
    }
}

#Preview {
    AsyncFetchImageView(imageURL: FavoriteCoffee.sample.imageURL)
        .scaledToFit()
}
