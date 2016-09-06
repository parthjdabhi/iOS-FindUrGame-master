//
//  Extensions.swift
//  What2Watch
//
//  Created by Dustin Allen on 7/15/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import UIKit


extension UIApplication {
    class func tryURL(urls: [String]) {
        let application = UIApplication.sharedApplication()
        for url in urls {
            if application.canOpenURL(NSURL(string: url)!) {
                application.openURL(NSURL(string: url)!)
                return
            }
        }
    }
}

extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIView {
    public func setBorder(width:CGFloat = 1, color: UIColor = UIColor.darkGrayColor())
    {
        self.layer.borderColor = color.CGColor
        self.layer.borderWidth = width
        self.layer.masksToBounds = true
    }
    public func setCornerRadious(radious:CGFloat = 4)
    {
        self.layer.cornerRadius = radious ?? 4
        self.layer.masksToBounds = true
    }
}

extension UITextField {
    public func setLeftMargin(marginWidth:CGFloat = 4)
    {
        let paddingLeft = UIView(frame: CGRectMake(0, 0, marginWidth, self.frame.size.height))
        self.leftView = paddingLeft
        self.leftViewMode = UITextFieldViewMode .Always
    }
    public func setRightMargin(marginWidth:CGFloat = 4)
    {
        let paddingRight = UIView(frame: CGRectMake(0, 0, marginWidth, self.frame.size.height))
        self.rightView = paddingRight
        self.rightViewMode = UITextFieldViewMode .Always
    }
}

extension UIButton {
    
    func alignImageAndTitleVertically(padding: CGFloat = 6.0) {
        let imageSize = self.imageView!.frame.size
        let titleSize = self.titleLabel!.frame.size
        let totalHeight = imageSize.height + titleSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageSize.height),
            left: 0,
            bottom: 0,
            right: -titleSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -imageSize.width,
            bottom: -(totalHeight - titleSize.height),
            right: 0
        )
    }
    
}

extension NSDateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat =  dateFormat
    }
}


extension NSDate {
    struct Formatter {
        //user_upload_time : Format (YYYY-MM-DD HH:MM:SS) 2016-08-02 11:22:11 (24 hours)
        static let custom = NSDateFormatter(dateFormat: "yyyy-MM-dd, HH:mm:ss")
        static let customUTC = NSDateFormatter(dateFormat: "yyyy-MM-dd, HH:mm:ss")
    }
    var strDateInLocal: String {
        //formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)  // you can set GMT time
        //formatter.timeZone = NSTimeZone.localTimeZone()        // or as local time
        return Formatter.custom.stringFromDate(self)
    }
    var strDateInUTC: String {
        Formatter.customUTC.timeZone = NSTimeZone(name: "UTC")
        return Formatter.customUTC.stringFromDate(self)
    }
}

extension String {
    var asDateLocal: NSDate? {
        return NSDate.Formatter.custom.dateFromString(self)
    }
    var asDateUTC: NSDate? {
        NSDate.Formatter.customUTC.timeZone = NSTimeZone(name: "UTC")
        return NSDate.Formatter.customUTC.dateFromString(self)
    }
    func asDateFormatted(with dateFormat: String) -> NSDate? {
        return NSDateFormatter(dateFormat: dateFormat).dateFromString(self)
    }
}

extension NSDate {
    
    func getElapsedInterval() -> String {
        
        var interval = NSCalendar.currentCalendar().components(.Year, fromDate: self, toDate: NSDate(), options: []).year
        
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "year ago" :
                "\(interval)" + " " + "years ago"
        }
        
        interval = NSCalendar.currentCalendar().components(.Month, fromDate: self, toDate: NSDate(), options: []).month
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "month ago" :
                "\(interval)" + " " + "months ago"
        }
        
        interval = NSCalendar.currentCalendar().components(.Day, fromDate: self, toDate: NSDate(), options: []).day
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "day ago" :
                "\(interval)" + " " + "days ago"
        }
        
        interval = NSCalendar.currentCalendar().components(.Hour, fromDate: self, toDate: NSDate(), options: []).hour
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "hour ago" :
                "\(interval)" + " " + "hours ago"
        }
        
        interval = NSCalendar.currentCalendar().components(.Minute, fromDate: self, toDate: NSDate(), options: []).minute
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "minute ago" :
                "\(interval)" + " " + "minutes ago"
        }
        
        return "a moment ago"
    }
}

extension NSDate {
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addDays(daysToAdd: Int) -> NSDate {
        let secondsInDays: NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd: Int) -> NSDate {
        let secondsInHours: NSTimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: NSDate = self.dateByAddingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}