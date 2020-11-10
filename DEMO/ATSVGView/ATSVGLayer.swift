//
//  ATSVGLayer.swift
//
//  Created by CaiSanze on 2020/10/27.
//  Copyright © 2020 atlasv. All rights reserved.
//

import UIKit
import PocketSVG

class ATSVGLayer: CALayer {

    public var paths: [SVGBezierPath] = [] {
        didSet {
            handlePaths()
        }
    }

    public var fillColor: CGColor? {
        didSet {
            shapeLayers.forEach { $0.fillColor = fillColor }
        }
    }

    public var strokeColor: CGColor? {
        didSet {
            shapeLayers.forEach { $0.strokeColor = strokeColor }
        }
    }

    public var shapeLayerCornerRadius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    public var disableActions: Bool = true {
        didSet {
            shapeLayers.forEach { $0.disableActions = disableActions }
        }
    }

    public var animateDuration: Double = 0.25 {
        didSet {
            shapeLayers.forEach { $0.animateDuration = animateDuration }
        }
    }


    private var untouchedPaths: [SVGBezierPath] = []
    private var shapeLayers: [ATSVGShapeLayer] = []

    private var adjustedFrame: CGRect {
        return SVGAdjustCGRectForContentsGravity(bounds, preferredFrameSize(), contentsGravity.rawValue)
    }
    private var scaledWidthRatio: CGFloat {
        return adjustedFrame.size.width / preferredFrameSize().width
    }
    private var scaledHeightRatio: CGFloat {
        return adjustedFrame.size.height / preferredFrameSize().height
    }

    override init() {
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func preferredFrameSize() -> CGSize {
        return SVGBoundingRectForPaths(untouchedPaths).size
    }

    override func layoutSublayers() {
        super.layoutSublayers()

        guard shapeLayers.count == untouchedPaths.count else {
            return
        }

        CATransaction.begin()
        CATransaction.setDisableActions(disableActions)
        let scale = CGAffineTransform(scaleX: scaledWidthRatio, y: scaledHeightRatio)
        let layerTransform = scale.concatenating(CGAffineTransform(translationX: adjustedFrame.origin.x, y: adjustedFrame.origin.y))
        for i in 0..<untouchedPaths.count {
            let path = untouchedPaths[i]
            let layer = shapeLayers[i]

            setColor(with: path, layer: layer)
            setFillRule(with: path, layer: layer)
            setLineCap(with: path, layer: layer)
            setLineJoin(with: path, layer: layer)
            setMiterLimit(with: path, layer: layer)
            setLineDashPattern(with: path, layer: layer)

            let pathBounds = path.bounds
            layer.frame = pathBounds.applying(layerTransform)
            let translationTransform = CGAffineTransform(translationX: -pathBounds.origin.x,
                                                         y: -pathBounds.origin.y)
            let pathTransform = translationTransform.concatenating(scale)
            path.apply(pathTransform)

            let finalPath = addArcIfNeeded(path: path)
            layer.path = finalPath.cgPath
        }
        CATransaction.commit()
    }

}

// MARK: - Actions

extension ATSVGLayer {

    private func handlePaths() {
        shapeLayers.forEach { $0.removeFromSuperlayer() }
        shapeLayers.removeAll()

        untouchedPaths.removeAll()
        CATransaction.begin()
        CATransaction.setDisableActions(disableActions)
        for path in paths {
            if let display = path.svgAttributes["display"] as? String, display == "none" {
                continue
            }

            var newPath = path
            if let transformValue = path.svgAttributes["transform"] as? NSValue {
                if let tmpPath = path.copy() as? SVGBezierPath {
                    tmpPath.apply(transformValue.cgAffineTransformValue)
                    newPath = tmpPath
                }
            }

            let layer = ATSVGShapeLayer()
            layer.disableActions = disableActions
            layer.contentsScale = UIScreen.main.scale
            layer.path = newPath.cgPath
            layer.lineWidth = newPath.lineWidth
            if let opacity = path.svgAttributes["opacity"] as? Float {
                layer.opacity = opacity
            } else {
                layer.opacity = 1
            }

            insertSublayer(layer, at: UInt32(shapeLayers.count))
            shapeLayers.append(layer)
            untouchedPaths.append(newPath)
        }

        setNeedsLayout()
        CATransaction.commit()
    }

    private func setColor(with path: SVGBezierPath, layer: CAShapeLayer) {
        let newFillColor = fillColor ?? (path.svgAttributes["fill"] as? UIColor)?.cgColor
        layer.fillColor = newFillColor ?? UIColor.black.cgColor
        layer.strokeColor = strokeColor ?? (path.svgAttributes["stoke"] as? UIColor)?.cgColor
    }

    private func setFillRule(with path: SVGBezierPath, layer: CAShapeLayer) {
        if let fillRule = path.svgAttributes["fill-rule"] as? String, fillRule == "evenodd" {
            layer.fillRule = .evenOdd
        } else {
            layer.fillRule = .nonZero
        }
    }

    private func setLineCap(with path: SVGBezierPath, layer: CAShapeLayer) {
        if let lineCap = path.svgAttributes["stroke-linecap"] as? String {
            if lineCap == "round" {
                layer.lineCap = .round
            } else if lineCap == "square" {
                layer.lineCap = .square
            } else {
                layer.lineCap = .butt
            }
        } else {
            layer.lineCap = .butt
        }
    }

    private func setLineJoin(with path: SVGBezierPath, layer: CAShapeLayer) {
        if let lineJoin = path.svgAttributes["stroke-linejoin"] as? String {
            if lineJoin == "round" {
                layer.lineJoin = .round
            } else if lineJoin == "bevel" {
                layer.lineJoin = .bevel
            } else {
                layer.lineJoin = .miter
            }
        } else {
            layer.lineJoin = .miter
        }
    }

    private func setMiterLimit(with path: SVGBezierPath, layer: CAShapeLayer) {
        if let miterLimit = path.svgAttributes["stroke-miterlimit"] as? CGFloat {
            layer.miterLimit = miterLimit
        }
    }

    private func setLineDashPattern(with path: SVGBezierPath, layer: CAShapeLayer) {
        if let dashArrayStr = path.svgAttributes["stroke-dasharray"] as? String {
            let dashPattern = dashArrayStr.split(separator: ",")
            layer.lineDashPattern = dashPattern.compactMap({ (dashValue) -> NSNumber? in
                if let dashValueFloat = Float(dashValue) {
                    return NSNumber(value: dashValueFloat)
                }

                return nil
            })
        }
    }

    private func addArcIfNeeded(path: UIBezierPath) -> UIBezierPath {
        guard shapeLayerCornerRadius > 0 else {
            return path
        }

        let scaledWidthRatio = adjustedFrame.width / preferredFrameSize().width
        let scaledRadius: CGFloat = shapeLayerCornerRadius / scaledWidthRatio
        let pointAndTypes = path.cgPath.getPointsAndTypes()
        guard pointAndTypes.count >= 3 else {
            return path
        }

        let newPath = CGMutablePath()
        let totalCount = pointAndTypes.count
        var shouldIgnoreCount: Int = 0
        for (i, (currentPoint, type)) in pointAndTypes.enumerated() {
            if shouldIgnoreCount > 0 {
                shouldIgnoreCount -= 1
                continue
            }

            if i == 0 {
                newPath.move(to: currentPoint)
            } else {
                let prePointIndex = (i - 1) % totalCount
                let (prePoint, _) = pointAndTypes[prePointIndex]
                
                let nextPointIndex = (i + 1) % totalCount
                let (nextPoint, nextType) = pointAndTypes[nextPointIndex]
                if type == .addQuadCurveToPoint {
                    shouldIgnoreCount = 1
                    newPath.addQuadCurve(to: nextPoint, control: currentPoint)
                } else if type == .addCurveToPoint {
                    shouldIgnoreCount = 2
                    let nextNextPointIndex = (i + 2) % totalCount
                    let (nextNextPoint, _) = pointAndTypes[nextNextPointIndex]
                    newPath.addCurve(to: nextNextPoint, control1: currentPoint, control2: nextPoint)
                } else {
                    let isSamePoint = currentPoint == nextPoint
                    if !isSamePoint {
                        if allowAddArc(type: type), allowAddArc(type: nextType) {
                            addArcForRadius(path: newPath,
                                            prePoint: prePoint,
                                            tangent1End: currentPoint,
                                            tangent2End: nextPoint,
                                            radius: scaledRadius)
                        } else {
                            newPath.addLine(to: currentPoint)
                        }
                    }
                }

                if i == totalCount - 1 {
                    let (lastPoint, _) = pointAndTypes[i]
                    let (lastLastPoint, _) = pointAndTypes[i - 1]
                    let (firstPoint, firstType) = pointAndTypes[0]
                    let (secondPoint, secondType) = pointAndTypes[1]
                    let prePoint = lastPoint == firstPoint ? lastLastPoint : lastPoint
                    if allowAddArc(type: firstType), allowAddArc(type: secondType) {
                        addArcForRadius(path: newPath,
                                        prePoint: prePoint,
                                        tangent1End: firstPoint,
                                        tangent2End: secondPoint,
                                        radius: scaledRadius)
                    }
                }
            }
        }

        return UIBezierPath(cgPath: newPath)
    }

    private func addArcForRadius(path: CGMutablePath, prePoint: CGPoint, tangent1End: CGPoint, tangent2End: CGPoint, radius: CGFloat) {
        let x_value1 = fabsf(Float(tangent1End.x - prePoint.x))
        let y_value1 = fabsf(Float(tangent1End.y - prePoint.y))
        let borderA = sqrt((x_value1 * x_value1 + y_value1 * y_value1))
        
        let x_value2 = fabsf(Float(tangent1End.x - tangent2End.x))
        let y_value2 = fabsf(Float(tangent1End.y - tangent2End.y))
        let borderB = sqrt((x_value2 * x_value2 + y_value2 * y_value2))
        
        let x_value3 = fabsf(Float(tangent2End.x - prePoint.x))
        let y_value3 = fabsf(Float(tangent2End.y - prePoint.y))
        let borderC = sqrt((x_value3 * x_value3 + y_value3 * y_value3))
        
        var scaledRadius: CGFloat = radius
        let q: Float = 2 * borderA * borderB
        if q > 0 {
            let cos_C = (borderA * borderA + borderB * borderB - borderC * borderC) / q
            let angle: CGFloat = CGFloat(acos(cos_C)) / 2
            let minValue: CGFloat = CGFloat(min(borderA, borderB) / 2)
            scaledRadius = minValue * tan(angle)
            scaledRadius = min(scaledRadius, radius)
        }
        
        path.addArc(tangent1End: tangent1End, tangent2End: tangent2End, radius: scaledRadius)
    }

    
    private func allowAddArc(type: CGPathElementType) -> Bool {
        let allowTypes: [CGPathElementType] = [
            .moveToPoint,
            .addLineToPoint
        ]

        return allowTypes.contains(type)
    }

}

private extension CGPath {

    func getPointsAndTypes() -> [(CGPoint, CGPathElementType)] {
        var points: [(CGPoint, CGPathElementType)] = []
        applyWithBlock({ (element) in
            let pointType = element.pointee.type
            switch pointType {
            case .moveToPoint, .addLineToPoint:
                let point = (element.pointee.points.pointee, pointType)
                points.append(point)
            case .addQuadCurveToPoint:
                let firstPoint = (element.pointee.points.pointee, pointType)
                points.append(firstPoint)

                let secondPoint = (element.pointee.points.advanced(by: 1).pointee, pointType)
                points.append(secondPoint)
            case .addCurveToPoint:
                let firstPoint = (element.pointee.points.pointee, pointType)
                points.append(firstPoint)

                let secondPoint = (element.pointee.points.advanced(by: 1).pointee, pointType)
                points.append(secondPoint)

                let thirdPoint = (element.pointee.points.advanced(by: 2).pointee, pointType)
                points.append(thirdPoint)
            case .closeSubpath:
                break
            @unknown default:
                break
            }
        })

        return points
    }

}
