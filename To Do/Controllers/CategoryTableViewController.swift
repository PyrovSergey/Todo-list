//
//  CategoryTableViewController.swift
//  To Do
//
//  Created by Sergey on 05/02/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {

    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categoryArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(category)
                }
            } catch {
                print("Error deleting category \(error)")
            }
        }
    }
    
    private let realm = try! Realm()
    private var categoryArray : Results<Category>?
        
}

// MARK: - Override
extension CategoryTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        load()
        setupTableViewStyle()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TodoListViewController
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        destinationVC.selectedCategory = categoryArray?[indexPath.row]
    }
}

// MARK: - TableView Datasource
extension CategoryTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categoies Added Yet"
        let colour = UIColor(hexString: categoryArray?[indexPath.row].colour ?? "1D9BF6")
        cell.backgroundColor = colour
        cell.textLabel?.textColor = ContrastColorOf(backgroundColor: colour!, returnFlat: true)
        return cell
    }
}

// MARK: - TableView Delegate
extension CategoryTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
}

// MARK: - Actions
extension CategoryTableViewController {
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var inputTextItem = UITextField()
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add category", style: .default) { action in
            
            guard let resultTextItem = inputTextItem.text else { return }
            
            let newCategory = Category()
            newCategory.name = resultTextItem
            newCategory.colour = UIColor.randomFlat().lighten(byPercentage: 99.0)!.hexValue()
            self.save(category: newCategory)

        }
        alert.addTextField { textField in
            textField.placeholder = "Create new category"
            inputTextItem = textField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Private
private extension CategoryTableViewController {
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        //tableView.beginUpdates()
        tableView.reloadData()
        //tableView.insertRows(at: [IndexPath(row: (categoryArray?.count ?? 0) - 1, section: 0)], with: .automatic)
        //tableView.endUpdates()
    }
    
    func load() {
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    func setupTableViewStyle() {
        tableView.rowHeight = 60.0
        tableView.separatorStyle = .none
    }
}
