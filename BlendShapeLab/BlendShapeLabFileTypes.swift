//
//  BlendShapeLabFileTypes.swift
//  BlendShapeLab
//
//  Created by 橋本一輝 on 2025/12/15.
//

import Foundation
import UniformTypeIdentifiers

enum BlendShapeLabFileTypes {
  static let allowedExtensions: Set<String> = ["usdz", "usd", "usda", "usdc"]

  static let allowedTypes: [UTType] = [
    UTType(filenameExtension: "usdz"),
    UTType(filenameExtension: "usd"),
    UTType(filenameExtension: "usda"),
    UTType(filenameExtension: "usdc"),
  ].compactMap { $0 }

  static func isSupportedFileURL(_ url: URL) -> Bool {
    allowedExtensions.contains(url.pathExtension.lowercased())
  }
}
