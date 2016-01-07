//
//  ViewController.swift
//  RGSwitchView
//
//  Created by RAIN on 15/10/8.
//  Copyright © 2015年 Smartech. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {
    //  MARK: Properties
    @IBOutlet weak var switchView: RGSwitchView!
    
    let sources = ["Tab_00", "Tab_01", "Tab_02", "Tab_03", "Tab_04", "Tab_05", "Tab_06", "Tab_07"]
    private lazy var controllerArray = [UIViewController]()
    
    //  MARK: Methods
    //  MARK: Lifecycle
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //  MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if respondsToSelector("edgesForExtendedLayout") {
            edgesForExtendedLayout = .None
        }
        
        switchView.delegate = self
        self.title = "滑动切换视图"
        switchView.tabItemNormalColor = UIColor(hexString: "#868686", alpha: 1)
        switchView.tabItemSelectedColor = UIColor(hexString: "#bb0b15", alpha: 1)
        switchView.shadowImage = UIImage(named: "red_line_and_shadow")!.stretchableImageWithLeftCapWidth(59, topCapHeight: 0)
        
        for i in 0 ..< sources.count {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("Detail VC") as! DetailViewController
            vc.title = sources[i]
            controllerArray.append(vc)
        }
        
        let rightButton = UIButton(type: .Custom)
        rightButton.setImage(UIImage(named: "icon_rightarrow"), forState: .Normal)
        rightButton.setImage(UIImage(named: "icon_rightarrow"), forState: .Highlighted)
        rightButton.frame = CGRect(x: 0, y: 0, width: 20, height: 44)
        rightButton.userInteractionEnabled = false
        switchView.rightTopButton = rightButton
        
//        let leftButton = UIButton(type: .Custom)
//        leftButton.setImage(UIImage(named: "icon_rightarrow"), forState: .Normal)
//        leftButton.setImage(UIImage(named: "icon_rightarrow"), forState: .Highlighted)
//        leftButton.frame = CGRect(x: 0, y: 0, width: 20, height: 44)
//        leftButton.userInteractionEnabled = false
//        switchView.leftTopButton = leftButton
        
        switchView.buildUI()
    }
}

//  MARK: - RGSwitchViewDelegate
extension DemoViewController: RGSwitchViewDelegate {
    func numberOfTab(view: RGSwitchView) -> Int {
        return sources.count
    }
    
    func switchView(view: RGSwitchView, viewOfTab tabNumber: Int) -> UIViewController {
        return controllerArray[tabNumber]
    }
    
    func switchView(view: RGSwitchView, didSelectTab tabNumber: Int) {
        let vc = controllerArray[tabNumber] as! DetailViewController
        vc.viewDidCurrentView()
    }
}

