//
//  ATSVGShapeLayer.swift
//
//  Created by CaiSanze on 2020/11/2.
//  Copyright © 2020 atlasv. All rights reserved.
//

import UIKit

class ATSVGShapeLayer: CAShapeLayer {

    public var disableActions: Bool = true
    public var animateDuration: Double = 0.25

    override func action(forKey event: String) -> CAAction? {
        if event == "path" {
            if !disableActions {
                let value = self.presentation()?.value(forKey: event) ?? self.value(forKey: event)

                let anim = CABasicAnimation(keyPath: event)
                anim.duration = animateDuration
                anim.fromValue = value
                anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

                return anim
            }
        }

        return super.action(forKey: event)
    }

    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "path" {
            return true
        }

        return super.needsDisplay(forKey: key)
    }

}
