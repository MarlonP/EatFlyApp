//
//  Post.swift
//  EatFlyApp
//
//  Created by Marlon Pavanello on 24/02/2017.
//  Copyright © 2017 Marlon Pavanello. All rights reserved.
//

import UIKit

class Post: NSObject {
    
    var author: String!
    var title: String!
    var likes: Int!
    var pathToImage: String!
    var userID: String!
    var postID: String!
    
    var peopleWhoLike: [String] = [String]()
    

}
