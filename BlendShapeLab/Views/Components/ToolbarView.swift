//
//  ToolbarView.swift
//  BlendShapeLab
//
//  Created by 橋本一輝 on 2025/12/15.
//

import SwiftUI

struct ToolbarView: View {
  @Environment(BlendShapeLabViewModel.self) private var model

  var body: some View {
    HStack(spacing: 8) {
      Button("Open…") { model.isFileImporterPresented = true }
        .keyboardShortcut("o", modifiers: [.command])

      Button("Reload") { model.reload() }
        .disabled(model.modelURL == nil)

      Button("Clear") { model.clearModel() }
        .disabled(model.modelURL == nil)

      Button("Reset All") { model.resetAllBlendWeights() }
        .disabled(!model.hasAnyBlendShapes)

      Spacer()
    }
  }
}
