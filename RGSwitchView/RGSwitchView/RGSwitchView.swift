//
//  RGSwitchView.swift
//  RGSwitchView
//
//  Created by RAIN on 15/10/8.
//  Copyright © 2015年 Smartech. All rights reserved.
//

import UIKit

private let kTagOfLeftSideButton: Int = 999
private let kTagOfRightSideButton: Int = 1999
private let kHeightOfTopScrollView: CGFloat = 44.0
private let kWidthOfButtonMargin: CGFloat = 16.0
private let kFontSizeOfTabButton: CGFloat = 17.0
private let kWidthOfLeftMargin: CGFloat = 8.0

//  MARK: RGSwitchViewDelegate
@objc protocol RGSwitchViewDelegate {
    /**
     顶部Tab个数
     
     - parameter view: 本控件
     
     - returns: Tab个数
     */
    func numberOfTab(_ view: RGSwitchView) -> Int
    
    /**
     每个Tab所对应的ViewController
     
     - parameter view:      本控件
     - parameter tabNumber: Tab索引
     
     - returns: 每个Tab对应的ViewController
     */
    func switchView(_ view: RGSwitchView, viewOfTab tabNumber: Int) -> UIViewController
    
    /**
     滑动左边界时传递手势
     
     - parameter view:        本控件
     - parameter panLeftEdge: 手势
     */
    @objc optional func switchView(_ view: RGSwitchView, panLeftEdge: UIPanGestureRecognizer)
    
    /**
     滑动右边界时传递手势
     
     - parameter view:         本控件
     - parameter panRightEdge: 手势
     */
    @objc optional func switchView(_ view: RGSwitchView, panRightEdge: UIPanGestureRecognizer)
    
    /**
     点击Tab
     
     - parameter view:      本控件
     - parameter tabNumber: Tab索引
     */
    @objc optional func switchView(_ view: RGSwitchView, didSelectTab tabNumber: Int)
}


//  MARK: -
class RGSwitchView: UIView {

    @IBOutlet weak var delegate: RGSwitchViewDelegate?
    
    lazy var shadowImageView = UIImageView()
    lazy var shadowImage = UIImage()
    
    lazy var topScrollViewBackgroundColor = UIColor()       //  顶部滑动视图背景色
    lazy var tabItemNormalColor = UIColor()                 //  正常时tab文字颜色
    lazy var tabItemSelectedColor = UIColor()               //  选中时tab文字颜色
    lazy var tabItemNormalBackgroundImage = UIImage()       //  正常时tab的背景
    lazy var tabItemSelectedBackgroundImage = UIImage()     //  选中时tab的背景
    
    var rightTopButton: UIButton {
        get {
            return self.rightSideButton
        }
        
        set {
            if let button = viewWithTag(kTagOfRightSideButton) as? UIButton {
                button.removeFromSuperview()
            }
            rightSideButton.tag = kTagOfRightSideButton
            self.rightSideButton = newValue
            addSubview(self.rightSideButton)
        }
    }
    
    var leftTopButton: UIButton {
        get {
            return self.leftSideButton
        }
        
        set {
            if let button = viewWithTag(kTagOfLeftSideButton) as? UIButton {
                button.removeFromSuperview()
            }
            leftSideButton.tag = kTagOfLeftSideButton
            self.rightSideButton = newValue
            addSubview(self.leftSideButton)
        }
    }

    private lazy var rootScrollView     =   UIScrollView()  //  主视图
    private lazy var topScrollView      =   UIScrollView()  //  顶部页签视图
    private lazy var rightSideButton    =   UIButton()      //  右侧按钮
    private lazy var leftSideButton     =   UIButton()      //  左侧按钮
    
    private lazy var userContentOffsetX: CGFloat = 0.0
    private lazy var isLeftScroll   =   false               //  是否左滑动
    private lazy var isRootScroll   =   false               //  主视图是否滑动
    private lazy var isBuildUI      =   false               //  是否建立了UI
    
    private lazy var userSelectedChannelID = 100            //  点击按钮选择名字ID
    
    private lazy var viewArray: [UIViewController] = []     //  主视图的子视图数组
    

    //  MARK: - Lifecycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initValues()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initValues()
    }

    private func initValues() {
        //  创建顶部可滑动的Tab
        topScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: kHeightOfTopScrollView))
        topScrollView.delegate = self
        topScrollView.backgroundColor = UIColor.clear
        topScrollView.isPagingEnabled = false
        topScrollView.showsHorizontalScrollIndicator = false
        topScrollView.showsVerticalScrollIndicator = false
        topScrollView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        addSubview(topScrollView)
        
        //  创建主滑动视图
        rootScrollView = UIScrollView(frame: CGRect(x: 0, y: kHeightOfTopScrollView,
            width: self.bounds.width, height: self.bounds.height - kHeightOfTopScrollView))
        rootScrollView.delegate = self
        rootScrollView.isPagingEnabled = true
        rootScrollView.isUserInteractionEnabled = true
        rootScrollView.bounces = false
        rootScrollView.showsHorizontalScrollIndicator = false
        rootScrollView.showsVerticalScrollIndicator = false
        rootScrollView.autoresizingMask = [.flexibleHeight, .flexibleBottomMargin, .flexibleWidth]
        rootScrollView.panGestureRecognizer.addTarget(self, action: Selector.scrollHandlePan)
        addSubview(rootScrollView)
        
        viewArray = [UIViewController]()
    }

    override func layoutSubviews() {
        //  如果有设置右侧视图，缩小顶部滚动视图的宽度以适应按钮
        if isBuildUI {
            topScrollView.backgroundColor = topScrollViewBackgroundColor
            if rightTopButton.bounds.width > 0 && leftTopButton.bounds.width == 0 {
                rightTopButton.frame = CGRect(x: bounds.size.width - rightTopButton.bounds.width, y: 0,
                    width: rightTopButton.bounds.width, height: topScrollView.bounds.height)
                
                topScrollView.frame = CGRect(x: 0, y: 0,
                    width: bounds.size.width - rightTopButton.bounds.size.width, height: kHeightOfTopScrollView)
            } else if leftTopButton.bounds.width > 0 && rightTopButton.bounds.width == 0 {
                leftTopButton.frame = CGRect(x: kWidthOfLeftMargin, y: 0,
                    width: leftTopButton.bounds.width, height: topScrollView.bounds.height)
                
                topScrollView.frame = CGRect(x: leftTopButton.frame.origin.x + leftTopButton.frame.size.width, y: 0,
                    width: bounds.width - leftTopButton.bounds.width, height: kHeightOfTopScrollView)
            } else if rightTopButton.bounds.width > 0 && leftTopButton.bounds.width > 0 {
                leftTopButton.frame = CGRect(x: kWidthOfLeftMargin, y: 0,
                    width: leftTopButton.bounds.width, height: topScrollView.bounds.height);
                
                rightTopButton.frame = CGRect(x: bounds.width - rightTopButton.bounds.width, y: 0,
                    width: rightTopButton.bounds.width, height: topScrollView.bounds.height);
                
                topScrollView.frame = CGRect(x: leftTopButton.frame.origin.x + leftTopButton.frame.size.width, y: 0,
                    width: bounds.width - leftTopButton.bounds.width - rightTopButton.bounds.width, height: kHeightOfTopScrollView);
            }
            
            // 更新主视图的总宽度
            rootScrollView.contentSize = CGSize(width: self.bounds.width * CGFloat(viewArray.count), height: 0)
            
            //  更新主视图各个子视图的宽度
            for i in 0 ..< viewArray.count {
                let listVC = viewArray[i]
                listVC.view.frame = CGRect(x: 0 + rootScrollView.bounds.width * CGFloat(i), y: 0,
                    width: rootScrollView.bounds.width, height: rootScrollView.bounds.height)
            }
            
            //  滚动到选中的视图
            rootScrollView.setContentOffset(CGPoint(x: CGFloat(userSelectedChannelID - 100) * bounds.width, y: 0), animated: false)
            
            //  调整顶部滚动视图选中按钮位置
            let button = topScrollView.viewWithTag(userSelectedChannelID) as! UIButton
            adjustScrollViewContentX(button)
        }
    }

    // MARK: - UI
    ///  创建子视图UI
    func buildUI() {
        let number = delegate?.numberOfTab(self)
        if let number = number {
            for i in 0 ..< number {
                let viewController = self.delegate?.switchView(self, viewOfTab: i)
                viewArray.append(viewController!)
                rootScrollView.addSubview((viewController?.view)!)
            }
        } else {
            print("RGSwitchView Error: number in buildUI is nil", terminator: "")
        }
        createNameButtons()
        
        //  选中第一个View
        if let delegate = delegate {
            delegate.switchView?(self, didSelectTab: userSelectedChannelID - 100)
        } else {
            print("delegate in RGSwitchView is nil", terminator: "")
        }
        
        isBuildUI = true
        
        //  创建完子视图UI才需要调整布局
        self.setNeedsLayout()
    }
    
    //  初始化顶部Tab的各个按钮
    private func createNameButtons() {
        shadowImageView = UIImageView()
        shadowImageView.image = shadowImage
        topScrollView.addSubview(shadowImageView)
        
        //  顶部 Tab Bar 的总长度
        var topScrollViewContentWidth = kWidthOfButtonMargin
        //  每个Tab偏移量
        var xOffset = kWidthOfButtonMargin
        for i in 0 ..< viewArray.count {
            let viewController = viewArray[i]
            let button = UIButton(type: .custom)
            let textSize = viewController.title?.boundingRect(with: CGSize(width: topScrollView.bounds.width, height: kHeightOfTopScrollView),
                options: .usesFontLeading,
                attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: kFontSizeOfTabButton)],
                context: nil)
            if let textSize = textSize {
                //  累计每个tab文字的长度
                topScrollViewContentWidth += kWidthOfButtonMargin + textSize.width
                //  设置按钮尺寸
                button.frame = CGRect(x: xOffset, y: 0, width: textSize.width, height: kHeightOfTopScrollView)
                //  计算下一个Tab的x偏移量
                xOffset += textSize.width + kWidthOfButtonMargin
                button.isSelected = false
                button.tag = i + 100
                if i == 0 {
                    shadowImageView.frame = CGRect(x: kWidthOfButtonMargin, y: 0, width: textSize.width, height: shadowImage.size.height)
                    button.isSelected = true
                }
            }
            
            button.setTitle(viewController.title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: kFontSizeOfTabButton)
            button.setTitleColor(tabItemNormalColor, for: .normal)
            button.setTitleColor(tabItemSelectedColor, for: .selected)
            button.setBackgroundImage(tabItemNormalBackgroundImage, for: .normal)
            button.setBackgroundImage(tabItemSelectedBackgroundImage, for: .selected)
            button.addTarget(self, action: Selector.selectNameButton, for: .touchUpInside)
            topScrollView.addSubview(button)
        }
        
        //  设置顶部滚动视图的内容总尺寸
        topScrollView.contentSize = CGSize(width: topScrollViewContentWidth, height: kHeightOfTopScrollView)
    }
    
    //  MARK: Top scrollView logic methods
    //  选中Tab事件
    @objc fileprivate func selectNameButton(_ sender: UIButton) {
        //  如果点击的Tab文字显示不全，调整滚动视图x坐标使用使Tab文字显示全
        adjustScrollViewContentX(sender)
        
        //  如果更换按钮
        if sender.tag != userSelectedChannelID {
            //  取之前的按钮
            let lastButton = topScrollView.viewWithTag(userSelectedChannelID) as! UIButton
            lastButton.isSelected = false
            //  赋值按钮ID
            userSelectedChannelID = sender.tag
        }
        
        //  按钮选中状态
        if sender.isSelected == false {
            sender.isSelected = true
            
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.shadowImageView.frame = CGRect(x: sender.frame.origin.x, y: 0,
                    width: sender.frame.size.width, height: self.shadowImage.size.height)
                }, completion: { (finished) -> Void in
                    if finished == true {
                        //  设置新页面出现
                        if self.isRootScroll == false {
                            self.rootScrollView.setContentOffset(CGPoint(x: CGFloat(sender.tag - 100) * self.bounds.width, y: 0), animated: true)
                        }
                        self.isRootScroll = false
                        
                        if let delegate = self.delegate {
                            if (delegate as! UIViewController).responds(to: #selector(RGSwitchViewDelegate.switchView(_:didSelectTab:))) {}
                            delegate.switchView?(self, didSelectTab: self.userSelectedChannelID - 100)
                        } else {
                            print("delegate in RGSwitchView is nil", terminator: "")
                        }
                        
                    }
            })
        } else {    //  重复点击选中按钮
            
        }
    }
    
    //  调整顶部滑动视图x位置
    private func adjustScrollViewContentX(_ sender: UIButton) {
        //  如果 当前显示的最后一个Tab文字超出右边界
        if sender.frame.origin.x - topScrollView.contentOffset.x > self.bounds.width - (kWidthOfButtonMargin + sender.bounds.width) {
            //  向左滑动视图 显示完整Tab文字
            topScrollView.setContentOffset(CGPoint(x: sender.frame.origin.x - (topScrollView.bounds.width - (kWidthOfButtonMargin + sender.bounds.width)), y: 0), animated: true)
        }
        
        //  如果 (Tab的文字坐标 - 当前滚动视图左边界所在整个视图的x坐标) < 按钮的隔间 ，代表Tab文字已超出边界
        if sender.frame.origin.x - topScrollView.contentOffset.x < kWidthOfButtonMargin {
            //  向右滚动视图(Tab文字的x坐标 - 按钮间隔 = 新的滚动视图左边界在整个视图的x坐标) 使文字显示完整
            topScrollView.setContentOffset(CGPoint(x: sender.frame.origin.x - kWidthOfButtonMargin, y: 0), animated: true)
        }
    }
    
    //  MARK: Main view logic method
    @objc fileprivate func scrollHandlePan(_ panParam: UIPanGestureRecognizer) {
        if rootScrollView.contentOffset.x <= 0 {
            if delegate != nil && (delegate as! UIViewController).responds(to: #selector(RGSwitchViewDelegate.switchView(_:panLeftEdge:))) {
                delegate?.switchView!(self, panLeftEdge: panParam)
            }
        } else if rootScrollView.contentOffset.x >= rootScrollView.contentSize.width - rootScrollView.bounds.width {
            if delegate != nil && (delegate as! UIViewController).responds(to: #selector(RGSwitchViewDelegate.switchView(_:panRightEdge:))) {
                delegate?.switchView!(self, panRightEdge: panParam)
            }
        }
    }
}


//  MARK: - Scroll View Delegate
extension RGSwitchView: UIScrollViewDelegate {
    //  scrollView开始滑动
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == rootScrollView {
            userContentOffsetX = scrollView.contentOffset.x
        }
    }
    
    //  scrollView结束滑动
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == rootScrollView {
            //  判断用户是左滑动还是右滑动
            isLeftScroll = userContentOffsetX < scrollView.contentOffset.x ? true : false
        }
    }
    
    //  scrollView释放滑动
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == rootScrollView {
            isRootScroll = true
            //  调整顶部滑动按钮的状态
            let tag = Int(scrollView.contentOffset.x / self.bounds.width) + 100
            let button = topScrollView.viewWithTag(tag) as! UIButton
            selectNameButton(button)
        }
    }
}


// MARK: - Selector
fileprivate extension Selector {
    static let scrollHandlePan = #selector(RGSwitchView.scrollHandlePan(_:))
    static let selectNameButton = #selector(RGSwitchView.selectNameButton(_:))
}
