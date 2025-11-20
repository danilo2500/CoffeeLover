//
//  HomeView.swift
//  CoffeeLover
//
//  Created by Danilo Henrique on 19/11/25.
//

import SwiftUI

struct FeedView: View {
    var body: some View {
        VStack {
            Text("Find your favorite")
            Spacer()
            Rectangle()
                .aspectRatio(contentMode: .fit)
                .padding()
            Spacer()
                .onDrag(<#T##data: () -> NSItemProvider##() -> NSItemProvider#>)
                
        }
        .background {
            BackgroundView()
        }
    }
}

#Preview {
    FeedView()
}
