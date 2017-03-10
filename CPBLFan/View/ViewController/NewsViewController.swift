//
//  NewsViewController.swift
//  CPBLFan
//
//  Created by Yang Tun-Kai on 2016/12/23.
//  Copyright © 2016年 Sparkr. All rights reserved.
//

import UIKit
import Kingfisher
import PKHUD
import DynamicColor
import ReachabilitySwift

class NewsViewController: UIViewController {
    
    @IBOutlet weak var newsTableView: UITableView!
    var page: Int = 0
    
    var tableViewHelper: TableViewHelper?
    
    var footerView: UIView!
    var activity: UIActivityIndicatorView!
    
    lazy var newsViewModel = {
        return NewsViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check net connection
        let reachability = Reachability()
        guard (reachability?.isReachable)! else {
            let alert = UIAlertController(title: "提示", message: "網路連線異常。")
            alert.show()
            return
        }
        
        
        // show loading activity view
        HUD.show(.progress)
        
        self.setUp()
        
        // load and show news from cpbl website
        self.newsViewModel.fetchNews(from: page, handler: { [unowned self] data in
            
            var source: [NewsViewModel] = data.map{ value -> NewsViewModel in
                return NewsViewModel(data: value)
            }

            // use tableview helper class to seperate uitableview delegate and datasource for reuse
            self.tableViewHelper = TableViewHelper(
                tableView: self.newsTableView,
                nibName: "NewsCell",
                source: source as [AnyObject],
                selectAction:{ [weak self] num in
                    // closure for tableview cell tapping
                    let destination: NewsContentViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewsContentViewController") as! NewsContentViewController
                    destination.newsUrl = data[num].newsUrl
                    destination.newsTitle = data[num].title
                    destination.newsDate = data[num].date
                    destination.newsImageUrl = data[num].imageUrl
                    self?.navigationController?.pushViewController(destination, animated: true)
                },
                refreshAction:{ page in
                    // closure for refresh(load more)data
                    self.activity.startAnimating()
                    self.newsViewModel.fetchNews(from: (page - 1), handler: { [unowned self] data in
                        let moreSource: [NewsViewModel] = data.map{ value -> NewsViewModel in
                            return NewsViewModel(data: value)
                        }
                        source.append(contentsOf: moreSource)
                        self.tableViewHelper?.savedData = source
                        self.activity.stopAnimating()
                    })
                }
            )
            self.footerView.isHidden = false
            
            HUD.hide(animated: true)
            self.newsTableView.isHidden = false
        })
    }
    
    func setUp(){
        // hide tableview
        self.newsTableView.isHidden = true
        
        // set navigation bar title
        self.navigationItem.title = "CPBL Fans"
        
        // set tableview layout
        self.newsTableView.separatorStyle = .none
        self.newsTableView.estimatedRowHeight = 200
        self.newsTableView.rowHeight = self.cellHeight()
        
        // set activity indicator in foot view
        footerView = UIView(frame: CGRect(x: 0, y: 5, width: self.view.bounds.size.width, height: 50))
        activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activity.frame = CGRect(x: (self.view.bounds.size.width - 44) / 2, y: 5, width: 44, height: 44)
        activity.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        footerView.addSubview(activity)
        footerView.isHidden = true
        self.newsTableView.tableFooterView = footerView
        
    }
    
    func cellHeight() -> CGFloat{
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return (UIScreen.main.bounds.size.height / CGFloat(3))
        case .phone:
            return 200
        default:
            return 200
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Tab bar height + Navigation bar height
        let adjustForTabbarInsets = UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0)
        self.newsTableView.contentInset = adjustForTabbarInsets
        self.newsTableView.scrollIndicatorInsets = adjustForTabbarInsets
    }
}
