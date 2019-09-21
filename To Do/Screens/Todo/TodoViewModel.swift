//
//  TodoViewModel.swift
//  To Do
//
//  Created by Sergey on 17/09/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//

import RxSwift
import RxCocoa

class TodoViewModel: NSObject {
    
    override init() {
        super.init()
        coreDataManger = CoreDataManager()
        subscribe()
    }
    
    var searchText = BehaviorRelay<String>(value: "")
    
    var name: String {
        return category.name ?? "Todo"
    }
    
    var color: String? {
        return category.colour
    }
    
    var todoItem: Driver<[TodoItem]> {
        return privateTodoItemData.asDriver()
    }
    
    private let privateTodoItemData: BehaviorRelay<[TodoItem]> = BehaviorRelay(value: [])
    private var privateTodoItemForSearch: [TodoItem] = []
    private var coreDataManger: CoreDataManager!
    private let bag = DisposeBag()
    
    private var category: Category! {
        didSet {
            let result = category?.todoItems?.allObjects as! [TodoItem]
            let sortedResult = result.sorted(by: { $0.dateCreated!.compare($1.dateCreated!) == .orderedAscending })
            privateTodoItemForSearch = sortedResult
            privateTodoItemData.accept(sortedResult)
        }
    }
}

// MARK: - Public interface
extension TodoViewModel {
    
    func config(category: Category) {
        self.category = category
    }
    
    func numberOfRows() -> Int {
        return privateTodoItemData.value.count
    }
    
    func save(title: String) -> Completable {
        
        return Completable.create(subscribe: { event -> Disposable in
            
            self.coreDataManger
                .saveTodoItem(todoItemTitle: title, category: self.category)
                .subscribe(onCompleted: {
                    self.load()
                    event(.completed)
                }, onError: { error in
                    event(.error(error))
                }).disposed(by: self.bag)
            return Disposables.create()
        })
    }
    
    func delete(indexPath: IndexPath) {
        
        let item = privateTodoItemData.value[indexPath.row]
        
        coreDataManger.deleteTodoItem(item: item, category: category)
            .subscribe(onCompleted: {
                self.load()
            }) { error in
                print(error.localizedDescription)
            }.disposed(by: bag)
    }
    
    func selectedTodoItem(at indexPath: IndexPath) {
        
        let item = privateTodoItemData.value[indexPath.row]
        item.isDone = !item.isDone
        
        coreDataManger.saveCurrentState()
            .subscribe(onCompleted: {
                self.load()
            }) { error in
                print(error.localizedDescription)
            }.disposed(by: bag)
    }
}

// MARK: - Private
private extension TodoViewModel {
    
    func subscribe() {
        searchText
            .skip(1)
            .subscribe(onNext: { text in
            guard text.isEmpty == false else {
                self.load()
                return
            }
            let result = self.privateTodoItemForSearch.filter({ todoItem -> Bool in
                return todoItem.title?.contains(text) ?? false
            })
            self.privateTodoItemData.accept(result)
        }).disposed(by: bag)
    }

    func load() {
        coreDataManger.loadCategory(category: category)
            .subscribe(onSuccess: { category in
                self.category = category
            }) { error in
                print(error.localizedDescription)
            }.disposed(by: bag)
    }
}
