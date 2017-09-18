//
//  Annotation.swift
//  Playing-with-RxSwift
//
//  Created by Roberto Gomez Muñoz on 15/9/17.
//  Copyright © 2017 Roberto Gómez. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import RxSwift

private let kMapAnimationTime           = 0.300
private let kCalloutWidth: CGFloat      = 300
private let kCalloutHeight: CGFloat     = 170
private let kCalloutSpacing: CGFloat    = 8

class AnnotationView: MKAnnotationView {
    
    var calloutView: CalloutView?
    var hitOutside: Bool = true
    var delegate: CalloutViewDelegate?
    let disposeBag = DisposeBag()
    
    // MARK: - life cycle
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.canShowCallout = false
    }
    
    // MARK: - callout showing and hiding
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.calloutView?.removeFromSuperview()
            
            if let newCustomCalloutView = (UINib(nibName: "CalloutView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? CalloutView) {
                
                newCustomCalloutView.frame.size = CGSize(width: UIScreen.main.bounds.width - kCalloutSpacing * 2, height: (UIScreen.main.bounds.width - kCalloutSpacing * 2) * (kCalloutHeight / kCalloutWidth))
                newCustomCalloutView.frame.origin.x -= newCustomCalloutView.frame.width / 2.0 - (self.frame.width / 2.0)
                newCustomCalloutView.frame.origin.y = self.frame.height
                
                self.calloutView = newCustomCalloutView
                
                (annotation as? Annotation).flatMap{ annotation in
                    self.calloutView.flatMap{
                        $0.setupWith(annotation.stadium, delegate: delegate)
                        
                        $0.favButton.rx.tap
                            .subscribe(onNext: {
                                annotation.stadium.flatMap{ stadium in
                                    self.delegate.flatMap{ $0.addFavouriteAnnotation(stadium) }
                                }
                            }).addDisposableTo($0.disposeBag)
                        
                        $0.routeButton.rx.tap
                            .subscribe(onNext: {
                                self.delegate.flatMap{ $0.routeFromUserLocation(CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))}
                            }).addDisposableTo($0.disposeBag)
                    }
                }
                
                self.addSubview(newCustomCalloutView)
                
                if animated {
                    self.calloutView!.alpha = 0.0
                    UIView.animate(withDuration: kMapAnimationTime, animations: {
                        self.calloutView!.alpha = 1.0
                    })
                }
            }
        } else {
            if calloutView != nil {
                if animated {
                    UIView.animate(withDuration: kMapAnimationTime, animations: {
                        self.calloutView!.alpha = 0.0
                    }, completion: { (success) in
                        self.calloutView!.removeFromSuperview()
                    })
                } else { self.calloutView!.removeFromSuperview() }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.calloutView?.removeFromSuperview()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if let parentHitView = super.hitTest(point, with: event) { return parentHitView }
        else { return calloutView.flatMap{ $0.hitTest(convert(point, to: $0), with: event)} }
    }
}

open class Annotation: NSObject, MKAnnotation {
    
    let reusableIdentifier: String = "annotation"
    
    open var coordinate = CLLocationCoordinate2D()
    open var title: String?
    open var subtitle: String?
    open var type: ClusterAnnotationType?
    open var stadium: Stadium?
    
    override init(){
        super.init()
    }
    
    init?(stadium: Stadium) {
        
        guard let longitude = stadium.lng,
            let latitude = stadium.lat,
            let team = stadium.team,
            let address = stadium.address else {
                return nil
        }
        
        self.stadium = stadium
        
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.title = team
        self.subtitle = address
        self.type = .color(UIColor.darkGray, radius: 25)
    }
}
