//
//  UIView+Extensions.swift
//  pacemaker-frontend
//
//  Created by 이동현 on 2021/11/01.
//

import UIKit

extension UIView {
    func applyShadow(
        color: UIColor = .black,
        alpha: Float = 0.2,
        x: CGFloat = 0,
        y: CGFloat = 0,
        blur: CGFloat = 20
    ) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = alpha
        layer.shadowOffset = CGSize(width: x, height: y)
        layer.shadowRadius = blur / 2.0
        layer.masksToBounds = false
    }

    func roundShadow(size: CGSize, radius: CGFloat? = nil) {
        let shadowLayer = CAShapeLayer()

        shadowLayer.path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: radius ?? size.height / 2).cgPath

        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        shadowLayer.shadowOpacity = 0.2
        shadowLayer.shadowRadius = 3

        layer.insertSublayer(shadowLayer, at: 0)
    }

    func roundCorner(_ radius: CGFloat? = 7, color: UIColor? = nil) {
        layer.cornerRadius = radius ?? frame.height / 2.0
        layer.masksToBounds = true
        if let color = color {
            layer.borderColor = color.cgColor
            layer.borderWidth = 1
        }
    }

    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    func addBottomBorder() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 0.5, width: self.frame.size.width, height: 1)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        layer.addSublayer(bottomLine)
    }

    func setBorder(_ edges: UIRectEdge, width: CGFloat, color: UIColor) {
        self.layer.sublayers?.forEach { layer in
            if layer.name == "borderLayer" {
                layer.removeFromSuperlayer()
            }
        }
        switch edges {
        case [.left, .right]:
            addBorder(.left, width: width, color: color)
            addBorder(.right, width: width, color: color)
        case [.top, .bottom]:
            addBorder(.top, width: width, color: color)
            addBorder(.bottom, width: width, color: color)
        case .left:
            addBorder(.left, width: width, color: color)
        case .right:
            addBorder(.right, width: width, color: color)
        case .top:
            addBorder(.top, width: width, color: color)
        case .bottom:
            addBorder(.bottom, width: width, color: color)
        case .all:
            addBorder(.all, width: width, color: color)
        default:
            addBorder(.left, width: width, color: color)
            addBorder(.right, width: width, color: color)
            addBorder(.top, width: width, color: color)
            addBorder(.bottom, width: width, color: color)
        }
    }

    private func addBorder(_ edges: UIRectEdge, width: CGFloat, color: UIColor) {
        DispatchQueue.main.async {
            var rect: CGRect!
            switch edges {
            case .left:
                rect = CGRect(x: 0, y: 0, width: width, height: self.frame.height)
            case .right:
                rect = CGRect(x: self.frame.width - width, y: 0, width: width, height: self.frame.height)
            case .top:
                rect = CGRect(x: 0, y: 0, width: self.frame.width, height: width)
            case .bottom:
                rect = CGRect(x: 0, y: self.frame.height - width, width: self.frame.width, height: width)
            default:
                self.layer.borderColor = color.cgColor
                self.layer.borderWidth = width
                return
            }

            let borderLayer = CALayer()
            borderLayer.name = "borderLayer"
            borderLayer.frame = rect
            borderLayer.borderColor = color.cgColor
            borderLayer.borderWidth = width
            self.layer.addSublayer(borderLayer)
        }
    }

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }

    func findSuperView() -> UIView? {
        var result: UIView? = self.superview
        while result?.superview != nil {
            result = result?.superview
        }
        return result
    }
}

