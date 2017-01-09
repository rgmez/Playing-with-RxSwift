//
//  ViewController.swift
//  Playing-with-RxSwift
//
//  Created by Roberto Gomez Muñoz on 7/1/17.
//  Copyright © 2017 Roberto Gómez. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let allSpainProvinces = ["A Coruña", "Álava", "Albacete", "Alicante", "Almería", "Asturias", "Ávila", "Badajoz", "Baleares","Barcelona", "Burgos", "Cáceres", "Cádiz", "Cantabria","Castellón", "Ciudad Real", "Córdoba", "Cuenca", "Girona", "Granada", "Guadalajara", "Gipuzkoa", "Huelva", "Huesca", "Jaén", "La Rioja", "Las Palmas", "León", "Lérida", "Lugo", "Madrid", "Málaga", "Murcia", "Navarra", "Orense", "Palencia", "Pontevedra", "Salamanca", "Segovia", "Sevilla", "Soria", "Tarragona", "Santa Cruz de Tenerife", "Teruel", "Toledo", "Valencia", "Valladolid", "Vizcaya", "Zamora", "Zaragoza"]
    
    let disposeBag = DisposeBag()
    
    var shownProvinces = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        searchBar
            .rx.text
            .throttle(0.5, scheduler: MainScheduler.instance) // Wait 0.5 for changes.
            .filter {
                ($0?.characters.count)! > 0
            }
            .subscribe(onNext: { (text) in
                
                self.shownProvinces = self.allSpainProvinces.filter { $0.hasPrefix(text!) }
                
                self.tableView.reloadData()
                
            }, onError: { (error: Error) in
                print("Error: \(error)")
            })
            .addDisposableTo(disposeBag)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownProvinces.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cityPrototypeCell")
        cell.textLabel?.text = shownProvinces[indexPath.row]
        
        return cell
    }


}

