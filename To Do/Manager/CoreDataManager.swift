//
//  CoreDataManager.swift
//  To Do
//
//  Created by Sergey on 16/09/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//

import CoreData
import RxSwift
import RxCocoa

enum DataError: Error {
    case errorPredicate
}

class CoreDataManager {
    
    init() {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    private let dateSortDescriptor = NSSortDescriptor(key: "dateCreated", ascending: true)
    private var categoriesList: [Category] = []
    private var context: NSManagedObjectContext!
}

// MARK: - Public interface
extension CoreDataManager {
    
    func loadCategories() -> Single<[Category]> {
        
        return Single<[Category]>.create(subscribe: { single -> Disposable in
            
            let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
            fetchRequest.sortDescriptors = [self.dateSortDescriptor]
            
            do {
                let resultFetchRequest = try self.context.fetch(fetchRequest)
                single(.success(resultFetchRequest))
            } catch {
                single(.error(error))
            }
            return Disposables.create()
        })
    }
    
    func loadCategory(category: Category) -> Single<Category> {
        return Single.create(subscribe: { single -> Disposable in
            
            let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
            let predicate = NSPredicate(format: "dateCreated == %@", category.dateCreated! as NSDate)
            fetchRequest.predicate = predicate
            
            do {
                let resultFetchRequest = try self.context.fetch(fetchRequest)
                if let category = resultFetchRequest.first {
                    single(.success(category))
                } else {
                    single(.error(DataError.errorPredicate))
                }
            } catch {
                single(.error(error))
            }
            return Disposables.create()
        })
        
    }
    
    func saveCategories(name: String, color: String) -> Completable {
        
        return Completable.create(subscribe: { event -> Disposable in
            
            self.createCategory(name, color)
            
            do {
                try self.context.save()
                event(.completed)
            } catch {
                event(.error(error))
            }
            return Disposables.create()
        })
    }
    
    func saveTodoItem(todoItemTitle: String, category: Category) -> Completable {
        
        return Completable.create(subscribe: { event -> Disposable in
            
            category.addToTodoItems(self.createTodoItem(todoItemTitle))
            
            do {
                try self.context.save()
                event(.completed)
            } catch {
                event(.error(error))
            }
            return Disposables.create()
        })
    }
    
    func saveCurrentState() -> Completable {
        
        return Completable.create(subscribe: { event -> Disposable in
            
            do {
                try self.context.save()
                event(.completed)
            } catch {
                event(.error(error))
            }
            
            return Disposables.create()
        })
    }
    
    func delete(category: Category) -> Completable {
        
        return Completable.create(subscribe: { event -> Disposable in
            
            self.context.delete(category)
            
            do {
                try self.context.save()
                event(.completed)
            } catch {
                event(.error(error))
            }
            return Disposables.create()
        })
    }
    
    func deleteTodoItem(item: TodoItem, category: Category) -> Completable {
        
        return Completable.create(subscribe: { event -> Disposable in
            
            category.removeFromTodoItems(item)
            
            do {
                try self.context.save()
                event(.completed)
            } catch {
                event(.error(error))
            }
            return Disposables.create()
        })
    }
}

// MARK: - Private
private extension CoreDataManager {
    
    func createCategory(_ title: String, _ stringColour: String) {
        let entity = NSEntityDescription.entity(forEntityName: "Category", in: self.context)
        let newCategory = NSManagedObject(entity: entity!, insertInto: self.context) as! Category
        newCategory.name = title
        newCategory.colour = stringColour
        newCategory.dateCreated = Date()
    }
    
    func createTodoItem(_ title: String) -> TodoItem {
        let entity = NSEntityDescription.entity(forEntityName: "TodoItem", in: self.context)
        let newTodoItem = NSManagedObject(entity: entity!, insertInto: self.context) as! TodoItem
        newTodoItem.title = title
        newTodoItem.dateCreated = Date()
        return newTodoItem
    }
}
