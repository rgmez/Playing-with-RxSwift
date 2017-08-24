//
//  RxTableViewController.swift
//  Playing-with-RxSwift
//
//  Created by Roberto Gomez Muñoz on 16/1/17.
//  Copyright © 2017 Roberto Gómez. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RxTableViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let items = Observable.just(
        (0..<30).map { "number \($0)" }
    )
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Populate tableview with elements of items array, and set cell properties
        items
            .bindTo(tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = element
            }
            .addDisposableTo(disposeBag)
        
        //modelSelected: returns an Observable you can use to watch information about when model objects are selected. Similar to func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
        tableView.rx
            .modelSelected(String.self)
            .subscribe(onNext: { (text) in
                
                let alert: UIAlertController = UIAlertController.init(title: "Item Selected", message: text, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
            }, onError: { (error: Error) in
                print("Error: \(error)")
            })
            .addDisposableTo(disposeBag)
        
        tableView.rx.setDelegate(self)
            .addDisposableTo(disposeBag)
        
    
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
