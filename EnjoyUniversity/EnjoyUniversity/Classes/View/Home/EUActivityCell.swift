//
//  EUActivityCell.swift
//  EnjoyUniversity
//
//  Created by lip on 17/3/7.
//  Copyright © 2017年 lip. All rights reserved.
//

import UIKit

class EUActivityCell: UITableViewCell {
    
    @IBOutlet weak var activityIcon: UIImageView!
    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var activityLocation: UILabel!
    @IBOutlet weak var activityTime: UILabel!

    

    override func awakeFromNib() {
        super.awakeFromNib()

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}