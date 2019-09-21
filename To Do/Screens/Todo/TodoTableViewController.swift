//
//  ViewController.swift
//  To Do
//
//  Created by Sergey on 01/02/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//

import RxSwift
import RxCocoa
import ChameleonFramework
import SwipeCellKit


class TodoTableViewController: SwipeTableViewController {
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private var viewModel: TodoViewModel!

    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        viewModel.delete(indexPath: indexPath)
    }
    
    private let bag = DisposeBag()
}

// MARK: - Override
extension TodoTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setContrastColorOfNavigationItems()
    }
}

// MARK: - Public interface
extension TodoTableViewController {
    
    func configure(category: Category) {
        viewModel.config(category: category)
    }
}

// MARK: - Actions
extension TodoTableViewController {
    
    @objc func addButtonPressed() {
        var inputTextItem = UITextField()
        let alert = UIAlertController(title: "Add new todo item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) {
            (action) in
            guard let resultTextInput = inputTextItem.text, inputTextItem.text?.isEmpty == false else { return }

            self.viewModel.save(title: resultTextInput)
                .subscribe(onCompleted: {
                self.scrollToNewRow()
            }, onError: { error in
                print(error.localizedDescription)
                }).disposed(by: self.bag)
        }

        alert.addTextField {
            (textField) in
            textField.placeholder = "Create new item"
            inputTextItem = textField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Private
private extension TodoTableViewController {
    
    func setupView() {
        
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.rowHeight = 60.0
        tableView.separatorStyle = .none
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        navigationItem.rightBarButtonItems = [addButton]
        
        subscribe()
    }
    
    func subscribe() {
        
        viewModel.todoItem
            .drive(tableView.rx.items(cellIdentifier: "todoCell", cellType: SwipeTableViewCell.self)) { row, element, cell in
            cell.rx.base.delegate = self
            cell.alpha = 0
            cell.textLabel?.text = element.title
            cell.accessoryType = element.isDone ? .checkmark : .none
            if let colour = UIColor(hexString: self.viewModel.color).darken(byPercentage: CGFloat(row) / CGFloat(self.viewModel.numberOfRows())) {
                        cell.backgroundColor = colour
                        cell.textLabel?.textColor = ContrastColorOf(backgroundColor: colour, returnFlat: true)
                }
            }.disposed(by: bag)
        
        tableView.rx
            .itemSelected
            .subscribe(onNext: { indexPath in
            self.viewModel.selectedTodoItem(at: indexPath)
        }).disposed(by: bag)
        
        searchBar.rx.text
            .orEmpty
            .bind(to: viewModel.searchText)
            .disposed(by: bag)
    }
    
    func setContrastColorOfNavigationItems() {
        if let colourHex = viewModel.color {
            title = viewModel.name
            if let navBar = navigationController?.navigationBar {
                if let navBarColour = UIColor(hexString: colourHex) {
                    navBar.barTintColor = navBarColour
                    navBar.tintColor = ContrastColorOf(backgroundColor: navBarColour, returnFlat: true)
                    navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(backgroundColor: navBarColour, returnFlat: true)]
                    searchBar.barTintColor = navBarColour
                }
            }
        }
    }
    
    func scrollToNewRow() {
        tableView.scrollToRow(at: IndexPath(item: viewModel.numberOfRows() - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
    }
}

// MARK: - StoryboardInstantinable
extension TodoTableViewController: StoryboardInstantinable {}


