//
//  AllViewController.swift
//  CarloudyNews
//
//  Created by zijia on 1/5/19.
//  Copyright © 2019 cognitiveAI. All rights reserved.
//

import UIKit
import CarloudyiOS


//https://newsapi.org/v2/everything?q=bitcoin&from=2018-12-08&sortBy=publishedAt&apiKey=b7f7add8d89849be8c82306180dac738

//top-headlines 下边才有country, 才有category、
//https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=b7f7add8d89849be8c82306180dac738

enum NewsCat {
    case everything
    case topheadlines
    var description : String {
        switch self {
        case .everything: return "everything"
        case .topheadlines: return "top-headlines"
        }
    }
}
enum NewsSubCat {
    case business
    case entertainment
    case health
    case science
    case sports
    case technology
    var description : String {
        switch self {
        case .business: return "Business"
        case .entertainment: return "Entertainment"
        case .health: return "Health"
        case .science: return "Science"
        case .sports: return "Sports"
        case .technology: return "Technology"
        }
    }
}

//https://newsapi.org/v2/everything?q=bitcoin&from=2018-12-08&sortBy=publishedAt&apiKey=b7f7add8d89849be8c82306180dac738
//https://newsapi.org/v2/everything?q=apple&from=2019-01-07&to=2019-01-07&sortBy=popularity&apiKey=b7f7add8d89849be8c82306180dac738
//sortBy=popularity
//sortBy=publishedAt

class AllViewController: UIViewController {

    lazy var homeViewModel = HomeViewModel()
    var country = "us"
    var subCat : String?
    var newsCat: String?
    
    required public init(cat: String, subCat: String){
        self.subCat = subCat
        self.newsCat = cat
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    fileprivate lazy var homeView: HomeMainView = { [unowned self] in
//        let topHeight = zjStatusHeight + zjNavigationBarHeight + zjTabBarHeight
//        let height = zjScreenHeight - topHeight - ZJTitleViewH
        let hv = HomeMainView(frame: CGRect(x: 0, y: 0, width: zjScreenWidth, height: zjScreenHeight))
        hv.backgroundColor = UIColor.background
        
        hv.delegate = self
        return hv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        view.addSubview(homeView)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(opendAppByCarloudy), name: NSNotification.Name(rawValue: launchAppByCarloudyNotificationKey_), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: launchAppByCarloudyNotificationKey_), object: nil)
    }
    
    // MARK:- 没有关闭app 被carloudy从background mode 打开
    @objc fileprivate func opendAppByCarloudy(){
        loadData()
        ZJPrint("opendAppByCarloudy")
    }


}


// MARK:- API
extension AllViewController{
    fileprivate func loadData(){
        if subCat == nil{return}
        var str = ""
        if newsCat == NewsCat.everything.description{
            str = "https://newsapi.org/v2/everything?q=\(subCat!)&apiKey=b7f7add8d89849be8c82306180dac738"
        }else if newsCat == NewsCat.topheadlines.description{
            str = "https://newsapi.org/v2/top-headlines?country=us&category=\(subCat!)&apiKey=b7f7add8d89849be8c82306180dac738"
        }
        ZJPrint(subCat)
        if str == ""{return}
        homeViewModel.loadNews(str: str) {
            DispatchQueue.main.async {
                self.homeView.articles = self.homeViewModel.articles
            }
        }
    }
}


// MARK:- HomeMainViewDelegate
extension AllViewController: HomeMainViewDelegate{
    func homeMainViewSecondCollectionViewCell(title: String, description: String, name: String) {
        let carloudyBLE = CarloudyBLE.shareInstance
        if let pairkey = carloudyBlePairKey_{
            carloudyBLE.newKeySendToPairAndorid_ = pairkey
        }
        carloudyBLE.startANewSession(appId: carloudyAppStoreAppKey_)
        carloudyBLE.createIDAndViewForCarloudyHud(textViewId: "3", labelTextSize: 25, postionX: 10, postionY: 10, width: 80, height: 60)
//        ZJPrint(title)
//        ZJPrint(carloudyBlePairKey_)
        carloudyBLE.sendMessage(textViewId: "3", message: title)
    }
    
    func homeMainView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let articles = self.homeViewModel.articles
        let article = articles[indexPath.item]
        let homeDetailVC = HomeDetailViewController()
        homeDetailVC.article = article
        navigationController?.pushViewController(homeDetailVC, animated: true)
    }
}



