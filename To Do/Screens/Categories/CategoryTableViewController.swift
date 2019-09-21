//
//  CategoryTableViewController.swift
//  To Do
//
//  Created by Sergey on 05/02/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//

import UIKit
import SwipeCellKit
import ChameleonFramework
import RxSwift
import RxCocoa


class CategoryTableViewController: SwipeTableViewController {

    @IBOutlet private var viewModel: CategoryViewModel!
    
    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        viewModel.delete(indexPath: indexPath)
    }
    
    private var firstOpening = (UIApplication.shared.delegate as? AppDelegate)?.firstOpeningScreen
    private let bag = DisposeBag()
}

// MARK: - Override
extension CategoryTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        viewModel.load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBarStyle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appearanceAnimation()
        firstOpening = false
    }
}

// MARK: - Actions
extension CategoryTableViewController {
    
    @objc func addButtonPressed() {
        
        var inputTextItem = UITextField()
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add category", style: .default) { action in

            guard let resultTextItem = inputTextItem.text,
                      inputTextItem.text?.isEmpty == false,
                  let color = UIColor.randomFlat().lighten(byPercentage: 99.0)?.hexValue()
                else { return }
            
            self.viewModel
                .save(newCategory: resultTextItem, colour: color)
                .subscribe(onCompleted: {
                    self.scrollToNewRow()
                }, onError: { error in
                    print(error.localizedDescription)
                }).disposed(by: self.bag)
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Create new category"
            inputTextItem = textField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Animations
private extension CategoryTableViewController {
    
    func appearanceAnimation() {
        
        guard viewModel.numberOfRows() != 0, firstOpening == true  else { return }

        for index in 0...viewModel.numberOfRows() - 1  {

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

// MARK: - Private
private extension CategoryTableViewController {

    func scrollToNewRow() {
        tableView.scrollToRow(at: IndexPath(item: viewModel.numberOfRows() - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
    }
    
    func setupView() {
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.rowHeight = 60.0
        tableView.separatorStyle = .none
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        navigationItem.rightBarButtonItems = [addButton]
        subscribe()
    }
    
    func subscribe() {
        
        viewModel.categories.drive(tableView.rx.items(cellIdentifier: "categoryCell", cellType: SwipeTableViewCell.self)) { row, element, cell in
            cell.rx.base.delegate = self
            cell.textLabel?.text = element.name
            let colour = UIColor(hexString: element.colour ?? "1D9BF6")
            cell.backgroundColor = colour
            cell.textLabel?.textColor = ContrastColorOf(backgroundColor: colour!, returnFlat: true)
            }.disposed(by: bag)
        
        tableView.rx.itemSelected.subscribe(onNext: { indexPath in
            self.viewModel.openCategory(indexPath: indexPath)
        }).disposed(by: bag)
    }
    
    func setupNavigationBarStyle() {
        title = "Category"
        navigationController?.navigationBar.barTintColor = UIColor.categoryColor
        navigationController?.navigationBar.tintColor = FlatWhite()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: FlatWhite()]
    }
}

// MARK: - StoryboardInstantinable
extension CategoryTableViewController: StoryboardInstantinable {}
