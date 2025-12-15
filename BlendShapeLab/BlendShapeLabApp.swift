//
//  BlendShapeLabApp.swift
//  BlendShapeLab
//
//  Created by 橋本一輝 on 2025/12/15.
//

import SwiftUI

@main
struct BlendShapeLabApp: App {
  @State private var model = BlendShapeLabViewModel()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(model)
    }
    .commands {
      CommandGroup(replacing: .newItem) {
        Button("Open…") {
          model.isFileImporterPresented = true
        }
        .keyboardShortcut("o", modifiers: [.command])
      }
    }
  }
}
