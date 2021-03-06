//
//  TodayViewController.swift
//  Schedule-Widget
//
//  Created by Yang Tun-Kai on 2017/2/26.
//  Copyright © 2017年 Sparkr. All rights reserved.
//

import UIKit
import NotificationCenter
import Firebase

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var todayGameTableView: UITableView!
    
    private lazy var gameScheduleViewModel = {
        return GameScheduleViewModel()
    }()
    
    var tableHelper: TableViewHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUp()
        self.bindViewModel()
        
    }
    
    private func setUp() {
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        // set table view
        self.todayGameTableView.allowsSelection = false
        self.todayGameTableView.rowHeight = 50
        self.todayGameTableView.sectionHeaderHeight = UITableView.automaticDimension
        
        self.alertLabel.isHidden = true
        
        // add a gesture on table view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tableViewTapped(tapGesture:)))
        self.todayGameTableView.addGestureRecognizer(tapGesture)
        
        self.tableHelper = TableViewHelper(
            tableView: self.todayGameTableView,
            nibName: IdentifierHelper.todayGameCell
        )
        
        if #available(iOS 10, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
    }
    
    private func bindViewModel() {
        
        self.gameScheduleViewModel.reloadTableViewClosure = { [weak self] gameSchedules in
            let todayGame = gameSchedules.filter({ $0.0.day == self?.gameScheduleViewModel.day })
            
            guard !todayGame.isEmpty else {
                self?.alertLabel.isHidden = false
                return
            }
            
            self?.tableHelper?.savedData = [todayGame.map({ $0.1 }) as [AnyObject]]
            self?.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
            self?.todayGameTableView.isHidden = false
            self?.alertLabel.isHidden = true
        }
    }
    
    @objc private func tableViewTapped(tapGesture: UITapGestureRecognizer){
        let url: URL = URL(string: "CPBLFan://?game")!
        self.extensionContext?.open(url, completionHandler: nil)
    }
    
    // for epanding view
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        var currentSize: CGSize = self.preferredContentSize
        switch activeDisplayMode {
        case .expanded:
            currentSize.height = 130
            self.preferredContentSize = currentSize
        case .compact:
            self.preferredContentSize = maxSize
        default:
            currentSize.height = 130
            self.preferredContentSize = currentSize
        }
    }
}
