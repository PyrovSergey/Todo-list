//
//  TodoItem.swift
//  To Do
//
//  Created by Sergey on 06/02/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//

import Foundation
import RealmSwift

class TodoItem : Object {
    @objc dynamic var title : String = ""
    @objc dynamic var isDone : Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
