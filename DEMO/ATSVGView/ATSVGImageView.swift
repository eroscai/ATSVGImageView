//
//  ATSVGImageView.swift
//
//  Created by CaiSanze on 2020/10/30.
//  Copyright © 2020 atlasv. All rights reserved.
//

import UIKit
import PocketSVG

class ATSVGImageView: UIImageView {

    public var fillColor: CGColor? {
        didSet {
            svgLayer?.fillColor = fillColor
        }
    }

    public var strokeColor: CGColor? {
        didSet {
            svgLayer?.strokeColor = strokeColor
        }
    }

    public var cornerRadius: CGFloat = 0 {
        didSet {
            svgLayer?.shapeLayerCornerRadius = cornerRadius
        }
    }

    public var disableActions: Bool = true {
        didSet{
            svgLayer?.disableActions = disableActions
        }
    }

    public var animateDuration: Double = 0.25 {
        didSet {
            svgLayer?.animateDuration = animateDuration
        }
    }

    private var svgLayer: ATSVGLayer? {
        return layer as? ATSVGLayer
    }

    override class var layerClass: AnyClass {
        return ATSVGLayer.self
    }

    init(contentsOf: URL) {
        super.init(frame: .zero)

        if FileManager.default.fileExists(atPath: contentsOf.path) {
            svgLayer?.paths = SVGBezierPath.pathsFromSVG(at: contentsOf)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
