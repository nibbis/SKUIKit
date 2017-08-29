//
//  SKButton
//
//  Copyright (c) 2016-Present Nibbis - http://nibbis.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import SpriteKit

/// Relay control events though `ThumbStickNodeDelegate`.
protocol SKTouchPadDelegate: class {
    /// Called when `touchPad` is moved. Values are normalized between [-1.0, 1.0].
    func touchPad(touchPad: SKTouchPad, didUpdateXValue xValue: Float, yValue: Float)
    
    /// Called to indicate when the `touchPad` is initially pressed, and when it is released.
    func touchPad(touchPad: SKTouchPad, isPressed: Bool)
}

/// Touch representation of a classic analog stick.
class SKTouchPad: SKSpriteNode {
    // MARK: Properties 
    
    /// The actual thumb pad that moves with touch.
    var touchPad: SKSpriteNode
    
    weak var delegate: SKTouchPadDelegate?
    
    /// The center point of this `ThumbStickNode`.
    let center: CGPoint
    
    /// The distance that `touchPad` can move from the `touchPadAnchorPoint`.
    let trackingDistance: CGFloat
    
    /// Styling settings for the thumbstick's nodes.
    let normalAlpha: CGFloat = 0.3
    let selectedAlpha: CGFloat = 0.5
    
    override var alpha: CGFloat {
        didSet {
            touchPad.alpha = 1
        }
    }
    
    // MARK: Initialization
    
    init(size: CGSize) {
        trackingDistance = size.width / 2
        
        let touchPadLength = size.width / 2.2
        center = CGPoint(x: size.width / 2 - touchPadLength, y: size.height / 2 - touchPadLength)
        
        let touchPadSize = CGSize(width: touchPadLength, height: touchPadLength)
        let touchPadTexture = SKTexture(image: SKTouchPad.circleImage(size: size, color: SKColor.lightGray))
        
        touchPad = SKSpriteNode(texture: touchPadTexture, color: UIColor.clear, size: touchPadSize)
        
        super.init(texture: touchPadTexture, color: UIColor.clear, size: size)

        alpha = normalAlpha
        
        addChild(touchPad)
        isUserInteractionEnabled = true
    }
    
    class func circleImage(size: CGSize, color: SKColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            context.cgContext.setFillColor(color.cgColor)
            context.cgContext.setStrokeColor(color.cgColor)
            context.cgContext.setLineWidth(0)
            
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            context.cgContext.addEllipse(in: rectangle)
            context.cgContext.drawPath(using: .fillStroke)
        }
        return image
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UITouch

extension SKTouchPad {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // Highlight that the control is being used by adjusting the alpha.
        alpha = selectedAlpha
        
        // Inform the delegate that the control is being pressed.
        delegate?.touchPad(touchPad: self, isPressed: true)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        // For each touch, calculate the movement of the touchPad.
        for touch in touches {
            let touchLocation = touch.location(in: self)
            
            var dx = touchLocation.x - center.x
            var dy = touchLocation.y - center.y
            
            // Calculate the distance from the `touchPadAnchorPoint` to the current location.
            let distance = hypot(dx, dy)
            
            /*
             If the distance is greater than our allowed `trackingDistance`,
             create a unit vector and multiply by max displacement
             (`trackingDistance`).
             */
            if distance > trackingDistance {
                dx = (dx / distance) * trackingDistance
                dy = (dy / distance) * trackingDistance
            }
            
            // Position the touchPad to match the touch's movement.
            touchPad.position = CGPoint(x: center.x + dx, y: center.y + dy)
            
            // Normalize the displacements between [-1.0, 1.0].
            let normalizedDx = Float(dx / trackingDistance)
            let normalizedDy = Float(dy / trackingDistance)
            delegate?.touchPad(touchPad: self, didUpdateXValue: normalizedDx, yValue: normalizedDy)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        // If the touches set is empty, return immediately.
        guard !touches.isEmpty else { return }
        
        resetTouchPad()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        super.touchesCancelled(touches!, with: event)
        resetTouchPad()
    }
    
    /// When touches end, reset the `touchPad` to the center of the control.
    func resetTouchPad() {
        alpha = normalAlpha
        
        let restoreToCenter = SKAction.move(to: CGPoint.zero, duration: 0.2)
        touchPad.run(restoreToCenter)
        
        delegate?.touchPad(touchPad: self, isPressed: false)
        delegate?.touchPad(touchPad: self, didUpdateXValue: 0, yValue: 0)
    }
}
