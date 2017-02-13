//
//  Item.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 12/02/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import Foundation
import SwiftyJSON

class Item {
    
    var name: String!
    var barcode: String!
    var price: String!
    var imgPath: String!
    
    init(json: JSON) {
        name = json["name"].stringValue
        barcode = json["barcodeNum"].stringValue
        price = json["price"].stringValue
        imgPath = json["img"].stringValue
    }
    
}

