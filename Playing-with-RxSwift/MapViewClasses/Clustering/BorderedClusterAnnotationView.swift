//
//  BorderedClusterAnnotationView.swift
//  Playing-with-RxSwift
//
//  Created by Roberto Gomez Muñoz on 15/9/17.
//  Copyright © 2017 Roberto Gómez. All rights reserved.
//

import UIKit
import MapKit

class BorderedClusterAnnotationView: ClusterAnnotationView {
    let borderColor: UIColor
    
    init(annotation: MKAnnotation?, reuseIdentifier: String?, type: ClusterAnnotationType, borderColor: UIColor) {
        self.borderColor = borderColor
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier, type: type)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configure(with type: ClusterAnnotationType) {
        super.configure(with: type)
        
        switch type {
        case .image:
            layer.borderWidth = 0
        case .color:
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = 2
        }
    }
}
