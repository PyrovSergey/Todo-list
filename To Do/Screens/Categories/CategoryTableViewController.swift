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
    
    private var firstOpening = (UIApplication.shared.delegate as? AppDelegate)?.firstOpeningScreen
    private var categoryArray: [Category] = []
    private var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let dateSortDescriptor = NSSortDescriptor(key: "dateCreated", ascending: true)
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Category> = {
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        fetchRequest.sortDescriptors = [ dateSortDescriptor ]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
    }()
}

// MARK: - Override
extension CategoryTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareFetchedResultController()
        load()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBarStyle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appearanceAnimation(tableView: tableView)
        firstOpening = false
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
        
        ///performSegue(withIdentifier: "goToItems", sender: self)
        
        Router.shared.openTodoTableViewController(category: categoryArray[indexPath.row])
    }
}

// MARK: - Actions
extension CategoryTableViewController {
    
    @objc func addButtonPressed() {
        var inputTextItem = UITextField()
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add category", style: .default) { action in

            guard let resultTextItem = inputTextItem.text, inputTextItem.text?.isEmpty == false else { return }

            let entity = NSEntityDescription.entity(forEntityName: "Category", in: self.context)

            let newCategory = NSManagedObject(entity: entity!, insertInto: self.context) as! Category
            newCategory.name = resultTextItem
            newCategory.colour = UIColor.randomFlat().lighten(byPercentage: 99.0)!.hexValue()
            newCategory.dateCreated = Date()
            self.save(category: newCategory)

        }
        alert.addTextField { textField in
            textField.placeholder = "Create new category"
            inputTextItem = textField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
          //fillTheList() // stub
    }
    
    // stub
//    func fillTheList() {
//
//        for n in 0...100 {
//
//            let entity = NSEntityDescription.entity(forEntityName: "Category", in: self.context)
//
//            let newCategory = NSManagedObject(entity: entity!, insertInto: self.context) as! Category
//            newCategory.name = "\(n)"
//            newCategory.colour = UIColor.randomFlat().lighten(byPercentage: 99.0)!.hexValue()
//            self.save(category: newCategory)
//
//        }
//    }
}

// MARK: - Animations
private extension CategoryTableViewController {
    
    func appearanceAnimation(tableView: UITableView) {
        
        guard categoryArray.isEmpty == false, firstOpening! else { return }

        for index in 0...categoryArray.count - 1  {
            
            guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) else { return }
            
            cell.alpha = 0
            cell.transform = CGAffineTransform(translationX: 0, y: -(cell.frame.height) * 2)
            
            UIView.animate(withDuration: 0.8,
                           delay: Double(index) * 0.1,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseInOut,
                           animations: {
                            cell.alpha = 1
                            cell.transform = .identity
            })
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension CategoryTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard type == .insert else { return }
        
        tableView.insertRows(at: [IndexPath(row: categoryArray.count - 1, section: 0)], with: .automatic)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

// MARK: - Private
private extension CategoryTableViewController {
    
    func prepareFetchedResultController() {
        
        fetchedResultsController.delegate = self
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
    }
    
    func save(category: Category) {
            
        do {
            
            categoryArray.append(category)
            
            try context.save()
            
        } catch {
            print(error.localizedDescription)
        }
        
        scrollToNewRow()
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
        
        fetchRequest.sortDescriptors = [ dateSortDescriptor ]
        
        do {
            
            let resultFetchRequest = try context.fetch(fetchRequest)
            
            categoryArray = resultFetchRequest

        } catch {
            print(error.localizedDescription)
        }
    }
    
    func scrollToNewRow() {
        tableView.scrollToRow(at: IndexPath(item: (categoryArray.count - 1), section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
    }
    
    func setupView() {
        tableView.rowHeight = 60.0
        tableView.separatorStyle = .none
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        navigationItem.rightBarButtonItems = [addButton]
    }
    
    func setupNavigationBarStyle() {
        title = "Category"
        navigationController?.navigationBar.barTintColor = UIColor.categoryColor
        navigationController?.navigationBar.tintColor = FlatWhite()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: FlatWhite()]
    }
}

extension CategoryTableViewController: StoryboardInstantinable {}
