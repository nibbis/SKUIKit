//
//  SKProgressBar
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

class SKProgressBar: SKSpriteNode {
    
    private let barNode: SKSpriteNode
    private let backgroundBarNode: SKSpriteNode
    private var originalSize: CGSize
    
    override var size: CGSize {
        didSet {
            barNode.size = size
            backgroundBarNode.size = size
        }
    }
    
    private let maxAmount: Int!
    
    init(size: CGSize, barColor: SKColor, backgroundColor: SKColor, maxAmount: Int) {
        backgroundBarNode = SKSpriteNode(texture: nil, color: backgroundColor, size: size)
        barNode = SKSpriteNode(texture: nil, color: barColor, size: size)
        originalSize = size
        
        self.maxAmount = maxAmount
        
        super.init(texture: nil, color: SKColor.clear, size: size)
        
        addChild(backgroundBarNode)
        
        barNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        addChild(barNode)
        
        barNode.layout { (layout) in
            layout.left.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func adjustProgress(amount: Int) {
        barNode.size.width = size.width * CGFloat(amount) / CGFloat(maxAmount)
    }
}

