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
      HStack(spacing: 8) {
        Button("Open…") { model.isFileImporterPresented = true }
          .keyboardShortcut("o", modifiers: [.command])

        Button("Reload") { model.reload() }
          .disabled(model.modelURL == nil)

        Button("Reset All") { model.resetAllBlendWeights() }
          .disabled(!model.hasAnyBlendShapes)

        Spacer()
      }

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

      List(model.filteredBlendShapeNames, id: \.self, selection: $model.selectedBlendShapeName) {
        name in
        Text(name)
          .font(.system(.body, design: .monospaced))
      }
    }
    .padding(12)
    .frame(minWidth: 320)
  }

  private var detail: some View {
    @Bindable var model = model
    return ZStack(alignment: .topLeading) {
      SceneView(
        scene: model.scene,
        options: [.allowsCameraControl, .autoenablesDefaultLighting]
      )
      .ignoresSafeArea()

      if model.modelURL == nil {
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
