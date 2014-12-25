//
//  CustomTableViewCell.swift
//  Lines
//
//  Created by Tiago Mergulhão on 24/12/14.
//  Copyright (c) 2014 Tiago Mergulhão. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet var feedName : UILabel!
    @IBOutlet var title : UILabel!
    @IBOutlet var address : UILabel!
    @IBOutlet weak var favImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
