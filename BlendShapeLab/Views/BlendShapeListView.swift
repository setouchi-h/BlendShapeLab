//
//  BlendShapeListView.swift
//  BlendShapeLab
//
//  Created by 橋本一輝 on 2025/12/15.
//

import SwiftUI

struct BlendShapeListView: View {
  @Environment(BlendShapeLabViewModel.self) private var model

  var body: some View {
    @Bindable var model = model
    List(model.filteredBlendShapeNames, id: \.self, selection: $model.selectedBlendShapeName) {
      name in
      Text(name)
        .font(.system(.body, design: .monospaced))
    }
  }
}
