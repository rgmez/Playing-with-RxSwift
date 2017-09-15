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

class MapViewController: UIViewController, CalloutViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nearButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var routeButton: UIButton!
    
    let disposeBag = DisposeBag()
    let locationManager = CLLocationManager()
    let clusterManager = ClusterManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureClusterManager()
        addAnnotations()
        
        mapView.showsUserLocation = true
        locationManager.requestWhenInUseAuthorization()
        
        mapView.rx.regionDidChange.asDriver()
            .drive(onNext: {
                debugPrint("Did region change: \($0.region) isAnimated \($0.isAnimated)")
                self.clusterManager.reload(self.mapView, visibleMapRect: self.mapView.visibleMapRect)
            })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didSelectAnnotationView.asDriver()
            .drive(onNext: {
                
                guard let annotation = $0.annotation else { return }
                
                if let cluster = annotation as? ClusterAnnotation {
                    var zoomRect = MKMapRectNull
                    for annotation in cluster.annotations {
                        let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
                        let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0)
                        if MKMapRectIsNull(zoomRect) {
                            zoomRect = pointRect
                        } else {
                            zoomRect = MKMapRectUnion(zoomRect, pointRect)
                        }
                    }
                    self.mapView.setVisibleMapRect(zoomRect, animated: true)
                } else {
                    
                    $0.image = #imageLiteral(resourceName: "marker_selected")
                    self.mapView.setCenter(annotation.coordinate, animated: true)
                    self.mapView.removeOverlays(self.mapView.overlays)
                }
            })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didDeselectAnnotationView.asDriver()
            .drive(onNext: {
                ($0 as? AnnotationView).flatMap {
                    $0.image = #imageLiteral(resourceName: "marker_normal")
                    self.mapView.removeOverlays(self.mapView.overlays)
                }
            })
            .addDisposableTo(disposeBag)
        
        mapView.rx.didStopLocatingUser.asObservable()
            .subscribe(onNext: {
                self.mapView.userTrackingMode = .none
            })
            .addDisposableTo(disposeBag)
        
        mapView.rx.handleViewForAnnotation { (mapView, annotation) in
            
            if let annotation = annotation as? ClusterAnnotation {
                
                guard let type = annotation.type else { return nil }
                let identifier = "Cluster"
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                if let view = view as? BorderedClusterAnnotationView {
                    view.annotation = annotation
                    view.configure(with: type)
                } else {
                    view = BorderedClusterAnnotationView(annotation: annotation, reuseIdentifier: identifier, type: type, borderColor: .white)
                }
                return view
            } else if let _ = annotation as? MKUserLocation {
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
                self.mapView.selectedAnnotations.first.flatMap {
                    self.routeFromUserLocation($0.coordinate)
                }
                
            }).addDisposableTo(disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureClusterManager() {
        clusterManager.zoomLevel = 17
        clusterManager.minimumCountForCluster = 3
        clusterManager.shouldRemoveInvisibleAnnotations = false
    }
    
    func addAnnotations() {
        
        if let file = Bundle.main.url(forResource: "data", withExtension: "json"),
            let data = try? Data(contentsOf: file),
            let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as! [[String: AnyObject]]  {
            
            clusterManager.add(jsonArray.flatMap(Annotation.init))
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
