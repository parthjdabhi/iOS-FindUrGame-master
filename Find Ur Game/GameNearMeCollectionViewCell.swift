//
//  GameNearMeCollectionViewCell.swift
//  Find Ur Game
//
//  Created by iParth on 9/7/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

class GameNearMeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblSport: UILabel!
    @IBOutlet weak var lblGameName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var imgUser1: UIImageView!
    @IBOutlet weak var imgUser2: UIImageView!
    @IBOutlet weak var lblMoreCount: UILabel!
    
    static let identifier = "GameNearMeCollectionViewCell"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //        self.image.layer.cornerRadius = max(self.image.frame.size.width, self.image.frame.size.height) / 2
        //        self.image.layer.borderWidth = 10
        //        self.image.layer.borderColor = UIColor(red: 110.0/255.0, green: 80.0/255.0, blue: 140.0/255.0, alpha: 1.0).CGColor
    }
}
