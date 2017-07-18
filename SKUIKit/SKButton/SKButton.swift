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

typealias SKButtonAction = () -> Void

class SKButton: SKSpriteNode {
    
    var action: SKButtonAction?
    var text: String? {
        didSet {
            labelNode.text = text
        }
    }
    var fontColor: UIColor? {
        didSet {
            labelNode.color = fontColor
        }
    }
    var fontName: String? {
        didSet {
            labelNode.fontName = fontName
        }
    }
    var fontSize: CGFloat = 12 {
        didSet {
            labelNode.fontSize = fontSize
        }
    }
    
    private(set) var defaultColor: SKColor!
    private(set) var highlightedColor: SKColor?
    
    private(set) var defaultTexture: SKTexture?
    private(set) var highlightedTexture: SKTexture?
    
    private var labelNode: SKLabelNode!
    
    fileprivate(set) var isHighlighted = false {
        didSet {
            if isHighlighted && !oldValue {
                if let highlightedTexture = highlightedTexture {
                    texture = highlightedTexture
                } else if let highlightedColor = highlightedColor {
                    color = highlightedColor
                }
            } else if !isHighlighted && oldValue {
                if let defaultTexture = defaultTexture {
                    texture = defaultTexture
                } else if let defaultColor = defaultColor {
                    color = defaultColor
                }
            }
        }
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.defaultColor = color
        self.defaultTexture = texture
        
        isUserInteractionEnabled = true
        
        labelNode = SKLabelNode(text: self.text)
        labelNode.fontSize = fontSize
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        
        addChild(labelNode)
    }
    
    convenience init(size: CGSize, defaultColor: SKColor, highlightedColor: SKColor?) {
        self.init(texture: nil, color: defaultColor, size: size)
        
        self.highlightedColor = highlightedColor
    }
    
    convenience init(size: CGSize, defaultTexture: SKTexture, highlightedTexture: SKTexture?) {
        self.init(texture: defaultTexture, color: SKColor.clear, size: size)
        
        self.highlightedTexture = highlightedTexture
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: UITouch

extension SKButton {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            guard let parent = parent else {
                return
            }
            
            let location = touch.location(in: parent)
            isHighlighted = self.contains(location)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            isHighlighted = false
            
            guard let action = action, let parent = parent else {
                return
            }
            
            let location = touch.location(in: parent)
            if self.contains(location) {
                action()
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = false
    }
}
