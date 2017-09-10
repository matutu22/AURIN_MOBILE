//
//  DatasetDetailTableViewCell.swift
//  AURIN Mobile
//
//  Created by Hayden on 16/4/10.
//  Updated by Chenhan on Aug 2017
//
//  Copyright © 2017 University of Melbourne. All rights reserved.
//

import UIKit

class DatasetDetailTableViewCell: UITableViewCell {


    @IBOutlet var fieldImage: UIImageView!
    @IBOutlet var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
