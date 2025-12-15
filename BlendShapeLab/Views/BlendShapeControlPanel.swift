//
//  BlendShapeControlPanel.swift
//  BlendShapeLab
//
//  Created by 橋本一輝 on 2025/12/15.
//

import SwiftUI

struct BlendShapeControlPanel: View {
  @Environment(BlendShapeLabViewModel.self) private var model

  var body: some View {
    @Bindable var model = model
    if let name = model.selectedBlendShapeName {
      VStack(alignment: .leading, spacing: 10) {
        Text(name)
          .font(.system(.body, design: .monospaced))
          .lineLimit(1)

        HStack(spacing: 10) {
          Slider(value: $model.sliderValue, in: 0...1, step: 0.01)
          Text(String(format: "%.2f", model.sliderValue))
            .font(.system(.body, design: .monospaced))
            .frame(width: 56, alignment: .trailing)

          Button("0") { model.sliderValue = 0 }
            .buttonStyle(.bordered)
          Button("1") { model.sliderValue = 1 }
            .buttonStyle(.bordered)
        }

        Toggle("Sweep", isOn: $model.isSweepEnabled)
          .toggleStyle(.switch)

        Text("targets: \(model.selectedTargetsCount)")
          .font(.footnote)
          .foregroundStyle(.secondary)
      }
      .padding(14)
      .background(.ultraThinMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
      .padding(16)
    }
  }
}
