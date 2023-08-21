//
//  UIView + Extensions.swift
//  Tracker
//
//  Created by Павел Афанасьев on 18.06.2023.
//

import UIKit

extension UIView {
    func addViewsWithNoTAMIC(_ view: UIView){
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UIView {
    private static let gradientBorderLayerName = "GradientBorderLayer"

    func createGradientBorder(
        width: CGFloat,
        cornerRadius: CGFloat = 0,
        colors: [UIColor],
        startPoint: CGPoint = .init(x: 0.5, y: 0),
        endPoint: CGPoint = .init(x: 0.5, y: 1)
    ) {
        let borderLayer = createGradientBorderLayer()
        let border = borderLayer ?? .init()
        border.frame = CGRect(
            x: bounds.origin.x,
            y: bounds.origin.y,
            width: bounds.size.width + width,
            height: bounds.size.height + width
        )
        border.colors = colors.map { $0.cgColor }
        border.startPoint = startPoint
        border.endPoint = endPoint
        
        let borderMask = CAShapeLayer()
        let maskRect = CGRect(
            x: bounds.origin.x + width/2,
            y: bounds.origin.y + width/2,
            width: bounds.size.width - width,
            height: bounds.size.height - width
        )
        borderMask.path = UIBezierPath(
            roundedRect: maskRect,
            cornerRadius: cornerRadius
        ).cgPath
        
        borderMask.fillColor = UIColor.clear.cgColor
        borderMask.strokeColor = UIColor.white.cgColor
        borderMask.lineWidth = width
        
        border.mask = borderMask
        
        let isAdded = (borderLayer != nil)
        if !isAdded {
            layer.addSublayer(border)
        }
    }
    
    private func createGradientBorderLayer() -> CAGradientLayer? {
        let borderLayers = layer.sublayers?.filter {
            $0.name == UIView.gradientBorderLayerName
        }
        if borderLayers?.count ?? 0 > 1 {
            assertionFailure()
        }
        return borderLayers?.first as? CAGradientLayer
    }
}
