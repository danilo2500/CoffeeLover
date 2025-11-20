//
//  BackgroundView.swift
//  CoffeeLover
//
//  Created by Danilo Henrique on 19/11/25.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ContainerRelativeShape()
            .fill(Color.palleteSecondary.gradient)
            .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView()
}


