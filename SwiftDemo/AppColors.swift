//
//  AppColors.swift
//  Wow
//
//  Created by adiel on 22/02/2016.
//  Copyright © 2016 adiel. All rights reserved.
//

import UIKit

extension UIColor{
    class func RGBNew(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    class func ColorFromHex (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    class func BlueGreenColor() -> UIColor
    {
        return RGBNew(39, green: 142, blue: 194);
    }
    
    class func BlueGreenPearsonAreaColor() -> UIColor
    {
        return RGBNew(18, green: 102, blue: 133);
    }
}
