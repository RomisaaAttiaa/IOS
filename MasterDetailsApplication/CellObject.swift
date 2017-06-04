

import Foundation
import UIKit


class ObjectDetail{
    let name: String
    let desc:String
    let owner:String
    let fullName:String
    let imageURL:String
    let date:String
    let htmlURL:String
    let fork:Bool
    
    
    init(name: String,desc: String,owner: String,fullName: String,imageURL: String,date: String,htmlURL: String,fork:Bool) {
        self.name = name
        self.desc = desc
        self.owner = owner
        self.fullName = fullName
        self.imageURL = imageURL
        self.date = date
        self.htmlURL = htmlURL
        self.fork=fork
    }
    
}




