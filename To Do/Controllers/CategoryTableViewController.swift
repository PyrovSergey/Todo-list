//
//  CategoryTableViewController.swift
//  To Do
//
//  Created by Sergey on 05/02/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {

    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {

        let category = categoryArray[indexPath.row] as Category
        delete(category: category)

    }
    
    private var categoryArray: [Category] = []
    private lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
        destinationVC.selectedCategory = categoryArray[indexPath.row]
    }
}

// MARK: - TableView Datasource
extension CategoryTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name ?? "No Categoies Added Yet"
        let colour = UIColor(hexString: categoryArray[indexPath.row].colour ?? "1D9BF6")
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
            
            guard let resultTextItem = inputTextItem.text, inputTextItem.text?.isEmpty == false else { return }
            
            let entity = NSEntityDescription.entity(forEntityName: "Category", in: self.context)
            
            let newCategory = NSManagedObject(entity: entity!, insertInto: self.context) as! Category
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
            
            categoryArray.append(category)
            
            try context.save()
            
        } catch {
            print(error.localizedDescription)
        }
        
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: categoryArray.count - 1, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
    
    func delete(category: Category) {
        
        context.delete(category)
        
        do {
            
            try context.save()
            
            load()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func load() {
        
        let  fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            
            let resultFetchRequest = try context.fetch(fetchRequest)
            
            categoryArray = resultFetchRequest
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func setupTableViewStyle() {
        tableView.rowHeight = 60.0
        tableView.separatorStyle = .none
    }
}
