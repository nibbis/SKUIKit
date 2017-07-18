//
//  SKLayout
//
//  Copyright (c) 2016-Present Nibbis - http://nibbis.com
//  Copyright (c) 2011-Present SnapKit Team - https://github.com/SnapKit
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

fileprivate typealias SKLayoutNode = SKNode

protocol SKLayoutItem {
    
    var frame: CGRect { get }
    var position: CGPoint { get set }
    var layoutAnchorPoint: CGPoint  { get }
}

extension SKLayoutNode: SKLayoutItem {
    var layoutAnchorPoint: CGPoint {
        get {
            if let node = self as? SKSpriteNode {
                return node.anchorPoint
            } else if let node = self as? SKScene {
                return node.anchorPoint
            } else {
                return CGPoint(x: 0.5, y: 0.5)
            }
        }
    }
}

extension SKLayoutItem {
    
    func layout(_ closure: (_ layout: SKLayoutMaker) -> Void) {
        let layout = SKLayoutMaker(item: self)
        closure(layout)
        layout.calculatePositions()
    }
}
