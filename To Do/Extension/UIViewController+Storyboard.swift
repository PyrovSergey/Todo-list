//
//  UIViewController+Storyboard.swift
//  To Do
//
//  Created by Sergey on 15/09/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//

import UIKit

public protocol StoryboardInstantinable: class {
    associatedtype ControllerType: UIViewController
    static func instantinateFromStoryboard(bundle: Bundle?) -> ControllerType
}

public extension StoryboardInstantinable where Self: UIViewController {
    
    static func instantinateFromStoryboard(bundle: Bundle? = nil) -> Self {
        
        let viewControllerIdentifier = String(describing: ControllerType.self)
        guard let viewController = UIStoryboard(name: storyboardName, bundle: bundle)
            .instantiateViewController(withIdentifier: viewControllerIdentifier) as? Self else {
                fatalError("Cannot instantinate view controller from storyboard")
        }
        return viewController
    }
    
    private static var storyboardName: String {
        
        let viewControllerNameSuffix = "ViewController"
        
        var storyboardName = String(describing: self)
        if let suffixIndex = storyboardName.range(of: viewControllerNameSuffix) {
            
            storyboardName.removeSubrange(suffixIndex)
        }
        return storyboardName
    }
}
