//
//  TableViewViewModel.swift
//  Playing-with-RxSwift
//
//  Created by Roberto Gómez on 18/9/17.
//  Copyright © 2017 Roberto Gómez. All rights reserved.
//

import Foundation
import RxSwift


class TableViewViewModel: NSObject {
    
    func retrieveStadiums() -> Variable<[Stadium]>? {
        
        guard let file = Bundle.main.url(forResource: "data", withExtension: "json"),
            let data = try? Data(contentsOf: file),
            let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as! [[String: AnyObject]] else {
                
                return nil
                
        }
        return Variable(Stadium.modelsFromDictionaryArray(array: jsonArray))
    }
}
