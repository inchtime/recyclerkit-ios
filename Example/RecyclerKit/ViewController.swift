//
//  ViewController.swift
//  RecyclerKit
//
//  Created by evan-cai on 04/26/2019.
//  Copyright (c) 2019 evan-cai. All rights reserved.
//

import UIKit
import RecyclerKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let identifier = String(describing: RecyclerKitCell.self)

    private var adapter : RecyclerTableAdapter!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupTableView() {
        
        tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)

        adapter = RecyclerKit
            .tableView(tableView)
            .modelViewBind { (indexPath, viewModel, tableViewCell) in
                switch viewModel.identifier {
                case self.identifier:
                    break
                default:
                    break
                }
            }
            .modelViewClick({ (indexPath, viewModel) in
                switch viewModel.identifier {
                case self.identifier:
                    break
                default:
                    break
                }
            })
            .build()

        let section: RecyclerTableAdapter.Section = RecyclerTableAdapter.Section()
        let models: [RecyclerTableAdapter.ViewModel] = [
            RecyclerTableAdapter.ViewModel(identifier: identifier, value: ""),
            RecyclerTableAdapter.ViewModel(identifier: identifier, value: ""),
            RecyclerTableAdapter.ViewModel(identifier: identifier, value: ""),
            RecyclerTableAdapter.ViewModel(identifier: identifier, value: "")
        ]

        section.name = "phrase"
        section.models = models
        self.adapter.sections = [section]

    }
    
}

