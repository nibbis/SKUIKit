//
//  SKGridView
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

protocol SKGridViewDatasource {

    func numberOfRows(gridView: SKGridView) -> Int
    func numberOfColumns(gridView: SKGridView) -> Int
    func gridView(gridView: SKGridView, cellFor row: Int, column: Int) -> SKGridViewCell
}

protocol SKGridViewDelegate {
    
    func gridView(gridView: SKGridView, didTap row: Int, column: Int)
    func gridView(gridView: SKGridView, didLongPress row: Int, column: Int)
    func gridView(gridView: SKGridView, heightFor row: Int) -> CGFloat
    func gridView(gridView: SKGridView, widthFor column: Int) -> CGFloat
}

class SKGridView: SKSpriteNode {
    
    var delegate: SKGridViewDelegate?
    var datasource: SKGridViewDatasource? {
        didSet {
            reloadData()
        }
    }
    
    var isVisible: Bool {
        return self.parent != nil
    }
    private(set) var numberOfRows = 0
    private(set) var numberOfColumns = 0
    
    private var parentNode: SKSpriteNode!
    
    // Cells
    fileprivate var cells: [[SKGridViewCell]]?
    fileprivate weak var selectedCell: SKGridViewCell?
    var showSeparators = true {
        didSet {
            reloadData()
        }
    }
    
    // UITouch vars
    fileprivate var startLocation: CGPoint!
    fileprivate var startTime: TimeInterval!
    fileprivate let highlightActionKey = "highlightAction"
    fileprivate var ignoreTouches = false
    
    // Managers
    let dragDropManager = SKDragDropManager.shared
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(texture: nil, color: SKColor.green, size: CGSize.zero)
        isUserInteractionEnabled = true
        
        parentNode = SKSpriteNode(texture: nil, color: SKColor.blue, size: CGSize.zero)
        parentNode.anchorPoint = CGPoint(x: 0, y: 1)
        
        addChild(parentNode)
    }
    
    func reloadData() {
        guard let datasource = datasource, let delegate = delegate else {
            return
        }
        
        parentNode.layout { layout in
            layout.center.equalTo(self)
        }
        
        numberOfRows = datasource.numberOfRows(gridView: self)
        numberOfColumns = datasource.numberOfColumns(gridView: self)
        
        var newCells = [[SKGridViewCell]]()
        var currentCellXOffset: CGFloat = 0
        var currentCellYOffset: CGFloat = 0
        
        // Need to remove existing cells in row before attempting to re-add
        if let cells = cells {
            for rowIndex in 0..<cells.count {
                for columnIndex in 0..<cells[rowIndex].count {
                    let cell = cells[rowIndex][columnIndex]
                    cell.removeDropTarget()
                    cell.removeAllChildren()
                    cell.removeFromParent()
                }
            }
            
            self.cells!.removeAll()
        }
        
        for rowIndex in 0..<numberOfRows {
            
            let rowHeight = delegate.gridView(gridView: self, heightFor: rowIndex)
            parentNode.size.height = rowHeight + currentCellYOffset
            
            newCells.append([SKGridViewCell]())
            
            for columnIndex in 0..<numberOfColumns {
                let columnWidth = delegate.gridView(gridView: self, widthFor: columnIndex)
                parentNode.size.width = columnWidth + currentCellXOffset
                
                let cell = datasource.gridView(gridView: self, cellFor: rowIndex, column: columnIndex)
                newCells[rowIndex].append(cell)
                
                cell.size = CGSize(width: columnWidth, height: rowHeight)
                cell.layout({ layout in
                    layout.top.equalTo(self).offset(currentCellYOffset)
                    layout.left.equalTo(self).offset(currentCellXOffset)
                })
                
                if showSeparators {
                    let bottomSeparator = SKSpriteNode(color: SKColor.lightGray, size: CGSize(width: cell.size.width, height: 1))
                    cell.addChild(bottomSeparator)
                    bottomSeparator.layout({ layout in
                        layout.bottom.equalTo(cell)
                    })
                    
                    let rightSeparator = SKSpriteNode(color: SKColor.lightGray, size: CGSize(width: 1, height: cell.size.height))
                    cell.addChild(rightSeparator)
                    rightSeparator.layout({ layout in
                        layout.right.equalTo(cell)
                    })
                }
                
                parentNode.addChild(cell)
                
                currentCellXOffset += columnWidth
            }
            
            currentCellXOffset = 0
            currentCellYOffset += rowHeight
        }
        
        cells = newCells
        
        parentNode.layout { layout in
            layout.center.equalTo(self)
        }
    }
    
    func cell(row: Int, columm: Int) -> SKGridViewCell? {
        guard let cells = cells else {
            return nil
        }
        
        var cell: SKGridViewCell?
        
        if row < cells.count && columm < cells[row].count {
            cell = cells[row][columm]
        }
        
        return cell
    }

    func deselect(row: Int, column: Int) {
        guard let cell = cell(row: row, columm: column) else {
            return
        }
        cell.run(SKAction.afterDelay(0.05, runBlock: {
            cell.isHighlighted = false
        }))
    }
}

// MARK: - UITouch

extension SKGridView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let dragNode = dragDropManager.dragNode {
            dragNode.touchesBegan(touches, with: event)
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            startLocation = location
            
            if let cell = cell(location: location) {
                selectedCell = cell
                startTime = touch.timestamp
                
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
        if let dragNode = dragDropManager.dragNode {
            dragNode.touchesMoved(touches, with: event)
        }
        
        if ignoreTouches == true {
            return
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            
            let distanceY = abs(location.y - startLocation.y)
            let distanceX = abs(location.x - startLocation.x)
            
            if let cell = cell(location: startLocation), distanceX > cell.size.width / 2 || distanceY > cell.size.height / 2 {
                selectedCell = nil
                cell.removeAction(forKey: highlightActionKey)
                cell.isHighlighted = false
            }
            
            let touchTime = touch.timestamp - startTime
            if let selectedCell = selectedCell, touchTime > 0.15 {
                ignoreTouches = true
                handleLongPress(cell: selectedCell)
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let dragNode = dragDropManager.dragNode {
            dragNode.touchesEnded(touches, with: event)
        }
        
        if ignoreTouches == true {
            ignoreTouches = false
            return
        }
        
        for _ in touches {
            if let selectedCell = selectedCell {
                handleTap(cell: selectedCell)
            }
        }
    }
    
    private func handleTap(cell: SKGridViewCell) {
        guard let delegate = delegate, let rowAndColumn = cellRowAndColumn(cell: cell) else {
            return
        }
        selectedCell = nil
        delegate.gridView(gridView: self, didTap: rowAndColumn.row, column: rowAndColumn.column)
    }
    
    private func handleLongPress(cell: SKGridViewCell) {
        guard let delegate = delegate, let rowAndColumn = cellRowAndColumn(cell: cell) else {
            return
        }
        selectedCell = nil
        delegate.gridView(gridView: self, didLongPress: rowAndColumn.row, column: rowAndColumn.column)
    }
    
    private func cell(location: CGPoint) -> SKGridViewCell? {
        var foundCell: SKGridViewCell?
        let selectedNodes = nodes(at: location)
        
        for selectedNode in selectedNodes {
            if let selectedCell = selectedNode as? SKGridViewCell {
                foundCell = selectedCell
                break
            }
        }

        return foundCell
    }
    
    private func cellRowAndColumn(cell: SKGridViewCell) -> (row: Int, column: Int)? {
        guard let cells = cells else {
            return nil
        }
        
        var rowAndColumn: (row: Int, column: Int)?
        
        for rowIndex in 0..<cells.count {
            for columnIndex in 0..<cells[rowIndex].count {
                let cellInArray = cells[rowIndex][columnIndex]
                
                if cellInArray == cell {
                    rowAndColumn = (rowIndex, columnIndex)
                    break
                }
            }
        }
        
        return rowAndColumn
    }
}
