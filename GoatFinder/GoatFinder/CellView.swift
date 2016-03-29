//
//  CellView.swift
//  GoatFinder
//
//  Created by Daniel Hauagge on 3/3/16.
//  Copyright © 2016 Daniel Hauagge. All rights reserved.
//

import UIKit
import RealmSwift

class CellView: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    var goat : Goat! {
        didSet {
            nameLabel.text = goat.name
            ageLabel.text = "\(goat.age)"
        }
    }
}
