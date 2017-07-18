//
//  SKDragDropManager
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

typealias SKDropTargetAction = (SKSpriteNode) -> Void

class SKDragDropManager {
    
    static let shared = SKDragDropManager()
        
    var dragNode: SKDragNode?
    
    var dropTargets = [Int : SKDropTarget]()
    
    func removeAllDropTargets() {
        dropTargets.removeAll()
    }
}

class SKDropTarget {
    
    var dropAction: SKDropTargetAction?
}

class SKDragNode {
    
    var spriteNode: SKSpriteNode!
    var tempNode: SKSpriteNode!
    
    var willDropAction: SKDropTargetAction?
    
    private let dragDropManager = SKDragDropManager.shared
    
    init(spriteNode: SKSpriteNode) {
        self.spriteNode = spriteNode
        
        if let spriteNodeParent = spriteNode.parent {
            tempNode = spriteNode.copy() as! SKSpriteNode
            spriteNodeParent.addChild(tempNode)
            spriteNode.alpha = 0.25
            
            let positionInParent = tempNode.convert(tempNode.position, to: spriteNodeParent)
            tempNode.position = positionInParent
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let scene = spriteNode.scene else {
            return
        }
        
        for touch in touches {
            let positionInScene = touch.location(in: scene)
            let previousPosition = touch.previousLocation(in: scene)
            let translation = CGPoint(x: positionInScene.x - previousPosition.x, y: positionInScene.y - previousPosition.y)
            
            tempNode.position = CGPoint(x: tempNode.position.x + translation.x, y: tempNode.position.y + translation.y)
        }
    }
    
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let scene = spriteNode.scene else {
            return
        }
        
        spriteNode?.alpha = 1.0
        
        for touch in touches {
            let positionInScene = touch.location(in: scene)
            
            let nodes = scene.nodes(at: positionInScene)
            for node in nodes {
                if let foundDropTarget = dragDropManager.dropTargets[node.hash] {
                    if let willDropAction = willDropAction {
                        willDropAction(spriteNode!)
                    }
                    if let dropAction = foundDropTarget.dropAction {
                        dropAction(spriteNode!)
                    }
                    
                    break
                }
            }
            
            spriteNode = nil
            tempNode.removeFromParent()
            dragDropManager.dragNode = nil
        }
    }
}

extension SKSpriteNode {
    
    func startDrag(willDropAction: SKDropTargetAction?) {
        let dragNode = SKDragNode(spriteNode: self)
        dragNode.willDropAction = willDropAction
        
        SKDragDropManager.shared.dragNode = dragNode
    }
    
    func setAsDropTarget(dropAction: SKDropTargetAction?) {
        let dropTarget = SKDropTarget()
        dropTarget.dropAction = dropAction
        SKDragDropManager.shared.dropTargets[self.hash] = dropTarget
    }
}
