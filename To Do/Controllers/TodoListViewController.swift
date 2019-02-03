//
//  ViewController.swift
//  To Do
//
//  Created by Sergey on 01/02/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = [TodoItem]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        // Data for testing
//        let item1 = TodoItem()
//        item1.title = "1"
//        item1.isDone = true
//        itemArray.append(item1)
//
//        let item2 = TodoItem()
//        item2.title = "2"
//        itemArray.append(item2)
//
//        let item3 = TodoItem()
//        item3.title = "3"
//        itemArray.append(item3)
//
//        let item4 = TodoItem()
//        item4.title = "4"
//        itemArray.append(item4)
//
//        let item5 = TodoItem()
//        item5.title = "5"
//        itemArray.append(item5)
//
//        let item6 = TodoItem()
//        item6.title = "6"
//        itemArray.append(item6)
//
//        let item7 = TodoItem()
//        item7.title = "7"
//        itemArray.append(item7)
//
//        let item8 = TodoItem()
//        item8.title = "8"
//        itemArray.append(item8)
//
//        let item9 = TodoItem()
//        item9.title = "9"
//        itemArray.append(item9)
//
//        let item10 = TodoItem()
//        item10.title = "10"
//        itemArray.append(item10)
//
//        let item11 = TodoItem()
//        item11.title = "11"
//        itemArray.append(item11)
//
//        let item12 = TodoItem()
//        item12.title = "12"
//        itemArray.append(item12)
//
//        let item13 = TodoItem()
//        item13.title = "13"
//        itemArray.append(item13)
//
//        let item14 = TodoItem()
//        item10.title = "14"
//        itemArray.append(item14)
//
//        let item15 = TodoItem()
//        item11.title = "15"
//        itemArray.append(item15)
//
//        let item16 = TodoItem()
//        item12.title = "16"
//        itemArray.append(item16)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.isDone ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].isDone = !itemArray[indexPath.row].isDone

        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var inputTextItem = UITextField()
        
        let alert = UIAlertController(title: "Add new todo item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) {
            (action) in
            //
            
            if let resultTextInput = inputTextItem.text {
                let newTodoItem = TodoItem()
                newTodoItem.title = resultTextInput
                self.itemArray.append(newTodoItem)
                self.saveItems()
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
    
    func saveItems() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding item array \(error)")
        }
        tableView.reloadData()
    }
    
    
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
            itemArray = try decoder.decode([TodoItem].self, from: data)
            } catch {
                print("Error dencoding item array \(error)")
            }
        }
    }
}

