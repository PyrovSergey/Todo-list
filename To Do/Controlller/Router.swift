//
//  Router.swift
//  To Do
//
//  Created by Sergey on 16/09/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//

import UIKit


class Router {
    
    static let shared = Router()
    
    private init() {}
    private var window: UIWindow?
    private var rootNavigationController: UINavigationController!
}


// MARK: - Public Interface
extension Router {
    
    func openCategoryTableViewController() {
        
        if window == nil {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        
        window?.changeRootViewController(to: initialCategoryTableViewController())
    }
    
    func openTodoTableViewController(category: Category) {
        
        let viewController = initialTodoTableViewController()
        
        viewController.configure(category: category)
        
        rootNavigationController.pushViewController(viewController, animated: true)
    }
    
}

// MARK: - Private
private extension Router {
    
    func initialCategoryTableViewController() -> UIViewController {
        
        let viewController = CategoryTableViewController.instantinateFromStoryboard()
        
        rootNavigationController = UINavigationController(rootViewController: viewController)
        
        return rootNavigationController
    }
    
    func initialTodoTableViewController() -> TodoTableViewController {
        
        let viewController = TodoTableViewController.instantinateFromStoryboard()
        
        return viewController
    }
}
