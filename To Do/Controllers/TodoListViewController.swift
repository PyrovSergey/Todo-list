//
//  ViewController.swift
//  To Do
//
//  Created by Sergey on 01/02/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework


class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }

    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        
//        guard let item = todoItems[indexPath.row], let _ = self.selectedCategory else { return }
        
//        do {
//            try self.realm.write {
//                self.realm.delete(item)
//            }
//        } catch {
//            print("Error deleting item \(error)")
//        }
    }
    
    private var todoItems : [TodoItem] = []
    //private let realm = try! Realm()
}

// MARK: - Override
extension TodoListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViewStyle()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        setContrastColorOfNavigationItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setDefoltStateNavigationController()
    }
}

// MARK: - Tableview Datasource
extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
//        if let item = todoItems[indexPath.row] {
//            cell.textLabel?.text = item.title
//            cell.accessoryType = item.isDone ? .checkmark : .none
//            if let colour = UIColor(hexString: (selectedCategory?.colour)!)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems.count)) {
//                cell.backgroundColor = colour
//                cell.textLabel?.textColor = ContrastColorOf(backgroundColor: colour, returnFlat: true)
//            }
//        } else {
//            cell.textLabel?.text = "No Items Added"
//        }
        return cell
    }
}

// MARK: - TableView Delegate
extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

//        guard let item = todoItems[indexPath.row] else { return }

//        do {
//            try realm.write {
//                item.isDone = !item.isDone
//                //realm.delete(item)
//            }
//        } catch {
//            print("Error update item \(error)")
//        }
        tableView.reloadData()
    }
}

// MARK: - Actions
extension TodoListViewController {
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var inputTextItem = UITextField()
        let alert = UIAlertController(title: "Add new todo item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) {
            (action) in
            if let resultTextInput = inputTextItem.text {
                if let currentCategory = self.selectedCategory {
//                    do {
//                        try self.realm.write {
//                            let newTodoItem = TodoItem()
//                            newTodoItem.title = resultTextInput
//                            newTodoItem.dateCreated = Date()
//                            currentCategory.items.append(newTodoItem)
//                        }
//                    } catch {
//                        print("Error saving item \(error)")
//                    }
                }
            }
            self.tableView.reloadData()
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

//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //todoItems = todoItems.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

// MARK: - Private
private extension TodoListViewController {
    
    func loadItems() {
        //todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    func setupTableViewStyle() {
        tableView.rowHeight = 60.0
        tableView.separatorStyle = .none
    }
    
    func setDefoltStateNavigationController() {
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "1D9BF6")
        navigationController?.navigationBar.tintColor = FlatWhite()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: FlatWhite()]
    }
    
    func setContrastColorOfNavigationItems() {
        if let colourHex = selectedCategory?.colour {
            title = selectedCategory?.name
            if let navBar = navigationController?.navigationBar {
                if let navBarColour = UIColor(hexString: colourHex) {
                    navBar.barTintColor = navBarColour
                    navBar.tintColor = ContrastColorOf(backgroundColor: navBarColour, returnFlat: true)
                    navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(backgroundColor: navBarColour, returnFlat: true)]
                    searchBar.barTintColor = navBarColour
                }
            }
        }
    }
}


