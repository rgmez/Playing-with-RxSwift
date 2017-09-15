//
//  CalloutView.swift
//  Playing-with-RxSwift
//
//  Created by Roberto Gomez Muñoz on 11/9/17.
//  Copyright © 2017 Roberto Gómez. All rights reserved.
//

import UIKit
import RxSwift
import MapKit

protocol CalloutViewDelegate {
    
    func routeFromUserLocation(_ location: CLLocationCoordinate2D)
    func addFavouriteAnnotation(_ data: [String: AnyObject])
}

class CalloutView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var favButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    func setupWith(_ data:[String: AnyObject], delegate: CalloutViewDelegate?) {
    
        guard let team = data["team"] as? String,
            let address = data["address"] as? String else {
            return
        }
        
        nameLabel.text = team
        addressLabel.text = address
    }
}
