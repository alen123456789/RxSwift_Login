//
//  Hero.swift
//  RxSwift_Login
//
//  Created by herbalife_han on 2018/12/27.
//  Copyright © 2018 anchnet. All rights reserved.
//

import UIKit

class Hero: NSObject {
    var name: String
    var desc: String
    var icon: String
    
    init(name: String, desc: String, icon: String) {
        self.name = name
        self.desc = desc
        self.icon = icon
    }
}
