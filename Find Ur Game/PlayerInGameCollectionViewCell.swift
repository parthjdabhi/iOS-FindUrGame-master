//
//  PlayerInGameCollectionViewCell.swift
//  Find Ur Game
//
//  Created by iParth on 9/8/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

class PlayerInGameCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgPlayer: UIImageView!
    
    static let identifier = "PlayerInGameCollectionViewCell"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
//        self.image.layer.cornerRadius = max(self.image.frame.size.width, self.image.frame.size.height) / 2
//        self.image.layer.borderWidth = 10
//        self.image.layer.borderColor = UIColor(red: 110.0/255.0, green: 80.0/255.0, blue: 140.0/255.0, alpha: 1.0).CGColor
        
    }
}
