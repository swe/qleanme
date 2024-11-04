//
//  HideTabBarKey.swift
//  QleanMe
//
//  Created by weirdnameofadmin on 2024-10-29.
//



import SwiftUI

private struct HideTabBarKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var hideTabBar: Bool {
        get { self[HideTabBarKey.self] }
        set { self[HideTabBarKey.self] = newValue }
    }
}
