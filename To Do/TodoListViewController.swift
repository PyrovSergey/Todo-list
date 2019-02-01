//
//  ViewController.swift
//  To Do
//
//  Created by Sergey on 01/02/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = [String]()
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let saveArray = defaults.value(forKey: "TodoList") as? [String] {
            itemArray = saveArray
        }

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
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var inputTextItem = UITextField()
        
        let alert = UIAlertController(title: "Add new todo item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) {
            (action) in
            //
            print("Succes")
            if let resultTextInput = inputTextItem.text {
                self.itemArray.append(resultTextInput)
                self.defaults.set(self.itemArray, forKey: "TodoList")
                self.tableView.reloadData()
            }
        }
        
        alert.addTextField {
            (textField) in
            textField.placeholder = "Create new item"
            inputTextItem = textField
        }
        
        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }
    
}

