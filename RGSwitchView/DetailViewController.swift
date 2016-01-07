//
//  DetailViewController.swift
//  RGSwitchView
//
//  Created by RAIN on 15/10/9.
//  Copyright © 2015年 Smartech. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    
    //  MARK: Lifecycle
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //  MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func viewDidCurrentView() {
        label.text = self.title
    }
}
