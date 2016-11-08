//
//  UIColor+Initialization.swift
//  RGUIExtension
//
//  Created by RAIN on 15/11/30.
//  Copyright © 2015年 Smartech. All rights reserved.
//

import UIKit

extension UIColor {
    /**
     通过指定的不透明度和 RGB 分量值, 初始化并返回一个颜色对象
     
     - parameter Red:   红色分量的值 (0 ~ 255)
     - parameter Green: 绿色分量的值 (0 ~ 255)
     - parameter Blue:  蓝色分量的值 (0 ~ 255)
     - parameter Alpha: 不透明度的值 (0 ~ 1)
     
     - returns: 被初始化的颜色
     */
    public convenience init(Red: CGFloat, Green: CGFloat, Blue: CGFloat, alpha: CGFloat) {
        self.init(red: Red / 255.0, green: Green / 255.0, blue: Blue / 255.0, alpha: alpha)
    }
    
    /**
     通过指定的不透明度 和 一个用16进制数字表示 RGB 分量值的字符串, 初始化并返回一个颜色对象
     
     - parameter hexString: 以"#"或"0x"开头, 后面跟随6位(或3位)16进制数字 表示RGB分量值的字符串
     - parameter alpha:     不透明度 (0 ~ 1)
     
     - returns: 被初始化的颜色
     */
    public convenience init(hexString: String, alpha: CGFloat) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0

        var cString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("0X") || cString.hasPrefix("#") {
            if cString.hasPrefix("0X") {
                cString = cString.substring(from: cString.characters.index(cString.startIndex, offsetBy: 2))
            } else if cString.hasPrefix("#") {
                cString = cString.substring(from: cString.characters.index(cString.startIndex, offsetBy: 1))
            }
            
            let scanner = Scanner(string: cString)
            var hexValue: CUnsignedLongLong = 0
            
            if scanner.scanHexInt64(&hexValue) {
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
                    print("Invalid RGB hex string, number of characters after '#' or '0x' should be either 3 or 6.", terminator: "")
                }
            } else {
                print("Scan hex error.", terminator: "")
            }
        } else {
            print("Invalid RGB hex string, missing '#' or '0x' as prefix.", terminator: "")
        }
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
