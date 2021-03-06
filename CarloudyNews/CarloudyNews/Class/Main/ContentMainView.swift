//
//  ContentMainView.swift
//  CarloudyNews
//
//  Created by zijia on 1/5/19.
//  Copyright © 2019 cognitiveAI. All rights reserved.
//

import UIKit


protocol ContentMainViewDelegate : class {
    func pageContentView(_ contentView : ContentMainView, progress : CGFloat, sourceIndex : Int, targetIndex : Int, direction_left: Bool)
}

private let ContentCellID = "ContentCellID"

class ContentMainView: UIView {
    
    // MARK:- 定义属性
    var childVcs : [UIViewController]{
        didSet{
            for childVc in childVcs {
                parentViewController?.addChild(childVc)
            }
            collectionView.reloadData()
        }
    }
    fileprivate weak var parentViewController : UIViewController?
    fileprivate var startOffsetX : CGFloat = 0
    fileprivate var isForbidScrollDelegate : Bool = false
    weak var delegate : ContentMainViewDelegate?
    fileprivate var direction_left: Bool?
    var isdefaultTheme = true
    
    // MARK:- 懒加载属性
    lazy var collectionView : UICollectionView = {[weak self] in
        // 1.创建layout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = (self?.bounds.size)!
//        layout.itemSize = CGSize(width: zjScreenWidth + 0.000001, height: zjScreenHeight)
//        layout.itemSize = CGSize(width: zjScreenWidth, height: zjScreenHeight)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        // 2.创建UICollectionView
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.scrollsToTop = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: ContentCellID)
        collectionView.backgroundColor = UIColor.clear
//        collectionView.contentInset = UIEdgeInsets(top: settingViewHeight, left: 0, bottom: 0, right: 0)
        return collectionView
        }()
    
    // MARK:- 自定义构造函数
    init(frame: CGRect, childVcs : [UIViewController], parentViewController : UIViewController?, isdefaultTheme: Bool = true) {
        self.childVcs = childVcs
        self.parentViewController = parentViewController
        self.isdefaultTheme = isdefaultTheme
        super.init(frame: frame)
        
        // 设置UI
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK:- 设置UI界面
extension ContentMainView {
    fileprivate func setupUI() {
        
        // 1.将所有的子控制器添加父控制器中
        for childVc in childVcs {
            parentViewController?.addChild(childVc)
        }
        
        // 2.添加UICollectionView,用于在Cell中存放控制器的View
        addSubview(collectionView)
        collectionView.frame = bounds
    }
}


// MARK:- 遵守UICollectionViewDataSource
extension ContentMainView : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVcs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 1.创建Cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCellID, for: indexPath)
        
        // 2.给Cell设置内容
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
//        let index = (indexPath as NSIndexPath).item == 0 ? 0 : (indexPath as NSIndexPath).item
        let childVc = childVcs[(indexPath as NSIndexPath).item] as! AllViewController
        childVc.isdefaultTheme = self.isdefaultTheme
        ZJPrint(indexPath.item)
        childVc.view.frame = cell.contentView.bounds
        cell.contentView.addSubview(childVc.view)
        
        return cell
    }
}

// MARK:- 遵守UICollectionViewDelegate
extension ContentMainView : UICollectionViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        isForbidScrollDelegate = false
        
        startOffsetX = scrollView.contentOffset.x
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // 0.判断是否是点击事件
        if isForbidScrollDelegate { return }
        
        // 1.定义获取需要的数据
        var progress : CGFloat = 0
        var sourceIndex : Int = 0
        var targetIndex : Int = 0
        
        // 2.判断是左滑还是右滑
        let currentOffsetX = scrollView.contentOffset.x
        let scrollViewW = scrollView.bounds.width
        if currentOffsetX > startOffsetX { // 左滑
            // 1.计算progress
            progress = currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW)
            ZJPrint(progress)
            // 2.计算sourceIndex
            sourceIndex = Int(currentOffsetX / scrollViewW)
            
            // 3.计算targetIndex
            targetIndex = sourceIndex + 1
            if targetIndex >= childVcs.count {
                targetIndex = childVcs.count - 1
            }
            ZJPrint("\(targetIndex)--\(sourceIndex)")
            direction_left = true
            // 4.如果完全划过去
            if currentOffsetX - startOffsetX == scrollViewW {
                progress = 1
                targetIndex = sourceIndex
                ZJPrint("\(targetIndex)--\(sourceIndex)")
            }
            
//            第二个Bug是滑动到最后一个快速滑多一下会闪一下，这样操作会导致最后回调时progress会变一下0，所以先变一下灰色，再变黄色，我这边直接用progress做判断就没问题了
            if progress == 0 {
                progress = 1
                targetIndex = sourceIndex
            }
        } else { // 右滑
            // 1.计算progress
            direction_left = false
            progress = 1 - (currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW))
            
            // 2.计算targetIndex
            targetIndex = Int(currentOffsetX / scrollViewW)
            
            // 3.计算sourceIndex
            sourceIndex = targetIndex + 1
            if sourceIndex >= childVcs.count {
                sourceIndex = childVcs.count - 1
            }
        }
        // 3.将progress/sourceIndex/targetIndex传递给titleView
        delegate?.pageContentView(self, progress: progress, sourceIndex: sourceIndex, targetIndex: targetIndex, direction_left: direction_left!)
    }
}


// MARK:- 对外暴露的方法
extension ContentMainView {
    func setCurrentIndex(_ currentIndex : Int) {
        
        // 1.记录需要进制执行代理方法
        isForbidScrollDelegate = true
        
        // 2.滚动正确的位置
        let offsetX = CGFloat(currentIndex) * collectionView.frame.width
        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
    }
}

