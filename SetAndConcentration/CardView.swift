//
//  CardView.swift
//  SetHomeworkCustomView
//
//  Created by Limbek Soma on 2019. 10. 30..
//  Copyright © 2019. Soma Limbek. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    var numberOfShapes: NumberOfShapes = .one { didSet {  if numberOfShapes != oldValue { setNeedsDisplay(); setNeedsLayout() } } }
    var shape: Shape = .diamond { didSet {  setNeedsDisplay() } }
    var shading: Shading = .solid { didSet {  setNeedsDisplay() } }
    var color: Color = .red { didSet {  setNeedsDisplay() } }
    var isFaceUp = true { didSet { setNeedsDisplay() } }
    
    let boundsReductionRatio: CGFloat = 9 / 10
    var originOffsetRatio: CGFloat { (1 - boundsReductionRatio) / 2 }
    let shapeGridAspectRatio: CGFloat = 10.0 / 5.0
    var cornerRadius: CGFloat { bounds.width / 10 }
    var borderWidth: CGFloat { bounds.width / 20 }
    
    override var bounds: CGRect {
        get {
            let width = super.bounds.size.width * boundsReductionRatio
            let height = super.bounds.size.height * boundsReductionRatio
            let size = CGSize(width: width, height: height)
            
            let originOffsetX = width * originOffsetRatio
            let originOffsetY = height * originOffsetRatio
            let origin = CGPoint(x: super.bounds.origin.x + originOffsetX, y: super.bounds.origin.y + originOffsetY)
            
            return CGRect(origin: origin, size:  size)
        }
        set { super.bounds = newValue }
    }
    
    var shapeGridFrame: CGRect {
        get {
            let width = bounds.size.width * boundsReductionRatio
            let height = bounds.size.height * boundsReductionRatio
            let size = CGSize(width: width, height: height)
            
            let originOffsetX = width * originOffsetRatio
            let originOffsetY = height * originOffsetRatio
            let origin = CGPoint(x: bounds.origin.x + originOffsetX, y: bounds.origin.y + originOffsetY)
            
            return CGRect(origin: origin, size:  size)
        }
        set { super.bounds = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isOpaque = false
    }
    
    convenience init(copyFrom other: CardView) {
        self.init(frame: other.frame)
        numberOfShapes = other.numberOfShapes
        shape = other.shape
        shading = other.shading
        color = other.color
        isFaceUp = other.isFaceUp
    }

    func addBorder(color: CGColor) {
        layer.borderWidth = borderWidth
        layer.borderColor = color
    }
    
    func removeBorder() {
        layer.borderWidth = 0.0
        layer.borderColor = nil
    }
    
    override func draw(_ rect: CGRect) {
        if isFaceUp {
            drawFront(rect)
        } else {
            drawBack(rect)
        }
    }
    
    private func drawBack(_ rect: CGRect) {
        let backgroundRect = CGRect(origin: bounds.origin, size: bounds.size)
        let backgroudPath = UIBezierPath(roundedRect: backgroundRect, cornerRadius: cornerRadius)
        UIColor.lightGray.setFill()
        backgroudPath.fill()
        
        UIColor.black.setStroke()
        backgroudPath.lineWidth = bounds.width / 50
        backgroudPath.stroke()
    }
    
    private func drawFront(_ rect: CGRect) {
        let backgroundRect = CGRect(origin: bounds.origin, size: bounds.size)
        let backgroudPath = UIBezierPath(roundedRect: backgroundRect, cornerRadius: cornerRadius)
        UIColor.white.setFill()
        backgroudPath.fill()
        
        var grid = Grid(layout: .aspectRatio(shapeGridAspectRatio), frame: shapeGridFrame)
        grid.cellCount = numberOfShapes.rawValue
        
        let shapeColor: UIColor
        switch color {
        case .red:
            shapeColor = UIColor.red
        case .green:
            shapeColor = UIColor.green
        case .purple:
            shapeColor = UIColor.purple
        }
        
        let shapePath = UIBezierPath()

        for index in 0..<grid.cellCount {
            if let cell = grid[index] {
                shapePath.lineWidth = cell.width / 60
                let offsetFromBounds: CGFloat = shapePath.lineWidth
                switch shape {
                case .diamond:
                    shapePath.move(to: CGPoint(x: cell.midX, y: cell.minY + offsetFromBounds))
                    shapePath.addLine(to: CGPoint(x: cell.maxX - offsetFromBounds, y: cell.midY))
                    shapePath.addLine(to: CGPoint(x: cell.midX, y: cell.maxY - offsetFromBounds))
                    shapePath.addLine(to: CGPoint(x: cell.minX + offsetFromBounds, y: cell.midY))
                    shapePath.close()
                case .squiggle:
                    let xOffset = cell.width/5 + offsetFromBounds
                    let yOffset = cell.height/4 + offsetFromBounds
                    let shapeTopLeft = CGPoint(x: cell.minX + xOffset, y: cell.minY + yOffset)
                    let shapeTopRight = CGPoint(x: cell.maxX - xOffset, y: cell.minY + yOffset)
                    let shapeBottomRight = CGPoint(x: cell.maxX - xOffset, y: cell.maxY - yOffset)
                    let shapeBottomLeft = CGPoint(x: cell.minX + xOffset, y: cell.maxY - yOffset)

                    let controlPointTopLeft = CGPoint(x: cell.width/3, y: cell.minY)
                    let controlPointTopRight = CGPoint(x: cell.maxX, y: cell.minY)
                    let controlPointBottomRight = CGPoint(x: cell.width*2/3, y: cell.maxY)
                    let controlPointBottomLeft = CGPoint(x: cell.minX, y: cell.maxY)
                    let controlPointMidLeft = CGPoint(x: cell.minX + cell.width/4 + xOffset, y: cell.midY)
                    let controlPointMidRight = CGPoint(x: cell.maxX - cell.width/4 - xOffset, y: cell.midY)
                    
                    shapePath.move(to: shapeTopLeft)
                    shapePath.addCurve(to: shapeTopRight, controlPoint1: controlPointTopLeft, controlPoint2: controlPointMidRight)
                    shapePath.addQuadCurve(to: shapeBottomRight, controlPoint: controlPointTopRight)
                    shapePath.addCurve(to: shapeBottomLeft, controlPoint1: controlPointBottomRight, controlPoint2: controlPointMidLeft)
                    shapePath.addQuadCurve(to: shapeTopLeft, controlPoint: controlPointBottomLeft)
                case .oval:
                    let rectOriginX = cell.minX + offsetFromBounds
                    let rectOriginY = cell.minY + offsetFromBounds
                    let rectOrigin = CGPoint(x: rectOriginX, y: rectOriginY)
                    
                    let rectWidth = cell.width - 2*offsetFromBounds
                    let rectHeight = cell.height - 2*offsetFromBounds
                    let rectSize = CGSize(width: rectWidth, height: rectHeight)
                    
                    let rect = CGRect(origin: rectOrigin, size: rectSize)
                    shapePath.append(UIBezierPath(roundedRect: rect, cornerRadius: 1000.0))
                    // TODO: Implement this case with addArc and addLine methods for practice.
                }
            }
            
        } // TODO: Clean Up This Mess. Extract cases to methods.
        
        shapeColor.setStroke()
        shapePath.stroke()
        switch shading {
        case .solid:
            shapeColor.setFill()
            shapePath.fill()
        case .striped:
            shapePath.addClip()
            let spaceBetweenStripes: CGFloat = shapePath.lineWidth * 1.7
            for x in stride(from: bounds.minX, to: bounds.maxX, by: spaceBetweenStripes) {
                shapePath.move(to: CGPoint(x: x, y: bounds.minY))
                shapePath.addLine(to: CGPoint(x: x, y: bounds.maxY))
            }
            shapePath.lineWidth /= 2
            shapePath.stroke()
        case .open:
            break
        }

    }

    enum NumberOfShapes: Int {
        case one = 1, two, three
    }
    
    enum Shape: Int {
        case diamond, squiggle, oval
    }
    
    enum Shading: Int {
        case solid, striped, open
    }
    
    enum Color: Int {
        case red, green, purple
    }

}
