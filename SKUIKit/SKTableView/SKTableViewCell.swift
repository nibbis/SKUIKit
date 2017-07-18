//
//  SKTableViewCell
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

class SKTableViewCell: SKSpriteNode {
    
    private(set) var defaultColor = SKColor.white
    private(set) var highlightedColor: SKColor? = SKColor.lightGray
    
    private(set) var defaultTexture: SKTexture?
    private(set) var highlightedTexture: SKTexture?
    
    var isHighlighted = false {
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
                } else {
                    color = defaultColor
                }
            }
            
        }
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.defaultColor = color
        self.defaultTexture = texture
    }
    
    convenience init() {
        self.init(texture: nil, color: SKColor.white, size: CGSize.zero)
    }
    
    convenience init(defaultColor: SKColor, highlightedColor: SKColor?) {
        self.init(texture: nil, color: defaultColor, size: CGSize.zero)
        
        self.highlightedColor = highlightedColor
    }
    
    convenience init(defaultTexture: SKTexture, highlightedTexture: SKTexture?) {
        self.init(texture: defaultTexture, color: SKColor.clear, size: CGSize.zero)
        
        self.highlightedTexture = highlightedTexture
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
