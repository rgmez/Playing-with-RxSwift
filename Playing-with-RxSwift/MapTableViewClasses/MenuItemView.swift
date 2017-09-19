//
//  MenuItemView.swift
//  Playing-with-RxSwift
//
//  Created by Roberto Gómez on 19/9/17.
//  Copyright © 2017 Roberto Gómez. All rights reserved.
//

import UIKit

class MenuItemView: UIView {
    // MARK: - Menu item view
    
    @IBOutlet weak var titleLabel : UILabel?
    @IBOutlet weak var imageView: UIImageView?
    var menuItemSeparator : UIView?
    
    func setUpMenuItemView(_ menuItemWidth: CGFloat, menuScrollViewHeight: CGFloat, indicatorHeight: CGFloat, separatorPercentageHeight: CGFloat, separatorWidth: CGFloat, separatorRoundEdges: Bool, menuItemSeparatorColor: UIColor) {
        
        imageView?.contentMode = .scaleAspectFit
        
        menuItemSeparator = UIView(frame: CGRect(x: menuItemWidth - (separatorWidth / 2), y: floor(menuScrollViewHeight * ((1.0 - separatorPercentageHeight) / 2.0)), width: separatorWidth, height: floor(menuScrollViewHeight * separatorPercentageHeight)))
        menuItemSeparator!.backgroundColor = menuItemSeparatorColor
        
        if separatorRoundEdges {
            menuItemSeparator!.layer.cornerRadius = menuItemSeparator!.frame.width / 2
        }
        
        menuItemSeparator!.isHidden = true
        self.addSubview(menuItemSeparator!)
    }
    
    func setTitleText(_ text: NSString) {
        if titleLabel != nil {
            titleLabel!.text = text as String
            titleLabel!.numberOfLines = 0
            titleLabel!.sizeToFit()
        }
    }
    
    func setImage(_ imageName: NSString) {
        if imageView != nil {
            imageView?.image = UIImage(named: imageName as String)
        }
    }
}
