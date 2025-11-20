//
//  SwipeFeedbackOverlay.swift
//  CoffeeLover
//
//  Created by Danilo Henrique on 19/11/25.
//

import SwiftUI

struct SwipeFeedbackOverlay: View {
    let textVisibility: Double
    let reachThreshold: Bool
    
    var body: some View {
        let like = textVisibility > 0
        let color: Color = like ? .green : .red
        
        Text(like ? "Like" : "Dislike")
            .font(.largeTitle.bold())
            .padding()
            .background(color.gradient, in: .capsule)
            .opacity(min(1, abs(textVisibility)))
            .scaleEffect(min(2, abs(textVisibility)))
            .shadow(color: reachThreshold ? color : .clear, radius: 30)
            .scaleEffect(reachThreshold ? 1.5 : 1)
            .rotationEffect(.degrees(reachThreshold ? 20 : .zero))
            .transition(.asymmetric(insertion: .identity, removal: .scale))
            .animation(.default, value: textVisibility)
            .accessibilityIdentifier(like ? "swipeFeedbackLike" : "swipeFeedbackDislike")
    }
}

#Preview {
    SwipeFeedbackOverlay(textVisibility: 1.5, reachThreshold: true)
}


