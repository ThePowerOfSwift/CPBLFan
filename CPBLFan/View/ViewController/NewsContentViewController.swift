//
//  NewsContentViewController.swift
//  CPBLFan
//
//  Created by Yang Tun-Kai on 2016/12/24.
//  Copyright © 2016年 Sparkr. All rights reserved.
//

import UIKit
import Kingfisher
import PKHUD

class NewsContentViewController: UIViewController {

    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var newsDateLabel: UILabel!
    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var newsContentLabel: UILabel!
    
    var newsUrl: String = ""
    var newsImageUrl: String = ""
    var newsTitle: String = ""
    var newsDate: String = ""
    
    var fontChanged: Bool = false
    
    lazy var newsViewModel = {
        return NewsViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUp()
        
        HUD.show(.progress)
        
        // get news content
        let route = "\(APIService.CPBLSourceURL)\(newsUrl)"
        self.newsViewModel.fetchNewsContent(from: route, handler: { [weak self] content in
            let attributedString = NSMutableAttributedString(string: content)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 5
            attributedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            self?.newsContentLabel.attributedText = attributedString
            
            HUD.hide(animated: true)
        })

        self.newsImage.kf.setImage(with: self.newsImageUrl.url!)
        self.newsTitleLabel.text = self.newsTitle
        self.newsDateLabel.text = self.newsDate
        
    }
    
    func setUp(){
        
        // set navigation bar style
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem.noTitleBarButtonItem()
        
        let fontButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "font"), style: .plain, target: self, action: #selector(self.changeFontSize))
        let shareButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "share"), style: .plain, target: self, action: #selector(self.shareNews))
        self.navigationItem.rightBarButtonItems = [shareButton,fontButton]

        self.navigationItem.title = "新聞"
        
    }
    
    func changeFontSize(){
        let size = self.newsContentLabel.font.pointSize
        if !self.fontChanged{
            self.newsContentLabel.font = UIFont.systemFont(ofSize: size * 2)
        }else{
            self.newsContentLabel.font = UIFont.systemFont(ofSize: size / 2)
        }
        self.fontChanged = !self.fontChanged
    }
    
    func shareNews(){
        let news = "\(APIService.CPBLSourceURL)\(self.newsUrl)"
        let activity: UIActivityViewController = UIActivityViewController(activityItems: [news], applicationActivities: nil)
        self.present(activity, animated: true, completion: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
