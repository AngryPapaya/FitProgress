//
//  UIView+Extensions.swift
//  FitProgress
//
//  Created by Daniel Castillo Montoya on 07/02/2025.
//

import UIKit

extension UIView {
    func activateConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.required, for: .vertical)
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    static func setShouldTranslateAutoresizingMaskIntoConstraints(_ flag: Bool) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let windows = windowScene.windows
        for window in windows {
            if flag {
                window.makeConstraintsCompatible()
            } else {
                window.translatesAutoresizingMaskIntoConstraints = false
            }
        }
    }
    
    private func makeConstraintsCompatible() {
        self.translatesAutoresizingMaskIntoConstraints = false
        for subview in self.subviews {
            subview.makeConstraintsCompatible()
        }
    }
}
