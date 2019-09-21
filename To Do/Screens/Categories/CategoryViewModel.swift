//
//  CategoryViewModel.swift
//  To Do
//
//  Created by Sergey on 16/09/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//

import RxSwift
import RxCocoa

class CategoryViewModel: NSObject {
    
    var categories: Driver<[Category]> {
        return privateCategoriesData.asDriver()
    }
    
    override init() {
        super.init()
        coreDataManger = CoreDataManager()
    }
    
    private let privateCategoriesData: BehaviorRelay<[Category]> = BehaviorRelay(value: [])
    private var coreDataManger: CoreDataManager!
    private let bag = DisposeBag()
}

// MARK: - Public interface
extension CategoryViewModel {
    
    func numberOfRows() -> Int {
        return privateCategoriesData.value.count
    }
    
    func load() {
        coreDataManger.loadCategories()
            .subscribe(onSuccess: { categories in
                self.privateCategoriesData.accept(categories)
            }) { error in
                print(error.localizedDescription)
            }.disposed(by: bag)
    }
    
    func save(newCategory: String, colour: String) -> Completable {
        
        return Completable.create(subscribe: { event -> Disposable in
            
            self.coreDataManger.saveCategories(name: newCategory, color: colour)
                .subscribe(onCompleted: {
                    self.load()
                    event(.completed)
                }) { error in
                    event(.error(error))
                }.disposed(by: self.bag)
            
            return Disposables.create()
        })
    }
    
    func delete(indexPath: IndexPath) {
        let categoryToDelete = privateCategoriesData.value[indexPath.row]
        coreDataManger.delete(category: categoryToDelete)
            .subscribe(onCompleted: {
                self.load()
            }) { error in
                print(error.localizedDescription)
            }.disposed(by: bag)
    }
    
    func openCategory(indexPath: IndexPath) {
        Router.shared.openTodoTableViewController(category: privateCategoriesData.value[indexPath.row])
    }
}

