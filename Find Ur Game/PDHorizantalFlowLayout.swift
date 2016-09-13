//
//  PDHorizantalFlowLayout.swift
//  Find Ur Game
//
//  Created by iParth on 9/13/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

//public class PDCarouselFlowLayout: UICollectionViewFlowLayout {

class PDHorizantalFlowLayout: UICollectionViewLayout
{
    var itemSize = CGSizeZero {
        didSet {
            invalidateLayout()
        }
    }
    private var cellCount = 0
    private var boundsSize = CGSizeZero
    
    var CellSpace:CGFloat = 8
    
    override func prepareLayout() {
        cellCount = self.collectionView!.numberOfItemsInSection(0)
        boundsSize = self.collectionView!.bounds.size
    }
    
    override func collectionViewContentSize() -> CGSize {
        let verticalItemsCount = Int(floor(boundsSize.height / itemSize.height))
        let horizontalItemsCount = Int(floor(boundsSize.width / itemSize.width))
        
        let itemsPerPage = verticalItemsCount * horizontalItemsCount
        let numberOfItems = cellCount
        let numberOfPages = Int(ceil(Double(numberOfItems) / Double(itemsPerPage)))
        
        CellSpace = CGFloat(floor((boundsSize.width - (itemSize.width * CGFloat(itemsPerPage))) / CGFloat(itemsPerPage-1)))
        var size = boundsSize
        size.width = CGFloat(numberOfPages) * boundsSize.width
        return size
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttributes = [UICollectionViewLayoutAttributes]()
        for i in 0 ..< cellCount {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            let attr = self.computeLayoutAttributesForCellAtIndexPath(indexPath)
            allAttributes.append(attr)
        }
        return allAttributes
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return self.computeLayoutAttributesForCellAtIndexPath(indexPath)
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    func computeLayoutAttributesForCellAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes {
        let row = indexPath.row
        let bounds = self.collectionView!.bounds
        
        let verticalItemsCount = Int(floor(boundsSize.height / itemSize.height))
        let horizontalItemsCount = Int(floor(boundsSize.width / itemSize.width))
        let itemsPerPage = verticalItemsCount * horizontalItemsCount
        
        let columnPosition = row % horizontalItemsCount
        let rowPosition = (row/horizontalItemsCount)%verticalItemsCount
        let itemPage = Int(floor(Double(row)/Double(itemsPerPage)))
        
        let attr = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        
        var frame = CGRectZero
        frame.origin.x = (CGFloat(itemPage) * bounds.size.width + CGFloat(columnPosition) * (itemSize.width + CellSpace))
        frame.origin.y = CGFloat(rowPosition) * itemSize.height
        frame.size = itemSize
        attr.frame = frame
        
        return attr
    }
}