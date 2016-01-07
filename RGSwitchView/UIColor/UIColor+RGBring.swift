//
//  UIColor+RGBring.swift
//  RGClass
//
//  Created by RAIN on 15/9/8.
//  Copyright © 2015年 Smartech. All rights reserved.
//

import UIKit

extension UIColor {
    /// 设置颜色(十进制 - RGB: 0 ~ 255, alpha: 0 ~ 1)
    public convenience init(Red: CGFloat, Green: CGFloat, Blue: CGFloat, alpha: CGFloat) {
        self.init(red: Red / 255.0, green: Green / 255.0, blue: Blue / 255.0, alpha: alpha)
    }
    
    /// 设置颜色(16进制 - alpha: 0 ~ 1)
    public convenience init(hexString: String, alpha: CGFloat) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        
        var cString = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if cString.hasPrefix("0X") || cString.hasPrefix("#") {
            if cString.hasPrefix("0X") {
                cString = cString.substringFromIndex(cString.startIndex.advancedBy(2))
            } else if cString.hasPrefix("#") {
                cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
            }
            
            let scanner = NSScanner(string: cString)
            var hexValue: CUnsignedLongLong = 0
            
            if scanner.scanHexLongLong(&hexValue) {
                switch (cString.characters.count) {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                    
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                    
                default:
                    print("Invalid RGB hex string, number of characters after '#' or '0x' should be either 3 or 6.")
                }
            } else {
                print("Scan hex error.")
            }
        } else {
            print("Invalid RGB hex string, missing '#' or '0x' as prefix.")
        }
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
