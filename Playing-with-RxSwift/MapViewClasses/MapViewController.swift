//
//  MapViewController.swift
//  Playing-with-RxSwift
//
//  Created by Roberto Gomez Muñoz on 24/8/17.
//  Copyright © 2017 Roberto Gómez. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxMapKit

class Annotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String? = nil
    let reusableIdentifier: String = "annotaion"
    
    init?(dictionary: [String: AnyObject]) {
        
        guard let longitude = dictionary["lng"] as? Double,
            let latitude = dictionary["lat"] as? Double,
            let team = dictionary["team"] as? String,
            let address = dictionary["address"] as? String else {
                return nil
        }
        
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.title = team
        self.subtitle = address
    }
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addAnnotations()
        
        // Camera position
        
        mapView.rx.regionDidChange.asDriver()
            .drive(onNext: { print("Did region change: \($0.region) isAnimated \($0.isAnimated)") })
            .addDisposableTo(disposeBag)
        
        // Update marker icon
        
        mapView.rx.didSelectAnnotationView.asDriver()
            .drive(onNext: { $0.image = #imageLiteral(resourceName: "marker_selected") })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didDeselectAnnotationView.asDriver()
            .drive(onNext: { $0.image = #imageLiteral(resourceName: "marker_normal") })
            .addDisposableTo(disposeBag)
        
        
        mapView.rx.handleViewForAnnotation { (mapView, annotation) in
            if let _ = annotation as? MKUserLocation {
                return nil
            } else {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "reusableIdentifier") ??
                    MKAnnotationView(annotation: annotation, reuseIdentifier: "reusableIdentifier")
                view.image = #imageLiteral(resourceName: "marker_normal")
                view.canShowCallout = true
                return view
            }
        }
        
        mapView.rx.didAddAnnotationViews.asDriver()
            .drive(onNext: { views in
                for v in views {
                    print("Did add annotation views: \(String(describing: v.annotation!.title!))")
                    v.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                    UIView.animate(withDuration: 0.4) { v.transform = CGAffineTransform.identity }
                }
            })
            .addDisposableTo(disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addAnnotations() {
        
        if let file = Bundle.main.url(forResource: "data", withExtension: "json"),
            let data = try? Data(contentsOf: file),
            let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as! [[String: AnyObject]]  {
            
            mapView.addAnnotations(jsonArray.flatMap(Annotation.init))
        }
    }
}
