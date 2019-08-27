//
//  BTNMessageCollLayout.swift
//  FaceChat
//
//  Created by yantommy on 2019/1/21.
//  Copyright © 2019 yantommy. All rights reserved.
//

import UIKit

public enum MessageListType: Int {
    case full = 0
    case min
}

class BTNMessageCollLayout: UICollectionViewFlowLayout {

    var listType: MessageListType = .full
    
    var firstItemTransform: CGFloat?
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
       
        let items = NSArray (array: super.layoutAttributesForElements(in: rect)!, copyItems: true)
        var headerAttributes: UICollectionViewLayoutAttributes?
        
        items.enumerateObjects(using: { (object, idex, stop) -> Void in
            let attributes = object as! UICollectionViewLayoutAttributes
            
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                headerAttributes = attributes
            }
            else {
                self.updateCellAttributes(attributes, headerAttributes: headerAttributes)
            }
        })
        return items as? [UICollectionViewLayoutAttributes]
    }
    
    func updateCellAttributes(_ attributes: UICollectionViewLayoutAttributes, headerAttributes: UICollectionViewLayoutAttributes?) {
        
        
        let currentIndex = attributes.indexPath.item
        let stretchMultiplier: CGFloat = (1 + (CGFloat(currentIndex + 1) * -0.2))
        var contentInset = UIEdgeInsets()
        if #available(iOS 11, *) {
            contentInset = self.collectionView!.adjustedContentInset
        } else {
            contentInset = self.collectionView!.contentInset
        }
        let contentOffsetTop = self.collectionView!.contentOffset.y + contentInset.top
       
        
        let minY = collectionView!.bounds.minY + collectionView!.contentInset.top
        var maxY = attributes.frame.origin.y
        
        if let headerAttributes = headerAttributes {
            maxY -= headerAttributes.bounds.height
        }
        
        var finalY = max(minY, maxY)
        
        if contentOffsetTop < contentInset.top {
            finalY = finalY + CGFloat(contentOffsetTop * stretchMultiplier)
        }         
        var origin = attributes.frame.origin
        let deltaY = (finalY - origin.y) / attributes.frame.height
        
        if let itemTransform = firstItemTransform {
            let scale = 1 - deltaY * itemTransform
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        
        origin.y = finalY
        attributes.frame = CGRect(origin: origin, size: attributes.frame.size)
        attributes.zIndex = attributes.indexPath.row
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

}
