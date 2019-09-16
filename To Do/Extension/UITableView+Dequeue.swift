//
//  UITableView+Dequeue.swift
//  To Do
//
//  Created by Sergey on 15/09/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//

import UIKit

public extension UITableView {
    
    func dequeueReusableCell<CellType: UITableViewCell>(for indexPath: IndexPath) -> CellType? {
        
        let typeName = String(describing: CellType.self)
        
        guard let cell = dequeueReusableCell(withIdentifier: typeName, for: indexPath) as? CellType else {
            return nil
        }
        return cell
    }
}
