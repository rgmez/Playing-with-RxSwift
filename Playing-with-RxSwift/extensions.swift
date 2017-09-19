//
//  extensions.swift
//  Playing-with-RxSwift
//
//  Created by Roberto Gómez on 19/9/17.
//  Copyright © 2017 Roberto Gómez. All rights reserved.
//

import UIKit

extension UIView {
    
    class func add(contentView: UIView, containerView: UIView) {
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(contentView)
        
        let viewDict = ["contentView": contentView, "containerView": containerView]
        
        containerView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: containerView, attribute: .width, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: containerView, attribute: .height, multiplier: 1.0, constant: 0))
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[contentView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[contentView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict))
    }
}
