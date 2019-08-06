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
    
    var selectedCategory : Category?

    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        
        let item = todoItems[indexPath.row]
        delete(todoItem: item)
    }
    
    private var todoItems : [TodoItem] = []
    private lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
}

// MARK: - Override
extension TodoListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
        setupTableViewStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setContrastColorOfNavigationItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setDefoltStateNavigationController()
    }
}

// MARK: - Tableview Datasource
extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let item = todoItems[indexPath.row]
        cell.alpha = 0
        cell.textLabel?.text = item.title
        cell.accessoryType = item.isDone ? .checkmark : .none
            if let colour = UIColor(hexString: (selectedCategory?.colour)!)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(backgroundColor: colour, returnFlat: true)
        }
        return cell
    }
}

// MARK: - TableView Delegate
extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let item = todoItems[indexPath.row]
        
        item.isDone = !item.isDone
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        
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
            guard let resultTextInput = inputTextItem.text, inputTextItem.text?.isEmpty == false else { return }
            
            let entity = NSEntityDescription.entity(forEntityName: "TodoItem", in: self.context)
            
            let newTodoItem = NSManagedObject(entity: entity!, insertInto: self.context) as! TodoItem
            
            newTodoItem.title = resultTextInput
            newTodoItem.dateCreated = Date()
            
            self.save(todoItem: newTodoItem)
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
        
        guard let searchString = searchBar.text else { return }
        
        todoItems = todoItems.filter { ($0.title?.lowercased().contains(searchString.lowercased()))! }
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            load()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            tableView.reloadData()
        }
    }
}

// MARK: - Private
private extension TodoListViewController {
    
    func save(todoItem: TodoItem) {
        
        do {
            
            selectedCategory?.addToTodoItems(todoItem)
            
            try context.save()
            load()
            
        } catch {
            print(error.localizedDescription)
        }
        
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: todoItems.count - 1, section: 0)], with: .automatic)
        tableView.endUpdates()
        scrollToNewRow()
    }
    
    func delete(todoItem: TodoItem) {
        
        selectedCategory?.removeFromTodoItems(todoItem)
        
        do {
            try context.save()
            load()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func load() {

        let result = selectedCategory?.todoItems?.allObjects as! [TodoItem]
        
        todoItems = result.sorted(by: { $0.dateCreated!.compare($1.dateCreated!) == .orderedAscending })
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
    
    func scrollToNewRow() {
        tableView.scrollToRow(at: IndexPath(item: (todoItems.count - 1), section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
    }
}


