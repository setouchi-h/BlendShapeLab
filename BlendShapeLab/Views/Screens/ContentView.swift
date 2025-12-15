//
//  ContentView.swift
//  BlendShapeLab
//
//  Created by 橋本一輝 on 2025/12/15.
//

import SceneKit
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
  @Environment(BlendShapeLabViewModel.self) private var model
  @State private var isDropTargeted = false

  var body: some View {
    @Bindable var model = model
    NavigationSplitView {
      sidebar
    } detail: {
      detail
    }
    .fileImporter(
      isPresented: $model.isFileImporterPresented,
      allowedContentTypes: BlendShapeLabFileTypes.allowedTypes,
      allowsMultipleSelection: false
    ) { result in
      switch result {
      case .success(let urls):
        if let url = urls.first {
          guard BlendShapeLabFileTypes.isSupportedFileURL(url) else {
            model.errorMessage = "Unsupported file type: \(url.lastPathComponent)"
            return
          }
          model.load(url: url)
        }
      case .failure(let error):
        model.errorMessage = error.localizedDescription
      }
    }
    .alert(
      "Error",
      isPresented: Binding(
        get: { model.errorMessage != nil }, set: { if !$0 { model.errorMessage = nil } })
    ) {
      Button("OK", role: .cancel) {}
    } message: {
      Text(model.errorMessage ?? "")
    }
    .onDrop(of: [UTType.fileURL], isTargeted: $isDropTargeted, perform: handleDrop(providers:))
  }

  private var sidebar: some View {
    @Bindable var model = model
    return VStack(alignment: .leading, spacing: 12) {
      ToolbarView()

      if let url = model.modelURL {
        Text(url.lastPathComponent)
          .font(.footnote)
          .lineLimit(1)
          .foregroundStyle(.secondary)
      } else {
        Text("Drop a USDZ/USD file here or open one.")
          .font(.footnote)
          .foregroundStyle(.secondary)
      }

      Divider()

      TextField("Search", text: $model.searchText)
        .textFieldStyle(.roundedBorder)

      Toggle("Solo", isOn: $model.isSoloMode)

      Divider()

      BlendShapeListView()
    }
    .padding(12)
    .frame(minWidth: 320)
  }

  private var detail: some View {
    ZStack(alignment: .topLeading) {
      SceneView(
        scene: model.scene,
        options: [.allowsCameraControl, .autoenablesDefaultLighting]
      )
      .ignoresSafeArea()

      if model.modelURL == nil {
        WelcomeOverlay()
      }

      BlendShapeControlPanel()
    }
  }

  private func handleDrop(providers: [NSItemProvider]) -> Bool {
    guard
      let provider = providers.first(where: {
        $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier)
      })
    else {
      return false
    }

    provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
      if let error {
        DispatchQueue.main.async {
          model.errorMessage = error.localizedDescription
        }
        return
      }

      let url: URL?
      if let u = item as? URL {
        url = u
      } else if let data = item as? Data {
        url = URL(dataRepresentation: data, relativeTo: nil)
      } else {
        url = nil
      }

      guard let url else { return }
      DispatchQueue.main.async {
        guard BlendShapeLabFileTypes.isSupportedFileURL(url) else {
          model.errorMessage = "Unsupported file type: \(url.lastPathComponent)"
          return
        }
        model.load(url: url)
      }
    }
    return true
  }
}

#Preview {
  ContentView()
    .environment(BlendShapeLabViewModel())
}
