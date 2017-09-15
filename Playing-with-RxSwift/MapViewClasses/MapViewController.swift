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

private let kPersonMapAnimationTime     = 0.300
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
                        $0.setupWith(annotation.data, delegate: delegate)
                    
                        $0.favButton.rx.tap
                            .subscribe(onNext: {
                                self.delegate.flatMap{ $0.addFavouriteAnnotation(annotation.data) }
                                self.setSelected(false, animated: true)
                            }).addDisposableTo($0.disposeBag)
                        
                        $0.routeButton.rx.tap
                            .subscribe(onNext: {
                                self.delegate.flatMap{ $0.routeFromUserLocation(CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))}
                                self.setSelected(false, animated: true)
                            }).addDisposableTo($0.disposeBag)
                    
                    }
                }
                
                self.addSubview(newCustomCalloutView)
                
                if animated {
                    self.calloutView!.alpha = 0.0
                    UIView.animate(withDuration: kPersonMapAnimationTime, animations: {
                        self.calloutView!.alpha = 1.0
                    })
                }
            }
        } else {
            if calloutView != nil {
                if animated {
                    UIView.animate(withDuration: kPersonMapAnimationTime, animations: {
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

class Annotation: NSObject, MKAnnotation {
    
    let reusableIdentifier: String = "annotation"
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String? = nil
    let data: [String: AnyObject]
    
    init?(dictionary: [String: AnyObject]) {
        
        guard let longitude = dictionary["lng"] as? Double,
            let latitude = dictionary["lat"] as? Double,
            let team = dictionary["team"] as? String,
            let address = dictionary["address"] as? String else {
                return nil
        }
        
        self.data = dictionary
        
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.title = team
        self.subtitle = address
    }
}

class MapViewController: UIViewController, CalloutViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nearButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var routeButton: UIButton!
    
    let disposeBag = DisposeBag()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addAnnotations()
        
        mapView.showsUserLocation = true
        
        locationManager.requestWhenInUseAuthorization()
        
        // Camera position
        mapView.rx.regionDidChange.asDriver()
            .drive(onNext: { print("Did region change: \($0.region) isAnimated \($0.isAnimated)") })
            .addDisposableTo(disposeBag)
        
        // Update marker icon
        
        mapView.rx.didSelectAnnotationView.asDriver()
            .drive(onNext: {
                $0.image = #imageLiteral(resourceName: "marker_selected")
                $0.annotation.flatMap{ self.centerMapIn(location: $0.coordinate) }
                self.mapView.removeOverlays(self.mapView.overlays)
            })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didDeselectAnnotationView.asDriver()
            .drive(onNext: {
                $0.image = #imageLiteral(resourceName: "marker_normal")
                self.mapView.removeOverlays(self.mapView.overlays)
            })
            .addDisposableTo(disposeBag)
        
        mapView.rx.showsUserLocation.asObservable()
            .subscribe(onNext: {
                print("Shows user location: \($0)")
            })
            .addDisposableTo(disposeBag)
        
        mapView.rx.willStartLocatingUser.asObservable()
            .subscribe(onNext: {
                
            })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didStopLocatingUser.asObservable()
            .subscribe(onNext: {
                self.mapView.userTrackingMode = .none
            })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didFailToLocateUser.asDriver()
            .drive(onNext: { print("Did fail to locate user: \($0)") })
            .addDisposableTo(disposeBag)
        
        mapView.rx.handleViewForAnnotation { (mapView, annotation) in
            if let _ = annotation as? MKUserLocation {
                return nil
            } else {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "reusableIdentifier") ??
                    AnnotationView(annotation: annotation, reuseIdentifier: "reusableIdentifier")
                
                (view as? AnnotationView).flatMap{ $0.delegate = self }
                
                view.image = #imageLiteral(resourceName: "marker_normal")
                return view
            }
        }
        
        mapView.rx.handleRendererForOverlay { (mapView, overlay) -> (MKOverlayRenderer) in
            
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.green
            return lineView
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
        
        nearButton.rx.tap
            .subscribe(onNext: {
                self.mapView.userTrackingMode = .follow
            }).addDisposableTo(disposeBag)
        
        favouriteButton.rx.tap
            .subscribe(onNext: {
                self.mapView.userTrackingMode = .none
            }).addDisposableTo(disposeBag)
        
        routeButton.rx.tap
            .subscribe(onNext: {
                self.locationManager.location.flatMap { userLocation in
                    self.mapView.selectedAnnotations.first.flatMap {
                        self.routeBetween(pointA: $0.coordinate, pointB: userLocation.coordinate)
                    }
                }
            }).addDisposableTo(disposeBag)
        
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
    
    func centerMapIn(location: CLLocationCoordinate2D) {
        mapView.setCenter(location, animated: true)
    }
    
    func routeBetween(pointA: CLLocationCoordinate2D, pointB: CLLocationCoordinate2D) {
        
        let directionRequest = MKDirectionsRequest()
        
        directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: pointA))
        directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: pointB))
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        // 8.
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
//            let rect = route.polyline.boundingMapRect
//            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    //MARK: CalloutDelegate
    func addFavouriteAnnotation(_ data: [String : AnyObject]) {
        
    }
    
    func routeFromUserLocation(_ location: CLLocationCoordinate2D) {
        present(NavigationServices.alertController(location: location, title: "", message: "", completion: {
            print($0)
        }), animated: true)
    }
}
