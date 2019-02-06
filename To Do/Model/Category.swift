//
//  Category.swift
//  To Do
//
//  Created by Sergey on 06/02/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    let items = List<TodoItem>()
}
