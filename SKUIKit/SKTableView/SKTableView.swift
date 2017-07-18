//
//  SKTableView
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

protocol SKTableViewDatasource {
    
    func numberOfRows(tableView: SKTableView) -> Int
    func tableView(tableView: SKTableView, cellFor row: Int) -> SKTableViewCell
}

protocol SKTableViewDelegate {
    
    func tableView(tableView: SKTableView, didSelect row: Int)
    func tableView(tableView: SKTableView, heightFor row: Int) -> CGFloat
}

class SKTableView: SKSpriteNode {
    
    var delegate: SKTableViewDelegate?
    var datasource: SKTableViewDatasource? {
        didSet {
            reloadData()
        }
    }
    
    var isVisible: Bool {
        return self.parent != nil
    }
    
    private let cropNode: SKCropNode
    fileprivate let scrollNode: SKSpriteNode
    
    // Cells
    fileprivate var cells = [SKTableViewCell]()
    fileprivate weak var selectedCell: SKTableViewCell?
    var showSeparators = true {
        didSet {
            reloadData()
        }
    }
    
    // Offsets
    private let cellYOffset: CGFloat = 0
    private var currentCellYOffset: CGFloat = 0
    
    // UITouch vars
    fileprivate var startLocation: CGPoint!
    fileprivate var startTime: TimeInterval!
    fileprivate var lastLocation: CGPoint!
    fileprivate var distancesForAveraging = [CGFloat]()
    fileprivate let highlightActionKey = "highlightAction"

    init(size: CGSize) {
        cropNode = SKCropNode()
        scrollNode = SKSpriteNode(color: SKColor.white, size: size)
        
        super.init(texture: nil, color: SKColor.clear, size: size)
        isUserInteractionEnabled = true
        
        scrollNode.anchorPoint = CGPoint(x: 0.5, y: 1)
        scrollNode.layout({ layout in
            layout.top.equalTo(self)
        })

        cropNode.addChild(scrollNode)
        
        cropNode.position = CGPoint(x: frame.midX, y: frame.midY)
        cropNode.maskNode = SKSpriteNode(color: SKColor.black, size: size)
        
        addChild(cropNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData() {
        guard let datasource = datasource, let delegate = delegate else {
            return
        }
        currentCellYOffset = 0
        
        let numberOfCells = datasource.numberOfRows(tableView: self)
        
        for index in 0..<numberOfCells {
            let cell = datasource.tableView(tableView: self, cellFor: index)
            
            if index < cells.count {
                cells[index].removeFromParent()
                cells[index] = cell
            } else {
                cells.append(cell)
            }
            
            let height = delegate.tableView(tableView: self, heightFor: index)
            cell.size = CGSize(width: scrollNode.size.width, height: height)
            cell.layout({ layout in
                layout.top.equalTo(scrollNode).offset(currentCellYOffset)
            })
            
            if showSeparators {
                let separator = SKSpriteNode(color: SKColor.lightGray, size: CGSize(width: cell.size.width, height: 1))
                cell.addChild(separator)
                separator.layout({ layout in
                    layout.bottom.equalTo(cell)
                })
            }
            
            scrollNode.addChild(cell)
            
            currentCellYOffset += cell.size.height + cellYOffset
            scrollNode.size.height = currentCellYOffset >= scrollNode.size.height ? currentCellYOffset : scrollNode.size.height
        }
    }
    
    func cell(row: Int) -> SKTableViewCell? {
        let cell: SKTableViewCell? = row < cells.count ? cells[row] : nil
        return cell
    }
    
    func deselect(row: Int) {
        guard let cell = cell(row: row) else {
            return
        }
        
        cell.run(SKAction.afterDelay(0.05, runBlock: {
            cell.isHighlighted = false
        }))
    }
}

// MARK: - UITouch

extension SKTableView {
    
    private func updateScrollNodePosition(y: CGFloat, duration: TimeInterval) {
        let position = CGPoint(x: scrollNode.position.x, y: scrollNode.position.y + y)
        
        let newY = position.y.clamped(scrollNode.size.height - size.height / 2, size.height / 2)
        
        let moveTo = SKAction.move(to: CGPoint(x: position.x, y: newY), duration: duration)
        moveTo.timingMode = .easeOut
        scrollNode.run(moveTo)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            startLocation = location
            startTime = touch.timestamp
            lastLocation = startLocation
            scrollNode.removeAllActions()
            
            if let cell = cell(location: location) {
                self.selectedCell = cell
                
                let highlightAction = SKAction.afterDelay(0.10, runBlock: {
                    if let selectedCell = self.selectedCell {
                        selectedCell.isHighlighted = true
                    }
                })
                cell.run(highlightAction, withKey:highlightActionKey)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let previousLocation = touch.previousLocation(in: self)
            
            let distance = abs(location.y - previousLocation.y)
            distancesForAveraging.append(distance)
            if distancesForAveraging.count > 5 {
                distancesForAveraging.remove(at: 0)
            }
            
            updateScrollNodePosition(y: location.y - lastLocation.y, duration: 0)
            lastLocation = location
            
            if let cell = cell(location: startLocation), distance > 1 {
                selectedCell = nil
                cell.removeAction(forKey: highlightActionKey)
                cell.isHighlighted = false
            }
        }
        
    }
    
   override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let selectedCell = selectedCell {
                handleTap(cell: selectedCell)
            } else if touchesDidSwipe() {
                handleSwipe(touch: touch)
            }
        }
        
    }
    
    private func cell(location: CGPoint) -> SKTableViewCell? {
        var foundCell: SKTableViewCell?
        let selectedNodes = nodes(at: location)
        
        if selectedNodes.count > 0, let selectedCell = selectedNodes[0] as? SKTableViewCell {
            foundCell = selectedCell
        }
        
        return foundCell
    }
    
    private func touchesDidSwipe() -> Bool {
        var didSwipe = false
        var distanceAverage: CGFloat = 0
        for distance in distancesForAveraging {
            distanceAverage += distance
        }
        
        distanceAverage = distanceAverage / CGFloat(distancesForAveraging.count)
        if distanceAverage > 4 {
            didSwipe = true
        }
        
        return didSwipe
    }
    
    func handleSwipe(touch: UITouch) {
        let endLocation = touch.location(in: self)
        
        var distance: CGFloat = 0
        
        var direction: CGFloat = 1
        if startLocation.y > endLocation.y {
            direction = -1
        }
        
        distance = (startLocation.y - endLocation.y) * direction
        
        let time = CGFloat(touch.timestamp - startTime)
        
        let magnitude = sqrt(distance * distance)
        let velocity = magnitude / time
        
        let slideMultiplier = magnitude / 200
        let slideFactor = 0.20 * slideMultiplier
        
        let y = (direction * velocity) * slideFactor
        
        updateScrollNodePosition(y: y, duration: TimeInterval(slideFactor))
    }
    
    func handleTap(cell: SKTableViewCell) {
        guard let delegate = delegate else {
            return
        }
        
        for index in 0..<cells.count {
            let cellInArray = cells[index]
            
            if cellInArray == cell {
                delegate.tableView(tableView: self, didSelect: index)
                break
            }
        }
    }
}
