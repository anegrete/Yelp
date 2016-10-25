//
//  ExpandableTableViewCell.swift
//  Yelp
//
//  Created by anegrete on 10/23/16.
//  Copyright © 2016 Alejandra Negrete. All rights reserved.
//

import UIKit

class ExpandableTableViewCell: UITableViewCell {

    @IBOutlet weak var expandableTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
