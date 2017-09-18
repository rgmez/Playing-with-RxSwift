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
    var items: Variable<[Stadium]>?
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = TableViewViewModel().retrieveStadiums()
        
        //Populate tableview with elements of items array, and set cell properties
        items?.asObservable()
            .bindTo(tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { row, data, cell in
                
                cell.textLabel?.text = data.team
                
            }.addDisposableTo(disposeBag)
        
        //modelSelected: returns an Observable you can use to watch information about when model objects are selected. Similar to func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
        tableView.rx
            .modelSelected(Stadium.self)
            .subscribe(onNext: { stadium in
            
                let alert: UIAlertController = UIAlertController.init(title: stadium.team, message: stadium.address, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                self.present(alert, animated: true, completion: nil)
                
            }, onError: { (error: Error) in
                print("Error: \(error)")
            })
            .addDisposableTo(disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .addDisposableTo(disposeBag)
        
    
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
}
