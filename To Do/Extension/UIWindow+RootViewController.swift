//
//  UIWindow+RootViewController.swift
//  To Do
//
//  Created by Sergey on 16/09/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//

import UIKit

extension UIWindow {
    
    func changeRootViewController(to viewController: UIViewController) {
        
        guard rootViewController != nil else {
            
            rootViewController = viewController
            makeKeyAndVisible()
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.window = self
            }
            return
        }
        
        UIView.transition(with: self,
                          duration: 0.3,
                          options: [.transitionCrossDissolve],
                          animations: {
                            
                            self.rootViewController = viewController
                            
        }, completion: nil)
    }
}
