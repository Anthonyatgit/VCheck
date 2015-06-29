//
//  FlatUIColor.swift
//  CocoaPodsDemo
//
//  Created by Gabriel Anthony on 15/4/14.
//  Copyright (c) 2015年 Gabriel Anthony. All rights reserved.
//

import UIKit
import Foundation

public struct FlatUIColors {
    
    #if os(iOS)
        public typealias OSColor = UIColor
    #elseif os(OSX)
        public typealias OSColor = NSColor
    #endif
    
    public static func colorFromHexCode(hex:String) -> OSColor! {
        
        var colorString: String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if colorString.hasPrefix("#") {
            colorString = colorString.FUI_subStringFromIndex(1)
        }
        
        let stringLength = count(colorString)
        if stringLength != 6 && stringLength != 8 {
            return nil
        }
        
        var rString = colorString.FUI_subStringToIndex(2)
        var gString = colorString.FUI_subStringFromIndex(2).FUI_subStringToIndex(2)
        var bString = colorString.FUI_subStringFromIndex(4).FUI_subStringToIndex(2)
        var aString : String?
        if stringLength == 8 {
            aString = colorString.FUI_subStringFromIndex(6).FUI_subStringToIndex(2)
        }
        
        var r: CUnsignedInt = 0
        var g: CUnsignedInt = 0
        var b: CUnsignedInt = 0
        var a: CUnsignedInt = 1
        
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        if let aString = aString {
            NSScanner(string: aString).scanHexInt(&a)
        }
        
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        let alpha = CGFloat(a) / 255.0
        
        return OSColor(red: red, green: green, blue: blue, alpha: alpha)
        
    }
    
    private static func alphaHEX (alpha: CGFloat) -> String {
        if alpha <= 1 {
            return String(Int(alpha * 255), radix: 16, uppercase: true)
        }
        else {
            return "FF"
        }
    }
    
    public static func turquoiseColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.turquoise + alphaHEX(alpha)) }
    public static func greenSeaColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.greenSea + alphaHEX(alpha)) }
    public static func emeraldColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.emerald + alphaHEX(alpha)) }
    public static func nephritisColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.nephritis + alphaHEX(alpha)) }
    public static func peterRiverColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.peterRiver + alphaHEX(alpha)) }
    public static func belizeHoleColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.belizeHole + alphaHEX(alpha)) }
    public static func amethystColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.amethyst + alphaHEX(alpha)) }
    public static func wisteriaColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.wisteria + alphaHEX(alpha)) }
    public static func wetAsphaltColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.wetAsphalt + alphaHEX(alpha)) }
    public static func midnightBlueColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.midnightBlue + alphaHEX(alpha)) }
    public static func sunflowerColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.sunflower + alphaHEX(alpha)) }
    public static func tangerineColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.tangerine + alphaHEX(alpha)) }
    public static func carrotColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.carrot + alphaHEX(alpha)) }
    public static func pumpkinColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.pumpkin + alphaHEX(alpha)) }
    public static func alizarinColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.alizarin + alphaHEX(alpha)) }
    public static func pomegranateColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.pomegranate + alphaHEX(alpha)) }
    public static func cloudsColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.clouds + alphaHEX(alpha)) }
    public static func silverColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.silver + alphaHEX(alpha)) }
    public static func concreteColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.concrete + alphaHEX(alpha)) }
    public static func asbestosColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.asbestos + alphaHEX(alpha)) }
    public static func exLightGrayColor(alpha: CGFloat = 1.0) -> OSColor! { return FlatUIColors.colorFromHexCode(ColorCodes.exLightGray + alphaHEX(alpha)) }
    
    /**
    Contains hex color code strings for the Flat UI color palette.
    */
    public struct ColorCodes
    {
        public static let turquoise = "1abc9c"
        public static let greenSea  = "16a085"
        public static let emerald  = "2ecc71"
        public static let nephritis = "27ae60"
        public static let peterRiver = "3498D8"
        public static let belizeHole = "2980b9"
        public static let amethyst = "9b59b6"
        public static let wisteria = "8e44ad"
        public static let wetAsphalt = "34495e"
        public static let midnightBlue = "2C3E50"
        public static let sunflower = "F1C40F"
        public static let tangerine = "F39C12"
        public static let carrot = "E67E22"
        public static let pumpkin = "D35400"
        public static let alizarin = "E74C3C"
        public static let pomegranate = "C0392B"
        public static let clouds = "ECF0F1"
        public static let silver = "BDC3C7"
        public static let concrete = "95A5A6"
        public static let asbestos = "7F8C8D"
        public static let darkGray = "666666"
        public static let exLightGray = "CCCCCC"
    }
    
    
    
}

private extension String {
    
    func FUI_subStringFromIndex(index: Int) -> String {
        let newStart = advance(startIndex, index)
        return self[newStart ..< endIndex]
    }
    
    func FUI_subStringToIndex(index: Int) -> String {
        let newEnd = advance(startIndex, index)
        return self[startIndex ..< newEnd]
    }
    
    
}

extension UIColor {
    
    convenience init(r: Int, g: Int, b: Int) {
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1.0)
    }
    
    class func turquoiseColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.turquoiseColor(alpha: alpha)
    }
    
    class func greenSeaColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.greenSeaColor(alpha: alpha)
    }
    
    class func emeraldColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.emeraldColor(alpha: alpha)
    }
    
    class func nephritisColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.nephritisColor(alpha: alpha)
    }
    
    class func peterRiverColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.peterRiverColor(alpha: alpha)
    }
    
    class func belizeHoleColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.belizeHoleColor(alpha: alpha)
    }
    
    class func amethystColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.amethystColor(alpha: alpha)
    }
    
    class func wisteriaColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.wisteriaColor(alpha: alpha)
    }
    
    class func wetAsphaltColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.wetAsphaltColor(alpha: alpha)
    }
    
    class func midnightBlueColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.midnightBlueColor(alpha: alpha)
    }
    
    class func sunflowerColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.sunflowerColor(alpha: alpha)
    }
    
    class func tangerineColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.tangerineColor(alpha: alpha)
    }
    
    class func carrotColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.carrotColor(alpha: alpha)
    }
    
    class func pumpkinColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.pumpkinColor(alpha: alpha)
    }
    
    class func alizarinColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.alizarinColor(alpha: alpha)
    }
    
    class func pomegranateColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.pomegranateColor(alpha: alpha)
    }
    
    class func cloudsColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.cloudsColor(alpha: alpha)
    }
    
    class func silverColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.silverColor(alpha: alpha)
    }
    
    class func concreteColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.concreteColor(alpha: alpha)
    }
    
    class func asbestosColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.asbestosColor(alpha: alpha)
    }
    
    class func exLightGrayColor(alpha: CGFloat = 1.0) -> UIColor {
        return FlatUIColors.exLightGrayColor(alpha: alpha)
    }
    
}






