//
//  FramedPortraitView.swift
//  CoffeeLover
//
//  Created by Danilo Henrique on 19/11/25.
//

import SwiftUI

struct FramedPortraitView: View {
    let imageURL: URL
    
    var body: some View {
        Image("frame")
            .resizable()
            .background {
                AsyncFetchImageView(imageURL: imageURL)
            }
            .background(Color.brown.gradient)
            .aspectRatio(contentMode: .fit)
            .clipShape(.rect(cornerRadius: 20))
            .shadow(radius: 20)
    }
}

#Preview {
    FramedPortraitView(imageURL: URL(string: "https://coffee.alexflipnote.dev/HEXjDfKXLn8_coffee.jpg")!)
        .padding()
}


