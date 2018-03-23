//
//  SupportComponents.swift
//  JHKVideoPlayer
//
//  This file provided typical components that used in JHKVideoPlayer.
//
//  Created by LuisGin on 2017/6/20.
//

import UIKit

/// Class LockAction is a pair of AttributedString and ButtonResponse. These gotta be used on player lock, providing extra information display on locked player screen. Tips: Since NSAttributedStringKey is modified in swift4, class functions could only called in swift4 project.
open class LockAction {
    /// Display attributed string
    var title: NSAttributedString
    /// Response handler
    var handler: (() -> Void)?

    init(title: String, attributes: [NSAttributedStringKey: Any] = [:]) {
        self.title = NSAttributedString(string: title, attributes: attributes)
    }

    open class func action(title: String, attributes: [NSAttributedStringKey: Any] = [:], handler: (()->(Void))?) -> LockAction {
        let action = LockAction(title: title, attributes: attributes)
        action.handler = handler
        return action
    }
}

extension UIImage {
    /// Extension for determined specific Image resources in the bundle of CocoaPods Component
    ///
    /// - Parameter name: (String) - image name in bundle
    /// - Parameter bundle: (String) - bundle name in specific
    /// - Returns: image if exist
    /// - Warning: for internal use only
    /// - SeeAlso: `imageInBundle()`
    internal class func imageInBundle(named name: String, from bundle: String? = nil) -> UIImage? {

        if let bundleUrl = Bundle(for: JHKVideoPlayer.self).url(forResource: "JHKVideoPlayer", withExtension: "bundle") {
            let bundle = Bundle(url: bundleUrl)!
            let imageNew = UIImage(named: name, in: bundle, compatibleWith: nil)

            return imageNew
        }

        return nil
    }
}

extension UITextView {
    /// Extension for textview to make attributes fits container.
    func contentSizeToFit() {
        if self.attributedText.length > 0 {
            let contentSize: CGSize = self.contentSize
            var offset: UIEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
            
            if contentSize.height <= self.frame.size.height {
                let offsetY: CGFloat = (self.frame.size.height - contentSize.height) / 2
                offset = UIEdgeInsets(top: offsetY, left: 0, bottom: 0, right: 0)
            }
            self.contentInset = offset
        }
    }
}
