//
//  AllViewController.swift
//  CarloudyNews
//
//  Created by zijia on 1/5/19.
//  Copyright © 2019 cognitiveAI. All rights reserved.
//

import UIKit
import CarloudyiOS
import AVFoundation


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


// MARK:- 如何设置只能自己访问和子类访问


class AllViewController: SiriViewController {

    
    var country = "us"
    var subCat : String?
    var newsCat: String?
    var isdefaultTheme = true
    
    
    
    
    
    
    
    required public init(cat: String, subCat: String){
        self.subCat = subCat
        self.newsCat = cat
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    fileprivate lazy var homeView: HomeMainView = { [unowned self] in
        let hv = HomeMainView(frame: CGRect(x: 0, y: 0, width: zjScreenWidth, height: zjScreenHeight), isdefaultTheme: isdefaultTheme)
        hv.backgroundColor = .clear
        hv.delegate = self
        return hv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(homeView)
        
//        GloableSiriFunc.shareInstance.delegate = self
        // Do any additional setup after loading the view.
    }
    
    deinit {
        ZJPrint("denit")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GloableSiriFunc.shareInstance.delegate = self
        loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(opendAppByCarloudy), name: NSNotification.Name(rawValue: launchAppByCarloudyNotificationKey_), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataBySettingView(userInfo:)), name: NSNotification.Name(rawValue: settingViewUpdateAndReloadDataNotificationKey_), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: launchAppByCarloudyNotificationKey_), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: settingViewUpdateAndReloadDataNotificationKey_), object: nil)
    }
    
    // MARK:- 没有关闭app 被carloudy从background mode 打开
    @objc fileprivate func opendAppByCarloudy(){
        loadData()
        ZJPrint("opendAppByCarloudy")
    }
    
    override func gloableSiriFuncTextReturn(text: String) {
        dataGotFromSiri = text
        ZJPrint(dataGotFromSiri)
    }
    override func gloableSiriFuncOpenCarloudyNewsWasSaid() {
        invalidatetimer_sendingData_home()
        invalidatetimer_checkText()
    }
    
    @objc fileprivate func reloadDataBySettingView(userInfo: NSNotification){
        //  https://newsapi.org/v2/everything?q=apple&from=2019-01-10&to=2019-01-10&sortBy=popularity&apiKey=b7f7add8d89849be8c82306180dac738
        let userInfo = userInfo.userInfo
        if let cellStyle: Int = userInfo?["cellStyle"] as? Int,
            let from: String = userInfo?["from"] as? String,
            let to: String = userInfo?["to"] as? String,
            let sortby: Int = userInfo?["sortby"] as? Int,
            let subCat: String = self.subCat{
            cellStyle_ = cellStyleSegmentedControl_Array[cellStyle]
            let baseUrl = "https://newsapi.org/v2/everything?q=\(subCat)"
            let timeUrl = "&from=\(from)&to=\(to)"
            var sortUrl = ""
            if sortby == 1{
                sortUrl = "&sortBy=popularity"
            }else if sortby == 2{
                sortUrl = "&sortBy=publishedAt"
            }
            let apikeyUrl = "&apiKey=b7f7add8d89849be8c82306180dac738"
            let url = baseUrl + timeUrl + sortUrl + apikeyUrl
            
            homeViewModel.loadNews(str: url) {
                DispatchQueue.main.async {
                    self.homeView.articles = self.homeViewModel.articles
                }
            }
        }
    }

}


// MARK:- API
extension AllViewController{
    fileprivate func loadData(){
        if subCat == nil{return}
        var str = ""
        if newsCat == NewsCat.everything.description{
            let sortby  = UserDefaults.standard.integer(forKey: sortbySegmentedControl_StringDescription)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let from = formatter.string(from: Date())
            let to = formatter.string(from: Date())
            let timeUrl = "&from=\(from)&to=\(to)"
            var sortUrl = ""
            if sortby == 1{
                sortUrl = "&sortBy=popularity"
            }else if sortby == 2{
                sortUrl = "&sortBy=publishedAt"
            }
            let cellStyle = UserDefaults.standard.integer(forKey: cellStyleSegmentedControl_StringDescription)
            cellStyle_ = cellStyleSegmentedControl_Array[cellStyle]
            str = "https://newsapi.org/v2/everything?q=\(subCat!)\(sortUrl)\(timeUrl)&apiKey=b7f7add8d89849be8c82306180dac738"
        }else if newsCat == NewsCat.topheadlines.description{
            str = "https://newsapi.org/v2/top-headlines?country=us&category=\(subCat!)&apiKey=b7f7add8d89849be8c82306180dac738"
        }
        ZJPrint(subCat)
        if str == ""{return}
        homeViewModel.loadNews(str: str) {
            DispatchQueue.main.async {
                self.homeView.articles = self.homeViewModel.articles
                if let titles = UserDefaults.standard.array(forKey: titles_StringDescription) as? [String]{
                    ZJPrint(self.subCat!)
                    ZJPrint(titles.first ?? "")
                    if self.subCat! == titles.first ?? ""{
//                        ZJPrint(self.subCat!)
                        self.sendData()
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    func sendData(){
            let articles = self.homeViewModel.articles
            let maxIndex = articles.count
            let article = articles[dataIndex]
            if let title = article.title{
                switch isListenForReadNews{
                case 0: //never
                    sendMessageWithTimer(articles: articles, maxIndex: maxIndex)
                    // category 会在globle timer里检查
                case 1: //User control
                    sendMessageWithTimer(articles: articles, maxIndex: maxIndex)
                    checkReadNews(articles, maxIndex)
                    
                case 2: //always
                    GloableSiriFunc.shareInstance.stopGlobleHeyCarloudyNews()
                    sendMessageWithNoTimer(articles: articles, maxIndex: maxIndex)
                default: break
                }
                
                dataIndex += 1
            if dataIndex >= maxIndex{
                dataIndex = 0
            }
        }
    }
}


extension AllViewController{
    
    
    
    
//    func speak(string: String, rate: CGFloat = 0.53){
//        //开始说时 关闭recording
//        GloableSiriFunc.shareInstance.stopGlobleHeyCarloudyNews()
//        let utterance = AVSpeechUtterance(string: string)
//        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
//        utterance.rate = Float(rate)
//        synthesizer.speak(utterance)
//        GloableSiriFunc.shareInstance.sendWaringLabelToCarloudy(title: "Say 'Stop' between two voices to cancel")
//    }
    
//    fileprivate func checkWhatUserSaidBetweenTwoVoices() {
//        //结束说时，打开语音。 给用户两秒时间 停止read
//        self.startGlobleHeyCarloudyNews()
//
//        invalidatetimer_checkText()
//        let articles = self.homeViewModel.articles
//        let maxIndex = articles.count
//
//        var timerIndex = 0
//        timer_checkText = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
//            timerIndex += 1
//
//            if timerIndex > 3{
//                self.timer_checkText?.invalidate()
//                self.timer_checkText = nil
//                if !dataGotFromSiri.contains("stop"){        //停止read
//                    GloableSiriFunc.shareInstance.stopGlobleHeyCarloudyNews()
//
//                    self.sendMessageWithNoTimer(articles: articles, maxIndex: maxIndex)
//                }else{
//                    GloableSiriFunc.shareInstance.sendWaringLabelToCarloudy(title: "Say 'category' to activate speech")
//                    self.sendMessageWithTimer(articles: articles, maxIndex: maxIndex)
//                    self.checkReadNews(articles, maxIndex)
//                }
//            }
//            ZJPrint(timerIndex)
//        }
//    }
    
    override func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        ZJPrint(utterance.speechString.lowercased())
        ZJPrint(currentSpeakingNews.lowercased())
        if utterance.speechString.lowercased() == currentSpeakingNews.lowercased(){
            if isListenForReadNews == 1{
                self.checkWhatUserSaidBetweenTwoVoices()
            }else if isListenForReadNews == 2{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    let articles = self.homeViewModel.articles
                    let maxIndex = articles.count
                    self.sendMessageWithNoTimer(articles: articles, maxIndex: maxIndex)
                }
            }
            
        }
        switch isListenForReadNews {
        case 0:
            break
        case 1:
            break
        case 2:
            break
        default:
            break
        }
        
        
    }
    
    
}


// MARK:- HomeMainViewDelegate
extension AllViewController: HomeMainViewDelegate{
    func homeMainViewSecondCollectionViewCell(title: String, description: String, name: String) {
//        sendMessageToCarloudy(title: title)
    }
    
    func homeMainView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let articles = self.homeViewModel.articles
        let article = articles[indexPath.item]
        let homeDetailVC = HomeDetailViewController()
        homeDetailVC.article = article
        navigationController?.pushViewController(homeDetailVC, animated: true)
    }
}





