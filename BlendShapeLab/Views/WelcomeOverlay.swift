//
//  WelcomeOverlay.swift
//  BlendShapeLab
//
//  Created by 橋本一輝 on 2025/12/15.
//

import SwiftUI

struct WelcomeOverlay: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("BlendShapeLab")
        .font(.title2.bold())
      Text("Open a USDZ/USD file, then select a blendshape and move the slider.")
        .foregroundStyle(.secondary)
    }
    .padding(16)
    .background(.ultraThinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    .padding(16)
  }
}
