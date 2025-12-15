//
//  BlendShapeLabViewModel.swift
//  BlendShapeLab
//
//  Created by 橋本一輝 on 2025/12/15.
//

import Foundation
import SceneKit

@MainActor
final class BlendShapeLabViewModel: ObservableObject {
  @Published var scene: SCNScene = SCNScene()
  @Published var modelURL: URL?
  @Published var errorMessage: String?

  @Published var isFileImporterPresented = false
  @Published var searchText: String = ""

  @Published var isSoloMode: Bool = true

  @Published var isSweepEnabled: Bool = false {
    didSet {
      if oldValue != isSweepEnabled {
        sweepStateDidChange()
      }
    }
  }

  @Published var selectedBlendShapeName: String? {
    didSet {
      guard oldValue != selectedBlendShapeName else { return }
      sliderValue = 0
      if isSoloMode {
        resetAllBlendWeights()
      }
    }
  }

  @Published var sliderValue: Double = 0 {
    didSet {
      applySelectedBlendShapeWeight(Float(sliderValue))
    }
  }

  private var bindingsByName: [String: [(SCNMorpher, Int)]] = [:]
  private var morphers: [SCNMorpher] = []

  private var sweepTask: Task<Void, Never>?

  var hasAnyBlendShapes: Bool { !bindingsByName.isEmpty }

  var filteredBlendShapeNames: [String] {
    let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    let all = bindingsByName.keys.sorted()
    guard !trimmed.isEmpty else { return all }
    return all.filter { $0.localizedCaseInsensitiveContains(trimmed) }
  }

  var selectedTargetsCount: Int {
    guard let name = selectedBlendShapeName else { return 0 }
    return bindingsByName[name]?.count ?? 0
  }

  func load(url: URL) {
    errorMessage = nil
    isSweepEnabled = false
    let didStartAccess = url.startAccessingSecurityScopedResource()
    defer {
      if didStartAccess {
        url.stopAccessingSecurityScopedResource()
      }
    }

    do {
      let loaded = try SCNScene(url: url, options: nil)
      configureSceneIfNeeded(loaded)
      rebuildBindings(for: loaded)
      scene = loaded
      modelURL = url

      // Default selection
      selectedBlendShapeName = bindingsByName.keys.sorted().first
      sliderValue = 0
    } catch {
      errorMessage = error.localizedDescription
    }
  }

  func reload() {
    guard let modelURL else { return }
    load(url: modelURL)
  }

  func resetAllBlendWeights() {
    for morpher in morphers {
      for i in morpher.weights.indices {
        morpher.setWeight(0, forTargetAt: i)
      }
    }
  }

  private func sweepStateDidChange() {
    sweepTask?.cancel()
    sweepTask = nil

    guard isSweepEnabled else { return }
    guard selectedBlendShapeName != nil else { return }

    sweepTask = Task { @MainActor in
      var direction: Double = 1
      while !Task.isCancelled {
        let delta = 0.02
        var next = sliderValue + direction * delta

        if next >= 1 {
          next = 1
          direction = -1
        } else if next <= 0 {
          next = 0
          direction = 1
        }

        sliderValue = next
        try? await Task.sleep(nanoseconds: 16_000_000)
      }
    }
  }

  private func applySelectedBlendShapeWeight(_ value: Float) {
    guard let name = selectedBlendShapeName else { return }
    if isSoloMode {
      resetAllBlendWeights()
    }
    setBlendShapeWeight(name: name, value: value)
  }

  private func setBlendShapeWeight(name: String, value: Float) {
    guard let pairs = bindingsByName[name] else { return }
    for (morpher, idx) in pairs {
      morpher.setWeight(CGFloat(value), forTargetAt: idx)
    }
  }

  private func rebuildBindings(for scene: SCNScene) {
    var map: [String: [(SCNMorpher, Int)]] = [:]
    var allMorphers: [SCNMorpher] = []

    scene.rootNode.enumerateChildNodes { node, _ in
      guard let morpher = node.morpher else { return }
      allMorphers.append(morpher)

      for (idx, target) in morpher.targets.enumerated() {
        let name = target.name ?? "target_\(idx)"
        map[name, default: []].append((morpher, idx))
      }
    }

    bindingsByName = map
    morphers = allMorphers
  }

  private func configureSceneIfNeeded(_ scene: SCNScene) {
    // If the asset does not include a camera, add a simple default one.
    let hasCamera = scene.rootNode.childNodes.contains { $0.camera != nil }
    if !hasCamera {
      let cameraNode = SCNNode()
      cameraNode.name = "BlendShapeLabCamera"
      cameraNode.camera = SCNCamera()
      cameraNode.camera?.zFar = 10_000

      // Rough framing based on bounds.
      let bounds = scene.rootNode.boundingBox
      let size = SCNVector3(
        bounds.max.x - bounds.min.x,
        bounds.max.y - bounds.min.y,
        bounds.max.z - bounds.min.z
      )
      let radius = max(size.x, max(size.y, size.z))
      cameraNode.position = SCNVector3(0, max(0.2, size.y * 0.5), max(1.0, radius * 2.2))
      scene.rootNode.addChildNode(cameraNode)
    }

    // Light (helps when the asset has no lights and default lighting is disabled).
    let hasLight = scene.rootNode.childNodes.contains { $0.light != nil }
    if !hasLight {
      let lightNode = SCNNode()
      lightNode.light = SCNLight()
      lightNode.light?.type = .directional
      lightNode.light?.intensity = 1000
      lightNode.eulerAngles = SCNVector3(-0.6, 0.7, 0)
      scene.rootNode.addChildNode(lightNode)

      let ambientNode = SCNNode()
      ambientNode.light = SCNLight()
      ambientNode.light?.type = .ambient
      ambientNode.light?.intensity = 300
      scene.rootNode.addChildNode(ambientNode)
    }
  }
}
