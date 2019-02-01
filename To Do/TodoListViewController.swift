//
//  ViewController.swift
//  To Do
//
//  Created by Sergey on 01/02/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    let itemArray = ["One", "Two", "Three"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        checkSelectRowItemAndUpdateUI(index: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    private func checkSelectRowItemAndUpdateUI(index: IndexPath) {
        if tableView.cellForRow(at: index)?.accessoryType == .checkmark {
            tableView.cellForRow(at: index)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: index)?.accessoryType = .checkmark
        }
    }

}

