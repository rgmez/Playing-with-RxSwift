//
//  MapTableViewController.swift
//  Playing-with-RxSwift
//
//  Created by Roberto Gómez on 18/9/17.
//  Copyright © 2017 Roberto Gómez. All rights reserved.
//

import UIKit

class MapTableViewController: UIViewController, CAPSPageMenuDelegate {
    
    @IBOutlet weak var containerView: UIView!
    
    let tableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RxTableViewController") as! RxTableViewController
    let mapViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
    
    var pageMenu : CAPSPageMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showPageMenu([mapViewController, tableViewController], pageToMove: 0)
        
        // Optional delegate
        pageMenu!.delegate = self
        
        self.view.addSubview(pageMenu!.view)
    }
    
    func showPageMenu(_ controllerArray: [UIViewController], pageToMove: Int) {
        
        // Customize menu (Optional)
        // Initialize scroll menu
        
        if let _ = pageMenu {
            pageMenu?.removeFromParentViewController()
            pageMenu?.view.removeFromSuperview()
            pageMenu = nil
        }
        
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, bgImages:["map", "list"], frame: CGRect(origin: CGPoint(x: 0, y: 60), size: CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height - 64)), pageMenuOptions: nil)
        
        pageMenu?.delegate = self;
        pageMenu?.view.isHidden = true
        self.addChildViewController(pageMenu!)
        self.view.addSubview(pageMenu!.view)
        pageMenu?.moveToPage(pageToMove)
        pageMenu?.view.isHidden = false
    }
    
    // Uncomment below for some navbar color animation fun using the new delegate functions
    
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        print("did move to page")
        
        //        var color : UIColor = UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)
        //        var navColor : UIColor = UIColor(red: 17.0/255.0, green: 64.0/255.0, blue: 107.0/255.0, alpha: 1.0)
        //
        //        if index == 1 {
        //            color = UIColor.orangeColor()
        //            navColor = color
        //        } else if index == 2 {
        //            color = UIColor.grayColor()
        //            navColor = color
        //        } else if index == 3 {
        //            color = UIColor.purpleColor()
        //            navColor = color
        //        }
        //
        //        UIView.animateWithDuration(0.5, animations: { () -> Void in
        //            self.navigationController!.navigationBar.barTintColor = navColor
        //        }) { (completed) -> Void in
        //            println("did fade")
        //        }
    }
    
    func willMoveToPage(_ controller: UIViewController, index: Int) {
        print("will move to page")
        
        //        var color : UIColor = UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)
        //        var navColor : UIColor = UIColor(red: 17.0/255.0, green: 64.0/255.0, blue: 107.0/255.0, alpha: 1.0)
        //
        //        if index == 1 {
        //            color = UIColor.orangeColor()
        //            navColor = color
        //        } else if index == 2 {
        //            color = UIColor.grayColor()
        //            navColor = color
        //        } else if index == 3 {
        //            color = UIColor.purpleColor()
        //            navColor = color
        //        }
        //
        //        UIView.animateWithDuration(0.5, animations: { () -> Void in
        //            self.navigationController!.navigationBar.barTintColor = navColor
        //        }) { (completed) -> Void in
        //            println("did fade")
        //        }
    }

}
