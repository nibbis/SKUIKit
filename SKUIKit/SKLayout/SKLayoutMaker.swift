//
//  SKLayoutMaker
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

enum SKLayoutAttribute {
    case top
    case bottom
    case left
    case right
    case centerX
    case centerY
    case center
}

enum SKLayoutRelation {
    case equalTo
}

class SKLayoutMaker {
    
    var descriptions = [SKLayoutDescription]()
    
    private var item: SKLayoutItem!
    
    public var left: SKLayoutMakerRelatable {
        return self.makeRelatable(.left)
    }
    
    public var top: SKLayoutMakerRelatable {
        return self.makeRelatable(.top)
    }
    
    public var bottom: SKLayoutMakerRelatable {
        return self.makeRelatable(.bottom)
    }
    
    public var right: SKLayoutMakerRelatable {
        return self.makeRelatable(.right)
    }
    
    public var centerX: SKLayoutMakerRelatable {
        return self.makeRelatable(.centerX)
    }
    
    public var centerY: SKLayoutMakerRelatable {
        return self.makeRelatable(.centerY)
    }
    
    public var center: SKLayoutMakerRelatable {
        return self.makeRelatable(.center)
    }
    
    init(item: SKLayoutItem) {
        self.item = item
    }
    
    func makeRelatable(_ attribute: SKLayoutAttribute) -> SKLayoutMakerRelatable {
        let description = SKLayoutDescription(item: self.item, attribute: attribute)
        self.descriptions.append(description)
        return SKLayoutMakerRelatable(description: description)
    }
    
    func calculatePositions() {
        for description in descriptions {
            if let otherItem = description.otherItem {
                switch description.attribute! {
                case .top:
                    let otherItemHeightCalculation = otherItem.frame.size.height * abs(otherItem.layoutAnchorPoint.y - 1)
                    let itemHeightCalculation = item.frame.size.height * abs(item.layoutAnchorPoint.y - 1)
                    item.position.y = otherItemHeightCalculation - itemHeightCalculation - description.offsetAmount
                case .bottom:
                    let otherItemHeightCalculation = otherItem.frame.size.height * abs(otherItem.layoutAnchorPoint.y) * -1
                    let itemHeightCalculation = item.frame.size.height * abs(item.layoutAnchorPoint.y)
                    item.position.y = otherItemHeightCalculation + itemHeightCalculation + description.offsetAmount
                case .left:
                    let otherItemWidthCalculation = otherItem.frame.size.width * abs(otherItem.layoutAnchorPoint.x) * -1
                    let itemWidthCalculation = item.frame.size.width * abs(item.layoutAnchorPoint.x)
                    item.position.x = otherItemWidthCalculation + itemWidthCalculation + description.offsetAmount
                case .right:
                    let otherItemWidthCalculation = otherItem.frame.size.width * abs(otherItem.layoutAnchorPoint.x - 1)
                    let itemWidthCalculation = item.frame.size.width * abs(item.layoutAnchorPoint.x - 1)
                    item.position.x = otherItemWidthCalculation - itemWidthCalculation - description.offsetAmount
                case .centerX:
                    item.position.x = otherItem.frame.midX - item.frame.midX + description.offsetAmount
                case .centerY:
                    item.position.y = otherItem.frame.midY - item.frame.midY - description.offsetAmount
                case .center:
                    item.position.x = otherItem.frame.midX - item.frame.midX
                    item.position.y = otherItem.frame.midY - item.frame.midY
                }
            }
        }
    }
}
